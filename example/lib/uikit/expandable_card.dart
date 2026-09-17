import 'package:flutter/material.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final List<Widget> children;
  const ExpandableCard(this.title, this.children, {super.key});

  @override
  State<ExpandableCard> createState() => ExpandableCardState();
}

class ExpandableCardState extends State<ExpandableCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ExpansionTile(
              title: Text(widget.title),
              children: widget.children,
            )));
  }
}
