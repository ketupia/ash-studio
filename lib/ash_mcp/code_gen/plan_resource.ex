defmodule AshMcp.CodeGen.PlanResource do
  @moduledoc """
  Creates the `mix ash.gen.resource` command to create resource.
  """
  use Ash.Resource,
    domain: AshMcp.CodeGen,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "plan_resource"
  end

  resource do
    require_primary_key? false
  end

  actions do
    create :plan do
      argument :name, :string, allow_nil?: false
      argument :fields, {:array, :string}, default: []
      argument :domain, :string

      change fn changeset, _ctx ->
        name = Ash.Changeset.get_argument(changeset, :name)
        domain = Ash.Changeset.get_argument(changeset, :domain)

        app = Mix.Project.config()[:app] |> to_string() |> Macro.camelize()
        module = "#{app}.#{domain}.#{name}"

        command =
          [
            "mix ash.gen.resource",
            module,
            "--uuid-primary-key id",
            "--timestamps",
            "--default-actions read,create,update,destroy",
            "--extend postgres,Ash.Notifier.PubSub",
            "--domain #{app}.#{domain}"
          ]
          |> Enum.join(" ")

        Ash.Changeset.change_attribute(changeset, :command, command)
      end
    end
  end

  attributes do
    attribute :command, :string, writable?: false
  end
end
