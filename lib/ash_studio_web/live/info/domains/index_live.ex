defmodule AshStudioWeb.Info.Domains.IndexLive do
  use AshStudioWeb, :live_view

  import AshStudioWeb.AshStudioComponents

  @impl true
  def mount(_params, _session, socket) do
    AshStudio.Info.reset_domain_and_resource_data()
    domains = AshStudio.Info.read_domains!()

    {:ok,
     socket
     |> assign(domains: domains)
     |> assign_selected_domain(List.first(domains))
     |> assign_diagram(:class_diagram)
     |> assign_diagram(:er_diagram)}
  end

  defp assign_diagram(socket, chart_type, format \\ "svg") do
    domain = socket.assigns.selected_domain
    source = domain.name.module_info(:compile)[:source]

    suffix =
      case chart_type do
        :er_diagram ->
          "mermaid-er-diagram"

        :class_diagram ->
          "mermaid-class-diagram"
      end

    file = Mix.Mermaid.file(source, suffix, format)

    svg =
      if File.exists?(file) do
        file
      else
        nil
      end

    socket
    |> assign(chart_type, svg)
  end

  defp assign_selected_domain(socket, domain) do
    send(self(), :create_er_diagram)
    send(self(), :create_class_diagram)

    socket
    |> assign(selected_domain: domain)
    |> assign_diagram(:class_diagram)
    |> assign_diagram(:er_diagram)
    |> assign(:resources, AshStudio.Info.domain_resources!(domain.name))
  end

  @impl true
  def handle_info(:create_er_diagram, socket) do
    domain = socket.assigns.selected_domain
    source = domain.name.module_info(:compile)[:source]

    Mix.Mermaid.generate_diagram(
      source,
      "mermaid-er-diagram",
      "svg",
      Ash.Domain.Info.Diagram.mermaid_er_diagram(domain.name),
      "Generated ER Diagram for #{inspect(domain.name)}"
    )

    {:noreply,
     socket
     |> assign_diagram(:er_diagram)}
  end

  def handle_info(:create_class_diagram, socket) do
    domain = socket.assigns.selected_domain

    source =
      domain.name.module_info(:compile)[:source]

    Mix.Mermaid.generate_diagram(
      source,
      "mermaid-class-diagram",
      "svg",
      Ash.Domain.Info.Diagram.mermaid_class_diagram(domain.name),
      "Generated Class Diagram for #{inspect(domain.name)}"
    )

    {:noreply,
     socket
     |> assign_diagram(:class_diagram)}
  end

  @impl true
  def handle_event("select_domain", %{"value" => domain}, socket) do
    atom_name = String.to_existing_atom(domain)
    selected_domain = Enum.find(socket.assigns.domains, &(&1.name == atom_name))

    {:noreply, socket |> assign_selected_domain(selected_domain)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <h1 class="text-2xl font-bold">Domains</h1>
      <select name="domain" value={@selected_domain.name} phx-click="select_domain">
        <option :for={domain <- @domains} value={domain.name}>
          <.module_name module={domain.name} />
        </option>
      </select>

      <p>{@selected_domain.description}</p>

      <div>
        <h2 class="text-xl font-semibold">Resources</h2>
        <ul>
          <li :for={resource <- @resources}>
            <.link
              navigate={"/studio/info/domains/#{@selected_domain.name}/resources/#{resource.name}"}
              class="underline"
            >
              <.module_name module={resource.name} />
            </.link>
          </li>
        </ul>
      </div>

      <h2 class="text-xl font-semibold">Entity Relationship Diagram</h2>
      <div :if={@er_diagram}>
        {raw(File.read!(@er_diagram))}
      </div>
      <p :if={is_nil(@er_diagram)}>
        Generating diagram...
      </p>

      <h2 class="text-xl font-semibold">Class Diagram</h2>
      <div :if={@class_diagram}>
        {raw(File.read!(@class_diagram))}
      </div>
      <p :if={is_nil(@class_diagram)}>
        Generating diagram...
      </p>
    </div>
    """
  end
end
