defmodule AshStudio.Tasks.Ash.Gen.Domain do
  @moduledoc """
  Creates the `mix ash.gen.domain` command to create domain.
  """

  use Ash.Resource,
    domain: AshStudio.Tasks,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "task.ash.gen.domain"
  end

  actions do
    create :command_line do
      description "Creates the command to generate an Ash Domain"

      argument :domain_module_name, :string,
        allow_nil?: false,
        description: "Name of the domain to generate",
        public?: true

      change fn changeset, _ctx ->
        command =
          (Ash.Changeset.get_argument(changeset, :domain_module_name) ||
             "")
          |> case do
            "" -> ""
            name -> "mix ash.gen.domain " <> name
          end

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
