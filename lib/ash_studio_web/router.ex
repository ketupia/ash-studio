defmodule AshStudioWeb.Router do
  use AshStudioWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AshStudioWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  pipeline :sse do
    plug :accepts, ["sse"]
  end

  pipeline :mcp_api do
    plug :accepts, ["json"]
    # Skip CSRF protection for MCP API requests
    # This is necessary for external MCP clients like Cursor
  end

  scope "/" do
    pipe_through :sse
    get "/sse", SSE.ConnectionPlug, :call

    pipe_through :mcp_api
    post "/message", SSE.ConnectionPlug, :call

    pipe_through :api
  end

  scope "/", AshStudioWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {AshStudioWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {AshStudioWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {AshStudioWeb.LiveUserAuth, :live_no_user}

      live "/", IndexLive
      live "/about", AboutLive

      live "/tasks", Tasks.IndexLive
      live "/tasks/ash/gen/domain", Tasks.Ash.Gen.Domain.PlanLive
      live "/tasks/ash/gen/resource", Tasks.Ash.Gen.Resource.PlanLive
      live "/tasks/ash/codegen", Tasks.Ash.Codegen.PlanLive
    end
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/json/open_api",
      default_model_expand_depth: 4,
      init_opts: []

    forward "/redoc",
            Redoc.Plug.RedocUI,
            spec_url: "/api/json/open_api",
            init_opts: []

    forward "/", AshStudioWeb.AshJsonApiRouter
  end

  scope "/", AshStudioWeb do
    pipe_through :browser

    # get "/", PageController, :home
    auth_routes AuthController, AshStudio.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{AshStudioWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    AshStudioWeb.AuthOverrides,
                    AshAuthentication.Phoenix.Overrides.Default
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [
                  AshStudioWeb.AuthOverrides,
                  AshAuthentication.Phoenix.Overrides.Default
                ]
  end

  # Other scopes may use custom stacks.
  # scope "/api", AshStudioWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ash_studio, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AshStudioWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Application.compile_env(:ash_studio, :dev_routes) do
    import AshAdmin.Router

    scope "/admin" do
      pipe_through :browser

      ash_admin "/"
    end
  end
end
