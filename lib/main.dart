import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const title = 'Blocks Pattern';
const W = Colors.white;
const O = Colors.orangeAccent;
const G = Colors.greenAccent;
const B = Colors.blueAccent;

void main() => runApp(Blocks());

class Blocks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Game(),
    );
  }
}

class Game extends StatefulWidget {
  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  var view = 'S';
  var type = 'F';
  var time = 0;
  int win = 0;
  int level = 0;
  int points = 0;
  double width = 1.0;
  double size = 98.0;
  var timer;
  var items = [];
  var levels = [];
  var challenge = [];
  var messages = '.......'.split('.');
  var board = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ];
  var figures = [
    null,
    Icons.check_box_outline_blank,
    Icons.keyboard_arrow_up,
    Icons.radio_button_unchecked,
    Icons.chevron_left,
    Icons.gamepad,
    Icons.chevron_right,
    Icons.change_history,
    Icons.keyboard_arrow_down,
    Icons.close,
  ];

  get mode => wr(<Widget>[
        act(tnum, 'Num', ami('N'), 1),
        act(tfig, 'Img', ami('F'), 1),
        act(tchr, 'Char', ami('C'), 1)
      ]);

  ami(t) => type == t ? G : W;

  List<Widget> get menu =>
      [level > levels.length ? act(rs, 'Reset') : act(play, 'Play')];

  List<Widget> get options {
    switch (view) {
      case 'G':
        return [bm(0), bhr(), bi(si()), bbr(0), bbr(1), bbr(2)];
      case 'S':
        return [bm(0), bm(1), bm(2), bar()];
      case 'R':
        return [bm(0), bi(sl()), bi(ss()), bi(sw()), bar()];
      case 'E':
        return [bm(4), bm(5), bi(sw()), bar()];
    }
  }

  get header {
    var all = <Widget>[];
    var s = size / 2;
    var w = width / 2;
    for (var prop in challenge) all.add(sqr(icon(prop[0], s, prop[1]), w));

    return all;
  }

  get body {
    List<Widget> children = options + [bi('')] + [mode];
    return ListView(children: children);
  }

  get decorate => BoxDecoration(shape: BoxShape.rectangle, color: B);

  sqr(child, edge) => AnimatedContainer(
      child: child,
      decoration: decorate,
      padding: EdgeInsets.all(1),
      width: edge,
      height: edge,
      duration: Duration(milliseconds: 500));

  info(v, [c = W, s = 28.0]) {
    var style = TextStyle(fontSize: s, color: c);
    var text = Text(v, style: style);
    var child = Container(child: Center(child: text));
    var padding = EdgeInsets.all(18);

    return Container(decoration: decorate, padding: padding, child: child);
  }

  icon(int i, s, c) {
    switch (type) {
      case 'F':
        return Icon(figures[i], size: s, color: c);
      case 'N':
        return info(' 123456789'[i], c);
      case 'C':
        return info(' ABCDEFGHI'[i], c);
    }
  }

  render(slot) {
    var c = <Widget>[];
    for (var idx = 0; idx < 3; idx++)
      c.add(InkWell(
          child: sqr(icon(slot[idx], size, W), width),
          onTap: () => mv(slot[idx])));

    return c;
  }

  act(fn, label, [c = W, int qty = 3]) =>
      InkWell(child: sqr(info(label, c), width * qty), onTap: fn);

  play() {
    level++;
    items = [];
    points = 0;
    time = 6;
    challenge = [];

    Timer.periodic(Duration(seconds: 1), (Timer t) async {
      timer = t;
      var f = time > 0;
      if (f) time--;
      if (!f) timer.cancel();
      sv(!f ? 'R' : 'G');
    });

    if (level > levels.length - 1) return sv('E');

    var target = levels[level];
    if (target != null) for (var id in target) challenge.add([id, W]);

    sv('G');
  }

  add(i) {
    items.add(i);

    var c = challenge[items.length - 1];
    var f = c.first == i;

    if (f) win++;
    if (f) points++;

    c[1] = f ? G : O;
  }

  prepare() async {
    if (levels.length > 1) return;

    var rl = await R('L');
    var rm = await R('M');
    var all = rl
        .split(',')
        .map((g) => g.split(''))
        .map((g) => g.map(int.parse))
        .map((l) => l.toList());

    setState(() => levels = all.toList());
    setState(() => messages = rm.split(','));
  }

  done() {
    time = 0;
    timer.stop();
    sv('R');
  }

  mv(i) => setState(() {
        if (items.length < 6) add(i);
        if (items.length == 6) done();
      });

  bar() => wr(menu);
  bhr() => wr(header);
  bi(s) => info(s);
  bb(i) => render(board[i]);
  bm(i) => info(messages[i]);
  wr(c) => Row(children: c);
  bbr(i) => wr(render(board[i]));

  rs() => setState(() => level = 0);
  sv(v) => setState(() => view = v);
  st(t) => setState(() => type = t);

  sl() => 'Level $level/${levels.length}';
  si() => 'Time $time s';
  ss() => 'Score: $points / ${items.length}';
  sw() => 'Total: $win / ${levels.length * 6}';

  tnum() => st('N');
  tfig() => st('F');
  tchr() => st('C');
  R(n) => rootBundle.loadString('assets/$n.txt');

  @override
  Widget build(BuildContext ctx) {
    prepare();
    width = MediaQuery.of(ctx).size.width / 3;

    return Scaffold(body: body);
  }
}
