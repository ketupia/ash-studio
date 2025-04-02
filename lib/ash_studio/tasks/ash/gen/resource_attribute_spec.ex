defmodule AshStudio.Tasks.Ash.Gen.ResourceAttributeSpec do
  @moduledoc """
  an attribute for a resource
  """
  use Ash.Resource,
    data_layer: :embedded,
    embed_nil_values?: false

  attributes do
    attribute :name, :string do
      allow_nil? false
      constraints trim?: true, allow_empty?: false
      public? true
      description "Name of the attribute"
    end

    attribute :type, :atom do
      allow_nil? false
      public? true
      description "Type of the attribute"
      constraints one_of: Keyword.keys(Ash.Type.short_names())
    end

    attribute :required?, :boolean do
      public? true
      default false
    end

    attribute :primary_key?, :boolean do
      public? true
      default false
    end

    attribute :public?, :boolean do
      public? true
      default false
    end

    attribute :sensitive?, :boolean do
      public? true
      default false
    end
  end

  identities do
    identity :unique_name, [:name], message: "Attribute names must be unique"
  end
end
