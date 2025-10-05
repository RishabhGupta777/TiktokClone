import 'package:flutter/cupertino.dart';

class TRoundedContainer extends StatelessWidget {
  const TRoundedContainer({
    super.key,
    this.child,
    this.width ,
    this.height ,
    this.radius =20,
    this.padding ,
    this.backgroundColor ,
    this.margin,
    this.borderColor,
    this.showBorder=false,
  });
  final Widget?child;
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color ? backgroundColor;
  final bool showBorder;
  final Color ? borderColor ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:width,
      height: height,
      margin:margin ,
      padding:padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius), //taki niche ke container se radius match kar paye
        color:backgroundColor ,
        border:showBorder ? Border.all(color:borderColor  ?? CupertinoColors.white) : null,
      ),
      clipBehavior: Clip.antiAlias, // Ensures child respects borderRadius
      child :child,
    );
  }
}
