import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class Toolbar extends StatelessWidget {
  final QuillController quillController;

  const Toolbar({
    Key? key,
    required this.quillController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuillToolbar.basic(
        showHeaderStyle: false,
        showCodeBlock: false,
        showIndent: false,
        showListNumbers: false,
        showListCheck: false,
        showBoldButton: true,
        showBackgroundColorButton: false,
        showLink: false,
        showQuote: false,
        showUnderLineButton: true,
        showItalicButton: true,
        showUndo: false,
        showRedo: false,
        showInlineCode: false,
        showImageButton: false,
        showVideoButton: false,
        showClearFormat: false,
        showStrikeThrough: false,
        controller: quillController);
  }
}
