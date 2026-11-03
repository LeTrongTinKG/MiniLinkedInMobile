import React from "react";
import {
  OffthreadVideo,
  staticFile,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Sparkles, Globe, Shield, CheckCircle2 } from "lucide-react";
import { ATOM_THEME } from "./types";

interface LiveScreenSceneProps {
  videoFile: string;
  trimBeforeSeconds?: number;
  title: string;
  category: string;
  highlights: Array<{
    startFrame: number;
    endFrame: number;
    icon?: string;
    title: string;
    subtitle: string;
    color?: string;
  }>;
}

export const LiveScreenScene: React.FC<LiveScreenSceneProps> = ({
  videoFile,
  trimBeforeSeconds = 0,
  title,
  category,
  highlights,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance spring animation for the browser shell
  const shellScale = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 95 },
  });

  const trimBeforeFrames = Math.round(trimBeforeSeconds * fps);

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
          width: 900,
          height: 900,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(37, 99, 235, 0.22) 0%, rgba(11, 15, 25, 0) 70%)",
          filter: "blur(110px)",
          top: "5%",
        }}
      />

      {/* Top Banner Tag */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 12,
          marginBottom: 20,
          zIndex: 10,
        }}
      >
        <span
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 6,
            padding: "6px 14px",
            borderRadius: 999,
            backgroundColor: "rgba(37, 99, 235, 0.2)",
            border: "1px solid rgba(37, 99, 235, 0.4)",
            color: "#60A5FA",
            fontSize: 14,
            fontWeight: 700,
          }}
        >
          <Sparkles size={16} /> {category}
        </span>
        <h2
          style={{
            fontSize: 28,
            fontWeight: 800,
            color: "#FFFFFF",
            margin: 0,
            letterSpacing: -0.5,
          }}
        >
          {title}
        </h2>
      </div>

      {/* Device Mockup Shell (MacBook / Desktop Browser) */}
      <div
        style={{
          width: "90%",
          maxWidth: 1650,
          background: "#111827",
          borderRadius: 24,
          border: "1px solid rgba(255, 255, 255, 0.15)",
          boxShadow:
            "0 35px 80px -15px rgba(0, 0, 0, 0.8), 0 0 0 1px rgba(255, 255, 255, 0.08)",
          overflow: "hidden",
          transform: `scale(${shellScale})`,
          opacity: shellScale,
          zIndex: 10,
          position: "relative",
        }}
      >
        {/* Browser Top Bar */}
        <div
          style={{
            height: 44,
            backgroundColor: "#0F172A",
            borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
            display: "flex",
            alignItems: "center",
            padding: "0 18px",
            gap: 14,
          }}
        >
          {/* Traffic light buttons */}
          <div style={{ display: "flex", gap: 8 }}>
            <div
              style={{
                width: 12,
                height: 12,
                borderRadius: "50%",
                backgroundColor: "#EF4444",
              }}
            />
            <div
              style={{
                width: 12,
                height: 12,
                borderRadius: "50%",
                backgroundColor: "#F59E0B",
              }}
            />
            <div
              style={{
                width: 12,
                height: 12,
                borderRadius: "50%",
                backgroundColor: "#10B981",
              }}
            />
          </div>

          {/* URL Pill */}
          <div
            style={{
              flex: 1,
              maxWidth: 550,
              margin: "0 auto",
              backgroundColor: "rgba(255, 255, 255, 0.06)",
              borderRadius: 8,
              padding: "5px 14px",
              color: "#94A3B8",
              fontSize: 13,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
            }}
          >
            <Globe size={14} color="#60A5FA" />
            <span style={{ color: "#E2E8F0", fontWeight: 500 }}>
              https://atom-web-ten.vercel.app
            </span>
          </div>

          <div style={{ display: "flex", gap: 10 }}>
            <span
              style={{
                display: "flex",
                alignItems: "center",
                gap: 4,
                fontSize: 12,
                color: "#10B981",
                fontWeight: 600,
              }}
            >
              <Shield size={12} /> SSL Verified
            </span>
          </div>
        </div>

        {/* Video Player Box */}
        <div
          style={{
            position: "relative",
            width: "100%",
            height: 720,
            backgroundColor: "#000000",
            overflow: "hidden",
          }}
        >
          <OffthreadVideo
            src={staticFile(videoFile)}
            trimBefore={trimBeforeFrames}
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover",
            }}
          />

          {/* Dynamic Floating Highlights */}
          {highlights.map((h, i) => {
            if (frame < h.startFrame || frame > h.endFrame) return null;

            const badgeEnter = spring({
              frame: frame - h.startFrame,
              fps,
              config: { damping: 12 },
            });

            return (
              <div
                key={i}
                style={{
                  position: "absolute",
                  bottom: 32,
                  right: 36,
                  padding: "16px 24px",
                  borderRadius: 18,
                  backgroundColor: "rgba(17, 24, 39, 0.92)",
                  border: `1px solid ${h.color || "#3B82F6"}`,
                  backdropFilter: "blur(16px)",
                  boxShadow: `0 20px 40px rgba(0, 0, 0, 0.6), 0 0 25px ${
                    h.color ? `${h.color}40` : "rgba(37, 99, 235, 0.3)"
                  }`,
                  display: "flex",
                  alignItems: "center",
                  gap: 16,
                  zIndex: 20,
                  transform: `translateY(${interpolate(
                    badgeEnter,
                    [0, 1],
                    [20, 0]
                  )}px)`,
                  opacity: badgeEnter,
                }}
              >
                <div
                  style={{
                    width: 44,
                    height: 44,
                    borderRadius: 12,
                    backgroundColor: h.color || "#2563EB",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  <CheckCircle2 size={24} color="#FFFFFF" />
                </div>
                <div>
                  <div
                    style={{
                      color: "#FFFFFF",
                      fontSize: 18,
                      fontWeight: 800,
                    }}
                  >
                    {h.title}
                  </div>
                  <div
                    style={{
                      color: "#94A3B8",
                      fontSize: 14,
                      marginTop: 2,
                    }}
                  >
                    {h.subtitle}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

