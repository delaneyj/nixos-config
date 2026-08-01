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
    const role = typeof input.agent === "string" ? input.agent.toLowerCase() : "";

    if (role === "reviewer") {
      input.model = "openai-codex/gpt-5.6-sol";
      input.thinking = "high";
      return;
    }

    input.model = role === "worker"
      ? "openai-codex/gpt-5.3-codex-spark"
      : "openai-codex/gpt-5.6-terra";
    input.thinking = "medium";
  });
}
