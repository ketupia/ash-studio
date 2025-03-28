defmodule AshStudio.CodeGen.Resource do
  @moduledoc """
  Reads resource information.
  Creates the `mix ash.gen.resource` command to create resource.
  """
  use Ash.Resource,
    domain: AshStudio.CodeGen,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "resource"
  end

  actions do
    create :plan do
      argument :name, :string,
        allow_nil?: false,
        description: "Name of the resource to generate",
        public?: true

      # argument :fields, {:array, :string},
      #   default: [],
      #   description: "Fields to add to the resource",
      #   public?: true

      argument :domain, :string,
        description: "Domain to add the resource to",
        public?: true

      change fn changeset, _ctx ->
        name = Ash.Changeset.get_argument(changeset, :name)
        domain = Ash.Changeset.get_argument(changeset, :domain)

        app =
          Mix.Project.config()[:app]
          |> to_string()
          |> Macro.camelize()

        # module = "#{app}.#{domain}.#{name}"

        command =
          [
            "mix ash.gen.resource",
            name,
            "--uuid-primary-key id",
            "--timestamps",
            "--default-actions read,create,update,destroy",
            "--extend postgres,Ash.Notifier.PubSub"
            # "--domain #{app}.#{domain}"
          ]
          |> Enum.join(" ")

        Ash.Changeset.change_attribute(changeset, :command, command)
      end
    end
  end

  attributes do
    integer_primary_key :id

    attribute :command, :string,
      public?: true,
      description: "Command to run to generate the resource"
  end
end
