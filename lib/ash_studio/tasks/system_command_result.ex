defmodule AshStudio.Tasks.SystemCommandResult do
  @moduledoc """
  A result of a system command
  """
  use Ash.Resource,
    domain: AshStudio.Tasks

  actions do
    create :run do
      argument :system_command, AshStudio.Tasks.SystemCommand, allow_nil?: false

      change fn changeset, _ctx ->
        system_command =
          Ash.Changeset.get_argument(changeset, :system_command)

        {stdout, exit_code} = System.cmd(system_command.command, system_command.args)

        changeset
        |> Ash.Changeset.change_attribute(:stdout, stdout)
        |> Ash.Changeset.change_attribute(:exit_code, exit_code)
      end
    end
  end

  attributes do
    integer_primary_key :id, public?: false

    attribute :stdout, :string do
      allow_nil? false
      description "Standard output of the command"
    end

    attribute :exit_code, :integer do
      allow_nil? false
      description "Exit code of the command"
    end
  end
end
