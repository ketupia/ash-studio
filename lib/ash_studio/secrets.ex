defmodule AshStudio.Secrets do
  @moduledoc false
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        AshStudio.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:ash_studio, :token_signing_secret)
  end
end
