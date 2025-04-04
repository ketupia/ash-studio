defmodule AshStudioWeb.Tasks.IndexLive do
  alias LangChain.Chains.LLMChain
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_new_chat() |> assign_chat_form()}
  end

  defp assign_new_chat(socket) do
    gemini_api_key = System.get_env("gemini_api_key")

    llmchain =
      %{
        llm:
          LangChain.ChatModels.ChatGoogleAI.new!(%{
            model: "gemini-2.0-flash",
            stream: true,
            api_key: gemini_api_key
          }),
        verbose?: true
      }
      |> LLMChain.new!()
      |> AshAi.setup_ash_ai(otp_app: :ash_studio)

    assign(socket, llmchain: llmchain)
  end

  defp assign_chat_form(socket) do
    assign(socket,
      form: to_form(%{"message" => ""})
    )
  end

  @impl true
  def handle_event("send", %{"message" => message}, socket) do
    socket =
      socket.assigns.llmchain
      |> LLMChain.add_message(LangChain.Message.new_user!(message))
      |> LLMChain.run(mode: :while_needs_response)
      |> case do
        {:ok, updated_chain} ->
          assign(socket, llmchain: updated_chain)

        {:error, _llmchain, error} ->
          put_flash(socket, :error, error.message)
      end
      |> assign_chat_form()

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row gap-4">
      <.card padding="medium" variant="outline" class="flex-1">
        <.card_title>Ash AI Chat</.card_title>
        <.card_content>
          <.chat
            :for={message <- @llmchain.messages}
            variant={(is_nil(message.content) && "transparent") || "shadow"}
            position={(message.role in [:tool, :assistant] && "flipped") || "normal"}
            color={
              (message.role == :user && "primary") || (message.role == :assistant && "secondary") ||
                "info"
            }
          >
            <%!-- Avatar --%>
            <.icon :if={message.role == :user} name="hero-user" class="size-6" />
            <.icon :if={message.role == :tool} name="hero-wrench" class="size-6" />
            <span :if={message.role == :assistant} class="text-3xl">🤖</span>
            <%!-- <.icon :if={message.role == :assistant} name="hero-beaker" class="size-6" /> --%>

            <.chat_section>
              <span :if={message.content}>{message.content}</span>
              <span :if={Enum.any?(message.tool_calls)}>
                Called {Enum.map_join(message.tool_calls, ",", & &1.name)}
              </span>
              <span :if={message.tool_results != nil}>
                Executed {Enum.map_join(message.tool_results, ",", & &1.name)}
              </span>
              <:meta>
                <div class="flex justify-between items-center">
                  <div>{message.role}</div>
                </div>
              </:meta>
            </.chat_section>
          </.chat>
        </.card_content>
        <.card_footer>
          <.form_wrapper for={@form} phx-submit="send" space="small">
            <.textarea_field field={@form[:message]} />
            <:actions>
              <.button type="submit">Send</.button>
            </:actions>
          </.form_wrapper>
        </.card_footer>
      </.card>

      <.menu space="small">
        <li>
          <.button_link variant="shadow" navigate="/tasks/ash/gen/domain">Domain</.button_link>
        </li>

        <li>
          <.button_link variant="shadow" navigate="/tasks/ash/gen/resource">Resource</.button_link>
        </li>
      </.menu>
    </div>

    <%!-- <pre>{inspect(@llmchain, pretty: true)}</pre> --%>
    """
  end
end
