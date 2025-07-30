import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_constants.dart';

/// Custom text field widget with consistent styling
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.fillColor,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _setupAnimations();
    _setupFocusListener();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AnimatedBuilder(
            animation: _focusAnimation,
            builder: (context, child) {
              return Text(
                widget.label!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _hasError
                      ? AppColors.error
                      : _isFocused
                          ? AppColors.primary
                          : AppColors.textSecondary,
                  fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onFieldSubmitted,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                initialValue: widget.initialValue,
                textCapitalization: widget.textCapitalization,
                autofocus: widget.autofocus,
                validator: (value) {
                  final error = widget.validator?.call(value);
                  setState(() {
                    _hasError = error != null;
                  });
                  return error;
                },
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: widget.enabled ? AppColors.textPrimary : AppColors.textHint,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textHint,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _hasError
                              ? AppColors.error
                              : _isFocused
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: widget.fillColor ?? 
                      (_isFocused 
                          ? AppColors.primary.withOpacity(0.05)
                          : AppColors.greyLight),
                  contentPadding: widget.contentPadding ??
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                  errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Search text field variant
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? 'Rechercher...',
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Password text field variant
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction textInputAction;

  const PasswordTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
    );
  }
}
