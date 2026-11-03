import React from "react";
import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { IntroScene } from "./IntroScene";
import { LiveScreenScene } from "./LiveScreenScene";
import { SkillExtractionScene } from "./SkillExtractionScene";
import { OutroScene } from "./OutroScene";

export const AtomDemoMaster: React.FC = () => {
  return (
    <div
      style={{
        flex: 1,
        backgroundColor: "#0B0F19",
      }}
    >
      <TransitionSeries>
        {/* Phân cảnh 1: Intro Thương Hiệu & Logo Phát Sáng (110 frames = 3.6s) */}
        <TransitionSeries.Sequence durationInFrames={110}>
          <IntroScene />
        </TransitionSeries.Sequence>

        {/* Chuyển cảnh 1: Fade vào màn hình ứng dụng thực tế */}
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: 20 })}
        />

        {/* Phân cảnh 2: Video thực tế Launch App, Tuyển dụng & Thảo luận (330 frames = 11s) */}
        <TransitionSeries.Sequence durationInFrames={330}>
          <LiveScreenScene
            videoFile="screen_launch_jobs.mp4"
            trimBeforeSeconds={0}
            category="DEMO THỰC TẾ #1"
            title="Khởi Động App, Khám Phá Việc Làm & Thảo Luận Cộng Đồng"
            highlights={[
              {
                startFrame: 0,
                endFrame: 110,
                title: "Khởi động Atom Web & Xác thực OAuth",
                subtitle: "Tải dữ liệu mượt mà, hỗ trợ Google & GitHub OAuth bảo mật",
                color: "#2563EB",
              },
              {
                startFrame: 115,
                endFrame: 220,
                title: "123+ Việc Làm Intern & Fresher",
                subtitle: "Bộ lọc thông minh theo kỹ năng Flutter, Node, Python, AI",
                color: "#10B981",
              },
              {
                startFrame: 225,
                endFrame: 325,
                title: "Mạng Xã Hội & Thảo Luận Đa Cấp",
                subtitle: "Bình luận lồng 2 cấp, trao đổi kiến thức phỏng vấn thực chiến",
                color: "#8B5CF6",
              },
            ]}
          />
        </TransitionSeries.Sequence>

        {/* Chuyển cảnh 2: Slide mượt sang tính năng AI Coach */}
        <TransitionSeries.Transition
          presentation={slide({ direction: "from-right" })}
          timing={linearTiming({ durationInFrames: 25 })}
        />

        {/* Phân cảnh 3: Video thực tế Chatbot Trợ Lý Kỹ Năng AI (360 frames = 12s) */}
        <TransitionSeries.Sequence durationInFrames={360}>
          <LiveScreenScene
            videoFile="screen_coach_ai.mp4"
            trimBeforeSeconds={0}
            category="DEMO THỰC TẾ #2"
            title="Trợ Lý Kỹ Năng AI Coach - Tư Vấn Lộ Trình Thời Gian Thực"
            highlights={[
              {
                startFrame: 0,
                endFrame: 120,
                title: "AI Career Coach 24/7",
                subtitle: "Mô hình Qwen 2B qua Ollama & 10 Intent Classification",
                color: "#8B5CF6",
              },
              {
                startFrame: 125,
                endFrame: 240,
                title: "Phân Tích Khoảng Cách Kỹ Năng (Skill Gap)",
                subtitle: "Gợi ý dự án thực hành và lộ trình học tập bám sát mục tiêu",
                color: "#3B82F6",
              },
              {
                startFrame: 245,
                endFrame: 355,
                title: "3 Lớp Guardrails Bảo Mật",
                subtitle: "Kiểm soát an toàn nội dung & hạn ngạch câu hỏi hàng ngày",
                color: "#10B981",
              },
            ]}
          />
        </TransitionSeries.Sequence>

        {/* Chuyển cảnh 3: Slide từ dưới lên sang Bóc tách kỹ năng Git */}
        <TransitionSeries.Transition
          presentation={slide({ direction: "from-bottom" })}
          timing={linearTiming({ durationInFrames: 25 })}
        />

        {/* Phân cảnh 4: Công nghệ Trích Xuất Kỹ Năng 3 Tầng (230 frames = 7.6s) */}
        <TransitionSeries.Sequence durationInFrames={230}>
          <SkillExtractionScene />
        </TransitionSeries.Sequence>

        {/* Chuyển cảnh 4: Fade vào Outro */}
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: 20 })}
        />

        {/* Phân cảnh 5: Outro & Call to Action (140 frames = 4.6s) */}
        <TransitionSeries.Sequence durationInFrames={140}>
          <OutroScene />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </div>
  );
};

