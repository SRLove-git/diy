
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';

enum PixTextRichType { defaultType, orderedList, unorderedList }

enum PixOrderedListIndexType { decimal, lowerAlpha, lowerRoman }

class PixTextRich extends StatelessWidget {
  TextAlign? textAlign;
  MainAxisAlignment? mainAxisAlignment;
  List<Widget>? children;
  TextStyle? style;
  bool? isEnding;

  PixTextRich({super.key, this.textAlign, this.children, this.mainAxisAlignment, this.style, this.isEnding});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          clipBehavior: isEnding == true ? Clip.hardEdge : Clip.none,
          child: Column(
            crossAxisAlignment: getCrossAxisAlignment(),
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
            children: children?.map((e) {
                  if (e is PixTextItem) {
                    e.textAlign = textAlign;
                    e.textStyle = style;
                    e.width = constraints.minWidth > 0 ? constraints.minWidth : null;
                  } else if (e is PixListText) {
                    e.textAlign = textAlign;
                    e.textStyle = style;
                    e.width = constraints.minWidth > 0 ? constraints.minWidth : null;
                  }
                  return e;
                }).toList() ??
                [],
          ),
        ),
      );
    });
  }

  CrossAxisAlignment getCrossAxisAlignment() {
    switch (textAlign) {
      case TextAlign.left:
        return CrossAxisAlignment.start;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.justify:
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }
}

class PixListText extends StatelessWidget {
  PixOrderedListIndexType indexType = PixOrderedListIndexType.decimal;
  PixTextRichType type = PixTextRichType.defaultType;
  int startIndex = 1;
  TextStyle? indexStyle = TextStyle(fontSize: 12, color: Colors.black);
  List<Widget>? children;
  double? width;
  TextAlign? textAlign;
  TextStyle? textStyle;

  PixListText({
    super.key,
    this.indexType = PixOrderedListIndexType.decimal,
    this.startIndex = 1,
    this.type = PixTextRichType.defaultType,
    this.indexStyle,
    this.width,
    this.children,
    this.textAlign,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    int index = 0;
    return Column(
      crossAxisAlignment: getCrossAxisAlignment(),
      children: children?.map((e) {
            if (e is PixTextItem) {
              e.index = getText(index);
              e.type = type;
              e.indexStyle = indexStyle;
              e.width = width;
              e.textAlign = textAlign;
              e.textStyle = textStyle;
              index++;
            } else if (e is PixListText) {
              e.width = width;
              e.textAlign = textAlign;
              e.textStyle = textStyle;
            }
            return e;
          }).toList() ??
          [],
    );
  }

  CrossAxisAlignment getCrossAxisAlignment() {
    if (type != PixTextRichType.defaultType) {
      switch (textAlign) {
        case TextAlign.left:
          return CrossAxisAlignment.start;
        case TextAlign.right:
          return CrossAxisAlignment.end;
        case TextAlign.center:
          return CrossAxisAlignment.center;
        case TextAlign.justify:
          return CrossAxisAlignment.stretch;
        default:
          return CrossAxisAlignment.start;
      }
    }
    return CrossAxisAlignment.start;
  }

  String getText(int index) {
    if (type == PixTextRichType.orderedList) {
      return '${getIndex(index + startIndex)}.';
    } else if (type == PixTextRichType.unorderedList) {
      return '•';
    }
    return "";
  }

  String getIndex(int index) {
    if (indexType == PixOrderedListIndexType.decimal) {
      return index.toString();
    } else if (indexType == PixOrderedListIndexType.lowerAlpha) {
      return _numberToAlphabet(index);
    } else if (indexType == PixOrderedListIndexType.lowerRoman) {
      return _numberToRoman(index);
    }
    return "";
  }

  String _numberToAlphabet(int number) {
    if (number < 1 || number > 26) return number.toString();
    return String.fromCharCode(96 + number);
  }

  String _numberToRoman(int number) {
    if (number < 1 || number > 50) return number.toString();

    final romanNumerals = [
      '',
      'i',
      'ii',
      'iii',
      'iv',
      'v',
      'vi',
      'vii',
      'viii',
      'ix',
      'x',
      'xi',
      'xii',
      'xiii',
      'xiv',
      'xv',
      'xvi',
      'xvii',
      'xviii',
      'xix',
      'xx',
      'xxi',
      'xxii',
      'xxiii',
      'xxiv',
      'xxv',
      'xxvi',
      'xxvii',
      'xxviii',
      'xxix',
      'xxx',
      'xxxi',
      'xxxii',
      'xxxiii',
      'xxxiv',
      'xxxv',
      'xxxvi',
      'xxxvii',
      'xxxviii',
      'xxxix',
      'xl',
      'xli',
      'xlii',
      'xliii',
      'xliv',
      'xlv',
      'xlvi',
      'xlvii',
      'xlviii',
      'xlix',
      'l',
    ];

    return romanNumerals[number];
  }
}

class PixTextItem extends StatefulWidget {
  double? width;
  EdgeInsets margin = EdgeInsets.zero;
  List? children = [];
  PixTextRichType type = PixTextRichType.defaultType;
  String index = "";
  TextStyle? indexStyle = TextStyle(fontSize: 12, color: Colors.black);
  TextAlign? textAlign;
  TextStyle? textStyle;

  PixTextItem({
    super.key,
    this.margin = EdgeInsets.zero,
    this.children,
    this.index = "",
    this.type = PixTextRichType.defaultType,
    this.indexStyle,
    this.width,
    this.textAlign,
    this.textStyle,
  });

  @override
  State<PixTextItem> createState() => _PixTextItemState();
}

class _PixTextItemState extends State<PixTextItem> {
  List _children = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _children = widget.children ?? [];
  }

  @override
  void didUpdateWidget(covariant PixTextItem oldWidget) {
    if ((oldWidget.index != widget.index && widget.index.isNotEmpty) || oldWidget.width != widget.width) {
      if (mounted) {
        setState(() {});
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: max(widget.margin.left - (widget.index.isNotEmpty ? ((getStyle()?.fontSize ?? 14).w + 8.w) : 0), 0),
          top: widget.margin.top,
          bottom: widget.margin.bottom,
          right: widget.margin.right),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.index.isNotEmpty) Text(widget.index, style: getStyle()),
          if (widget.index.isNotEmpty)
            SizedBox(
              width: 2.w,
            ),
          Container(
            constraints: BoxConstraints(
                maxWidth: (widget.width ?? 0) > 0
                    ? ((widget.width ?? 0) -
                        widget.margin.left -
                        widget.margin.right +
                        (widget.index.isNotEmpty ? 4.w : 0))
                    : double.infinity),
            child: Text.rich(
              style: widget.textStyle,
              TextSpan(children: _children.map((e) => e is InlineSpan ? e : WidgetSpan(child: e)).toList()),
              textAlign: widget.textAlign,
            ),
          )
        ],
      ),
    );
  }

  TextStyle? getStyle() {
    if (widget.type == PixTextRichType.orderedList || widget.type == PixTextRichType.unorderedList) {
      TextStyle? style = widget.indexStyle ??
          widget.textStyle ??
          (_children.whereType<InlineSpan>().firstOrNull)?.style ??
          TextStyle(fontSize: 12, color: Colors.black);
      return TextStyle(
          fontSize: style.fontSize,
          color: style.color,
          fontWeight: style.fontWeight,
          fontFamily: style.fontFamily,
          height: style.height);
    }
    return null;
  }

  String getSPANText() {
    if (widget.type == PixTextRichType.orderedList || widget.type == PixTextRichType.unorderedList) {
      return (_children.whereType<TextSpan>().firstOrNull)?.text ?? '';
    }
    return '';
  }
}


