import React from "react";
import { OffthreadVideo, staticFile } from "remotion";
import { Monitor } from "lucide-react";
import { ATOM_THEME } from "./types";

interface ScreenRecordingProps {
  type?: "browser" | "phone";
  src?: string;
  title?: string;
}

export const ScreenRecordingPlayer: React.FC<ScreenRecordingProps> = ({
  type = "browser",
  src = "demo-screen.mp4",
  title = "Atom - https://atom-web-ten.vercel.app",
}) => {
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
        padding: 60,
        fontFamily: "system-ui, sans-serif",
      }}
    >
      {/* Device Mockup Shell */}
      <div
        style={{
          width: "100%",
          maxWidth: type === "browser" ? 1440 : 480,
          background: "#1E293B",
          borderRadius: 24,
          boxShadow:
            "0 35px 80px -15px rgba(0, 0, 0, 0.7), 0 0 0 1px rgba(255, 255, 255, 0.1)",
          overflow: "hidden",
          display: "flex",
          flexDirection: "column",
        }}
      >
        {/* Browser Top Bar */}
        {type === "browser" && (
          <div
            style={{
              height: 48,
              backgroundColor: "#0F172A",
              borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
              display: "flex",
              alignItems: "center",
              padding: "0 18px",
              gap: 12,
            }}
          >
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

            <div
              style={{
                flex: 1,
                maxWidth: 600,
                margin: "0 auto",
                backgroundColor: "rgba(255, 255, 255, 0.06)",
                borderRadius: 8,
                padding: "6px 14px",
                color: "#94A3B8",
                fontSize: 13,
                textAlign: "center",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: 8,
              }}
            >
              🔒 <span>{title}</span>
            </div>
          </div>
        )}

        {/* Video Canvas or Placeholder */}
        <div
          style={{
            position: "relative",
            width: "100%",
            aspectRatio: type === "browser" ? "16/9" : "9/19.5",
            backgroundColor: "#000000",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {/* Attempt to load video if user added video/public/demo-screen.mp4 */}
          <OffthreadVideo
            src={staticFile(src)}
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover",
            }}
            onError={(e) => {
              // fallback is handled visually below if file does not exist
            }}
          />

          <div
            style={{
              position: "absolute",
              inset: 0,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              color: "#94A3B8",
              backgroundColor: "rgba(15, 23, 42, 0.9)",
              padding: 30,
              textAlign: "center",
              pointerEvents: "none",
            }}
          >
            <Monitor size={54} color="#3B82F6" style={{ marginBottom: 16 }} />
            <h3 style={{ color: "#FFFFFF", fontSize: 24, margin: "0 0 8px 0" }}>
              Khu Vực Phát Video Quay Màn Hình Thực Tế
            </h3>
            <p style={{ maxWidth: 500, fontSize: 15, lineHeight: 1.5 }}>
              Thả video quay màn hình thao tác app của bạn vào:
              <br />
              <code
                style={{
                  color: "#60A5FA",
                  backgroundColor: "rgba(37, 99, 235, 0.15)",
                  padding: "4px 8px",
                  borderRadius: 6,
                }}
              >
                video/public/{src}
              </code>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
