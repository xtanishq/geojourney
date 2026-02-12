import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PressUnpress extends StatefulWidget {
  final String? imageAssetUnPress;
  final String? imageAssetPress;
  final VoidCallback onTap;
  final void Function(TapDownDetails)? onTapDown; // ✅ Added this
  final Color? pressColor;
  final Color? unPressColor;
  final double height;
  final double width;
  final Widget? child;
  final Alignment? imageAlignment;
  final Alignment? alignment;
  final LinearGradient? pressLinearGradient;
  final LinearGradient? unPressLinearGradient;

  const PressUnpress({
    super.key,
    this.imageAssetUnPress,
    this.imageAssetPress,
    required this.width,
    required this.height,
    required this.onTap,
    this.onTapDown, // ✅ added
    this.child,
    this.pressColor,
    this.unPressColor,
    this.alignment,
    this.imageAlignment,
    this.pressLinearGradient,
    this.unPressLinearGradient,
  });

  @override
  _PressUnpressState createState() => _PressUnpressState();
}

class _PressUnpressState extends State<PressUnpress> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.imageAssetPress?.isNotEmpty ?? false) {
      precacheImage(AssetImage(widget.imageAssetPress ?? ''), context);
    }
    return GestureDetector(
      onTapDown: (details) {
        widget.onTapDown?.call(details); // ✅ call external handler if provided
        _handleTap(true);
      },
      onTapUp: (_) => _handleTap(false),
      onTapCancel: _resetTap,
      onTap: widget.onTap,
      child: buildContainer(),
    );
  }

  void _handleTap(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
  }

  void _resetTap() {
    _handleTap(false);
  }

  Widget buildContainer() {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.imageAssetUnPress == null
            ? BorderRadius.circular(40)
            : null,
        color: _isPressed ? widget.pressColor : widget.unPressColor,
        gradient: _isPressed
            ? widget.pressLinearGradient
            : widget.unPressLinearGradient,
        image:
            widget.imageAssetUnPress != null &&
                widget.imageAssetUnPress!.isNotEmpty &&
                widget.imageAssetPress != null &&
                widget.imageAssetPress!.isNotEmpty
            ? DecorationImage(
                image: AssetImage(
                  _isPressed
                      ? widget.imageAssetPress!
                      : widget.imageAssetUnPress!,
                ),
                fit: BoxFit.contain,
                alignment: widget.imageAlignment ?? Alignment.center,
              )
            : null,
      ),
      alignment: widget.alignment,
      child: widget.child ?? const SizedBox.shrink(),
    );
  }
}
