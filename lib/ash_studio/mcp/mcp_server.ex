defmodule AshStudio.MCP.Server do
  use MCPServer
  require Logger

  @protocol_version "2024-11-05"

  @impl true
  def handle_ping(request_id) do
    {:ok, %{jsonrpc: "2.0", id: request_id, result: %{}}}
  end

  @impl true
  def handle_initialize(request_id, params) do
    Logger.info("Client initialization params: #{inspect(params, pretty: true)}")

    case validate_protocol_version(params["protocolVersion"]) do
      :ok ->
        {:ok,
         %{
           jsonrpc: "2.0",
           id: request_id,
           result: %{
             protocolVersion: @protocol_version,
             capabilities: %{
               tools: %{
                 listChanged: true
               }
             },
             serverInfo: %{
               name: "AshStudio",
               version: "0.1.0"
             }
           }
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def handle_list_tools(request_id, _params) do
    {:ok,
     %{
       jsonrpc: "2.0",
       id: request_id,
       result: %{
         tools: [
           %{
             name: "tasks.ash.gen.domain",
             description: "Creates the command to generate an Ash Domain",
             inputSchema: %{
               type: "object",
               required: ["domain_module_name"],
               properties: %{
                 domain_module_name: %{
                   type: "string",
                   description: "The domain name"
                 }
               }
             },
             outputSchema: %{
               type: "object",
               required: ["command"],
               properties: %{
                 command: %{
                   type: "string",
                   description: "The command to run to generate the domain"
                 }
               }
             }
           }
         ]
       }
     }}
  end

  @impl true
  def handle_call_tool(request_id, %{
        "name" => "tasks.ash.gen.domain",
        "arguments" => %{"domain_module_name" => domain_module_name}
      }) do
    AshStudio.Tasks.domain_command_line(domain_module_name)
    |> case do
      {:ok, domain} ->
        {:ok,
         %{
           jsonrpc: "2.0",
           id: request_id,
           result: %{
             content: [
               %{
                 type: "text",
                 text: domain.command
               }
             ]
           }
         }}

      {:error, _} ->
        {:error,
         %{
           jsonrpc: "2.0",
           id: request_id,
           error: %{
             code: -32601,
             message: "Method not found",
             data: %{
               name: "tasks.ash.gen.domain"
             }
           }
         }}
    end
  end

  def handle_call_tool(request_id, %{"name" => unknown_tool} = params) do
    Logger.warning(
      "Unknown tool called: #{unknown_tool} with params: #{inspect(params, pretty: true)}"
    )

    {:error,
     %{
       jsonrpc: "2.0",
       id: request_id,
       error: %{
         code: -32601,
         message: "Method not found",
         data: %{
           name: unknown_tool
         }
       }
     }}
  end

  # implementations of other calls for resources, prompts, etc.
end
