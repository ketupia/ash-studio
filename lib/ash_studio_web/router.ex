defmodule AshStudioWeb.Router do
  @moduledoc """
  Use `AshStudio.Router.routes()` in your router to include AshStudio routes.
  """

  defmacro ash_studio_routes(opts \\ []) do
    quote do
      scope unquote(opts[:path] || "/studio"), AshStudioWeb do
        pipe_through unquote(opts[:pipe_through] || [:browser])

        live "/", IndexLive
        live "/tasks/ash/gen/domain", Tasks.Ash.Gen.Domain.PlanLive
        live "/tasks/ash/gen/resource", Tasks.Ash.Gen.Resource.PlanLive
        live "/tasks/ash/codegen", Tasks.Ash.Codegen.PlanLive

        live "/info/domains", Info.Domains.IndexLive
        live "/info/domains/:domain/resources/:resource", Info.Domains.Resources.ShowLive
      end
    end
  end

  # This is from when I had the jason api installed and a first class feature
  # scope "/api/json" do
  #   pipe_through [:api]

  #   forward "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
  #     path: "/api/json/open_api",
  #     default_model_expand_depth: 4,
  #     init_opts: []

  #   forward "/redoc",
  #           Redoc.Plug.RedocUI,
  #           spec_url: "/api/json/open_api",
  #           init_opts: []

  #   forward "/", AshStudioWeb.AshJsonApiRouter
  # end
end
