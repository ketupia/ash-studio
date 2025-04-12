defmodule AshStudioWeb.IndexLive do
  alias AshStudio.ChatModelFactory
  alias LangChain.Chains.LLMChain
  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_new_chat()
     |> assign_chat_form()
     |> assign_old_chat_messages()}
  end

  defp assign_new_chat(socket) do
    llmchain =
      %{
        llm: ChatModelFactory.new(),
        verbose?: true
      }
      |> LLMChain.new!()
      |> AshAi.setup_ash_ai(otp_app: :ash_studio)

    assign(socket, llmchain: llmchain)
  end

  defp assign_old_chat_messages(socket) do
    llmchain =
      Map.put(socket.assigns.llmchain, :messages, [
        %LangChain.Message{
          content: "Your name is?",
          processed_content: nil,
          index: nil,
          status: :complete,
          role: :user,
          name: nil,
          tool_calls: [],
          tool_results: nil,
          metadata: nil
        },
        %LangChain.Message{
          content: "I am known as Assistant. How can I help you today?",
          processed_content: nil,
          index: 0,
          status: :complete,
          role: :assistant,
          name: nil,
          tool_calls: [],
          tool_results: nil,
          metadata: nil
        }
      ])

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
          IO.inspect(updated_chain.messages, label: "updated_chain messages")
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
              <%!-- <:meta>
                <div class="flex justify-between items-center">
                  <div>{message.role}</div>
                </div>
              </:meta> --%>
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

      <.card padding="small" variant="shadow" color="neutral">
        <.card_title>Tools</.card_title>
        <.card_content>
          <.ash_gen_menu />
          <.ash_codegen_menu />
        </.card_content>
      </.card>
    </div>

    <%!-- <pre>{inspect(@llmchain, pretty: true)}</pre> --%>
    """
  end

  defp ash_codegen_menu(assigns) do
    ~H"""
    <.menu space="small">
      <li>
        <.button_link variant="shadow" navigate="/tasks/ash/codegen">
          ash.codegen
        </.button_link>
      </li>
    </.menu>
    """
  end

  defp ash_gen_menu(assigns) do
    ~H"""
    <.menu space="small">
      <li>
        <.button_link variant="shadow" navigate="/tasks/ash/gen/domain">
          ash.gen.domain
        </.button_link>
      </li>

      <li>
        <.button_link variant="shadow" navigate="/tasks/ash/gen/resource">
          ash.gen.resource
        </.button_link>
      </li>
    </.menu>
    """
  end
end
