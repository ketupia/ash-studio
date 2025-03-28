defmodule AshStudio.Tasks.Ash.Gen.Domain do
  @moduledoc """
  Creates the `mix ash.gen.resource` command to create resource.
  """
  use Ash.Resource,
    domain: AshStudio.Tasks,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "task.ash.gen.domain"
  end

  actions do
    create :plan do
      argument :domain_module_name, :string,
        allow_nil?: false,
        description: "Name of the domain to generate",
        public?: true

      change fn changeset, _ctx ->
        domain_module_name =
          Ash.Changeset.get_argument(changeset, :domain_module_name)

        command =
          ["mix ash.gen.domain", domain_module_name]
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
      description: "Command to run to generate the domain"
  end
end
