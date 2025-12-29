// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FFButtonOptions {
  const FFButtonOptions({
    this.textAlign,
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconAlignment,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
    this.hoverColor,
    this.hoverBorderSide,
    this.hoverTextColor,
    this.hoverElevation,
    this.maxLines,
    this.focusBorderSide,
    this.focusBorderRadius,
  });

  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final int? maxLines;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final IconAlignment? iconAlignment;
  final EdgeInsetsGeometry? iconPadding;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final Color? hoverColor;
  final BorderSide? hoverBorderSide;
  final Color? hoverTextColor;
  final double? hoverElevation;
  final BorderSide? focusBorderSide;
  final BorderRadius? focusBorderRadius;
}

class FFButtonWidget extends StatefulWidget {
  const FFButtonWidget({
    required this.text,
    required this.onPressed,
    required this.options,
    super.key,
    this.icon,
    this.iconData,
    this.showLoadingIndicator = true,
  });

  final String text;
  final Widget? icon;
  final IconData? iconData;
  final Function()? onPressed;
  final FFButtonOptions options;
  final bool showLoadingIndicator;

  @override
  State<FFButtonWidget> createState() => _FFButtonWidgetState();
}

class _FFButtonWidgetState extends State<FFButtonWidget> {
  bool loading = false;

  int get maxLines => widget.options.maxLines ?? 1;
  String? get text => widget.options.textStyle?.fontSize == 0 ? null : widget.text;

  @override
  Widget build(final BuildContext context) {
    final textWidget = loading
        ? SizedBox(
            width: widget.options.width == null ? _getTextWidth(text, widget.options.textStyle, maxLines) : null,
            child: Center(
              child: SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.options.textStyle?.color ?? Colors.white,
                  ),
                ),
              ),
            ),
          )
        : AutoSizeText(
            text ?? '',
            style: text == null ? null : widget.options.textStyle?.withoutColor(),
            textAlign: widget.options.textAlign,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          );

    final onPressed = widget.onPressed != null
        ? (widget.showLoadingIndicator
            ? () async {
                if (loading) {
                  return;
                }
                setState(() => loading = true);
                try {
                  await widget.onPressed!();
                } finally {
                  if (mounted) {
                    setState(() => loading = false);
                  }
                }
              }
            : () => widget.onPressed!())
        : null;

    final style = ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((final states) {
        if (states.contains(WidgetState.hovered) && widget.options.hoverBorderSide != null) {
          return RoundedRectangleBorder(
            borderRadius: widget.options.borderRadius ?? BorderRadius.circular(8),
            side: widget.options.hoverBorderSide!,
          );
        }
        if (states.contains(WidgetState.focused) && widget.options.focusBorderSide != null) {
          return RoundedRectangleBorder(
            borderRadius: widget.options.focusBorderRadius ?? widget.options.borderRadius ?? BorderRadius.circular(8),
            side: widget.options.focusBorderSide!,
          );
        }
        return RoundedRectangleBorder(
          borderRadius: widget.options.borderRadius ?? BorderRadius.circular(8),
          side: widget.options.borderSide ?? BorderSide.none,
        );
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((final states) {
        if (states.contains(WidgetState.disabled) && widget.options.disabledTextColor != null) {
          return widget.options.disabledTextColor;
        }
        if (states.contains(WidgetState.hovered) && widget.options.hoverTextColor != null) {
          return widget.options.hoverTextColor;
        }
        return widget.options.textStyle?.color ?? Colors.white;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((final states) {
        if (states.contains(WidgetState.disabled) && widget.options.disabledColor != null) {
          return widget.options.disabledColor;
        }
        if (states.contains(WidgetState.hovered) && widget.options.hoverColor != null) {
          return widget.options.hoverColor;
        }
        return widget.options.color;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((final states) {
        if (states.contains(WidgetState.pressed)) {
          return widget.options.splashColor;
        }
        return widget.options.hoverColor == null ? null : Colors.transparent;
      }),
      padding: WidgetStateProperty.all(
        widget.options.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      elevation: WidgetStateProperty.resolveWith<double?>((final states) {
        if (states.contains(WidgetState.hovered) && widget.options.hoverElevation != null) {
          return widget.options.hoverElevation!;
        }
        return widget.options.elevation ?? 2.0;
      }),
      iconColor: WidgetStateProperty.resolveWith<Color?>((final states) {
        if (states.contains(WidgetState.disabled) && widget.options.disabledTextColor != null) {
          return widget.options.disabledTextColor;
        }
        if (states.contains(WidgetState.hovered) && widget.options.hoverTextColor != null) {
          return widget.options.hoverTextColor;
        }
        return widget.options.iconColor;
      }),
    );

    if ((widget.icon != null || widget.iconData != null) && !loading) {
      final icon = widget.icon ??
          FaIcon(
            widget.iconData!,
            size: widget.options.iconSize,
            color: widget.options.iconColor,
          );

      if (text == null) {
        return Container(
          height: widget.options.height,
          width: widget.options.width,
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              widget.options.borderSide ?? BorderSide.none,
            ),
            borderRadius: widget.options.borderRadius ?? BorderRadius.circular(8),
          ),
          child: IconButton(
            splashRadius: 1,
            icon: Padding(
              padding: widget.options.iconPadding ?? EdgeInsets.zero,
              child: icon,
            ),
            onPressed: onPressed,
            style: style,
          ),
        );
      }
      return SizedBox(
        height: widget.options.height,
        width: widget.options.width,
        child: ElevatedButton.icon(
          icon: Padding(
            padding: widget.options.iconPadding ?? EdgeInsets.zero,
            child: icon,
          ),
          label: textWidget,
          onPressed: onPressed,
          style: style,
          iconAlignment: widget.options.iconAlignment ?? IconAlignment.start,
        ),
      );
    }

    return SizedBox(
      height: widget.options.height,
      width: widget.options.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: textWidget,
      ),
    );
  }
}

extension _WithoutColorExtension on TextStyle {
  TextStyle withoutColor() => TextStyle(
        inherit: inherit,
        color: null,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        leadingDistribution: leadingDistribution,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        debugLabel: debugLabel,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        // The _package field is private so unfortunately we can't set it here,
        // but it's almost always unset anyway.
        // package: _package,
        overflow: overflow,
      );
}

// Slightly hacky method of getting the layout width of the provided text.
double? _getTextWidth(final String? text, final TextStyle? style, final int maxLines) => text != null
    ? (TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
      )..layout())
        .size
        .width
    : null;

class FFFocusIndicator extends StatefulWidget {
  final Widget child;
  final Border? border;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;

  const FFFocusIndicator({
    required this.child,
    super.key,
    this.border,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  State<FFFocusIndicator> createState() => _FFFocusIndicatorState();
}

class _FFFocusIndicatorState extends State<FFFocusIndicator> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: widget.padding,
      decoration: BoxDecoration(
        border: _hasFocus ? widget.border : null,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusNode: _focusNode,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        child: widget.child,
      ),
    );
  }
}
