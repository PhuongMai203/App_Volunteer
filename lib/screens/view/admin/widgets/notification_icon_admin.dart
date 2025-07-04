import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../components/app_colors.dart';
import '../../business/view/sub/campaign_detail.dart';
import '../sub_pages/business_detail_screen.dart';
import 'support_requests_page.dart';

enum _UnifiedNotificationSource { notifications, reports, supportRequests }

class _UnifiedNotification {
  final String id;
  final DateTime createdAt;
  final bool isRead;
  final String? notificationMessage;
  final String? reportReason;
  final String relatedId;
  final String type;
  final _UnifiedNotificationSource source;
  final DocumentReference ref;
  final Map<String, dynamic>? metadata;

  _UnifiedNotification({
    required this.id,
    required this.createdAt,
    required this.isRead,
    this.notificationMessage,
    this.reportReason,
    required this.relatedId,
    required this.type,
    required this.source,
    required this.ref,
    this.metadata,
  });
}

class NotificationsScreen extends StatefulWidget {
  // Thêm callback để gửi số lượng thông báo chưa đọc lên widget cha
  final Function(int unreadCount)? onUnreadCountChanged;

  const NotificationsScreen({
    Key? key,
    this.onUnreadCountChanged, // Khởi tạo callback
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, LayerLink> _layerLinks = {};
  OverlayEntry? _overlayEntry;
  late final AnimationController _ctrl;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _fadeAnim;
  String? _selectedId;

  // Biến trạng thái để lưu số lượng thông báo chưa đọc
  int _unreadCount = 0;

  Stream<List<_UnifiedNotification>> get combinedStream {
    final notifStream = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();

    final reportStream = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots();
    final supportStream = FirebaseFirestore.instance
        .collection('support_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Rx.combineLatest3<QuerySnapshot, QuerySnapshot, QuerySnapshot, List<_UnifiedNotification>>(
      notifStream,
      reportStream,
      supportStream,
          (notifSnap, reportSnap, supportSnap) {
        final list1 = notifSnap.docs.map((doc) {
          final d = doc.data()! as Map<String, dynamic>;
          final msg = (d['message'] as String)
              .replaceFirst('Yêu cầu xác minh: ', '');
          return _UnifiedNotification(
            id: doc.id,
            createdAt: (d['createdAt'] as Timestamp).toDate(),
            isRead: d['isRead'] as bool? ?? false,
            notificationMessage: msg,
            reportReason: null,
            relatedId: d['relatedId'] as String,
            type: d['type'] as String,
            source: _UnifiedNotificationSource.notifications,
            ref: doc.reference,
            metadata: d['metadata'] as Map<String, dynamic>?,
          );
        }).toList();

        final list2 = reportSnap.docs.map((doc) {
          final d = doc.data()! as Map<String, dynamic>;
          return _UnifiedNotification(
            id: doc.id,
            createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isRead: d['isRead'] as bool? ?? false,
            notificationMessage: null,
            reportReason: d['reason'] as String,
            relatedId: d['activityId'] as String? ?? '',
            type: 'report',
            source: _UnifiedNotificationSource.reports,
            ref: doc.reference,
            metadata: null,
          );
        }).where((item) => item.relatedId.isNotEmpty).toList();

        final list3 = supportSnap.docs.map((doc) {
          final d = doc.data()! as Map<String, dynamic>;
          return _UnifiedNotification(
            id: doc.id,
            createdAt: (d['createdAt'] as Timestamp).toDate(),
            isRead: d['isRead'] as bool? ?? false,
            notificationMessage: 'new_support_request_from'.tr(),
            reportReason: null,
            relatedId: d['userId'] ?? '',
            type: 'support_request',
            source: _UnifiedNotificationSource.supportRequests,
            ref: doc.reference,
            metadata: d,
          );
        }).toList();

        final merged = [...list1, ...list2, ...list3];
        merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return merged;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_ctrl);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _removeOverlay(animate: false);
    _ctrl.dispose();
    super.dispose();
  }

  void _removeOverlay({bool animate = true}) {
    if (_overlayEntry == null) return;
    if (animate) {
      _ctrl.reverse();
      Future.delayed(const Duration(milliseconds: 200), () {
        _overlayEntry?.remove();
        _overlayEntry = null;
        setState(() => _selectedId = null);
      });
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _selectedId = null;
    }
  }

  // Hàm này để đánh dấu thông báo đã đọc
  Future<void> _markNotificationAsRead(_UnifiedNotification notification) async {
    if (!notification.isRead) {
      await notification.ref.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.notifi,
      // Đã loại bỏ AppBar
      body: Column( // Sử dụng Column để chứa dòng tiêu đề và ListView
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
            child: Text(
              '${"notifications".tr()} ($_unreadCount)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepOcean, // Chọn màu phù hợp với chủ đề ứng dụng của bạn
              ),
            ),
          ),
          Expanded( // Đảm bảo ListView chiếm hết không gian còn lại
            child: StreamBuilder<List<_UnifiedNotification>>(
              stream: combinedStream,
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('${"error".tr()} ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;

                // Tính toán số lượng thông báo chưa đọc
                final currentUnread = items.where((item) => !item.isRead).length;

                // Cập nhật _unreadCount và gọi callback nếu có thay đổi
                if (_unreadCount != currentUnread) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _unreadCount = currentUnread;
                    });
                    // Gọi callback để truyền số lượng chưa đọc lên widget cha
                    if (widget.onUnreadCountChanged != null) {
                      widget.onUnreadCountChanged!(_unreadCount);
                    }
                  });
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: AppColors.slateGrey),
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    final formattedTime =
                    DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt);
                    final link = _layerLinks.putIfAbsent(item.id, () => LayerLink());

                    Widget messageWidget;

                    if (item.source == _UnifiedNotificationSource.notifications) {
                      if (item.type == 'business_verification') {
                        messageWidget = RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: "New_verification".tr(),
                                style: const TextStyle(
                                  color: AppColors.deepOcean,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: ' ${item.metadata?['company'] ?? 'Một doanh nghiệp'}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        messageWidget = Text(
                          item.notificationMessage ?? '',
                          style: const TextStyle(
                            color: AppColors.deepOcean,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        );
                      }
                    } else if (item.source == _UnifiedNotificationSource.reports) {
                      messageWidget = FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('featured_activities')
                            .doc(item.relatedId)
                            .get(),
                        builder: (ctx, snap) {
                          String title = item.relatedId;
                          if (snap.connectionState == ConnectionState.done &&
                              snap.hasData &&
                              snap.data!.data() != null) {
                            final data = snap.data!.data()! as Map<String, dynamic>;
                            title = data['title'] as String? ?? title;
                          }
                          return RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(text: "user_report: Campaign".tr()),
                                TextSpan(
                                  text: title,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '${"has_content".tr()} ${item.reportReason}',
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (item.source == _UnifiedNotificationSource.supportRequests) {
                      messageWidget = Text(
                        item.notificationMessage ?? '',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      );
                    } else {
                      // Phòng trường hợp ngoài ý muốn
                      messageWidget = Text(
                        "undetermined_notice".tr(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () async {
                        await _markNotificationAsRead(item);

                        if (item.source == _UnifiedNotificationSource.reports) {
                          final doc = await FirebaseFirestore.instance
                              .collection('featured_activities')
                              .doc(item.relatedId)
                              .get();
                          if (!doc.exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("campaign_not_found".tr()),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          final data = doc.data()! as Map<String, dynamic>;
                          final activity = FeaturedActivity.fromMap(
                            data,
                            doc.id,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CampaignDetailBN(activity: activity),
                            ),
                          );
                        } else if (item.type == 'business_verification') {
                          final doc = await FirebaseFirestore.instance
                              .collection('businessVerifications')
                              .doc(item.relatedId)
                              .get();
                          if (!doc.exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("verification_request_not_found".tr()),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessDetailScreen(
                                businessId: item.relatedId,
                              ),
                            ),
                          );
                        } else if (item.source == _UnifiedNotificationSource.supportRequests) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupportRequestsPage(
                                highlightRequestId: item.relatedId,
                              ),
                            ),
                          );

                        }
                      },
                      child: Row(
                        children: [
                          CompositedTransformTarget(
                            link: link,
                            child: Icon(
                              item.source == _UnifiedNotificationSource.notifications
                                  ? Icons.business
                                  : item.source == _UnifiedNotificationSource.supportRequests
                                  ? Icons.support_agent
                                  : Icons.report,
                              color: item.source == _UnifiedNotificationSource.notifications
                                  ? (item.type == 'business_verification'
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600)
                                  : item.source == _UnifiedNotificationSource.supportRequests
                                  ? Colors.deepOrange
                                  : Colors.redAccent.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                messageWidget,
                                const SizedBox(height: 4),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.deepOcean.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!item.isRead)
                            const Icon(Icons.brightness_1, size: 10, color: Colors.red),
                        ],
                      ),
                    );

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
