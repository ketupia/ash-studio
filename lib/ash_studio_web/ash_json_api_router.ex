defmodule AshStudioWeb.AshJsonApiRouter do
  @moduledoc false
  use AshJsonApi.Router,
    domains: [AshStudio.Tasks],
    open_api: "/open_api"
end
