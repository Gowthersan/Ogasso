import 'package:flutter/widgets.dart';

class CircleImageWidget extends StatelessWidget {

  final double width;
  final double heigth;
  final String url;

  const CircleImageWidget({Key? key, required this.width, required this.heigth, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: heigth,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: new NetworkImage(
                    "${url}")
            )
        ));
  }
}
