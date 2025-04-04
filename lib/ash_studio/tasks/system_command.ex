defmodule AshStudio.Tasks.SystemCommand do
  @moduledoc """
  A command to be run in the system.
  """
  use Ash.Resource,
    data_layer: :embedded,
    embed_nil_values?: false

  attributes do
    attribute :command, :string do
      allow_nil? false
      constraints trim?: true, allow_empty?: false
      description "Command to run"
    end

    attribute :args, {:array, :string} do
      allow_nil? false
      description "the command arguments"
    end
  end
end
