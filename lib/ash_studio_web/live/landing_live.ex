defmodule AshStudioWeb.LandingLive do
  use AshStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.card variant="transparent" padding="medium">
        <.card_title title="About Ash Studio" />
        <.card_content class="space-y-4">
          <p>
            This is an experimental or starter site aimed at building AI development tools for the Ash Framework.
            It is not an official Ash module.
          </p>

          <p>The premise is to have a single set of Ash resources that can be used by</p>
          <.ol>
            <li><.icon name="hero-check" class="size-6 text-green-500" /> Forms</li>
            <li><.icon name="hero-check" class="size-6 text-green-500" /> AI Chat Bots</li>
            <li><.icon name="hero-x-mark" class="size-6 text-red-500" /> AI Code Agents</li>
          </.ol>
          <p>
            <.icon name="hero-x-mark" class="size-6 text-red-500" />
            In all cases, enable executing the operation on your behalf.
          </p>
        </.card_content>
      </.card>
    </div>
    <.link navigate="/tasks" class="underline text-lg">See it here</.link>
    """
  end
end
