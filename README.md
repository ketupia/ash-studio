# 🧠 Ash Studio

This library is aims to build AI development tools for the [Ash Framework](https://ash-hq.org). It is not an official Ash module.

## Ideas

Resource browser, live updating on compile, bidirectional sync w/ source code, tracing of actions that execute as they execute, resource graph visualizer w/ canvas instead of mermaid, monitor reactors as they run etc.

The premise is to have a single set of Ash resources that can be used by

- ✅ Forms
- ✅ AI Chat Bots
- ❌ AI Code Agents (MCP)

❌ In all cases, enable executing the operation on your behalf.

---

## 🔧 Architecture Overview

- **Ash Framework** — defines MCP services as embedded, stateless resources.
- **Ash AI** — exposes the tools in a chat interface.
- **Phoenix LiveView** — provides a chat interface and forms for human developers to interact with tools.

---

## 📍 Goals

- Let AI agents safely interact with your dev environment using domain-aware tools
- Provide consistent, convention-driven automation surfaces for common Ash/Phoenix tasks
- Keep humans in the loop with a LiveView UI

---

## 📦 Status

This is an experimental playground — feedback and contributions welcome.

[Github Repo](https://github.com/ketupia/ash-studio)

[See it here](https://ash-studio-demo.fly.dev) - The site will spin down after a period of inactivity; give it time to rehydrate on first request.

## Installation

### Mix Dependency

      {:ash_studio, "~> 0.1", github: "ketupia/ash_studio", only: :dev},

### Config

    Add AshStudio.Tasks to your app's `:ash_domains`
    ```elixir
        config :your_app,
            ash_domains: [AshStudio.Tasks]
    ```

    Add :ash_studio to your app's `:host_app` config
    ```elixir
        config :ash_studio,
            ash_domains: [AshStudio.Tasks],
            host_app: :ash_studio_demo,
            open_ai_model: "gpt-4o-mini"
    ```

### Routes

    In your router file

    ```elixir
        import AshStudioWeb.Router

        ash_studio_routes(path: "/studio", pipe_through: [:browser])
    ```

    You must use `/studio` as the path presently.

### Open AI Config

    Add your OpenAI API key as an environment variable.
    e.g.
    ```
        System.put_env("open_api_key", "your key here")
    ```

    Specify the Open AI model to use
    ```elixir
        config :ash_studio, :open_ai_model, "gpt-4o-mini"
    ```
