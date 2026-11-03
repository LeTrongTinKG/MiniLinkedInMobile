import React from "react";
import {
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Sparkles, Brain, Code2, Target, Smartphone } from "lucide-react";
import { ATOM_THEME } from "./types";

export const IntroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Animations
  const logoScale = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 100 },
  });

  const titleOpacity = interpolate(frame, [15, 35], [0, 1], {
    extrapolateRight: "clamp",
  });
  const titleY = interpolate(frame, [15, 35], [20, 0], {
    extrapolateRight: "clamp",
  });

  const subtitleOpacity = interpolate(frame, [30, 50], [0, 1], {
    extrapolateRight: "clamp",
  });

  const badgesProgress = spring({
    frame: frame - 45,
    fps,
    config: { damping: 15 },
  });

  // Glow pulse
  const glowScale = interpolate(
    Math.sin((frame / 15) * Math.PI),
    [-1, 1],
    [0.9, 1.1]
  );

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
        position: "relative",
        overflow: "hidden",
        fontFamily: "system-ui, -apple-system, sans-serif",
      }}
    >
      {/* Background ambient lighting */}
      <div
        style={{
          position: "absolute",
          width: 800,
          height: 800,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(37, 99, 235, 0.25) 0%, rgba(11, 15, 25, 0) 70%)",
          transform: `scale(${glowScale})`,
          filter: "blur(60px)",
          pointerEvents: "none",
        }}
      />

      <div
        style={{
          position: "absolute",
          width: 500,
          height: 500,
          right: "10%",
          top: "15%",
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(16, 185, 129, 0.15) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(80px)",
          pointerEvents: "none",
        }}
      />

      {/* Main Content */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          zIndex: 10,
        }}
      >
        {/* Glowing Badge 'A' */}
        <div
          style={{
            transform: `scale(${logoScale})`,
            marginBottom: 28,
            position: "relative",
          }}
        >
          <div
            style={{
              width: 120,
              height: 120,
              borderRadius: 32,
              background: "linear-gradient(135deg, #3B82F6 0%, #1D4ED8 100%)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              boxShadow:
                "0 20px 50px rgba(37, 99, 235, 0.5), inset 0 2px 4px rgba(255, 255, 255, 0.3)",
              border: "1px solid rgba(255, 255, 255, 0.2)",
            }}
          >
            <span
              style={{
                color: "#FFFFFF",
                fontSize: 68,
                fontWeight: 900,
                letterSpacing: -1,
                textShadow: "0 4px 12px rgba(0,0,0,0.3)",
              }}
            >
              A
            </span>
          </div>

          <div
            style={{
              position: "absolute",
              top: -8,
              right: -8,
              background: "#10B981",
              borderRadius: "50%",
              padding: 6,
              boxShadow: "0 0 15px rgba(16, 185, 129, 0.6)",
            }}
          >
            <Sparkles size={20} color="#FFFFFF" />
          </div>
        </div>

        {/* Brand Title */}
        <div
          style={{
            opacity: titleOpacity,
            transform: `translateY(${titleY}px)`,
            textAlign: "center",
          }}
        >
          <h1
            style={{
              fontSize: 84,
              fontWeight: 900,
              letterSpacing: -2,
              margin: 0,
              color: ATOM_THEME.textPrimary,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 16,
            }}
          >
            <span>Atom</span>
          </h1>
        </div>

        {/* Tagline */}
        <div
          style={{
            opacity: subtitleOpacity,
            marginTop: 16,
            maxWidth: 820,
            textAlign: "center",
          }}
        >
          <p
            style={{
              fontSize: 28,
              fontWeight: 500,
              color: ATOM_THEME.textSecondary,
              lineHeight: 1.4,
              margin: 0,
            }}
          >
            Nền tảng Tuyển dụng & Phát triển Sự nghiệp Thông minh
            <br />
            <span style={{ color: "#60A5FA", fontWeight: 600 }}>
              Dành riêng cho Sinh viên Công nghệ
            </span>
          </p>
        </div>

        {/* Feature Highlights Pills */}
        <div
          style={{
            opacity: Math.max(0, badgesProgress),
            transform: `translateY(${interpolate(badgesProgress, [0, 1], [30, 0])}px)`,
            display: "flex",
            gap: 16,
            marginTop: 44,
          }}
        >
          {[
            {
              icon: <Brain size={20} color="#60A5FA" />,
              label: "AI Career Coach (Qwen 2B)",
            },
            {
              icon: <Code2 size={20} color="#34D399" />,
              label: "3-Tier Skill Extraction (Git Commits)",
            },
            {
              icon: <Target size={20} color="#F472B6" />,
              label: "Smart Job Match",
            },
            {
              icon: <Smartphone size={20} color="#A78BFA" />,
              label: "Flutter Web & Mobile",
            },
          ].map((item, index) => (
            <div
              key={index}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 10,
                padding: "12px 20px",
                borderRadius: 999,
                background: "rgba(17, 24, 39, 0.75)",
                border: "1px solid rgba(255, 255, 255, 0.1)",
                backdropFilter: "blur(12px)",
                color: ATOM_THEME.textPrimary,
                fontSize: 16,
                fontWeight: 600,
                boxShadow: "0 10px 25px rgba(0, 0, 0, 0.3)",
              }}
            >
              {item.icon}
              <span>{item.label}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

