import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';

/// Shows a plain-text legal document. Supports "## " headings and "- "
/// bullets; a leading "# " title line is skipped (the title is shown above).
class LegalDocScreen extends StatelessWidget {
  const LegalDocScreen({super.key, required this.title, required this.text});

  final String title;
  final String text;

  static const _bodyStyle = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  List<Widget> _blocks() {
    final blocks = <Widget>[];
    for (final raw in text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('# ')) continue;
      if (line.startsWith('## ')) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              line.substring(3),
              style: AppText.rowLabel.copyWith(color: AppColors.gold),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        blocks.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              const Text('•', style: _bodyStyle),
              Expanded(child: Text(line.substring(2), style: _bodyStyle)),
            ],
          ),
        );
      } else {
        blocks.add(Text(line, style: _bodyStyle));
      }
    }
    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: AppPage(
          children: [Text(title, style: AppText.title), ..._blocks()],
        ),
      ),
    );
  }
}
