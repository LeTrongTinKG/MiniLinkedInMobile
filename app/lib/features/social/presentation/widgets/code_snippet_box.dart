import 'package:flutter/material.dart';

/// Hộp Code Snippet mô phỏng IDE theo thiết kế v0.
class CodeSnippetBox extends StatelessWidget {
  final String fileName;
  final String language;
  final String code;
  final VoidCallback? onInsert;
  final VoidCallback? onClose;

  const CodeSnippetBox({
    super.key,
    this.fileName = 'main.dart',
    this.language = 'Dart',
    this.code = 'class MiniLinkedInApp extends StatelessWidget {\n'
        '  const MiniLinkedInApp({super.key});\n\n'
        '  @override\n'
        '  Widget build(BuildContext context) => const Scaffold();\n'
        '}',
    this.onInsert,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    language,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                ),
                if (onInsert != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onInsert,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Chèn',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                if (onClose != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onClose,
                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.45,
                  color: Color(0xFFBFDBFE),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
