import 'package:flutter/material.dart';

class SearchGridView extends StatelessWidget {
  SearchGridView({Key? key, required this.interests, required this.onTap})
      : super(key: key);
  List interests;

  final Function(String interest)? onTap;

  Widget _listviewitem(String interest) {
    Widget widget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        image: DecorationImage(
            image: AssetImage(
              "assets/images/interestbanners/${interest.toLowerCase()}.jpeg",
            ),
            fit: BoxFit.cover),
      ),
      child: Center(
          child: Text(
        interest,
        style: const TextStyle(
            fontSize: 33, fontWeight: FontWeight.bold, color: Colors.white),
        textScaler: TextScaler.linear(1.0),
      )),
    );

    return GestureDetector(
      onTap: () => onTap?.call(interest),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 80),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        shrinkWrap: true,
        itemCount: interests.length,
        itemBuilder: ((context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: _listviewitem(interests[index]),
          );
        }),
      ),
    );
  }
}
