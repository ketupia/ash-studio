defmodule AshStudioWeb.Tasks.Ash.Gen.Resource.PlanLive do
  alias AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec
  alias AshStudio.Tasks.Ash.Gen.ResourceAttributeSpec
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    existing_domains =
      Application.get_env(:ash_studio, :host_app)
      |> Application.get_env(:ash_domains)
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(&String.replace(&1, "Elixir.", ""))

    # |> IO.inspect(label: "existing_domains")

    existing_resources =
      Application.get_env(:ash_studio, :host_app)
      |> Application.get_env(:ash_domains)
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

    socket |> assign(form: to_form(form), command: "")
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
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
      <div class="p-4 shadow-lg">
        <h2 class="text-lg font-semibold mb-2">mix ash.gen.resource</h2>
        <div class="space-y-4">
          <p style="color: #6b7280;">Generate the command line to create an Ash Resource</p>
          <.simple_form for={@form} phx-change="validate" phx-submit="validate">
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

            <%!-- <:actions>
              <.button phx-disable-with="Thinking...">Submit</.button>
            </:actions> --%>
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
      </div>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp extensions(assigns) do
    ~H"""
    <div class="p-4 shadow-lg">
      <h2 class="text-lg font-semibold mb-2">Extensions</h2>
      <.input
        type="select"
        field={@field}
        multiple={true}
        size={6}
        options={[
          {"Policies", "Ash.Policy.Authorizer"},
          {"Admin", "AshAdmin.Resource"},
          {"Json API", "json_api"},
          {"GraphQL", "graphql"},
          {"PubSub", "Ash.Notifier.PubSub"},
          {"Postgres", "postgres"}
        ]}
      />
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp default_actions(assigns) do
    ~H"""
    <div class="p-4 shadow-lg">
      <h2 class="text-lg font-semibold mb-2">Default Actions</h2>
      <.input
        type="select"
        field={@field}
        multiple={true}
        size={4}
        options={[
          {"Create", "create"},
          {"Read", "read"},
          {"Update", "update"},
          {"Destroy", "destroy"}
        ]}
      />
    </div>
    """
  end

  attr :form_name, :string, required: true
  attr :field, Phoenix.HTML.FormField, required: true
  attr :existing_resources, :list, required: true

  defp relationships(assigns) do
    ~H"""
    <div class="p-4 shadow-lg">
      <h2 class="text-lg font-semibold mb-2">Relationships</h2>
      <div class="space-y-4">
        <.button
          type="button"
          phx-click="add-relationship-spec"
          phx-value-path={@form_name <> "[relationship_specs]"}
        >
          <.icon name="hero-plus" class="size-4" />
        </.button>
      </div>
      <div class="space-y-4">
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
      </div>
    </div>
    """
  end

  attr :form_name, :string, required: true
  attr :field, Phoenix.HTML.FormField, required: true

  defp attributes(assigns) do
    assigns =
      assign(assigns, :attribute_type_options, Enum.sort(Keyword.keys(Ash.Type.short_names())))

    ~H"""
    <div class="p-4 shadow-lg">
      <h2 class="text-lg font-semibold mb-2">Attributes</h2>
      <div class="space-y-4">
        <.button
          type="button"
          phx-click="add-attribute-spec"
          phx-value-path={@form_name <> "[attribute_specs]"}
        >
          <.icon name="hero-plus" class="size-4" />
        </.button>
      </div>
      <div class="space-y-4">
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
      </div>
    </div>
    """
  end

  attr :type_field, Phoenix.HTML.FormField, required: true
  attr :name_field, Phoenix.HTML.FormField, required: true

  defp primary_key(assigns) do
    ~H"""
    <div class="p-4 shadow-lg">
      <h2 class="text-lg font-semibold mb-2">Primary Key</h2>
      <div class="space-y-4">
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
      </div>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp include_timestamps(assigns) do
    ~H"""
    <.input type="checkbox" label="Include Timestamps" field={@field} />
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp ignore_if_exists(assigns) do
    ~H"""
    <.input type="checkbox" label="Ignore If Exists" field={@field} />
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
