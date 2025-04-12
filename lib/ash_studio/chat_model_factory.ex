defmodule AshStudio.ChatModelFactory do
  @moduledoc """
  A factory for creating chat models.
  """

  def new() do
    open_api()
  end

  defp open_api() do
    open_api_key = System.get_env("open_api_key")

    LangChain.ChatModels.ChatOpenAI.new!(%{
      model: "gpt-4o-mini",
      stream: true,
      api_key: open_api_key
    })
  end

  # defp google() do
  #   gemini_api_key = System.get_env("gemini_api_key")

  #   LangChain.ChatModels.ChatGoogleAI.new!(%{
  #     model: "gemini-2.0-flash",
  #     stream: true,
  #     api_key: gemini_api_key
  #   })
  # end
end
