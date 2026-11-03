import "./index.css";
import { Composition, Still } from "remotion";
import { AtomDemoMaster } from "./AtomDemo/AtomDemoMaster";
import { AtomDemo } from "./AtomDemo/AtomDemo";
import { AtomThumbnail } from "./AtomDemo/AtomThumbnail";
import { ScreenRecordingPlayer } from "./AtomDemo/ScreenRecordingPlayer";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* 1. MASTER VIDEO: Kết hợp Video Quay Màn Hình Thực Tế + Chuyển Cảnh + Motion Graphics (36s, 1080 frames) */}
      <Composition
        id="AtomDemo"
        component={AtomDemoMaster}
        durationInFrames={1080}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          title: "Atom",
          tagline: "Nền tảng Hướng nghiệp & Tuyển dụng Thông minh",
          webUrl: "https://atom-web-ten.vercel.app",
        }}
      />

      {/* 2. Motion Graphics Solo (Bản đồ họa chuyển động thuần 30s) */}
      <Composition
        id="AtomMotionGraphics"
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

      {/* 3. Screen Mockup Đơn Lẻ */}
      <Composition
        id="AtomScreenMockup"
        component={ScreenRecordingPlayer}
        durationInFrames={600}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          type: "browser",
          src: "screen_launch_jobs.mp4",
          title: "Atom Web - https://atom-web-ten.vercel.app",
        }}
      />

      {/* 4. Still Thumbnail chất lượng cao 1920x1080 */}
      <Still
        id="AtomThumbnail"
        component={AtomThumbnail}
        width={1920}
        height={1080}
      />
    </>
  );
};
