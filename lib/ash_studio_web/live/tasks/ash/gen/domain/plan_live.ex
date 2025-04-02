defmodule AshStudioWeb.Tasks.Ash.Gen.Domain.PlanLive do
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_form(socket)}
  end

  defp assign_form(socket) do
    form = AshStudio.Tasks.form_to_domain_command_line()
    socket |> assign(form: to_form(form), command: "new")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.card variant="transparent">
        <.card_title title="mix ash.gen.domain" />
        <.card_content>
          Generate the command line to create an Ash Domain
        </.card_content>
      </.card>

      <.form_wrapper for={@form} phx-change="validate">
        <.input
          field={@form[:domain_module_name]}
          type="text"
          label="Domain Module Name"
          phx-debounce
        />
        <:actions>
          <.button>Submit</.button>
        </:actions>
      </.form_wrapper>

      <h2>Command</h2>
      <.card variant="shadow" color="white" rounded="large">
        <.card_content padding="medium">
          {@command}
        </.card_content>
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
