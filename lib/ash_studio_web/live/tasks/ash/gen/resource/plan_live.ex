defmodule AshStudioWeb.Tasks.Ash.Gen.Resource.PlanLive do
  alias AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec
  alias AshStudio.Tasks.Ash.Gen.ResourceAttributeSpec
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    existing_resources =
      Ash.Domain.Info.resources(AshStudio.Tasks)
      |> Enum.map(&(Atom.to_string(&1) |> String.replace("Elixir.", "")))

    {:ok, socket |> assign(:existing_resources, existing_resources) |> assign_form()}
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
          <.domain_module_name field={@form[:domain_module_name]} />
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

  defp domain_module_name(assigns) do
    ~H"""
    <.input label="Domain Module Name" field={@field} type="text" phx-debounce />
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp resource_module_name(assigns) do
    ~H"""
    <.input label="Resource Module Name" field={@field} type="text" required phx-debounce />
    """
  end

  #   def foo() do
  #  %Phoenix.HTML.Form{
  #       source: #AshPhoenix.Form<
  #         resource: AshStudio.Tasks.Ash.Gen.Resource,
  #         action: :command_line,
  #         type: :create,
  #         params: %{
  #           "_unused_default_actions" => [""],
  #           "_unused_domain_module_name" => "",
  #           "_unused_extensions" => [""],
  #           "_unused_ignore_if_exists?" => "",
  #           "_unused_primary_key_name" => "",
  #           "_unused_primary_key_type" => "",
  #           "_unused_resource_module_name" => "",
  #           "_unused_timestamps?" => "",
  #           "default_actions" => [],
  #           "domain_module_name" => "",
  #           "extensions" => [],
  #           "ignore_if_exists?" => "true",
  #           "primary_key_name" => "id",
  #           "primary_key_type" => "uuid_v4",
  #           "relationship_specs" => %{
  #             "0" => %{
  #               "_form_type" => "create",
  #               "_persistent_id" => "0",
  #               "_touched" => "name,type,required?,destination,calculations,aggregates,__lateral_join_source__,__metadata__,__order__,__meta__,primary_key?,public?,sensitive?,__lateral_join_source__,__meta__,__metadata__,__order__,_form_type,_touched,aggregates,calculations,destination,name,primary_key?,public?,required?,sensitive?,type",
  #               "_unused_destination" => "",
  #               "_unused_name" => "",
  #               "_unused_public?" => "",
  #               "destination" => "",
  #               "name" => "",
  #               "public?" => "false",
  #               "type" => "belongs_to"
  #             }
  #           },
  #           "resource_module_name" => "Foo",
  #           "timestamps?" => "true"
  #         },
  #         source: #Ash.Changeset<
  #           domain: AshStudio.Tasks,
  #           action_type: :create,
  #           action: :command_line,
  #           attributes: %{
  #             command: "mix ash.gen.resource Foo --timestamps --ignore-if-exists --primary-key-uuid id"
  #           },
  #           relationships: %{},
  #           arguments: %{
  #             extensions: [],
  #             domain_module_name: "",
  #             resource_module_name: "Foo",
  #             attribute_specs: [],
  #             relationship_specs: [],
  #             default_actions: [],
  #             ignore_if_exists?: true,
  #             primary_key_type: :uuid_v4,
  #             primary_key_name: "id",
  #             timestamps?: true
  #           },
  #           errors: [
  #             %Ash.Error.Changes.Required{
  #               field: :name,
  #               type: :attribute,
  #               resource: AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec,
  #               splode: Ash.Error,
  #               bread_crumbs: [],
  #               vars: [],
  #               path: [:relationship_specs, 0],
  #               stacktrace: #Splode.Stacktrace<>,
  #               class: :invalid
  #             }
  #           ],
  #           data: #AshStudio.Tasks.Ash.Gen.Resource<
  #             __meta__: #Ecto.Schema.Metadata<:built, "">,
  #             id: nil,
  #             command: nil,
  #             aggregates: %{},
  #             calculations: %{},
  #             ...
  #           >,
  #           valid?: false
  #         >,
  #         name: "form",
  #         data: nil,
  #         form_keys: [
  #           attribute_specs: [
  #             type: :list,
  #             resource: AshStudio.Tasks.Ash.Gen.ResourceAttributeSpec,
  #             create_action: :create,
  #             update_action: :update,
  #             embed?: true,
  #             data: #Function<40.101098749/1 in AshPhoenix.Form.Auto.embedded/3>,
  #             forms: []
  #           ],
  #           relationship_specs: [
  #             type: :list,
  #             resource: AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec,
  #             create_action: :create,
  #             update_action: :update,
  #             embed?: true,
  #             data: #Function<40.101098749/1 in AshPhoenix.Form.Auto.embedded/3>,
  #             forms: []
  #           ]
  #         ],
  #         forms: %{
  #           relationship_specs: [
  #             #AshPhoenix.Form<
  #               resource: AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec,
  #               action: :create,
  #               type: :create,
  #               params: %{
  #                 "_form_type" => "create",
  #                 "_persistent_id" => "0",
  #                 "_touched" => "name,type,required?,destination,calculations,aggregates,__lateral_join_source__,__metadata__,__order__,__meta__,primary_key?,public?,sensitive?,__lateral_join_source__,__meta__,__metadata__,__order__,_form_type,_touched,aggregates,calculations,destination,name,primary_key?,public?,required?,sensitive?,type",
  #                 "_unused_destination" => "",
  #                 "_unused_name" => "",
  #                 "_unused_public?" => "",
  #                 "destination" => "",
  #                 "name" => "",
  #                 "public?" => "false",
  #                 "type" => "belongs_to"
  #               },
  #               source: #Ash.Changeset<
  #                 domain: AshStudio.Tasks,
  #                 action_type: :create,
  #                 action: :create,
  #                 attributes: %{
  #                   name: nil,
  #                   type: :belongs_to,
  #                   required?: false,
  #                   destination: nil,
  #                   primary_key?: false,
  #                   public?: false,
  #                   sensitive?: false
  #                 },
  #                 relationships: %{},
  #                 errors: [
  #                   %Ash.Error.Changes.Required{
  #                     field: :destination,
  #                     type: :attribute,
  #                     resource: AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec,
  #                     splode: Ash.Error,
  #                     bread_crumbs: [],
  #                     vars: [],
  #                     path: [],
  #                     stacktrace: #Splode.Stacktrace<>,
  #                     class: :invalid
  #                   },
  #                   %Ash.Error.Changes.Required{
  #                     field: :name,
  #                     type: :attribute,
  #                     resource: AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec,
  #                     splode: Ash.Error,
  #                     bread_crumbs: [],
  #                     vars: [],
  #                     path: [],
  #                     stacktrace: #Splode.Stacktrace<>,
  #                     class: :invalid
  #                   },
  #                   %Ash.Error.Changes.Required{
  #                     field: :name,
  #                     type: :attribute,
  #                     resource: AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec,
  #                     splode: Ash.Error,
  #                     bread_crumbs: [],
  #                     vars: [],
  #                     path: [],
  #                     stacktrace: #Splode.Stacktrace<>,
  #                     class: :invalid
  #                   }
  #                 ],
  #                 data: #AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec<
  #                   __meta__: #Ecto.Schema.Metadata<:built, "">,
  #                   name: nil,
  #                   destination: nil,
  #                   type: :has_many,
  #                   public?: false,
  #                   required?: false,
  #                   primary_key?: false,
  #                   sensitive?: false,
  #                   aggregates: %{},
  #                   calculations: %{},
  #                   ...
  #                 >,
  #                 valid?: false
  #               >,
  #               name: "form[relationship_specs][0]",
  #               data: nil,
  #               form_keys: [],
  #               forms: %{},
  #               domain: AshStudio.Tasks,
  #               method: "post",
  #               submit_errors: nil,
  #               id: "form_relationship_specs_0",
  #               transform_errors: nil,
  #               original_data: nil,
  #               transform_params: nil,
  #               prepare_params: nil,
  #               prepare_source: nil,
  #               raw_params: %{
  #                 "_form_type" => "create",
  #                 "_persistent_id" => "0",
  #                 "_touched" => "name,type,required?,destination,calculations,aggregates,__lateral_join_source__,__metadata__,__order__,__meta__,primary_key?,public?,sensitive?,__lateral_join_source__,__meta__,__metadata__,__order__,_form_type,_touched,aggregates,calculations,destination,name,primary_key?,public?,required?,sensitive?,type",
  #                 "_unused_destination" => "",
  #                 "_unused_name" => "",
  #                 "_unused_public?" => "",
  #                 "destination" => "",
  #                 "name" => "",
  #                 "public?" => "false",
  #                 "type" => "belongs_to"
  #               },
  #               warn_on_unhandled_errors?: true,
  #               any_removed?: false,
  #               added?: true,
  #               changed?: true,
  #               touched_forms: MapSet.new([:name, :type, :required?, :destination,
  #                :calculations, :aggregates, :__lateral_join_source__, :__metadata__,
  #                :__order__, :__meta__, :primary_key?, :public?, :sensitive?,
  #                "__lateral_join_source__", ...]),
  #               valid?: false,
  #               errors: true,
  #               submitted_once?: false,
  #               just_submitted?: false,
  #               ...
  #             >
  #           ]
  #         },
  #         domain: AshStudio.Tasks,
  #         method: "post",
  #         submit_errors: nil,
  #         id: "form",
  #         transform_errors: nil,
  #         original_data: nil,
  #         transform_params: nil,
  #         prepare_params: nil,
  #         prepare_source: nil,
  #         raw_params: %{
  #           "_unused_default_actions" => [""],
  #           "_unused_domain_module_name" => "",
  #           "_unused_extensions" => [""],
  #           "_unused_ignore_if_exists?" => "",
  #           "_unused_primary_key_name" => "",
  #           "_unused_primary_key_type" => "",
  #           "_unused_resource_module_name" => "",
  #           "_unused_timestamps?" => "",
  #           "default_actions" => [],
  #           "domain_module_name" => "",
  #           "extensions" => [],
  #           "ignore_if_exists?" => "true",
  #           "primary_key_name" => "id",
  #           "primary_key_type" => "uuid_v4",
  #           "relationship_specs" => %{
  #             "0" => %{
  #               "_form_type" => "create",
  #               "_persistent_id" => "0",
  #               "_touched" => "name,type,required?,destination,calculations,aggregates,__lateral_join_source__,__metadata__,__order__,__meta__,primary_key?,public?,sensitive?,__lateral_join_source__,__meta__,__metadata__,__order__,_form_type,_touched,aggregates,calculations,destination,name,primary_key?,public?,required?,sensitive?,type",
  #               "_unused_destination" => "",
  #               "_unused_name" => "",
  #               "_unused_public?" => "",
  #               "destination" => "",
  #               "name" => "",
  #               "public?" => "false",
  #               "type" => "belongs_to"
  #             }
  #           },
  #           "resource_module_name" => "Foo",
  #           "timestamps?" => "true"
  #         },
  #         warn_on_unhandled_errors?: true,
  #         any_removed?: false,
  #         added?: false,
  #         changed?: true,
  #         touched_forms: MapSet.new(["_form_type", "_touched",
  #          "_unused_default_actions", "_unused_domain_module_name",
  #          "_unused_extensions", "_unused_ignore_if_exists?",
  #          "_unused_primary_key_name", "_unused_primary_key_type",
  #          "_unused_resource_module_name", "_unused_timestamps?", "default_actions",
  #          "domain_module_name", "extensions", "ignore_if_exists?",
  #          "primary_key_name", "primary_key_type", "relationship_specs",
  #          "resource_module_name", "timestamps?"]),
  #         valid?: false,
  #         errors: true,
  #         submitted_once?: false,
  #         just_submitted?: false,
  #         ...
  #       >,
  #       impl: Phoenix.HTML.FormData.AshPhoenix.Form,
  #       id: "form",
  #       name: "form",
  #       data: nil,
  #       action: nil,
  #       hidden: [
  #         _touched: "_form_type,_touched,_unused_default_actions,_unused_domain_module_name,_unused_extensions,_unused_ignore_if_exists?,_unused_primary_key_name,_unused_primary_key_type,_unused_resource_module_name,_unused_timestamps?,default_actions,domain_module_name,extensions,ignore_if_exists?,primary_key_name,primary_key_type,relationship_specs,resource_module_name,timestamps?",
  #         _form_type: "create"
  #       ],
  #       params: %{
  #         "_unused_default_actions" => [""],
  #         "_unused_domain_module_name" => "",
  #         "_unused_extensions" => [""],
  #         "_unused_ignore_if_exists?" => "",
  #         "_unused_primary_key_name" => "",
  #         "_unused_primary_key_type" => "",
  #         "_unused_resource_module_name" => "",
  #         "_unused_timestamps?" => "",
  #         "default_actions" => [],
  #         "domain_module_name" => "",
  #         "extensions" => [],
  #         "ignore_if_exists?" => "true",
  #         "primary_key_name" => "id",
  #         "primary_key_type" => "uuid_v4",
  #         "relationship_specs" => %{
  #           "0" => %{
  #             "_form_type" => "create",
  #             "_persistent_id" => "0",
  #             "_touched" => "name,type,required?,destination,calculations,aggregates,__lateral_join_source__,__metadata__,__order__,__meta__,primary_key?,public?,sensitive?,__lateral_join_source__,__meta__,__metadata__,__order__,_form_type,_touched,aggregates,calculations,destination,name,primary_key?,public?,required?,sensitive?,type",
  #             "_unused_destination" => "",
  #             "_unused_name" => "",
  #             "_unused_public?" => "",
  #             "destination" => "",
  #             "name" => "",
  #             "public?" => "false",
  #             "type" => "belongs_to"
  #           }
  #         },
  #         "resource_module_name" => "Foo",
  #         "timestamps?" => "true"
  #       },
  #       errors: [],
  #       options: [method: "post"],
  #       index: nil
  #     }
  #   end
end
