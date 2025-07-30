import 'package:flutter/material.dart';

class ScanFrameIcon extends StatelessWidget {
  const ScanFrameIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _cornerWidget()),
          Positioned(bottom: 0, right: 0, child: _cornerWidget(isRight: true)),
          Center(child: Divider(color: Colors.black, thickness: 2)),
          Positioned(top: 0, right: 0, child: _cornerWidget(isBottom: true)),
          Positioned(
            bottom: 0,
            left: 0,
            child: _cornerWidget(isBottom: true, isRight: true),
          ),
        ],
      ),
    );
  }

  Widget _cornerWidget({bool isBottom = false, bool isRight = false}) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationZ(
        (isBottom ? 1 : 0) * 3.1416 / 2 + (isRight ? 1 : 0) * 3.1416,
      ),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 2, color: Colors.black),
            left: BorderSide(width: 2, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
