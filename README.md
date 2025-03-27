# 🧠 ash_mcp

A modular, AI-friendly **command protocol framework** built on [Ash Framework](https://ash-hq.org) and Phoenix LiveView.

This project explores the concept of **MCP (Modular Command Protocol)**: exposing **development tools** and **code generation plans** through an Elixir app's **runtime**, using Ash Resources as programmable, stateless command surfaces.

---

## ✨ Core Idea

**Each MCP service is an Ash Resource** — a stateless, JSON-API-accessible command with structured inputs and outputs.

MCP services let agents (or devs via UI) plan actions like:

- Generating Ash resources
- Inspecting app structure
- Planning UI scaffolds
- Producing CLI commands with project-specific conventions

---

## 🔧 Architecture Overview

- **Ash Framework** — defines MCP services as embedded, stateless resources.
- **AshJsonApi** — exposes services to agents via standardized HTTP/JSON.
- **Phoenix LiveView** — provides a UI for human developers to interact with tools.
- **Ash Domains** — group related services into discoverable toolsets.

---

## 🧪 Example: Plan a Resource

POST `/json_api/plan_resources`

```json
{
  "data": {
    "type": "plan_resource",
    "attributes": {
      "name": "Event",
      "fields": ["title:string", "starts_at:utc_datetime"],
      "domain": "Events"
    }
  }
}
```

Response:

```json
{
  "data": {
    "type": "plan_resource",
    "attributes": {
      "command": "mix ash.gen.resource MyApp.Events.Event --uuid-primary-key id ..."
    }
  }
}
```

---

## 🗂️ Service Discovery

MCP domains act as **tool manifests**.

Agents (or UIs) can discover all services via:

- `/json_api/types` — list of resource types
- `/json_api/<resource>/schema` — input fields
- `/openapi` — full schema for all exposed services

---

## 🧰 Available Services

| Service         | Type                | Description                            |
| --------------- | ------------------- | -------------------------------------- |
| Plan Resource   | `plan_resource`     | Returns codegen commands for resources |
| _(coming soon)_ | `inspect_schema`    | Introspects your Ash domain & fields   |
| _(coming soon)_ | `generate_liveview` | Plans a LiveView UI for a resource     |

---

## 🛠️ Setup

```bash
git clone https://github.com/yourname/ash_mcp
cd ash_mcp
mix deps.get
mix ash.generate_registry
mix phx.server
```

Visit the MCP LiveView UI at [http://localhost:4000](http://localhost:4000)

---

## 🤖 Agent Integration

Agents can:

- Call `POST /json_api/<service>` with JSON payloads
- Parse the structured response
- Use the `command` to take action in the dev environment
- Query `/openapi` to learn available tools

---

## 📍 Goals

- Let AI agents safely interact with your dev environment using domain-aware tools
- Provide consistent, convention-driven automation surfaces for common Ash/Phoenix tasks
- Keep humans in the loop with a LiveView UI

---

## 📦 Status

This is an experimental playground — feedback and contributions welcome.
