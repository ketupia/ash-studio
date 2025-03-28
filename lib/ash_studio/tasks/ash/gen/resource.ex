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
        public?: true

      # argument :fields, {:array, :string},
      #   default: [],
      #   description: "Fields to add to the resource",
      #   public?: true

      argument :domain_module_name, :string,
        description: "Domain to add the resource to",
        public?: true,
        allow_nil?: true

      change fn changeset, _ctx ->
        name =
          Ash.Changeset.get_argument(changeset, :name)
          |> String.trim()

        domain =
          (Ash.Changeset.get_argument(changeset, :domain) ||
             "")
          |> String.trim()

        full_name =
          if String.contains?(name, ".") do
            [name]
          else
            app = Mix.Project.config()[:app] |> to_string()
            [app, name]
          end
          |> Enum.map_join(".", &Macro.camelize/1)

        command =
          [
            "mix ash.gen.resource",
            full_name,
            if(domain == "", do: nil, else: "--domain #{domain}"),
            "--uuid-primary-key id",
            "--timestamps",
            "--default-actions read,create,update,destroy",
            "--extend postgres,Ash.Notifier.PubSub"
          ]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" ")

        Ash.Changeset.change_attribute(changeset, :command, command)
      end
    end
  end

  attributes do
    integer_primary_key :id, public?: false

    attribute :command, :string,
      allow_nil?: false,
      public?: true,
      description: "Command to run to generate the resource"
  end
end
