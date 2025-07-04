import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
	final TextEditingController controller;
  final String hintText;
  final bool obscureText;
	final TextInputType keyboardType;
	final Widget? suffixIcon;
	final VoidCallback? onTap;
	final Widget? prefixIcon;
	final String? Function(String?)? validator;
	final FocusNode? focusNode;
	final String? errorMsg;
	final String? Function(String?)? onChanged;

	const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
		required this.keyboardType,
		this.suffixIcon,
		this.onTap,
		this.prefixIcon,
		this.validator,
		this.focusNode,
		this.errorMsg,
		this.onChanged
  });
	
	@override
	Widget build(BuildContext context) {
		return TextFormField(
			validator: validator,
			controller: controller,
			obscureText: obscureText,
			keyboardType: keyboardType,
			focusNode: focusNode,
			onTap: onTap,
			textInputAction: TextInputAction.next,
			onChanged: onChanged,
			decoration: InputDecoration(
				suffixIcon: suffixIcon,
				prefixIcon: prefixIcon,
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(20),
					borderSide:  BorderSide(color: Colors.orange.shade700, width: 2),
				),
				errorBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: const BorderSide(color: Colors.red, width: 2),
				),
				focusedErrorBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(20),
					borderSide: const BorderSide(color: Colors.redAccent, width: 2), // Viền đỏ khi lỗi và focus
				),
				fillColor: Colors.white,
				filled: true,
				hintText: hintText,
				hintStyle: TextStyle(color: Colors.grey.shade700),
				errorText: errorMsg,
			),
		);
	}
}