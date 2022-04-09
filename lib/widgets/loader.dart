import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatefulWidget {
  final Color color;
  final double size;

  const Loader({Key key, this.color = Colors.amber, this.size = 50.0})
      : super(key: key);

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: widget.color,
      size: widget.size,
    );
  }
}
