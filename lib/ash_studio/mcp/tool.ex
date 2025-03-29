defmodule AshStudio.MCP.Tool do
  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback arguments() :: [String.t()]
end
