defmodule AshStudio.Tasks.Ash.Gen.Resource do
  @moduledoc """
  Reads resource information.
  Creates the `mix ash.gen.resource` command to create resource.
  """
  use Ash.Resource,
    domain: AshStudio.Tasks,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "task.ash.gen.resource"
  end

  actions do
    create :plan do
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
        constraints: [trim?: true]

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
        default: :none,
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
            extend_option(changeset)
          ]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" ")

        Ash.Changeset.change_attribute(changeset, :command, command)
      end
    end
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

    # attribute :resource_module_name, :string do
    #   description "The module name of the resource"
    #   allow_nil? false
    #   constraints trim?: true, allow_empty?: false
    #   public? true
    # end

    # attribute :domain_module_name, :string do
    #   description "The domain module to add the resource to. i.e -d MyApp.MyDomain. This defaults to the resource's module name, minus the last segment."
    #   default ""
    #   public? true
    #   constraints trim?: true, allow_empty?: true
    # end

    # attribute :timestamps?, :boolean do
    #   description "Adds inserted_at and updated_at timestamps to the resource"
    #   default true
    #   public? true
    # end

    # attribute :ignore_if_exists?, :boolean do
    #   description "Does nothing if the resource already exists"
    #   default true
    #   public? true
    # end

    # attribute :primary_key_type, :atom do
    #   constraints one_of: [:none, :uuid_v4, :uuid_v7, :integer]
    #   default :uuid_v4
    #   public? true
    # end

    # attribute :primary_key_name, :string do
    #   description "The name of the primary key"
    #   default "id"
    #   public? true
    #   constraints trim?: true
    # end

    # attribute :default_actions_create?, :boolean do
    #   description "Adds create default actions to the resource"
    #   default true
    #   public? true
    # end

    # attribute :default_actions_read?, :boolean do
    #   description "Adds read default actions to the resource"
    #   default true
    #   public? true
    # end

    # attribute :default_actions_update?, :boolean do
    #   description "Adds update default actions to the resource"
    #   default true
    #   public? true
    # end

    # attribute :default_actions_destroy?, :boolean do
    #   description "Adds destroy default actions to the resource"
    #   default true
    #   public? true
    # end

    # attribute :extension_admin?, :boolean do
    #   description "Ash.Admin extension"
    #   default true
    #   public? true
    # end

    # attribute :extension_authorizer?, :boolean do
    #   description "Ash.Policy.Authorizer extension"
    #   default false
    #   public? true
    # end

    # attribute :extension_pubsub?, :boolean do
    #   description "Ash.Notifier.PubSub extension"
    #   default true
    #   public? true
    # end

    # attribute :extension_graphql?, :boolean do
    #   description "AshGraphql.Resource extension"
    #   default false
    #   public? true
    # end

    # attribute :extension_jsonapi?, :boolean do
    #   description "AshJsonApi.Resource extension"
    #   default false
    #   public? true
    # end

    # attribute :extension_postgres?, :boolean do
    #   description "Postgres extension"
    #   default true
    #   public? true
    # end
  end

  # calculations do
  #   calculate :command, :string, AshStudio.Tasks.Ash.Gen.CalculateResourceCommand
  # end
end
