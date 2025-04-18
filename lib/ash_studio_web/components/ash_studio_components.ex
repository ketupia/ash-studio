defmodule AshStudioWeb.AshStudioComponents do
  use AshStudioWeb, :html

  attr :module, :atom, required: true

  def module_name(assigns) do
    ~H"""
    {@module |> Atom.to_string() |> String.replace("Elixir.", "")}
    """
  end
end
