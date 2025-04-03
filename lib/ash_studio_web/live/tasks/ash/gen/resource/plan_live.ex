defmodule AshStudioWeb.Tasks.Ash.Gen.Resource.PlanLive do
  alias AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec
  alias AshStudio.Tasks.Ash.Gen.ResourceAttributeSpec
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    existing_domains =
      Application.get_env(:ash_studio, :ash_domains, [])
      |> Enum.map(&(Atom.to_string(&1) |> String.replace("Elixir.", "")))
      |> Enum.sort()

    # |> IO.inspect(label: "existing_domains")

    existing_resources =
      Application.get_env(:ash_studio, :ash_domains, [])
      |> Enum.flat_map(&Ash.Domain.Info.resources/1)
      |> Enum.map(&(Atom.to_string(&1) |> String.replace("Elixir.", "")))
      |> Enum.sort()

    # |> IO.inspect(label: "existing_resources")

    {:ok,
     socket
     |> assign(existing_domains: existing_domains, existing_resources: existing_resources)
     |> assign_form()}
  end

  defp assign_form(socket) do
    form =
      AshStudio.Tasks.form_to_resource_command_line()

    socket |> assign(form: to_form(form), command: "new")
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    params =
      update_in(params["default_actions"], fn default_actions ->
        Enum.reject(default_actions, &(&1 == ""))
      end)

    params =
      update_in(params["extensions"], fn extensions ->
        Enum.reject(extensions, &(&1 == ""))
      end)

    form = AshPhoenix.Form.validate(socket.assigns.form, params)

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
          "** check your attributes and relationships **"
      end

    {:noreply, assign(socket, form: form, command: command)}
  end

  def handle_event("add-attribute-spec", %{"path" => path}, socket) do
    form =
      AshPhoenix.Form.add_form(socket.assigns.form, path,
        params: Map.from_struct(%ResourceAttributeSpec{})
      )

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("add-relationship-spec", %{"path" => path}, socket) do
    form =
      AshPhoenix.Form.add_form(socket.assigns.form, path,
        params: Map.from_struct(%ResourceRelationshipSpec{})
      )

    {:noreply, assign(socket, :form, form)}
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

      <.form_wrapper for={@form} phx-change="validate" phx-submit="validate" space="small">
        <.resource_module_name field={@form[:resource_module_name]} />

        <div class="flex flex-wrap gap-4">
          <.ignore_if_exists field={@form[:ignore_if_exists?]} />
          <.domain_module_name
            field={@form[:domain_module_name]}
            existing_domains={@existing_domains}
          />
        </div>

        <.primary_key type_field={@form[:primary_key_type]} name_field={@form[:primary_key_name]} />
        <.include_timestamps field={@form[:timestamps?]} />

        <.attributes field={@form[:attribute_specs]} form_name={@form.name} />
        <.relationships
          field={@form[:relationship_specs]}
          form_name={@form.name}
          existing_resources={@existing_resources}
        />

        <.default_actions field={@form[:default_actions]} />

        <.extensions field={@form[:extensions]} />

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

  attr :field, Phoenix.HTML.FormField, required: true

  defp extensions(assigns) do
    ~H"""
    <.card padding="small">
      <.card_title title="Extensions" />
      <.card_content>
        <.checkbox_card field={@field} cols="three" show_checkbox={true}>
          <:checkbox
            :for={
              {label, value, description} <- [
                {"Policies", "Ash.Policy.Authorizer", "Ash.Policy.Authorizer"},
                {"Admin", "AshAdmin.Resource", "AshAdmin.Resource"},
                {"Json API", "json_api", ""},
                {"GraphQL", "graphql", ""},
                {"PubSub", "Ash.Notifier.PubSub", "Ash.Notifier.PubSub"},
                {"Postgres", "postgres", ""}
              ]
            }
            value={value}
            title={label}
            description={description}
            checked={value in @field.value}
          >
          </:checkbox>
        </.checkbox_card>
      </.card_content>
    </.card>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp default_actions(assigns) do
    ~H"""
    <.card padding="small">
      <.card_title title="Default Actions" />
      <.card_content>
        <.checkbox_card field={@field} cols="four" show_checkbox={true}>
          <:checkbox
            :for={
              {label, value} <- [
                {"Create", "create"},
                {"Read", "read"},
                {"Update", "update"},
                {"Destroy", "destroy"}
              ]
            }
            value={value}
            title={label}
            checked={value in @field.value}
          >
          </:checkbox>
        </.checkbox_card>
      </.card_content>
    </.card>
    """
  end

  attr :form_name, :string, required: true
  attr :field, Phoenix.HTML.FormField, required: true
  attr :existing_resources, :list, required: true

  defp relationships(assigns) do
    ~H"""
    <.card padding="small">
      <.card_title>
        <h2>Relationships</h2>

        <.button
          type="button"
          phx-click="add-relationship-spec"
          phx-value-path={@form_name <> "[relationship_specs]"}
        >
          <.icon name="hero-plus" class="size-4" />
        </.button>
      </.card_title>
      <.card_content>
        <datalist id="existing_resources">
          <option :for={name <- @existing_resources} value={name} />
        </datalist>
        <.inputs_for :let={rel} field={@field}>
          <div class="flex flex-wrap gap-2 mb-2">
            <div>
              <div class="flex flex-wrap gap-2">
                <.input field={rel[:name]} type="text" label="Name" phx-debounce />
                <.input
                  field={rel[:type]}
                  type="select"
                  label="Type"
                  options={[:belongs_to, :has_many, :has_one, :many_to_many]}
                  phx-debounce
                />
                <.input
                  field={rel[:destination]}
                  type="text"
                  label="Destination"
                  phx-debounce
                  list="existing_resources"
                />
              </div>
              <div class="flex flex-wrap gap-4 items-center">
                <.input field={rel[:public?]} type="checkbox" label="Public" />
                <.input
                  :if={rel[:type].value == :belongs_to}
                  field={rel[:required?]}
                  type="checkbox"
                  label="Required"
                />
                <.input
                  :if={rel[:type].value == :belongs_to}
                  field={rel[:sensitive?]}
                  type="checkbox"
                  label="Sensitive"
                />
                <.input
                  :if={rel[:type].value == :belongs_to}
                  field={rel[:primary_key?]}
                  type="checkbox"
                  label="Primary Key"
                />
              </div>
            </div>
            <label>
              <input
                type="checkbox"
                name={"#{@form_name}[_drop_relationship_specs][]"}
                value={rel.index}
                class="hidden"
              />

              <.icon name="hero-trash" class="size-6 text-red-700" />
            </label>
          </div>
        </.inputs_for>
      </.card_content>
    </.card>
    """
  end

  attr :form_name, :string, required: true
  attr :field, Phoenix.HTML.FormField, required: true

  defp attributes(assigns) do
    assigns =
      assign(assigns, :attribute_type_options, Enum.sort(Keyword.keys(Ash.Type.short_names())))

    ~H"""
    <.card padding="small">
      <.card_title>
        <h2>Attributes</h2>

        <.button
          type="button"
          phx-click="add-attribute-spec"
          phx-value-path={@form_name <> "[attribute_specs]"}
        >
          <.icon name="hero-plus" class="size-4" />
        </.button>
      </.card_title>
      <.card_content>
        <.inputs_for :let={attr} field={@field}>
          <div class="flex flex-wrap gap-2 mb-2">
            <div>
              <div class="flex flex-wrap gap-2">
                <.input field={attr[:name]} type="text" label="Name" phx-debounce />
                <.input
                  field={attr[:type]}
                  type="select"
                  label="Type"
                  options={@attribute_type_options}
                  phx-debounce
                />
              </div>
              <div class="flex flex-wrap gap-4 items-center">
                <.input field={attr[:public?]} type="checkbox" label="Public" />
                <.input field={attr[:required?]} type="checkbox" label="Required" />
                <.input field={attr[:sensitive?]} type="checkbox" label="Sensitive" />
                <.input field={attr[:primary_key?]} type="checkbox" label="Primary Key" />
              </div>
            </div>
            <label>
              <input
                type="checkbox"
                name={"#{@form_name}[_drop_attribute_specs][]"}
                value={attr.index}
                class="hidden"
              />

              <.icon name="hero-trash" class="size-6 text-red-700" />
            </label>
          </div>
        </.inputs_for>
      </.card_content>
    </.card>
    """
  end

  attr :type_field, Phoenix.HTML.FormField, required: true
  attr :name_field, Phoenix.HTML.FormField, required: true

  defp primary_key(assigns) do
    ~H"""
    <.card padding="small">
      <.card_title title="Primary Key" />
      <.card_content>
        <div class="flex flex-wrap gap-2">
          <.input
            field={@type_field}
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
          <.input field={@name_field} type="text" label="Name" phx-debounce />
        </div>
      </.card_content>
    </.card>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp include_timestamps(assigns) do
    ~H"""
    <.toggle_field label="Include Timestamps" field={@field} checked={@field.value} phx-debounce />
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp ignore_if_exists(assigns) do
    ~H"""
    <.toggle_field label="Ignore If Exists" field={@field} checked={@field.value} phx-debounce />
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :existing_domains, :list, required: true

  defp domain_module_name(assigns) do
    ~H"""
    <datalist id="existing_domains">
      <option :for={name <- @existing_domains} value={name} />
    </datalist>

    <.input
      label="Domain Module Name"
      field={@field}
      type="text"
      phx-debounce
      list="existing_domains"
    />
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp resource_module_name(assigns) do
    ~H"""
    <.input label="Resource Module Name" field={@field} type="text" required phx-debounce />
    """
  end
end
