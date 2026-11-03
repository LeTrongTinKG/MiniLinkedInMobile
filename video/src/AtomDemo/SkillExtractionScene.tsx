import React from "react";
import {
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import {
  FileText,
  CheckCircle2,
  ShieldCheck,
  Award,
  Zap,
} from "lucide-react";
import { ATOM_THEME } from "./types";

const GithubIcon: React.FC<{ size?: number; color?: string }> = ({
  size = 24,
  color = "currentColor",
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 24 24"
    fill="none"
    stroke={color}
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
  >
    <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" />
    <path d="M9 18c-4.51 2-5-2-7-2" />
  </svg>
);

export const SkillExtractionScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance
  const cardSlide = spring({
    frame,
    fps,
    config: { damping: 14 },
  });

  const scanProgress = interpolate(frame, [20, 80], [0, 100], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const skillsEntrance = spring({
    frame: frame - 40,
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
      {/* Background glow */}
      <div
        style={{
          position: "absolute",
          width: 700,
          height: 700,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(16, 185, 129, 0.2) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(90px)",
          top: "10%",
          left: "5%",
        }}
      />

      {/* Header Section */}
      <div
        style={{
          textAlign: "center",
          marginBottom: 44,
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
            backgroundColor: "rgba(16, 185, 129, 0.15)",
            border: "1px solid rgba(16, 185, 129, 0.3)",
            color: "#34D399",
            fontSize: 16,
            fontWeight: 700,
            marginBottom: 16,
          }}
        >
          <Zap size={18} />
          <span>TÍNH NĂNG ĐỘT PHÁ #1</span>
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
          Trích Xuất Kỹ Năng Đa Tầng & Xác Thực Bằng Git Commits
        </h2>
        <p
          style={{
            fontSize: 22,
            color: ATOM_THEME.textSecondary,
            marginTop: 10,
          }}
        >
          Chống gian lận CV thông qua phân tích cú pháp AST, Manifest và tần suất commit thực tế
        </p>
      </div>

      {/* Main Content: Split 2 columns */}
      <div
        style={{
          display: "flex",
          gap: 40,
          width: "100%",
          maxWidth: 1500,
          zIndex: 10,
        }}
      >
        {/* Left Column: CV & Git Scanner */}
        <div
          style={{
            flex: 1,
            background: "rgba(17, 24, 39, 0.8)",
            backdropFilter: "blur(16px)",
            borderRadius: 24,
            border: "1px solid rgba(255, 255, 255, 0.12)",
            padding: 36,
            boxShadow: "0 25px 50px -12px rgba(0, 0, 0, 0.5)",
            transform: `translateX(${interpolate(cardSlide, [0, 1], [-60, 0])}px)`,
            opacity: cardSlide,
            position: "relative",
            overflow: "hidden",
          }}
        >
          {/* Laser scan line */}
          <div
            style={{
              position: "absolute",
              top: `${scanProgress}%`,
              left: 0,
              right: 0,
              height: 3,
              background:
                "linear-gradient(90deg, transparent 0%, #10B981 50%, transparent 100%)",
              boxShadow: "0 0 15px #10B981",
              zIndex: 5,
            }}
          />

          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
              paddingBottom: 20,
              marginBottom: 24,
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
              <div
                style={{
                  background: "#2563EB",
                  padding: 12,
                  borderRadius: 14,
                }}
              >
                <FileText size={26} color="#FFFFFF" />
              </div>
              <div>
                <h3
                  style={{
                    color: ATOM_THEME.textPrimary,
                    fontSize: 22,
                    fontWeight: 700,
                    margin: 0,
                  }}
                >
                  NguyenVanA_Resume.pdf
                </h3>
                <span
                  style={{
                    color: ATOM_THEME.textMuted,
                    fontSize: 15,
                  }}
                >
                  Phân tích Regex Lookaround + Manifest Scan
                </span>
              </div>
            </div>
            <span
              style={{
                backgroundColor: "rgba(16, 185, 129, 0.15)",
                color: "#10B981",
                padding: "6px 14px",
                borderRadius: 999,
                fontSize: 14,
                fontWeight: 700,
              }}
            >
              {scanProgress < 100 ? "Scanning..." : "Completed ✓"}
            </span>
          </div>

          {/* GitHub Linked Box */}
          <div
            style={{
              background: "rgba(31, 41, 55, 0.5)",
              border: "1px solid rgba(255, 255, 255, 0.08)",
              borderRadius: 16,
              padding: 20,
              display: "flex",
              alignItems: "center",
              gap: 16,
            }}
          >
            <GithubIcon size={36} color="#F9FAFB" />
            <div style={{ flex: 1 }}>
              <div
                style={{
                  color: "#FFFFFF",
                  fontWeight: 700,
                  fontSize: 17,
                }}
              >
                github.com/nguyenvana/flutter-ecommerce
              </div>
              <div
                style={{
                  color: "#9CA3AF",
                  fontSize: 14,
                  marginTop: 4,
                }}
              >
                Đã kiểm chứng: 142 commits, AST phân tích State Management
              </div>
            </div>
            <ShieldCheck size={28} color="#10B981" />
          </div>

          <div
            style={{
              marginTop: 24,
              padding: 16,
              borderRadius: 12,
              background: "rgba(37, 99, 235, 0.08)",
              border: "1px dashed rgba(37, 99, 235, 0.3)",
              color: "#93C5FD",
              fontSize: 15,
              lineHeight: 1.5,
            }}
          >
            💡 <b>Cơ chế Anti-Gaming:</b> Bỏ qua các kỹ năng tự ghi nếu không có commit thực tế hoặc bằng chứng đóng góp code.
          </div>
        </div>

        {/* Right Column: 3-Tier Confidence Badges */}
        <div
          style={{
            flex: 1,
            display: "flex",
            flexDirection: "column",
            gap: 16,
            opacity: Math.max(0, skillsEntrance),
            transform: `translateX(${interpolate(skillsEntrance, [0, 1], [60, 0])}px)`,
          }}
        >
          {[
            {
              skill: "Flutter & Dart",
              tier: "VERIFIED_BY_CODE",
              badgeColor: "#10B981",
              bgBadge: "rgba(16, 185, 129, 0.15)",
              icon: <ShieldCheck size={18} color="#10B981" />,
              confidence: "100% Tin cậy",
              desc: "Tìm thấy 12 file Dart, pubspec.yaml có provider & dio, 142 commits",
            },
            {
              skill: "FastAPI & Python",
              tier: "VERIFIED_BY_CODE",
              badgeColor: "#10B981",
              bgBadge: "rgba(16, 185, 129, 0.15)",
              icon: <ShieldCheck size={18} color="#10B981" />,
              confidence: "95% Tin cậy",
              desc: "Trích xuất từ requirements.txt và repository backend AI cá nhân",
            },
            {
              skill: "Node.js & Express",
              tier: "ENDORSED",
              badgeColor: "#3B82F6",
              bgBadge: "rgba(59, 130, 246, 0.15)",
              icon: <Award size={18} color="#3B82F6" />,
              confidence: "85% Đã xác thực",
              desc: "Được 3 thành viên trong nhóm dự án xác thực năng lực chuyên môn",
            },
            {
              skill: "Docker & CI/CD",
              tier: "SELF_CLAIMED",
              badgeColor: "#9CA3AF",
              bgBadge: "rgba(156, 163, 175, 0.15)",
              icon: <CheckCircle2 size={18} color="#9CA3AF" />,
              confidence: "Tự khai báo",
              desc: "Kỹ năng được sinh viên đưa vào mục tự học trên hồ sơ cá nhân",
            },
          ].map((item, idx) => (
            <div
              key={idx}
              style={{
                background: "rgba(17, 24, 39, 0.8)",
                border: "1px solid rgba(255, 255, 255, 0.1)",
                borderRadius: 18,
                padding: "20px 24px",
                display: "flex",
                flexDirection: "column",
                gap: 8,
              }}
            >
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                }}
              >
                <span
                  style={{
                    color: "#FFFFFF",
                    fontSize: 20,
                    fontWeight: 800,
                  }}
                >
                  {item.skill}
                </span>

                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 6,
                    padding: "6px 14px",
                    borderRadius: 999,
                    backgroundColor: item.bgBadge,
                    color: item.badgeColor,
                    fontSize: 13,
                    fontWeight: 700,
                  }}
                >
                  {item.icon}
                  <span>{item.confidence}</span>
                </div>
              </div>

              <div
                style={{
                  color: ATOM_THEME.textSecondary,
                  fontSize: 14,
                  lineHeight: 1.4,
                }}
              >
                {item.desc}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
