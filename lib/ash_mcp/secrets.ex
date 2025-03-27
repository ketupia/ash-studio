defmodule AshMcp.Secrets do
  @moduledoc false
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        AshMcp.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:ash_mcp, :token_signing_secret)
  end
end
