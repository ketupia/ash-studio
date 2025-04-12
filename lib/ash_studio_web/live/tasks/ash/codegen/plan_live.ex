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
      <.card variant="transparent" padding="medium">
        <.card_title title="mix ash.codegen" />
        <.card_content>
          <.p color="silver">Generate the command line to create a migration file</.p>
          <.form_wrapper for={@form} phx-change="validate" padding="small" space="small">
            <.input
              field={@form[:migration_file_name]}
              type="text"
              label="Migration File Name"
              phx-debounce
            />
          </.form_wrapper>
        </.card_content>

        <.card_footer>
          <.button
            disabled={@command == ""}
            phx-hook="CopyToClipboardHook"
            data-target="command"
            id="copy-command-button"
            variant="default"
            color="primary"
          >
            <.icon name="hero-clipboard" class="size-6" />
          </.button>
          <span id="command">{@command}</span>
          <.skeleton
            :if={@command == ""}
            class="inline-block"
            color="base"
            height="large"
            rounded="large"
            width="w-24 md:w-72"
          />
        </.card_footer>
      </.card>
    </div>

    <.card class="mt-12" padding="medium" variant="transparent">
      <.card_title>Other Codegen Commands</.card_title>
      <.card_content>
        <.button
          phx-hook="CopyToClipboardHook"
          data-target="check_command"
          id="copy-check-command-button"
          variant="outline"
          color="primary"
        >
          <.icon name="hero-clipboard" class="size-6" />
          <span id="check_command">mix ash.codegen --check</span>
        </.button>
        <.button
          phx-hook="CopyToClipboardHook"
          data-target="dry_run_command"
          id="copy-dry-run-command-button"
          variant="outline"
          color="primary"
        >
          <.icon name="hero-clipboard" class="size-6" />
          <span id="dry_run_command">mix ash.codegen --dry-run</span>
        </.button>
      </.card_content>
    </.card>
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
          "errors"

        true ->
          "true"
      end

    {:noreply, assign(socket, form: form, command: command)}
  end
end
