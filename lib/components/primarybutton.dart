import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton(
      {super.key,
      required this.screenwidth,
      required this.buttonpressed,
      required this.text,
      required this.buttonwidth,
      required this.bold});

  final double screenwidth;
  final bool buttonpressed;
  final String text;
  final double buttonwidth;
  final bool bold;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
    ]).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
    ]).animate(_controller);
    widget.buttonpressed ? _controller.repeat() : _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: widget.buttonwidth,
      child: widget.buttonpressed
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: const [
                              Color.fromARGB(255, 255, 27, 103),
                              Color.fromARGB(255, 255, 94, 172),
                            ],
                            begin: _topAlignmentAnimation.value,
                            end: _bottomAlignmentAnimation.value),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: widget.buttonpressed
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: SpinKitThreeInOut(
                              color: Colors.white,
                              size: widget.screenwidth * 0.04,
                            ),
                          )
                        : Center(
                            child: Text(
                              widget.text,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                              textScaleFactor: 1.1,
                            ),
                          ));
              })
          : Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: widget.buttonpressed
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: SpinKitThreeInOut(
                        color: Colors.white,
                        size: widget.screenwidth * 0.04,
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: widget.bold
                                ? FontWeight.bold
                                : FontWeight.normal),
                        textScaleFactor: 1.1,
                      ),
                    )),
    );
  }
}
