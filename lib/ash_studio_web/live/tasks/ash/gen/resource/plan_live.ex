defmodule AshStudioWeb.Tasks.Ash.Gen.Resource.PlanLive do
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       default_actions: [
         {"Create", "create"},
         {"Read", "read"},
         {"Update", "update"},
         {"Destroy", "destroy"}
       ]
     )
     |> assign(
       extensions: [
         {"Policies", "Ash.Policy.Authorizer", "Ash.Policy.Authorizer"},
         {"Admin", "AshAdmin.Resource", "AshAdmin.Resource"},
         {"Json API", "json_api", ""},
         {"GraphQL", "graphql", ""},
         {"PubSub", "Ash.Notifier.PubSub", "Ash.Notifier.PubSub"},
         {"Postgres", "postgres", ""}
       ]
     )
     |> assign_form()}
  end

  defp assign_form(socket) do
    form =
      AshStudio.Tasks.form_to_plan_resource()

    socket |> assign(form: to_form(form), command: "new")
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    IO.inspect(params, label: "params")

    form =
      AshPhoenix.Form.validate(socket.assigns.form, params)

    # |> IO.inspect(label: "form")

    command =
      cond do
        form.source.valid? ->
          resource =
            AshPhoenix.Form.submit!(form, params: params)

          resource.command

        form.errors != [] ->
          Enum.map_join(form.errors, ", ", fn {field, {message, _}} ->
            "#{field}: #{message}"
          end)

        true ->
          "true"
      end

    {:noreply, assign(socket, form: form, command: command)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.card variant="transparent">
        <.card_title title="mix ash.gen.resource" />
        <.card_content>
          Generate the command line to create an Ash Resource
        </.card_content>
      </.card>

      <.form_wrapper for={@form} phx-change="validate" space="small">
        <.input
          label="Resource Module Name"
          field={@form[:resource_module_name]}
          type="text"
          required
          phx-debounce
        />

        <.input
          label="Domain Module Name"
          field={@form[:domain_module_name]}
          type="text"
          phx-debounce
        />

        <.toggle_field
          label="Ignore If Exists"
          field={@form[:ignore_if_exists?]}
          checked={@form[:ignore_if_exists?].value}
          phx-debounce
        />

        <.toggle_field
          label="Include Timestamps"
          field={@form[:timestamps?]}
          checked={@form[:timestamps?].value}
          phx-debounce
        />

        <.card padding="small">
          <.card_title title="Primary Key" />
          <.card_content>
            <div class="flex flex-wrap gap-2">
              <.input
                field={@form[:primary_key_type]}
                type="select"
                label="Type"
                options={[
                  {"none", :none},
                  {"uuid_v4", :uuid_v4},
                  {"uuid_v7", :uuid_v7},
                  {"integer", :integer}
                ]}
                phx-debounce
              />
              <.input field={@form[:primary_key_name]} type="text" label="Name" phx-debounce />
            </div>
          </.card_content>
        </.card>

        <.card padding="small">
          <.card_title title="Default Actions" />
          <.card_content>
            <.checkbox_card
              label="Default Actions"
              field={@form[:default_actions]}
              cols="four"
              show_checkbox={true}
            >
              <:checkbox
                :for={{label, value} <- @default_actions}
                value={value}
                title={label}
                checked={value in @form[:default_actions].value}
              >
              </:checkbox>
            </.checkbox_card>
          </.card_content>
        </.card>

        <.card padding="small">
          <.card_title title="Extensions" />
          <.card_content>
            <.checkbox_card
              label="Extensions"
              field={@form[:extensions]}
              cols="three"
              show_checkbox={true}
            >
              <:checkbox
                :for={{label, value, description} <- @extensions}
                value={value}
                title={label}
                description={description}
                checked={value in @form[:extensions].value}
              >
              </:checkbox>
            </.checkbox_card>
          </.card_content>
        </.card>

        <:actions>
          <.button>Submit</.button>
        </:actions>
      </.form_wrapper>

      <.divider type="dotted">
        <%!-- <:icon name="hero-bolt" class="size-4" /> --%>
        <:icon name="hero-beaker" class="size-4" />
      </.divider>

      <h2>Command</h2>
      <.card variant="shadow" color="white" rounded="large">
        <.card_content padding="medium">
          {@command}
        </.card_content>
      </.card>
    </div>
    """
  end
end
