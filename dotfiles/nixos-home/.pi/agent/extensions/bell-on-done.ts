import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async () => {
    spawn("/run/current-system/sw/bin/paplay", ["/home/delaney/.local/share/sounds/ghostty-bell.wav"], {
      detached: true,
      stdio: "ignore",
    }).unref();
  });
}
