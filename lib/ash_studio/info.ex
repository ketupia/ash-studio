defmodule AshStudio.Info do
  @moduledoc """
  Info domain - use to get information about Ash Domains and Resources
  """

  use Ash.Domain,
    otp_app: :ash_studio,
    extensions: [AshAi]

  tools do
    tool :read_domains, AshStudio.Info.Domain, :read_domains
    tool :read_resources, AshStudio.Info.Resource, :read_resources
  end

  resources do
    resource AshStudio.Info.Domain do
      define :read_domains, action: :read
      define :get_domain_by_name, action: :read, get_by: :name
    end

    resource AshStudio.Info.Resource do
      define :read_resources, action: :read
      define :domain_resources, action: :for_domain, args: [:domain_name]
      define :get_resource_by_name, action: :read, get_by: :name
    end
  end

  domain do
    description "Provides Information about Domains and Resources"
  end

  def host_domains(),
    do:
      Application.get_env(:ash_studio, :host_app)
      |> Application.get_env(:ash_domains)

  def reset_domain_and_resource_data() do
    Ash.bulk_destroy!(AshStudio.Info.Domain, :destroy, %{})
    Ash.bulk_destroy!(AshStudio.Info.Resource, :destroy, %{})

    host_domains()
    |> Enum.each(fn domain ->
      AshStudio.Info.Domain
      |> Ash.Changeset.for_create(:create, %{
        name: domain,
        description: Ash.Domain.Info.description(domain)
      })
      |> Ash.create!()
    end)

    host_domains()
    |> Enum.each(fn domain ->
      Ash.Domain.Info.resources(domain)
      |> Enum.each(fn resource ->
        params = %{
          name: resource,
          domain: domain,
          description: Ash.Resource.Info.description(resource),
          attributes:
            Ash.Resource.Info.attributes(resource)
            |> Enum.reject(& &1.generated?)
            |> Enum.map(fn attr ->
              Map.take(attr, [
                :name,
                :type,
                :allow_nil?,
                :primary_key?,
                :public?,
                :writable?,
                :always_select?,
                :select_by_default?,
                :description
              ])
              |> Map.put(:default, inspect(attr.default))
              |> Map.put(:update_default, inspect(attr.update_default))
            end)
        }

        AshStudio.Info.Resource
        |> Ash.Changeset.for_create(:create, params)
        |> Ash.create!()
      end)
    end)
  end
end
