defmodule AshStudio.Tasks.Ash.Codegen do
  @moduledoc """
  Creates the `mix ash.gencodegen` command for managing code migrations.
  """

  use Ash.Resource,
    domain: AshStudio.Tasks

  actions do
    create :check do
      description "Checks if there are any migrations to run. No files are created, returns an exit(1) code if any code would need to be generated"

      change fn changeset, _ctx ->
        Ash.Changeset.change_attribute(changeset, :command, "mix ash.codegen --check")
      end
    end

    create :dry_run do
      description "Performs a dry run of the codegen command. No files are created, instead the new generated code is printed to the console"

      change fn changeset, _ctx ->
        Ash.Changeset.change_attribute(changeset, :command, "mix ash.codegen --check")
      end
    end

    create :command_line do
      description "Plans the codegen command to runs all codegen tasks for any extension on any resource/domain in your application."

      argument :migration_file_name, :string,
        allow_nil?: false,
        description: "Name of the migration file to generate",
        public?: true,
        default: "",
        constraints: [trim?: true, allow_empty?: true]

      change fn changeset, _ctx ->
        command =
          Ash.Changeset.get_argument(changeset, :migration_file_name)
          |> String.split()
          |> Enum.map(&String.trim/1)
          |> Enum.reject(&(String.length(&1) == 0))
          |> Enum.join("_")
          |> String.downcase()
          |> case do
            "" -> ""
            migration_file_name -> "mix ash.codegen #{migration_file_name}"
          end

        Ash.Changeset.change_attribute(changeset, :command, command)
      end
    end
  end

  attributes do
    integer_primary_key :id, public?: false

    attribute :command, :string,
      allow_nil?: true,
      public?: true,
      description: "Command to run to generate the domain"
  end
end
