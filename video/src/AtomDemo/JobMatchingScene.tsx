import React from "react";
import {
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import {
  Briefcase,
  Building,
  MapPin,
  DollarSign,
  CheckCircle2,
  Send,
  Zap,
} from "lucide-react";
import { ATOM_THEME } from "./types";

export const JobMatchingScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance
  const cardScale = spring({
    frame,
    fps,
    config: { damping: 14 },
  });

  // Score counter animation
  const matchScore = Math.min(
    96,
    Math.round(
      interpolate(frame, [15, 60], [40, 96], {
        extrapolateLeft: "clamp",
        extrapolateRight: "clamp",
      })
    )
  );

  // Apply button state change
  const isApplied = frame > 75;
  const buttonSpring = spring({
    frame: frame - 75,
    fps,
    config: { damping: 12 },
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
          width: 800,
          height: 800,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(37, 99, 235, 0.22) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(90px)",
          bottom: "10%",
          left: "15%",
        }}
      />

      {/* Header */}
      <div
        style={{
          textAlign: "center",
          marginBottom: 40,
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
            backgroundColor: "rgba(37, 99, 235, 0.15)",
            border: "1px solid rgba(37, 99, 235, 0.3)",
            color: "#60A5FA",
            fontSize: 16,
            fontWeight: 700,
            marginBottom: 14,
          }}
        >
          <Zap size={18} />
          <span>TÍNH NĂNG ĐỘT PHÁ #3</span>
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
          Thuật Toán Khớp Việc Thông Minh & Ứng Tuyển 1 Chạm
        </h2>
        <p
          style={{
            fontSize: 22,
            color: ATOM_THEME.textSecondary,
            marginTop: 10,
          }}
        >
          Tối ưu tỷ lệ trúng tuyển dựa trên kỹ năng thực chiến và văn hóa doanh nghiệp
        </p>
      </div>

      {/* Main Job Card Mockup */}
      <div
        style={{
          width: "100%",
          maxWidth: 1050,
          background: "rgba(17, 24, 39, 0.85)",
          backdropFilter: "blur(20px)",
          borderRadius: 28,
          border: "1px solid rgba(255, 255, 255, 0.12)",
          padding: 40,
          boxShadow: "0 30px 60px rgba(0, 0, 0, 0.6)",
          zIndex: 10,
          transform: `scale(${cardScale})`,
          opacity: cardScale,
        }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "flex-start",
            borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
            paddingBottom: 28,
            marginBottom: 28,
          }}
        >
          <div style={{ display: "flex", gap: 20 }}>
            <div
              style={{
                width: 64,
                height: 64,
                borderRadius: 18,
                background: "linear-gradient(135deg, #2563EB 0%, #1D4ED8 100%)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <Briefcase size={32} color="#FFFFFF" />
            </div>

            <div>
              <h3
                style={{
                  fontSize: 28,
                  fontWeight: 800,
                  color: "#FFFFFF",
                  margin: 0,
                }}
              >
                Flutter Mobile Software Engineer (Junior / Mid)
              </h3>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 20,
                  marginTop: 8,
                  color: ATOM_THEME.textSecondary,
                  fontSize: 16,
                }}
              >
                <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <Building size={16} /> TechVanguard Corp
                </span>
                <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <MapPin size={16} /> Hồ Chí Minh (Hybrid)
                </span>
                <span
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 6,
                    color: "#34D399",
                    fontWeight: 700,
                  }}
                >
                  <DollarSign size={16} /> 15.000.000 - 25.000.000 VNĐ
                </span>
              </div>
            </div>
          </div>

          {/* Match Score Badge */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              padding: "16px 24px",
              borderRadius: 20,
              background: "rgba(16, 185, 129, 0.15)",
              border: "1px solid rgba(16, 185, 129, 0.3)",
              boxShadow: "0 0 25px rgba(16, 185, 129, 0.25)",
            }}
          >
            <div
              style={{
                fontSize: 42,
                fontWeight: 900,
                color: "#10B981",
                letterSpacing: -1,
                lineHeight: 1,
              }}
            >
              {matchScore}%
            </div>
            <div
              style={{
                color: "#34D399",
                fontSize: 13,
                fontWeight: 700,
                textTransform: "uppercase",
                marginTop: 6,
              }}
            >
              Độ Khớp Hồ Sơ
            </div>
          </div>
        </div>

        {/* Matched Breakdown */}
        <div style={{ marginBottom: 32 }}>
          <div
            style={{
              color: ATOM_THEME.textPrimary,
              fontWeight: 700,
              fontSize: 16,
              marginBottom: 12,
            }}
          >
            Phân tích Kỹ năng Yêu cầu từ Nhà Tuyển Dụng:
          </div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 10 }}>
            {[
              { label: "Flutter / Dart", status: "MATCHED" },
              { label: "State Management (Provider/Bloc)", status: "MATCHED" },
              { label: "RESTful API Integration", status: "MATCHED" },
              { label: "Git Workflow & PR Review", status: "MATCHED" },
              { label: "CI/CD & App Store Release", status: "IN_PROGRESS" },
            ].map((skill, index) => (
              <span
                key={index}
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: 6,
                  padding: "8px 16px",
                  borderRadius: 999,
                  backgroundColor:
                    skill.status === "MATCHED"
                      ? "rgba(16, 185, 129, 0.15)"
                      : "rgba(245, 158, 11, 0.15)",
                  color:
                    skill.status === "MATCHED" ? "#34D399" : "#FBBF24",
                  fontSize: 14,
                  fontWeight: 600,
                  border: `1px solid ${
                    skill.status === "MATCHED"
                      ? "rgba(16, 185, 129, 0.3)"
                      : "rgba(245, 158, 11, 0.3)"
                  }`,
                }}
              >
                <CheckCircle2 size={16} />
                {skill.label}
              </span>
            ))}
          </div>
        </div>

        {/* Action Button */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <span style={{ color: ATOM_THEME.textMuted, fontSize: 15 }}>
            ⚡ Hệ thống tự động chọn CV tối ưu nhất của bạn kèm báo cáo bằng chứng code
          </span>

          <div
            style={{
              padding: "16px 36px",
              borderRadius: 999,
              backgroundColor: isApplied ? "#10B981" : "#2563EB",
              color: "#FFFFFF",
              fontSize: 18,
              fontWeight: 700,
              display: "flex",
              alignItems: "center",
              gap: 12,
              boxShadow: isApplied
                ? "0 10px 30px rgba(16, 185, 129, 0.4)"
                : "0 10px 30px rgba(37, 99, 235, 0.4)",
              transform: isApplied
                ? `scale(${interpolate(buttonSpring, [0, 1], [0.95, 1])})`
                : "none",
            }}
          >
            {isApplied ? (
              <>
                <CheckCircle2 size={22} />
                <span>Đã nộp hồ sơ thành công! (Viewed)</span>
              </>
            ) : (
              <>
                <Send size={20} />
                <span>Ứng tuyển ngay bằng 1 chạm</span>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

