defmodule AshStudio.Tasks do
  @moduledoc """
  Services that generate command line instructions for code generation.
  """

  use Ash.Domain,
    otp_app: :ash_studio,
    extensions: [AshAdmin.Domain, AshJsonApi.Domain, AshPhoenix, AshAi]

  admin do
    show? true
  end

  # json_api do
  #   routes do
  #     base_route "/tasks/resources", AshStudio.Tasks.Ash.Gen.Resource do
  #       post :command_line
  #     end

  #     base_route "/tasks/domains", AshStudio.Tasks.Ash.Gen.Domain do
  #       post :command_line
  #     end
  #   end
  # end

  tools do
    tool :codegen_check, AshStudio.Tasks.Ash.Codegen, :check
    tool :codegen_dry_run, AshStudio.Tasks.Ash.Codegen, :dry_run
    tool :codegen_plan, AshStudio.Tasks.Ash.Codegen, :plan
    tool :domain_command_line, AshStudio.Tasks.Ash.Gen.Domain, :command_line
    # tool :resource_command_line, AshStudio.Tasks.Ash.Gen.Resource, :command_line
  end

  resources do
    resource AshStudio.Tasks.Ash.Codegen do
      define :codegen_check, action: :check
      define :codegen_dry_run, action: :dry_run
      define :codegen_plan, action: :plan, args: [:migration_file_name]
    end

    resource AshStudio.Tasks.Ash.Gen.Domain do
      define :domain_command_line, action: :command_line, args: [:domain_module_name]
    end

    resource AshStudio.Tasks.Ash.Gen.Resource do
      define :resource_command_line,
        action: :command_line,
        args: [
          :resource_module_name,
          {:optional, :attribute_specs},
          {:optional, :relationship_specs},
          {:optional, :default_actions},
          {:optional, :domain_module_name},
          {:optional, :extensions},
          {:optional, :ignore_if_exists?},
          {:optional, :primary_key_type},
          {:optional, :primary_key_name},
          {:optional, :timestamps?}
        ]
    end
  end
end
