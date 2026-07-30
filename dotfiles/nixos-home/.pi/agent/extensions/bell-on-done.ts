import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
  pi.on("agent_settled", async () => {
    const mute = await pi.exec(
      "/run/current-system/sw/bin/pactl",
      ["get-sink-mute", "@DEFAULT_SINK@"],
      { timeout: 1_000 },
    );
    if (mute.code !== 0 || mute.stdout.trim() !== "Mute: no") return;

    spawn("/run/current-system/sw/bin/paplay", [join(homedir(), ".local/share/sounds/ghostty-bell.wav")], {
      detached: true,
      stdio: "ignore",
    }).unref();
  });
}
