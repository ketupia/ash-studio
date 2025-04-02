defmodule AshStudio.Tasks.Ash.Gen.ResourceRelationshipSpec do
  @moduledoc """
  a relationship for a resource
  """

  use Ash.Resource,
    data_layer: :embedded,
    embed_nil_values?: false

  attributes do
    attribute :name, :string do
      allow_nil? false
      constraints trim?: true, allow_empty?: false
      public? true
    end

    attribute :destination, :string do
      allow_nil? false
      constraints trim?: true, allow_empty?: false
      public? true
    end

    attribute :type, :atom do
      allow_nil? false
      public? true
      default :has_many

      constraints one_of: [
                    :belongs_to,
                    :has_many,
                    :has_one,
                    :many_to_many
                  ]
    end

    attribute :public?, :boolean do
      public? true
      default false
    end

    attribute :required?, :boolean do
      public? true
      default false
    end

    attribute :primary_key?, :boolean do
      public? true
      default false
    end

    attribute :sensitive?, :boolean do
      public? true
      default false
    end
  end

  identities do
    identity :unique_name, [:name], message: "Relationship names must be unique"
  end
end
