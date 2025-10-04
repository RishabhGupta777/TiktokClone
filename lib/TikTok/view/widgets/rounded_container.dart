import 'package:flutter/cupertino.dart';

class TRoundedContainer extends StatelessWidget {
  const TRoundedContainer({
    super.key,
    this.child,
    this.width ,
    this.height ,
    this.radius =20,
    this.padding = 0,
    this.backgroundColor ,
    this.margin=0,
    this.borderColor,
    this.showBorder=false,
  });
  final Widget?child;
  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final double margin;
  final Color ? backgroundColor;
  final bool showBorder;
  final Color ? borderColor ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:width,
      height: height,
      margin:EdgeInsets.all(margin) ,
      padding: EdgeInsets.all(padding),
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
