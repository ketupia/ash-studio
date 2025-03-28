defmodule AshStudio.CodeGen.Domain do
  @moduledoc """
  Creates the `mix ash.gen.resource` command to create resource.
  """
  use Ash.Resource,
    domain: AshStudio.CodeGen,
    extensions: [AshJsonApi.Resource]

  json_api do
    type "domain"
  end

  actions do
    read :info do
      argument :name, :string,
        allow_nil?: false,
        description: "Name of the domain",
        public?: true
    end
  end

  attributes do
    attribute :name, :atom,
      allow_nil?: false,
      primary_key?: true,
      public?: true,
      description: "Name of the domain"

    attribute :description, :string,
      public?: true,
      description: "Description of the domain"
  end
end
