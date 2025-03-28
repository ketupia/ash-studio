defmodule AshStudio.Accounts do
  use Ash.Domain, otp_app: :ash_studio, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource AshStudio.Accounts.Token
    resource AshStudio.Accounts.User
  end
end
