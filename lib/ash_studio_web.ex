defmodule AshStudioWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use AshStudioWeb, :controller
      use AshStudioWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def static_path(path) do
    Path.join(Application.app_dir(:ash_studio, "priv/static"), path)
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {AshStudioWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: AshStudioWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      import AshStudioWeb.CoreComponents

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes(opts \\ []) do
    endpoint = Keyword.get(opts, :endpoint, AshStudioWeb.Endpoint)
    router = Keyword.get(opts, :router, AshStudioWeb.Router)
    statics = Keyword.get(opts, :statics, AshStudioWeb.static_paths())

    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: unquote(endpoint),
        router: unquote(router),
        statics: unquote(statics)
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
