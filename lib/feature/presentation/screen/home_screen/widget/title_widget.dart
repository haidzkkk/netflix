
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.padding,
  });

  final String title;
  final Function() onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                style: TextStyle(fontSize: 24.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10,),
            const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white,),
          ],
        ),
      ),
    );
  }
}