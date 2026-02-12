import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Shimmer.fromColors(
      baseColor: Color(0xffefeeee),
      highlightColor: Color(0xfff1c2c2),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}