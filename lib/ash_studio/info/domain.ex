defmodule AshStudio.Info.Domain do
  @moduledoc """
  Ash Domain Information
  """

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    domain: AshStudio.Info

  code_interface do
    define :read
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:name, :description]
  end

  attributes do
    attribute :name, :atom,
      primary_key?: true,
      allow_nil?: false,
      public?: true,
      description: "Name of the domain"

    attribute :description, :string, default: "", public?: true
  end
end
