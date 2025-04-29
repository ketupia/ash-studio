defmodule AshStudio.Mermaid do
  @doc """
  Generates a Mermaid diagram image URL from a diagram string.
  """
  def generate_image_url(diagram) when is_binary(diagram) do
    base64 =
      diagram
      |> :unicode.characters_to_binary(:utf8)
      |> Base.url_encode64()

    "https://mermaid.ink/img/#{base64}"
  end
end
