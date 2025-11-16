import 'package:flutter/material.dart';

class QueryEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final Color? borderColor;

  const QueryEditor({
    super.key,
    required this.controller,
    this.hintText = 'Enter your code here...',
    this.readOnly = false,
    this.borderColor,
  });

  @override
  State<QueryEditor> createState() => _QueryEditorState();
}

class _QueryEditorState extends State<QueryEditor> {
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor ?? Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              readOnly: widget.readOnly,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontFamily: 'Monospace',
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Monospace',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          // Editor Status Bar
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  widget.readOnly ? 'PostgreSQL' : 'SQL',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!widget.readOnly)
                  IconButton(
                    icon: Icon(
                      Icons.clear_all,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      _focusNode.requestFocus();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Clear',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
