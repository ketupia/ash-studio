defmodule AshStudio.Tasks do
  @moduledoc """
  Services that generate command line instructions for code generation.
  """

  use Ash.Domain, otp_app: :ash_studio, extensions: [AshAdmin.Domain, AshJsonApi.Domain]

  admin do
    show? true
  end

  json_api do
    routes do
      base_route "/tasks/resources", AshStudio.Tasks.Ash.Gen.Resource do
        post :plan
      end

      base_route "/tasks/domains", AshStudio.Tasks.Ash.Gen.Domain do
        post :plan
      end
    end
  end

  resources do
    resource AshStudio.Tasks.Ash.Gen.Domain do
      define :plan_domain, action: :plan, args: [:domain_module_name]
    end

    resource AshStudio.Tasks.Ash.Gen.Resource do
      define :plan_resource, action: :plan, args: [:resource_module_name, :domain_module_name]
    end
  end
end
