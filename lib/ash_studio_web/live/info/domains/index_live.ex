defmodule AshStudioWeb.Info.Domains.IndexLive do
  use AshStudioWeb, :live_view

  import AshStudioWeb.AshStudioComponents
  alias AshStudio.Mermaid

  @impl true
  def mount(_params, _session, socket) do
    AshStudio.Info.reset_domain_and_resource_data()
    domains = AshStudio.Info.read_domains!()

    {:ok,
     socket
     |> assign(domains: domains)
     |> assign_selected_domain(List.first(domains))}
  end

  defp assign_selected_domain(socket, domain) do
    class_diagram_url =
      Ash.Domain.Info.Diagram.mermaid_class_diagram(domain.name)
      |> Mermaid.generate_image_url()

    er_diagram_url =
      Ash.Domain.Info.Diagram.mermaid_er_diagram(domain.name)
      |> Mermaid.generate_image_url()

    socket
    |> assign(selected_domain: domain)
    |> assign(class_diagram_url: class_diagram_url)
    |> assign(er_diagram_url: er_diagram_url)
    |> assign(:resources, AshStudio.Info.domain_resources!(domain.name))
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
      <img :if={@er_diagram_url} src={@er_diagram_url} />

      <h2 class="text-xl font-semibold">Class Diagram</h2>
      <img :if={@class_diagram_url} src={@class_diagram_url} />
    </div>
    """
  end
end
