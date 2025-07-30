import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_constants.dart';

/// Custom button widget with consistent styling and animations
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isOutlined;
  final BorderSide? borderSide;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.gradient,
    this.width,
    this.height,
    this.elevation = 2,
    this.borderRadius = AppConstants.borderRadius,
    this.padding,
    this.isLoading = false,
    this.isOutlined = false,
    this.borderSide,
    this.textStyle,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildButton(context, isEnabled),
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isEnabled) {
    if (widget.isOutlined) {
      return _buildOutlinedButton(context, isEnabled);
    } else if (widget.gradient != null) {
      return _buildGradientButton(context, isEnabled);
    } else {
      return _buildElevatedButton(context, isEnabled);
    }
  }

  Widget _buildElevatedButton(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 48,
      child: ElevatedButton(
        onPressed: isEnabled ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? AppColors.primary,
          foregroundColor: widget.textColor ?? AppColors.white,
          elevation: isEnabled ? widget.elevation : 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 48,
      child: OutlinedButton(
        onPressed: isEnabled ? widget.onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: widget.textColor ?? AppColors.primary,
          side: widget.borderSide ?? BorderSide(
            color: isEnabled ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildGradientButton(BuildContext context, bool isEnabled) {
    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: Container(
        width: widget.width,
        height: widget.height ?? 48,
        decoration: BoxDecoration(
          gradient: isEnabled ? widget.gradient : null,
          color: isEnabled ? null : AppColors.greyLight,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: widget.elevation * 2,
              offset: Offset(0, widget.elevation),
            ),
          ] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: _buildButtonContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.textColor ?? AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Chargement...',
            style: _getTextStyle(context),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: widget.textColor ?? (widget.isOutlined ? AppColors.primary : AppColors.white),
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: _getTextStyle(context),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: _getTextStyle(context),
      textAlign: TextAlign.center,
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    return widget.textStyle ?? 
        Theme.of(context).textTheme.labelLarge?.copyWith(
          color: widget.textColor ?? (widget.isOutlined ? AppColors.primary : AppColors.white),
          fontWeight: FontWeight.w600,
        ) ?? 
        TextStyle(
          color: widget.textColor ?? (widget.isOutlined ? AppColors.primary : AppColors.white),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        );
  }
}

/// Small button variant
class SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const SmallButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      isOutlined: isOutlined,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Icon button variant
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.white,
          size: iconSize,
        ),
        splashRadius: size / 2,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Floating action button variant
class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool mini;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      mini: mini,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 8,
      child: Icon(icon),
    );
  }
}
