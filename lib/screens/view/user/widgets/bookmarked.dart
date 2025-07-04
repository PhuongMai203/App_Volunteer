import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookmarkProvider extends ChangeNotifier {
  List<FeaturedActivity> _bookmarkedEvents = [];

  List<FeaturedActivity> get bookmarkedEvents => _bookmarkedEvents;

  void setBookmarks(List<FeaturedActivity> bookmarks) {
    _bookmarkedEvents = bookmarks;
    notifyListeners();
  }

  void addBookmark(FeaturedActivity activity) {
    _bookmarkedEvents.add(activity);
    notifyListeners();
  }

  void removeBookmark(FeaturedActivity activity) {
    _bookmarkedEvents.removeWhere((a) => a.id == activity.id);
    notifyListeners();
  }

  Future<void> toggleBookmark(String activityId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      final bookmarks = List<String>.from(doc.data()?['bookmarkedEvents'] ?? []);

      if (bookmarks.contains(activityId)) {
        bookmarks.remove(activityId);
      } else {
        bookmarks.add(activityId);
      }

      await userRef.update({'bookmarkedEvents': bookmarks});
      await loadBookmarkedEvents(); // Cập nhật lại danh sách sau khi toggle
    }
  }

  Future<void> loadBookmarkedEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final List<dynamic> bookmarkIds = userDoc.data()?['bookmarkedEvents'] ?? [];

      if (bookmarkIds.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('featured_activities')
            .where(FieldPath.documentId, whereIn: bookmarkIds)
            .get();

        final events = querySnapshot.docs
            .where((doc) => doc.exists && doc.id.isNotEmpty) // kiểm tra tồn tại và id hợp lệ
            .map((doc) => FeaturedActivity.fromDocument(doc)) // chuyển thành model
            .toList();

        _bookmarkedEvents = events;
        notifyListeners();
      } else {
        _bookmarkedEvents = [];
        notifyListeners();
      }
    } catch (e) {
      print(tr('error_loading_saved_event', args: [e.toString()]));
    }
  }
}
