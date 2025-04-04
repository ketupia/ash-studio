defmodule AshStudio.Tasks.Ash.Gen.Resource do
  @moduledoc """
  Reads resource information.
  Creates the `mix ash.gen.resource` command to create resource.
  """
  alias AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec
  alias AshStudio.Tasks.Ash.Gen.ResourceAttributeSpec

  use Ash.Resource,
    domain: AshStudio.Tasks,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "task.ash.gen.resource"
  end

  actions do
    create :command_line do
      argument :resource_module_name, :string,
        allow_nil?: false,
        description: "Name of the resource to generate",
        public?: true,
        constraints: [trim?: true]

      argument :domain_module_name, :string,
        allow_nil?: false,
        description: "Name of the domain to generate",
        public?: true,
        default: "",
        constraints: [trim?: true, allow_empty?: true]

      argument :timestamps?, :boolean,
        description: "Adds inserted_at and updated_at timestamps to the resource",
        public?: true,
        default: true

      argument :ignore_if_exists?, :boolean,
        description: "Does nothing if the resource already exists",
        default: true,
        public?: true

      argument :primary_key_type, :atom,
        constraints: [one_of: [:none, :uuid_v4, :uuid_v7, :integer]],
        default: :uuid_v4,
        public?: true

      argument :primary_key_name, :string,
        description: "The name of the primary key",
        default: "id",
        public?: true,
        constraints: [trim?: true]

      argument :default_actions, {:array, :string},
        description: "The default actions to add to the resource",
        default: [],
        public?: true

      argument :extensions, {:array, :string},
        description: "List of extensions to add to the resource",
        default: [],
        public?: true

      argument :attribute_specs, {:array, ResourceAttributeSpec} do
        description "List of attributes to add to the resource"
        default []
        public? true
      end

      argument :relationship_specs, {:array, ResourceRelationshipSpec} do
        description "List of relationships to add to the resource"
        default []
        public? true
      end

      change fn changeset, _ctx ->
        resource_module_name =
          Ash.Changeset.get_argument(changeset, :resource_module_name)

        domain_module_name =
          Ash.Changeset.get_argument(changeset, :domain_module_name)

        command =
          [
            "mix ash.gen.resource",
            resource_module_name,
            domain_option(changeset),
            timestamp_option(changeset),
            ignore_if_exists_option(changeset),
            primary_key_option(changeset),
            default_action_option(changeset),
            extend_option(changeset),
            attribute_specs(changeset),
            relationship_specs(changeset)
          ]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" ")

        Ash.Changeset.change_attribute(changeset, :command, command)
      end
    end
  end

  defp relationship_specs(changeset) do
    Ash.Changeset.get_argument(changeset, :relationship_specs)
    |> Enum.map_join(" ", fn relationship ->
      "--relationship #{relationship.type}:#{relationship.name}:#{relationship.destination}" <>
        if relationship.public? do
          ":public"
        else
          ""
        end <>
        if relationship.required? and relationship.type == :belongs_to do
          ":required"
        else
          ""
        end <>
        if relationship.primary_key? and relationship.type == :belongs_to do
          ":primary_key"
        else
          ""
        end <>
        if relationship.sensitive? and relationship.type == :belongs_to do
          ":sensitive"
        else
          ""
        end
    end)
  end

  defp attribute_specs(changeset) do
    Ash.Changeset.get_argument(changeset, :attribute_specs)
    |> Enum.map_join(" ", fn attribute ->
      "--attribute #{attribute.name}:#{attribute.type}" <>
        if attribute.required? do
          ":required"
        else
          ""
        end <>
        if attribute.public? do
          ":public"
        else
          ""
        end <>
        if attribute.primary_key? do
          ":primary_key"
        else
          ""
        end <>
        if attribute.sensitive? do
          ":sensitive"
        else
          ""
        end
    end)
  end

  defp extend_option(changeset) do
    csv =
      Ash.Changeset.get_argument(changeset, :extensions)
      |> Enum.reject(&(&1 == ""))
      |> Enum.join(",")

    if csv == "" do
      nil
    else
      "--extend #{csv}"
    end
  end

  defp default_action_option(changeset) do
    csv =
      Ash.Changeset.get_argument(changeset, :default_actions)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.join(",")

    if csv == "" do
      nil
    else
      "--default-actions #{csv}"
    end
  end

  defp primary_key_option(changeset) do
    primary_key_name = Ash.Changeset.get_argument(changeset, :primary_key_name)

    Ash.Changeset.get_argument(changeset, :primary_key_type)
    |> case do
      :uuid_v4 ->
        "--primary-key-uuid #{primary_key_name}"

      :uuid_v7 ->
        "--primary-key-uuid-v7 #{primary_key_name}"

      :integer ->
        "--primary-key-integer #{primary_key_name}"

      _ ->
        nil
    end
  end

  defp ignore_if_exists_option(changeset) do
    if Ash.Changeset.get_argument(changeset, :ignore_if_exists?),
      do: "--ignore-if-exists",
      else: nil
  end

  defp timestamp_option(changeset) do
    if Ash.Changeset.get_argument(changeset, :timestamps?), do: "--timestamps", else: nil
  end

  defp domain_option(changeset) do
    Ash.Changeset.get_argument(changeset, :domain_module_name)
    |> case do
      nil -> nil
      "" -> nil
      domain_module_name -> "--domain #{domain_module_name}"
    end
  end

  attributes do
    integer_primary_key :id, public?: false

    attribute :command, :string,
      allow_nil?: false,
      public?: true,
      description: "Command to run to generate the domain"
  end
end
