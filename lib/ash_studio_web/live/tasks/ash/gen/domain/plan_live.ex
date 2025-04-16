defmodule AshStudioWeb.Tasks.Ash.Gen.Domain.PlanLive do
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_form(socket)}
  end

  defp assign_form(socket) do
    form = AshStudio.Tasks.form_to_domain_command_line()
    socket |> assign(form: to_form(form), command: "")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <h2 class="text-lg font-semibold mb-2">mix ash.gen.domain</h2>
      <p style="color: #6b7280;">Generate the command line to create an Ash Domain</p>
      <.simple_form for={@form} phx-change="validate">
        <.input
          field={@form[:domain_module_name]}
          type="text"
          label="Domain Module Name"
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
    """
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    command =
      cond do
        form.source.valid? ->
          domain =
            AshPhoenix.Form.submit!(form, params: params)

          domain.command

        form.errors != [] ->
          ""

        true ->
          ""
      end

    {:noreply, assign(socket, form: form, command: command)}
  end
end
