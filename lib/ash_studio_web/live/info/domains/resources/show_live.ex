defmodule AshStudioWeb.Info.Domains.Resources.ShowLive do
  alias AshStudio.Mermaid
  use AshStudioWeb, :live_view

  import AshStudioWeb.AshStudioComponents

  @impl true
  def mount(%{"domain" => _domain_str, "resource" => resource_str}, _session, socket) do
    AshStudio.Info.reset_domain_and_resource_data()
    resource = AshStudio.Info.get_resource_by_name!(resource_str)

    {:ok,
     socket
     |> assign(resource: resource)
     |> assign(
       policy_flowchart_url:
         Mermaid.generate_image_url(Ash.Policy.Chart.Mermaid.chart(resource.name))
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <h1>
        <.module_name module={@resource.name} />
      </h1>

      <p>{@resource.description}</p>

      <h2 class="text-xl font-semibold">Attributes</h2>
      <.table id="attributes-table" rows={@resource.attributes}>
        <:col :let={attr} label="name">
          <.icon :if={attr.primary_key?} name="hero-key" class="size-4" />
          {attr.name}
        </:col>
        <:col :let={attr} label="type">{inspect(attr.type)}</:col>
        <:col :let={attr} label="allow_nil?">{attr.allow_nil?}</:col>
        <:col :let={attr} label="description">{attr.description}</:col>
      </.table>

      <h2 class="text-xl font-semibold">Policy Flowchart</h2>
      <img :if={@policy_flowchart_url} src={@policy_flowchart_url} />

      <.back navigate="/studio/info/domains">Back to domains</.back>
    </div>
    """
  end
end
