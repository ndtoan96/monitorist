import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReactiveTextField extends StatefulWidget {
  final int value;
  final void Function(int) setValue;
  final bool readOnly;

  const ReactiveTextField({
    super.key,
    required this.value,
    required this.setValue,
    this.readOnly = false,
  });

  @override
  State<ReactiveTextField> createState() => _ReactiveTextFieldState();
}

class _ReactiveTextFieldState extends State<ReactiveTextField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _textController.text = widget.value.toString();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textController.text = widget.value.toString();
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _focusNode.unfocus();
        }
      },
      child: TextField(
        readOnly: widget.readOnly,
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          isDense: true,
        ),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (value) {
          final brightness = int.tryParse(value);
          if (brightness != null) {
            widget.setValue(brightness.clamp(0, 100));
          } else {
            _textController.text = widget.value.toString();
          }
        },
      ),
    );
  }
}
