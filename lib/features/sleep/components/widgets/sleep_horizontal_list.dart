import 'package:flutter/material.dart';

class SleepHorizontalList extends StatefulWidget {
  final List<Widget> cards;
  const SleepHorizontalList({super.key, required this.cards});



  @override
  State<SleepHorizontalList> createState() => _SleepHorizontalListState();
}

class _SleepHorizontalListState extends State<SleepHorizontalList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 226, // 최소 높이
        maxHeight: 249, // 최대 높이
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: widget.cards,
      ),
    );
  }
}
