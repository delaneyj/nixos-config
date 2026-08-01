import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type SubagentInput = {
  agent?: unknown;
  model?: unknown;
  thinking?: unknown;
};

export default function (pi: ExtensionAPI) {
  pi.on("project_trust", () => ({
    trusted: process.env.PI_SUBAGENT_ID ? "no" : "undecided",
  }));

  pi.on("tool_call", (event) => {
    if (event.toolName !== "subagent") return;

    const input = event.input as SubagentInput;
    const reviewer = input.agent === "reviewer";

    input.model = reviewer ? "openai-codex/gpt-5.6-sol" : "openai-codex/gpt-5.6-terra";
    input.thinking = reviewer ? "high" : "medium";
  });
}
