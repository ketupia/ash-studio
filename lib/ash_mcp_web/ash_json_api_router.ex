defmodule AshStudioWeb.AshJsonApiRouter do
  @moduledoc false
  use AshJsonApi.Router,
    domains: [AshStudio.CodeGen],
    open_api: "/open_api"
end
