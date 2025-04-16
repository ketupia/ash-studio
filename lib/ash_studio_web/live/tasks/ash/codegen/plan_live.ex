defmodule AshStudioWeb.Tasks.Ash.Codegen.PlanLive do
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_form(socket)}
  end

  defp assign_form(socket) do
    form = AshStudio.Tasks.form_to_codegen_command_line()
    socket |> assign(form: to_form(form), command: "")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <h2 class="text-lg font-semibold mb-2">mix ash.codegen</h2>
      <p style="color: #6b7280;">Generate the command line to create a migration file</p>
      <.simple_form for={@form} phx-change="validate">
        <.input
          field={@form[:migration_file_name]}
          type="text"
          label="Migration File Name"
          phx-debounce
          required
        />
      </.simple_form>

      <div class="flex gap-2 items-center">
        <.button
          disabled={@command == "" or @command == nil}
          phx-hook="CopyToClipboardHook"
          data-target="command"
          id="copy-command-button"
        >
          <span :if={@command != "" and @command != nil} class="text-lg">📋</span>
        </.button>
        <span id="command">{@command}</span>
        <div
          :if={@command == "" or @command == nil}
          style="background-color: #6b7280; width: 24ch; height:1em; border-radius: 0.75rem;"
        />
      </div>
    </div>

    <div class="space-y-4 p-4 shadow-lg">
      <h2 class="text-lg font-semibold mb-2">Other Codegen Commands</h2>
      <div class="flex gap-2 items-center">
        <.button
          phx-hook="CopyToClipboardHook"
          data-target="check_command"
          id="copy-check-command-button"
        >
          <span class="text-lg">📋</span>
          <span id="check_command">mix ash.codegen --check</span>
        </.button>
        <.button
          phx-hook="CopyToClipboardHook"
          data-target="dry_run_command"
          id="copy-dry-run-command-button"
        >
          <span class="text-lg">📋</span>
          <span id="dry_run_command">mix ash.codegen --dry-run</span>
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    command =
      cond do
        form.source.valid? ->
          codegen =
            AshPhoenix.Form.submit!(form, params: params)

          codegen.command

        form.errors != [] ->
          ""

        true ->
          ""
      end

    {:noreply, assign(socket, form: form, command: command)}
  end
end
