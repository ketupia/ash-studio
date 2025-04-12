defmodule AshStudioWeb.AboutLive do
  use AshStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.card variant="transparent" padding="medium">
        <.card_title title="About" />
        <.card_content>
          <p>
            This is an experimental or starter site aimed at building AI development tools for the Ash Framework.
            It is not yet an official Ash module.
          </p>

          <p>The premise is to have a single set of Ash resources that can be used by</p>
          <.ol>
            <li><.icon name="hero-check" class="size-6 text-green-500" /> Forms</li>
            <li><.icon name="hero-check" class="size-6 text-green-500" /> AI Chat Bots</li>
            <li><.icon name="hero-x-mark" class="size-6 text-red-500" /> AI Code Agents</li>
          </.ol>
        </.card_content>
      </.card>
    </div>
    """
  end
end
