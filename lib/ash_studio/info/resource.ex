defmodule AshStudio.Info.Resource do
  @moduledoc """
  Ash Resource Information
  """

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    domain: AshStudio.Info

  code_interface do
    define :read
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:name, :domain, :description, :attributes]

    read :for_domain do
      argument :domain_name, :atom, allow_nil?: false

      filter expr(domain == ^arg(:domain_name))
    end
  end

  attributes do
    attribute :name, :atom,
      primary_key?: true,
      allow_nil?: false,
      public?: true,
      description: "Name of the resource"

    attribute :domain, :atom,
      allow_nil?: false,
      public?: true,
      description: "Domain of the resource"

    attribute :description, :string, default: "", public?: true

    attribute :attributes, {:array, :term}, public?: true
  end
end
