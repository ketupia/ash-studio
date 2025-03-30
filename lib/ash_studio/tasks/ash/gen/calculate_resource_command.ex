defmodule AshStudio.Tasks.Ash.Gen.CalculateResourceCommand do
  @moduledoc """
  Convert a resource to a command line
  """
  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    records
    |> Enum.map(fn resource ->
      ([
         "mix ash.gen.resource",
         resource.resource_module_name,
         if(resource.domain_module_name == "",
           do: nil,
           else: "--domain #{resource.domain_module_name}"
         ),
         if(resource.timestamps?, do: "--timestamps", else: nil),
         if(resource.ignore_if_exists?, do: "--ignore-if-exists", else: nil),
         primary_key_command_line(resource),
         default_actions_command_line(resource),
         extensions_command_line(resource)
       ] ++
         attribute_command_lines(resource) ++
         relationship_command_lines(resource))
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")
    end)
  end

  defp relationship_command_lines(resource) do
    resource.relationship_specs
    |> Enum.map(fn relationship ->
      "--relationship #{relationship.type}:#{relationship.name}:#{relationship.destination}" <>
        if relationship.public? do
          ":public"
        else
          ""
        end <>
        if relationship.required? and relationship.type == :belongs_to do
          ":required"
        else
          ""
        end <>
        if relationship.primary_key? and relationship.type == :belongs_to do
          ":primary_key"
        else
          ""
        end <>
        if relationship.sensitive? and relationship.type == :belongs_to do
          ":sensitive"
        else
          ""
        end
    end)
  end

  defp attribute_command_lines(resource) do
    resource.attribute_specs
    |> Enum.map(fn attribute ->
      "--attribute #{attribute.name}:#{attribute.type}" <>
        if attribute.required? do
          ":required"
        else
          ""
        end <>
        if attribute.public? do
          ":public"
        else
          ""
        end <>
        if attribute.primary_key? do
          ":primary_key"
        else
          ""
        end <>
        if attribute.sensitive? do
          ":sensitive"
        else
          ""
        end
    end)
  end

  defp extensions_command_line(resource) do
    csv =
      [
        if(resource.extension_admin?, do: "AshAdmin.Resource", else: nil),
        if(resource.extension_authorizer?, do: "Ash.Policy.Authorizer", else: nil),
        if(resource.extension_pubsub?, do: "Ash.Notifier.PubSub", else: nil),
        if(resource.extension_graphql?, do: "AshGraphql.Resource", else: nil),
        if(resource.extension_jsonapi?, do: "AshJsonApi.Resource", else: nil),
        if(resource.extension_postgres?, do: "postgres", else: nil)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(",")

    if csv == "" do
      nil
    else
      "--extend #{csv}"
    end
  end

  defp default_actions_command_line(resource) do
    csv =
      [
        if(resource.default_actions_create?, do: "create", else: nil),
        if(resource.default_actions_read?, do: "read", else: nil),
        if(resource.default_actions_update?, do: "update", else: nil),
        if(resource.default_actions_destroy?, do: "destroy", else: nil)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(",")

    if csv == "" do
      nil
    else
      "--default-actions #{csv}"
    end
  end

  defp primary_key_command_line(resource) do
    cond do
      resource.primary_key_type == :uuid_v4 ->
        "--primary-key-uuid #{resource.primary_key_name}"

      resource.primary_key_type == :uuid_v7 ->
        "--primary-key-uuid-v7 #{resource.primary_key_name}"

      resource.primary_key_type == :integer ->
        "--primary-key-integer #{resource.primary_key_name}"

      true ->
        nil
    end
  end
end
