import 'package:flutter/material.dart';
import '../../domain/entities/reaction_kind.dart';

/// Màu chữ của nút Thích theo cảm xúc đang chọn.
Color reactionColor(ReactionKind? kind) {
  switch (kind) {
    case null:
      return const Color(0xFF65676B); // chưa thả: xám
    case ReactionKind.like:
      return const Color(0xFF2952CC);
    case ReactionKind.love:
      return const Color(0xFFE0245E);
    case ReactionKind.angry:
      return const Color(0xFFE9710F);
    case ReactionKind.haha:
    case ReactionKind.wow:
    case ReactionKind.sad:
      return const Color(0xFFD99A00);
  }
}
