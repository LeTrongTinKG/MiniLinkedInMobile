import React from "react";
import { Sequence } from "remotion";
import { IntroScene } from "./IntroScene";
import { SkillExtractionScene } from "./SkillExtractionScene";
import { CareerCoachScene } from "./CareerCoachScene";
import { JobMatchingScene } from "./JobMatchingScene";
import { OutroScene } from "./OutroScene";
import { AtomDemoProps } from "./types";

export const AtomDemo: React.FC<AtomDemoProps> = () => {
  return (
    <div
      style={{
        flex: 1,
        backgroundColor: "#0B0F19",
      }}
    >
      {/* 1. Intro & Brand (0s - 4.7s) */}
      <Sequence from={0} durationInFrames={140} name="Intro & Brand">
        <IntroScene />
      </Sequence>

      {/* 2. 3-Tier Skill Extraction & Git AST (4.3s - 12.6s) */}
      <Sequence from={130} durationInFrames={250} name="AI Skill Extraction">
        <SkillExtractionScene />
      </Sequence>

      {/* 3. AI Career Coach Chatbot (12.3s - 20.6s) */}
      <Sequence from={370} durationInFrames={250} name="AI Career Coach">
        <CareerCoachScene />
      </Sequence>

      {/* 4. Smart Job Matching & 1-Click Apply (20.3s - 26.6s) */}
      <Sequence from={610} durationInFrames={190} name="Smart Job Matching">
        <JobMatchingScene />
      </Sequence>

      {/* 5. Outro & Call to Action (26.3s - 30s) */}
      <Sequence from={790} durationInFrames={110} name="Outro & CTA">
        <OutroScene />
      </Sequence>
    </div>
  );
};

