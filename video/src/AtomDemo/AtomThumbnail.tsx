import React from "react";
import { Brain, Code2, Target, Globe } from "lucide-react";
import { ATOM_THEME } from "./types";

export const AtomThumbnail: React.FC = () => {
  return (
    <div
      style={{
        width: 1920,
        height: 1080,
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
      {/* Background glow orbs */}
      <div
        style={{
          position: "absolute",
          width: 1000,
          height: 1000,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(37, 99, 235, 0.35) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(100px)",
        }}
      />
      <div
        style={{
          position: "absolute",
          width: 600,
          height: 600,
          right: "5%",
          top: "10%",
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(16, 185, 129, 0.25) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(90px)",
        }}
      />

      {/* Main card */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          zIndex: 10,
        }}
      >
        {/* Logo Badge 'A' */}
        <div
          style={{
            width: 140,
            height: 140,
            borderRadius: 36,
            background: "linear-gradient(135deg, #3B82F6 0%, #1D4ED8 100%)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            boxShadow:
              "0 25px 60px rgba(37, 99, 235, 0.6), inset 0 2px 4px rgba(255, 255, 255, 0.4)",
            border: "2px solid rgba(255, 255, 255, 0.25)",
            marginBottom: 32,
          }}
        >
          <span
            style={{
              color: "#FFFFFF",
              fontSize: 80,
              fontWeight: 900,
            }}
          >
            A
          </span>
        </div>

        <h1
          style={{
            fontSize: 100,
            fontWeight: 900,
            color: "#FFFFFF",
            letterSpacing: -3,
            margin: 0,
            textAlign: "center",
          }}
        >
          ATOM
        </h1>

        <p
          style={{
            fontSize: 34,
            fontWeight: 600,
            color: "#93C5FD",
            marginTop: 16,
            marginBottom: 44,
            textAlign: "center",
          }}
        >
          Nền Tảng Hướng Nghiệp & Tuyển Dụng Thông Minh Bằng AI
        </p>

        {/* Feature Badges */}
        <div style={{ display: "flex", gap: 18 }}>
          {[
            {
              icon: <Brain size={24} color="#60A5FA" />,
              text: "AI Career Coach (Qwen 2B)",
            },
            {
              icon: <Code2 size={24} color="#34D399" />,
              text: "3-Tier Skill Extraction (Git Commits)",
            },
            {
              icon: <Target size={24} color="#F472B6" />,
              text: "Thuật toán Khớp việc 96%",
            },
            {
              icon: <Globe size={24} color="#A78BFA" />,
              text: "atom-web-ten.vercel.app",
            },
          ].map((item, idx) => (
            <div
              key={idx}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 12,
                padding: "16px 26px",
                borderRadius: 999,
                backgroundColor: "rgba(17, 24, 39, 0.85)",
                border: "1px solid rgba(255, 255, 255, 0.15)",
                backdropFilter: "blur(12px)",
                color: "#FFFFFF",
                fontSize: 18,
                fontWeight: 700,
                boxShadow: "0 15px 35px rgba(0, 0, 0, 0.4)",
              }}
            >
              {item.icon}
              <span>{item.text}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
