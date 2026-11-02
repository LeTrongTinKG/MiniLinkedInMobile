import 'package:flutter/material.dart';
import 'package:app/ui_kit/curved_drawer_painter.dart';
import 'package:app/ui_kit/curved_menu_button.dart';
import 'package:app/ui_kit/curved_nav_item.dart';
/// CurvedDrawer - Menu trượt cạnh phải với viền cong Bezier động chuẩn 21st.dev.
class CurvedDrawer extends StatefulWidget {
  final List<CurvedNavItem> items;
  final Widget? footer;
  const CurvedDrawer({super.key, required this.items, this.footer});
  static Future<void> show(
    BuildContext context, {
    required List<CurvedNavItem> items,
    Widget? footer,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (_, __, ___) => CurvedDrawer(items: items, footer: footer),
    );
  }
  @override
  State<CurvedDrawer> createState() => _CurvedDrawerState();
}
class _CurvedDrawerState extends State<CurvedDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slideAnim;
  late final Animation<double> _curveAnim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Cubic(0.76, 0.0, 0.24, 1.0),
    );
    _curveAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  Future<void> _close() async {
    await _ctrl.reverse();
    if (mounted) Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final fgColor = isDark ? Colors.white : Colors.black;
    final width = (MediaQuery.of(context).size.width * 0.88).clamp(300.0, 480.0);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(onTap: _close, child: Container(color: Colors.transparent)),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final offset = (1.0 - _slideAnim.value) * (width + 120);
              return Positioned(
                right: -offset,
                top: 0,
                bottom: 0,
                width: width,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -99,
                      top: 0,
                      bottom: 0,
                      width: 100,
                      child: CustomPaint(
                        painter: CurvedDrawerPainter(
                          progress: _curveAnim.value,
                          color: bgColor,
                        ),
                      ),
                    ),
                    Container(
                      color: bgColor,
                      padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(fgColor),
                            const SizedBox(height: 16),
                            Expanded(child: _buildItemList(fgColor)),
                            widget.footer ?? _buildFooter(fgColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(Color fg) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NAVIGATION',
                style: TextStyle(
                  color: fg.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CurvedMenuButton(isActive: true, onTap: _close),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: fg.withValues(alpha: 0.15), height: 1, thickness: 1),
        ],
      );
  Widget _buildItemList(Color fg) => ListView.separated(
        itemCount: widget.items.length,
        separatorBuilder: (_, __) =>
            Divider(color: fg.withValues(alpha: 0.15), height: 1, thickness: 1),
        itemBuilder: (ctx, i) {
          final item = widget.items[i];
          return InkWell(
            onTap: () => _close().then((_) => item.onTap()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                children: [
                  Text(
                    '${i + 1}.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w200,
                      color: fg.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.0,
                        color: fg,
                      ),
                    ),
                  ),
                  if (item.icon != null)
                    Icon(item.icon, size: 20, color: fg.withValues(alpha: 0.3)),
                ],
              ),
            ),
          );
        },
      );
  Widget _buildFooter(Color fg) => Column(
        children: [
          Divider(color: fg.withValues(alpha: 0.15), height: 1, thickness: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _foot(Icons.link_rounded, fg),
              _foot(Icons.code_rounded, fg),
              _foot(Icons.language_rounded, fg),
              _foot(Icons.share_outlined, fg),
            ],
          ),
        ],
      );
  Widget _foot(IconData icon, Color color) => IconButton(
        icon: Icon(icon, color: color.withValues(alpha: 0.7), size: 22),
        onPressed: () {},
      );
}
