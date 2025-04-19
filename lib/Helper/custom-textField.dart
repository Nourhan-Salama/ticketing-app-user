import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final Function? onSuffixPressed;
  final TextInputType? keyboardType;
  final String? errorText;
  final String? successText;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? hintText;
  final String label;
  final TextEditingController? controller;
  final List<String>? dropdownItems;
   final String? selectedValue; 
  final ValueChanged<String?>? onChanged;
  final bool? isDropdown;

  const CustomTextField({
    Key? key,
    this.selectedValue,
    this.successText,
    this.onSuffixPressed,
    this.keyboardType,
    this.errorText,
    this.obscureText = false,
    required this.label,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.dropdownItems,
    this.onChanged, 
     this.isDropdown,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        widget.dropdownItems == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _controller,
                    obscureText: _isObscured,
                    keyboardType: widget.keyboardType,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: widget.prefixIcon != null
                          ? Icon(widget.prefixIcon)
                          : null,
                      suffixIcon: widget.obscureText
                          ? IconButton(
                              icon: Icon(
                                  _isObscured ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            )
                          : widget.suffixIcon != null
                              ? Icon(widget.suffixIcon)
                              : null,
                      errorText: widget.errorText, 
                    ),
                    onChanged: widget.onChanged,
                  ),

                  
                  if (widget.successText != null && widget.errorText == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 8),
                      child: Text(
                        widget.successText!,
                        style: const TextStyle(
                          color: Colors.green, 
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              )
            : DropdownButtonFormField<String>(
              value: widget.selectedValue,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(widget.prefixIcon)
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? Icon(widget.suffixIcon)
                      : null,
                ),
                items: widget.dropdownItems!
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: widget.onChanged,
              ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

