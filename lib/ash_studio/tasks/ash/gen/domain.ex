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
    create :command_line do
      description "Creates the command to generate an Ash Domain"

      argument :domain_module_name, :string,
        allow_nil?: false,
        description: "Name of the domain to generate",
        public?: true

      change fn changeset, _ctx ->
        domain_module_name =
          Ash.Changeset.get_argument(changeset, :domain_module_name) || ""

        command = command(domain_module_name)

        Ash.Changeset.change_attribute(changeset, :command, command)
      end
    end
  end

  defp command(domain_module_name) do
    module_name_parts =
      String.split(domain_module_name, ".")
      |> Enum.map(&Macro.camelize/1)

    module_name_parts =
      if hd(module_name_parts) == app_name() do
        module_name_parts
      else
        [app_name() | module_name_parts]
      end

    domain_module_name =
      module_name_parts
      |> Enum.join(".")

    ["mix ash.gen.domain", domain_module_name]
    |> Enum.join(" ")
  end

  attributes do
    integer_primary_key :id, public?: false

    attribute :command, :string,
      allow_nil?: false,
      public?: true,
      description: "Command to run to generate the domain"
  end

  defp app_name() do
    {:ok, application} = :application.get_application(__MODULE__)
    Macro.camelize(to_string(application))
  end
end
