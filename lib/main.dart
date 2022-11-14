import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: const [
            RelationWidget(),
            RelationWidget(),
            RelationWidget(),
            RelationWidget(),
            RelationWidget(),
            RelationWidget(),
            RelationWidget(),
            RelationWidget(),
          ],
        ),
      ),
    );
  }
}

class Item {
  Item(this.label, this.tag, this.key);

  final String label;
  final String tag;
  final GlobalKey key;
}

class Relation {
  final List<String> tags;
  final Color color;

  Relation(this.color, [this.tags = const []]);
}


class RelationWidget extends StatefulWidget {
  const RelationWidget({super.key});

  @override
  State<RelationWidget> createState() => _RelationWidgetState();
}

class _RelationWidgetState extends State<RelationWidget> {
  final leftItems = [
    Item("jeruk", "j", GlobalKey()),
    Item("Kambing Testing teksnya panjang ya bro\n sampai tiga baris\nApakah bisa?", "k",
        GlobalKey()),
    Item("Nanas", "n", GlobalKey()),
    Item("Supriyadi", "s", GlobalKey()),
  ];
  final rightItems = [Item("Manusia", "m", GlobalKey()), Item("Hewan", "h", GlobalKey())];
  final relations = <Relation>[
    Relation(Colors.red.shade200, ["j", "m"]),
    // Relation(Colors.orange.shade200, ["k", "m"]),
    Relation(Colors.green.shade200, ["j", "h"]),
    Relation(Colors.blue.shade200, ["k", "h"]),
    Relation(Colors.purple.shade200, ["s", "m"]),
  ];

  final _parentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          key: _parentKey,
          foregroundPainter: MyPainter(leftItems, rightItems, relations, _parentKey),
          child: Row(
            children: [
              Expanded(child: _buildItems(leftItems)),
              const Expanded(child: SizedBox.shrink()),
              Expanded(child: _buildItems(rightItems)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildItems(List<Item> items) {
    return Column(
      children: items.map((e) {
        final colors = relations
            .where((element) => element.tags.contains(e.tag))
            .map((element) => element.color)
            .toList();
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            key: e.key,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              color: colors.isEmpty || colors.length > 1 ? null : colors.first,
              gradient: colors.length >= 2 ? LinearGradient(colors: colors) : null,
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(title: Text(e.label)),
          ),
        );
      }).toList(),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Item> leftItems;
  final List<Item> rightItems;
  final List<Relation> relations;
  final GlobalKey parentKey;

  const MyPainter(this.leftItems, this.rightItems, this.relations, this.parentKey);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final parentBox = parentKey.currentContext?.findRenderObject() as RenderBox;
    final parentOffset = parentBox.localToGlobal(Offset.zero);
    for (Relation relation in relations) {
      if (relation.tags.length < 2) continue;
      paint.color = relation.color;
      Item leftItem = leftItems.firstWhere(
        (element) => element.tag == relation.tags.first,
        orElse: () => rightItems.firstWhere((element) => element.tag == relation.tags.first),
      );
      Item rightItem = leftItems.firstWhere(
        (element) => element.tag == relation.tags[1],
        orElse: () => rightItems.firstWhere((element) => element.tag == relation.tags[1]),
      );

      RenderBox leftbox = leftItem.key.currentContext?.findRenderObject() as RenderBox;
      RenderBox rightbox = rightItem.key.currentContext?.findRenderObject() as RenderBox;
      final leftOffsetTemp = leftbox.localToGlobal(Offset.zero);
      final rightOffsetTempp = rightbox.localToGlobal(Offset.zero);
      final leftOffset = Offset(
          leftOffsetTemp.dx + leftbox.size.width - parentOffset.dx, leftOffsetTemp.dy + leftbox.size.height / 2 - parentOffset.dy);
      final rightOffset =
          Offset(rightOffsetTempp.dx-parentOffset.dx, rightOffsetTempp.dy + rightbox.size.height / 2-parentOffset.dy);
      canvas.drawLine(leftOffset, rightOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
