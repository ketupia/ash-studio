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
      <.card variant="transparent" padding="medium">
        <.card_title title="mix ash.gen.domain" />
        <.card_content>
          <.p color="silver">Generate the command line to create an Ash Domain</.p>
          <.form_wrapper for={@form} phx-change="validate" padding="small" space="small">
            <.input
              field={@form[:domain_module_name]}
              type="text"
              label="Domain Module Name"
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
          "errors"

        true ->
          "true"
      end

    {:noreply, assign(socket, form: form, command: command)}
  end
end
