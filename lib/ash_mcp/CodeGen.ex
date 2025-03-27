defmodule AshMcp.CodeGen do
  @moduledoc """
  Services that generate command line instructions for code generation.
  """

  use Ash.Domain, otp_app: :ash_mcp, extensions: [AshAdmin.Domain, AshJsonApi.Domain]

  admin do
    show? true
  end

  json_api do
    routes do
      base_route "/plan-resources", AshMcp.CodeGen.PlanResource do
        post :plan
      end
    end
  end

  resources do
    resource AshMcp.CodeGen.PlanResource
  end
end
