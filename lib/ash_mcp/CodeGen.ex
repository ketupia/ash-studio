defmodule AshStudio.CodeGen do
  @moduledoc """
  Services that generate command line instructions for code generation.
  """

  use Ash.Domain, otp_app: :ash_studio, extensions: [AshAdmin.Domain, AshJsonApi.Domain]

  admin do
    show? true
  end

  json_api do
    routes do
      base_route "/resources", AshStudio.CodeGen.Resource do
        post :plan
      end

      base_route "/domains", AshStudio.CodeGen.Domain do
        get :info
      end
    end
  end

  resources do
    resource AshStudio.CodeGen.Domain
    resource AshStudio.CodeGen.Resource
  end
end
