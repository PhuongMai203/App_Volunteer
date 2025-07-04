import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DismissibleCampaignItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;

  const DismissibleCampaignItem({
    super.key,
    required this.child,
    required this.onDelete,
  });

  @override
  State<DismissibleCampaignItem> createState() => _DismissibleCampaignItemState();
}

class _DismissibleCampaignItemState extends State<DismissibleCampaignItem> with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  double maxDrag = 100;
  final double borderRadius = 16;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-maxDrag, 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() < maxDrag / 2) {
      setState(() => _dragOffset = 0);
    } else {
      setState(() => _dragOffset = -maxDrag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          // Nền chứa nút xoá
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: const Color(0xFFFF0000),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 28),
                  onPressed: widget.onDelete,
                ),
              ),
            ),
          ),
          // Widget chính có thể trượt
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: SizedBox(
                  height: 140,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}