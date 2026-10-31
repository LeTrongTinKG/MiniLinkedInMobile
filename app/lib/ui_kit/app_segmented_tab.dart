import 'package:flutter/material.dart';
import 'ui_tokens.dart';

/// Bộ chuyển đổi tab dạng pill phỏng theo mẫu 21st.dev Premium Auth & phong cách Clay.
class AppSegmentedTab extends StatelessWidget {
  const AppSegmentedTab({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.height = 48.0,
  }) : assert(tabs.length >= 2, 'Cần ít nhất 2 tab để tạo SegmentedTab');

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: UiTokens.muted,
        borderRadius: BorderRadius.circular(UiTokens.radiusDock),
        border: Border.all(color: UiTokens.border, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth) / tabs.length;

          return Stack(
            children: [
              // Thanh trượt chỉ báo tab đang chọn
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: UiTokens.background,
                    borderRadius: BorderRadius.circular(UiTokens.radiusPill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Danh sách các nút tab
              Row(
                children: List.generate(tabs.length, (i) {
                  final isSelected = i == selectedIndex;

                  return Expanded(
                    child: Semantics(
                      label: tabs[i],
                      selected: isSelected,
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTabChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? UiTokens.primary
                                  : UiTokens.mutedForeground,
                            ),
                            child: Text(
                              tabs[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
