defmodule AshMcp.Accounts do
  use Ash.Domain, otp_app: :ash_mcp, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource AshMcp.Accounts.Token
    resource AshMcp.Accounts.User
  end
end
