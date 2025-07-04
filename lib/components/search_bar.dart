import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchBarWidget({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onSearchChanged,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "search_placeholder".tr(),
          prefixIcon: const Icon(Icons.search, color: Colors.orange),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.orange, width: 1.5),
          ),
        ),
      ),
    );
  }
}