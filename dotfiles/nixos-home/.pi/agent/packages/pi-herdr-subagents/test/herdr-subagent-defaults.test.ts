import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { Value } from "@sinclair/typebox/value";
import configureSubagentDefaults from "../../../extensions/herdr-subagent-defaults.ts";
import * as subagentsModule from "../pi-extension/subagents/index.ts";

type ToolCallEvent = { toolName: string; input: Record<string, unknown> };
type ToolCallHandler = (event: ToolCallEvent) => void;
type RegisteredTool = { name: string; parameters?: unknown };

function createDefaultsMockApi() {
  const eventHandlers = new Map<string, ToolCallHandler[]>();

  const api = {
    on(event: string, handler: ToolCallHandler) {
      const handlers = eventHandlers.get(event) ?? [];
      handlers.push(handler);
      eventHandlers.set(event, handlers);
    },
  };

  return { api, eventHandlers };
}

function createSubagentToolSchemaApi() {
  const eventHandlers = new Map<string, ToolCallHandler[]>();
  const registeredTools: RegisteredTool[] = [];

  const api = {
    on(event: string, handler: ToolCallHandler) {
      const handlers = eventHandlers.get(event) ?? [];
      handlers.push(handler);
      eventHandlers.set(event, handlers);
    },
    registerTool(tool: RegisteredTool) {
      registeredTools.push(tool);
    },
    registerCommand() {},
    registerMessageRenderer() {},
    registerShortcut() {},
    sendUserMessage() {},
    sendMessage() {},
    getAllTools() {
      return [];
    },
  };

  return { api, eventHandlers, registeredTools };
}

function getSubagentSchema() {
  const oldSubagentId = process.env.PI_SUBAGENT_ID;
  const oldDenyTools = process.env.PI_DENY_TOOLS;

  delete process.env.PI_SUBAGENT_ID;
  delete process.env.PI_DENY_TOOLS;

  try {
    const context = createSubagentToolSchemaApi();
    (subagentsModule as any).default(context.api);

    const subagentTool = context.registeredTools.find((tool) => tool.name === "subagent");
    assert.ok(subagentTool, "expected subagent tool registration");
    return subagentTool.parameters;
  } finally {
    if (oldSubagentId == null) {
      delete process.env.PI_SUBAGENT_ID;
    } else {
      process.env.PI_SUBAGENT_ID = oldSubagentId;
    }
    if (oldDenyTools == null) {
      delete process.env.PI_DENY_TOOLS;
    } else {
      process.env.PI_DENY_TOOLS = oldDenyTools;
    }
  }
}

function callToolHook(
  api: ReturnType<typeof createDefaultsMockApi>,
  event: ToolCallEvent,
) {
  const handlers = api.eventHandlers.get("tool_call") ?? [];
  assert.equal(handlers.length, 1);
  handlers[0](event);
}

describe("herdr-subagent-defaults", () => {
  const roleContracts = {
    worker: { model: "openai-codex/gpt-5.3-codex-spark", thinking: "medium" as const },
    scout: { model: "openai-codex/gpt-5.6-terra", thinking: "medium" as const },
    reviewer: { model: "openai-codex/gpt-5.6-sol", thinking: "high" as const },
    unknown: { model: "openai-codex/gpt-5.6-terra", thinking: "medium" as const },
  };

  for (const [role, expected] of Object.entries(roleContracts)) {
    it(`sets defaults for ${role} when model and thinking are absent`, () => {
      const extension = createDefaultsMockApi();
      configureSubagentDefaults(extension.api as never);

      const input = { agent: role };
      callToolHook(extension, { toolName: "subagent", input });

      assert.equal(input.model, expected.model);
      assert.equal(input.thinking, expected.thinking);
    });

    it(`keeps explicit model for ${role} and defaults thinking only when absent`, () => {
      const extension = createDefaultsMockApi();
      configureSubagentDefaults(extension.api as never);

      const input = {
        agent: role,
        model: "custom/model",
      };
      callToolHook(extension, { toolName: "subagent", input });

      assert.equal(input.model, "custom/model");
      assert.equal(input.thinking, expected.thinking);
    });

    it(`keeps explicit thinking for ${role} and defaults model only when absent`, () => {
      const extension = createDefaultsMockApi();
      configureSubagentDefaults(extension.api as never);

      const input = {
        agent: role,
        thinking: "high",
      };
      callToolHook(extension, { toolName: "subagent", input });

      assert.equal(input.thinking, "high");
      assert.equal(input.model, expected.model);
    });
  }

  it("keeps explicit empty model and applies default thinking", () => {
    const extension = createDefaultsMockApi();
    configureSubagentDefaults(extension.api as never);

    const input = {
      agent: "worker",
      model: "",
    };
    callToolHook(extension, { toolName: "subagent", input });

    assert.equal(input.model, "");
    assert.equal(input.thinking, "medium");
  });

  it("does not alter non-subagent tool calls", () => {
    const extension = createDefaultsMockApi();
    configureSubagentDefaults(extension.api as never);

    const input = {
      agent: "reviewer",
      model: "custom/model",
      thinking: "high",
    };
    callToolHook(extension, { toolName: "subagent_resume", input });

    assert.equal(input.model, "custom/model");
    assert.equal(input.thinking, "high");
  });

  it("applies defaults when subagent launch includes fork and interactive options", () => {
    const extension = createDefaultsMockApi();
    configureSubagentDefaults(extension.api as never);

    const input = {
      agent: "worker",
      fork: true,
      interactive: false,
    };
    callToolHook(extension, { toolName: "subagent", input });

    assert.equal(input.model, "openai-codex/gpt-5.3-codex-spark");
    assert.equal(input.thinking, "medium");
  });

  it("rejects null model, null thinking, and empty thinking through subagent tool schema", () => {
    const schema = getSubagentSchema();
    assert.ok(schema, "expected schema from registered tool");

    const base = {
      name: "worker-subagent",
      task: "Run checks",
      agent: "worker",
      model: "fake/model",
      thinking: "medium",
    };

    assert.equal(Value.Check(schema as never, { ...base, model: null }), false);
    assert.equal(Value.Check(schema as never, { ...base, thinking: null }), false);
    assert.equal(Value.Check(schema as never, { ...base, thinking: "" }), false);
  });

  it("accepts schema-valid empty model and keeps it through defaults hook", () => {
    const schema = getSubagentSchema();
    assert.ok(schema, "expected schema from registered tool");

    const withEmptyModel = {
      name: "worker-subagent",
      task: "Run checks",
      model: "",
      agent: "worker",
    };
    assert.equal(Value.Check(schema as never, withEmptyModel), true);

    const extension = createDefaultsMockApi();
    configureSubagentDefaults(extension.api as never);
    const input: Record<string, unknown> = { ...withEmptyModel };
    callToolHook(extension, { toolName: "subagent", input });

    assert.equal(input.model, "");
    assert.equal(input.thinking, "medium");
  });
});
