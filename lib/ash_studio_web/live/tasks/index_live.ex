defmodule AshStudioWeb.Tasks.IndexLive do
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.menu space="small">
      <li>
        <.button_link variant="shadow" navigate="/tasks/ash/gen/domain">Domain</.button_link>
      </li>

      <li>
        <.button_link variant="shadow" navigate="/tasks/ash/gen/resource">Resource</.button_link>
      </li>
    </.menu>
    """
  end
end
