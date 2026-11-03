import React from "react";
import {
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Globe } from "lucide-react";
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

export const OutroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const scale = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 90 },
  });

  const cardsY = interpolate(frame, [20, 50], [40, 0], {
    extrapolateRight: "clamp",
  });
  const cardsOpacity = interpolate(frame, [20, 50], [0, 1], {
    extrapolateRight: "clamp",
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
        position: "relative",
        overflow: "hidden",
        fontFamily: "system-ui, -apple-system, sans-serif",
      }}
    >
      {/* Background glow */}
      <div
        style={{
          position: "absolute",
          width: 900,
          height: 900,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(37, 99, 235, 0.28) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(100px)",
        }}
      />

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          zIndex: 10,
          transform: `scale(${scale})`,
        }}
      >
        {/* Brand Icon */}
        <div
          style={{
            width: 100,
            height: 100,
            borderRadius: 28,
            background: "linear-gradient(135deg, #3B82F6 0%, #1D4ED8 100%)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            boxShadow: "0 20px 50px rgba(37, 99, 235, 0.5)",
            border: "1px solid rgba(255, 255, 255, 0.2)",
            marginBottom: 20,
          }}
        >
          <span
            style={{
              color: "#FFFFFF",
              fontSize: 56,
              fontWeight: 900,
            }}
          >
            A
          </span>
        </div>

        <h1
          style={{
            fontSize: 72,
            fontWeight: 900,
            letterSpacing: -2,
            color: ATOM_THEME.textPrimary,
            margin: 0,
            textAlign: "center",
          }}
        >
          Bứt Phá Sự Nghiệp Công Nghệ Cùng Atom
        </h1>

        <p
          style={{
            fontSize: 26,
            color: ATOM_THEME.textSecondary,
            marginTop: 12,
            marginBottom: 36,
            textAlign: "center",
            maxWidth: 800,
          }}
        >
          Đồng hành cùng hàng nghìn sinh viên công nghệ và nhà tuyển dụng hàng đầu
        </p>

        {/* Links Cards */}
        <div
          style={{
            display: "flex",
            gap: 20,
            opacity: cardsOpacity,
            transform: `translateY(${cardsY}px)`,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 14,
              padding: "18px 28px",
              borderRadius: 20,
              background: "rgba(17, 24, 39, 0.8)",
              border: "1px solid rgba(37, 99, 235, 0.4)",
              boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
              color: "#FFFFFF",
            }}
          >
            <div
              style={{
                background: "#2563EB",
                borderRadius: 12,
                padding: 10,
              }}
            >
              <Globe size={24} color="#FFFFFF" />
            </div>
            <div>
              <div style={{ fontSize: 13, color: "#9CA3AF", fontWeight: 600 }}>
                Trải nghiệm trực tuyến
              </div>
              <div style={{ fontSize: 20, fontWeight: 800, color: "#60A5FA" }}>
                atom-web-ten.vercel.app
              </div>
            </div>
          </div>

          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 14,
              padding: "18px 28px",
              borderRadius: 20,
              background: "rgba(17, 24, 39, 0.8)",
              border: "1px solid rgba(255, 255, 255, 0.12)",
              boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
              color: "#FFFFFF",
            }}
          >
            <div
              style={{
                background: "#1F2937",
                borderRadius: 12,
                padding: 10,
              }}
            >
              <GithubIcon size={24} color="#FFFFFF" />
            </div>
            <div>
              <div style={{ fontSize: 13, color: "#9CA3AF", fontWeight: 600 }}>
                Open-Source Repository
              </div>
              <div style={{ fontSize: 20, fontWeight: 800, color: "#FFFFFF" }}>
                github.com/LeTrongTinKG/MiniLinkedInMobile
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
