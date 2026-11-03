import React from "react";
import {
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Bot, User, Sparkles, Shield, Cpu } from "lucide-react";
import { ATOM_THEME } from "./types";

export const CareerCoachScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const userMsgProgress = spring({
    frame: frame - 15,
    fps,
    config: { damping: 14 },
  });

  const aiThinking = frame > 40 && frame < 75;

  const aiMsgProgress = spring({
    frame: frame - 75,
    fps,
    config: { damping: 14 },
  });

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        backgroundColor: ATOM_THEME.bg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "0 80px",
        position: "relative",
        overflow: "hidden",
        fontFamily: "system-ui, -apple-system, sans-serif",
      }}
    >
      {/* Background radial glow */}
      <div
        style={{
          position: "absolute",
          width: 700,
          height: 700,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(139, 92, 246, 0.2) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(90px)",
          top: "15%",
          right: "5%",
        }}
      />

      {/* Header */}
      <div
        style={{
          textAlign: "center",
          marginBottom: 36,
          zIndex: 10,
        }}
      >
        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 8,
            padding: "8px 18px",
            borderRadius: 999,
            backgroundColor: "rgba(139, 92, 246, 0.15)",
            border: "1px solid rgba(139, 92, 246, 0.3)",
            color: "#A78BFA",
            fontSize: 16,
            fontWeight: 700,
            marginBottom: 14,
          }}
        >
          <Sparkles size={18} />
          <span>TÍNH NĂNG ĐỘT PHÁ #2</span>
        </div>
        <h2
          style={{
            fontSize: 54,
            fontWeight: 900,
            margin: 0,
            color: ATOM_THEME.textPrimary,
            letterSpacing: -1,
          }}
        >
          AI Career Coach - Tư Vấn Lộ Trình Nghề Nghiệp 24/7
        </h2>
        <p
          style={{
            fontSize: 22,
            color: ATOM_THEME.textSecondary,
            marginTop: 10,
          }}
        >
          Mô hình Qwen 2B qua Ollama & 10 Intent Classification với 3 lớp Guardrails bảo mật
        </p>
      </div>

      {/* Chat Window Mockup */}
      <div
        style={{
          width: "100%",
          maxWidth: 1100,
          background: "rgba(17, 24, 39, 0.85)",
          backdropFilter: "blur(20px)",
          borderRadius: 24,
          border: "1px solid rgba(255, 255, 255, 0.12)",
          padding: 36,
          boxShadow: "0 25px 60px rgba(0, 0, 0, 0.6)",
          zIndex: 10,
          display: "flex",
          flexDirection: "column",
          gap: 24,
        }}
      >
        {/* Chat Header Bar */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
            paddingBottom: 16,
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
            <div
              style={{
                width: 44,
                height: 44,
                borderRadius: 14,
                background: "linear-gradient(135deg, #8B5CF6 0%, #6D28D9 100%)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <Bot size={24} color="#FFFFFF" />
            </div>
            <div>
              <div style={{ color: "#FFFFFF", fontWeight: 800, fontSize: 18 }}>
                Atom Career Coach AI
              </div>
              <div
                style={{
                  color: "#10B981",
                  fontSize: 13,
                  fontWeight: 600,
                  display: "flex",
                  alignItems: "center",
                  gap: 6,
                }}
              >
                <span
                  style={{
                    width: 8,
                    height: 8,
                    borderRadius: "50%",
                    backgroundColor: "#10B981",
                  }}
                />
                Trực tuyến • Model Qwen 2B Instruct Local
              </div>
            </div>
          </div>

          <div style={{ display: "flex", gap: 10 }}>
            <span
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                fontSize: 13,
                padding: "6px 12px",
                borderRadius: 8,
                backgroundColor: "rgba(255, 255, 255, 0.06)",
                color: "#E5E7EB",
              }}
            >
              <Cpu size={14} color="#A78BFA" /> Local Inference (Zero Cost)
            </span>
            <span
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                fontSize: 13,
                padding: "6px 12px",
                borderRadius: 8,
                backgroundColor: "rgba(16, 185, 129, 0.1)",
                color: "#34D399",
              }}
            >
              <Shield size={14} color="#34D399" /> 3-Tier Guardrails
            </span>
          </div>
        </div>

        {/* Message 1: User Prompt */}
        <div
          style={{
            alignSelf: "flex-end",
            maxWidth: "75%",
            display: "flex",
            gap: 14,
            alignItems: "flex-start",
            opacity: Math.max(0, userMsgProgress),
            transform: `translateY(${interpolate(userMsgProgress, [0, 1], [30, 0])}px)`,
          }}
        >
          <div
            style={{
              backgroundColor: "#2563EB",
              color: "#FFFFFF",
              padding: "18px 24px",
              borderRadius: "20px 20px 4px 20px",
              fontSize: 18,
              lineHeight: 1.5,
              fontWeight: 500,
              boxShadow: "0 10px 25px rgba(37, 99, 235, 0.3)",
            }}
          >
            "Mình là sinh viên năm 3 đã có nền tảng Flutter. Mình muốn tìm việc thực tập Mobile, mình cần bổ sung thêm những kỹ năng gì để CV nổi bật?"
          </div>
          <div
            style={{
              width: 40,
              height: 40,
              borderRadius: "50%",
              backgroundColor: "#374151",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              flexShrink: 0,
            }}
          >
            <User size={20} color="#F3F4F6" />
          </div>
        </div>

        {/* Thinking Indicator */}
        {aiThinking && (
          <div
            style={{
              alignSelf: "flex-start",
              display: "flex",
              gap: 8,
              padding: "14px 20px",
              borderRadius: 16,
              background: "rgba(31, 41, 55, 0.6)",
              color: "#A78BFA",
              fontSize: 15,
              fontWeight: 600,
            }}
          >
            <Sparkles size={18} /> Đang phân tích hồ sơ và khoảng cách kỹ năng (Skill Gap)...
          </div>
        )}

        {/* Message 2: AI Coach Response */}
        <div
          style={{
            alignSelf: "flex-start",
            maxWidth: "85%",
            display: "flex",
            gap: 14,
            alignItems: "flex-start",
            opacity: Math.max(0, aiMsgProgress),
            transform: `translateY(${interpolate(aiMsgProgress, [0, 1], [30, 0])}px)`,
          }}
        >
          <div
            style={{
              width: 42,
              height: 42,
              borderRadius: 14,
              background: "linear-gradient(135deg, #8B5CF6 0%, #6D28D9 100%)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              flexShrink: 0,
            }}
          >
            <Bot size={22} color="#FFFFFF" />
          </div>
          <div
            style={{
              backgroundColor: "rgba(31, 41, 55, 0.8)",
              border: "1px solid rgba(255, 255, 255, 0.1)",
              color: "#F3F4F6",
              padding: "20px 26px",
              borderRadius: "20px 20px 20px 4px",
              fontSize: 17,
              lineHeight: 1.6,
              boxShadow: "0 10px 25px rgba(0, 0, 0, 0.3)",
            }}
          >
            Chào bạn! Qua phân tích CV và GitHub commits của bạn:
            <ul style={{ margin: "10px 0", paddingLeft: 22 }}>
              <li>
                <b>Điểm mạnh:</b> Nền tảng Dart & UI Layout của bạn đạt mức tốt (
                <span style={{ color: "#34D399" }}>95% match</span>).
              </li>
              <li>
                <b>Khoảng cách cần bù đắp (Skill Gap):</b> Các vị trí thực tập hiện nay ưu tiên ứng viên nắm vững <b>Bloc / Riverpod</b> và đã từng tích hợp <b>Firebase / RESTful API</b>.
              </li>
              <li>
                <b>Lộ trình đề xuất:</b> Hoàn thành 1 project có offline caching & CI/CD deployment trong 2 tuần tới để tăng gấp đôi tỷ lệ gọi phỏng vấn!
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

