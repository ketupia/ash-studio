defmodule AshMcpWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [AshMcp.CodeGen],
    open_api: "/open_api"
end
