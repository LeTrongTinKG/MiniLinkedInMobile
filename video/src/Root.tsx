import "./index.css";
import { Composition, Still } from "remotion";
import { AtomDemo } from "./AtomDemo/AtomDemo";
import { AtomThumbnail } from "./AtomDemo/AtomThumbnail";
import { ScreenRecordingPlayer } from "./AtomDemo/ScreenRecordingPlayer";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* 1. Master Video Demo Landscape 16:9 (30s) */}
      <Composition
        id="AtomDemo"
        component={AtomDemo}
        durationInFrames={900}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          title: "Atom",
          tagline: "Nền tảng Hướng nghiệp & Tuyển dụng Thông minh",
          webUrl: "https://atom-web-ten.vercel.app",
        }}
      />

      {/* 2. Video Demo Portrait 9:16 (Shorts / Reels / TikTok 30s) */}
      <Composition
        id="AtomDemoPortrait"
        component={AtomDemo}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{
          title: "Atom",
          tagline: "Nền tảng Hướng nghiệp & Tuyển dụng Thông minh",
          webUrl: "https://atom-web-ten.vercel.app",
        }}
      />

      {/* 3. Screen Recording Player (Wraps your screen recording in a MacBook mockup) */}
      <Composition
        id="AtomScreenMockup"
        component={ScreenRecordingPlayer}
        durationInFrames={600}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          type: "browser",
          src: "demo-screen.mp4",
          title: "Atom Web - https://atom-web-ten.vercel.app",
        }}
      />

      {/* 4. Still Thumbnail for YouTube / Slides Cover */}
      <Still
        id="AtomThumbnail"
        component={AtomThumbnail}
        width={1920}
        height={1080}
      />
    </>
  );
};
