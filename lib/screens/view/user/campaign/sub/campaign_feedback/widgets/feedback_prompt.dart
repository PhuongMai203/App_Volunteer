import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../components/app_colors.dart';

class FeedbackPrompt extends StatefulWidget {
  final VoidCallback onCancel;
  final void Function(int rating, String? comment) onSubmit;

  const FeedbackPrompt({
    Key? key,
    required this.onCancel,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<FeedbackPrompt> createState() => _FeedbackPromptState();
}

class _FeedbackPromptState extends State<FeedbackPrompt> {
  int _selectedStar = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _buildStar(int index, double iconSize) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStar = index;
        });
      },
      child: Icon(
        index <= _selectedStar ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: iconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.08; // Icon ngôi sao tỉ lệ theo màn hình
    final titleFontSize = screenWidth * 0.045;
    final buttonFontSize = screenWidth * 0.04;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400, // Giới hạn tối đa cho tablet
            minWidth: screenWidth * 0.85,
          ),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.feedback, color: Colors.orange, size: iconSize),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          'rate_campaign'.tr(),
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: iconSize * 0.8),
                        onPressed: widget.onCancel,
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.04),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => _buildStar(index + 1, iconSize)),
                  ),

                  SizedBox(height: screenWidth * 0.05),

                  // Comment box
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'comment_placeholder'.tr(),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.sunrise, width: 2),
                      ),
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.06),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onCancel,
                        icon: Icon(Icons.cancel, color: Colors.red, size: iconSize * 0.7),
                        label: Text(
                          'cancel'.tr(),
                          style: TextStyle(color: Colors.red, fontSize: buttonFontSize),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      ElevatedButton.icon(
                        onPressed: _selectedStar > 0
                            ? () {
                          widget.onSubmit(
                            _selectedStar,
                            _commentController.text.trim().isEmpty
                                ? null
                                : _commentController.text.trim(),
                          );
                        }
                            : null,
                        icon: Icon(Icons.send, size: iconSize * 0.7),
                        label: Text(
                          'send'.tr(),
                          style: TextStyle(fontSize: buttonFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedStar > 0 ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.025,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
