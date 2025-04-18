defmodule AshStudioWeb.Info.Domains.Resources.ShowLive do
  use AshStudioWeb, :live_view

  import AshStudioWeb.AshStudioComponents

  @impl true
  def mount(%{"domain" => _domain_str, "resource" => resource_str}, _session, socket) do
    AshStudio.Info.reset_domain_and_resource_data()
    resource = AshStudio.Info.get_resource_by_name!(resource_str)

    send(self(), :create_policy_flowchart)

    {:ok,
     socket
     |> assign(resource: resource)
     |> assign_diagram(:policy_flowchart)}
  end

  defp assign_diagram(socket, chart_type, format \\ "svg") do
    resource = socket.assigns.resource
    source = resource.name.module_info(:compile)[:source]

    suffix =
      case chart_type do
        :policy_flowchart -> "policy-flowchart"
      end

    file = Mix.Mermaid.file(source, suffix, format)

    svg =
      if File.exists?(file) do
        file
      else
        nil
      end

    socket |> assign(chart_type, svg)
  end

  @impl true
  def handle_info(:create_policy_flowchart, socket) do
    resource = socket.assigns.resource
    source = resource.name.module_info(:compile)[:source]

    Mix.Mermaid.generate_diagram(
      source,
      "policy-flowchart",
      "svg",
      Ash.Policy.Chart.Mermaid.chart(resource.name),
      "Generated Mermaid Flow Chart for #{inspect(resource.name)}"
    )

    {:noreply,
     socket
     |> assign_diagram(:policy_flowchart)}
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
        <:col :let={attr} label="type">{attr.type}</:col>
        <:col :let={attr} label="allow_nil?">{attr.allow_nil?}</:col>
        <:col :let={attr} label="description">{attr.description}</:col>
      </.table>

      <h2 class="text-xl font-semibold">Policy Flowchart</h2>
      <div :if={@policy_flowchart}>
        {raw(File.read!(@policy_flowchart))}
      </div>
      <p :if={is_nil(@policy_flowchart)}>
        Generating diagram...
      </p>

      <.back navigate="/studio/info/domains">Back to domains</.back>
    </div>
    """
  end
end
