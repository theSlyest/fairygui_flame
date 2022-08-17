import 'package:flutter_test/flutter_test.dart';
import 'package:fariygui_flame/utils/ubb_parser.dart';

void main() {
  test('Parse a BB text', () {
    final UBBParser ubbParser = UBBParser();
    expect(
        ubbParser.parse(
            '[size=16]This[/size] [i]is[/i] a [b]test[/b] in [color=#990000]red[/color] [Sly]'),
        '<font size="16">This</font> <i>is</i> a <b>test</b> in <font color="#990000">red</font> [Sly]');
  });
}
