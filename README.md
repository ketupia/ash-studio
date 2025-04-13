# 🧠 ash_studio

This is an experimental or starter site aimed at building AI development tools for the [Ash Framework](https://ash-hq.org). It is not an official Ash module.

The premise is to have a single set of Ash resources that can be used by

- ✅ Forms
- ✅ AI Chat Bots
- ❌ AI Code Agents (MCP)

❌ In all cases, enable executing the operation on your behalf.

---

## 🔧 Architecture Overview

- **Ash Framework** — defines MCP services as embedded, stateless resources.
- **Ash AI** — exposes the tools in a chat interface.
- **Phoenix LiveView** — provides a UI for human developers to interact with tools.
- **Mishka Chelekom** — UI component library.

---

## 📍 Goals

- Let AI agents safely interact with your dev environment using domain-aware tools
- Provide consistent, convention-driven automation surfaces for common Ash/Phoenix tasks
- Keep humans in the loop with a LiveView UI

---

## 📦 Status

This is an experimental playground — feedback and contributions welcome.

[Github Repo](https://github.com/ketupia/ash-studio)

[See it here](https://ash-studio.fly.dev) - The site will spin down after a period of inactivity; give it time to rehydrate on first request.
