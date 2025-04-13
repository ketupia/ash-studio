defmodule AshStudioWeb.Tasks.IndexLive do
  alias Phoenix.HTML.Form
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
    <div class="space-y-4">
      <div class="flex flex-row gap-4">
        <div class="flex-auto space-y-8">
          <.chat_interface llmchain={@llmchain} form={@form} />
        </div>
        <div class="flex-1 space-y-8">
          <.card padding="small" variant="shadow" color="neutral">
            <.card_title title="Task Forms" />
            <.card_content>
              <.p color="silver">Forms for mix tasks</.p>
              <.ash_gen_menu />
              <.ash_codegen_menu />
            </.card_content>
          </.card>
          <.chat_suggestions />
        </div>
      </div>
    </div>
    """
  end

  attr :form, Form, required: true
  attr :llmchain, LLMChain, required: true

  defp chat_interface(assigns) do
    ~H"""
    <.card padding="medium" variant="default" color="natural">
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
          space="small"
        >
          <%!-- Avatar --%>
          <.icon :if={message.role == :user} name="hero-user" class="size-6" />
          <.icon :if={message.role == :tool} name="hero-wrench" class="size-6" />
          <span :if={message.role == :assistant} class="text-3xl">🤖</span>

          <.chat_section>
            <span :if={message.content}>{message.content}</span>
            <span :if={Enum.any?(message.tool_calls)}>
              Called {Enum.map_join(message.tool_calls, ",", & &1.name)}
            </span>
            <span :if={message.tool_results != nil}>
              Executed {Enum.map_join(message.tool_results, ",", & &1.name)}
            </span>
          </.chat_section>
        </.chat>
      </.card_content>
      <.card_footer>
        <.form_wrapper for={@form} phx-submit="send" space="small" id="my_form">
          <.textarea_field
            field={@form[:message]}
            phx-keydown={JS.dispatch("submit", to: "#my_form")}
            phx-key="Enter"
            required
          />
          <:actions>
            <.button type="submit" phx-disabled_with="Sending...">
              Send
            </.button>
          </:actions>
        </.form_wrapper>
      </.card_footer>
    </.card>
    <.alert variant="outline" kind={:danger}>
      The Chat feature uses my personal OpenAI account with $5 credit! Try it! Be kind, leave credits available for other users.
    </.alert>
    """
  end

  defp chat_suggestions(assigns) do
    assigns =
      assign(assigns,
        suggestions: [
          "What is the command to create a domain named Tunez?",
          "What is the command to create a migration named add album?"
        ],
        failing_suggestions: [
          "What is the command to create a resource named Artist in the Music domain? Artists use a UUID-v4 for their ID. They have a name - it's required. They have a biography - it's optional. The record should include timestamps."
        ]
      )

    ~H"""
    <div class="flex flex-wrap gap-4">
      <.p color="silver"><.icon name="hero-beaker" class="size-6" /> Suggestions</.p>
      <div
        :for={{suggestion, index} <- Enum.with_index(@suggestions)}
        class="max-w-[24ch]"
        phx-hook="CopyToClipboardHook"
        data-target={"suggestion_#{index}"}
        id={"suggestion_#{index}"}
      >
        <.icon name="hero-clipboard" class="size-6" />
        {suggestion}
      </div>
      <div :for={suggestion <- @failing_suggestions} class="max-w-[24ch] text-red-500">
        <.icon name="hero-x-mark" class="size-6" />
        {suggestion}
      </div>
    </div>
    """
  end

  defp ash_codegen_menu(assigns) do
    ~H"""
    <.menu space="small">
      <li>
        <.button_link variant="outline" color="natural" navigate="/tasks/ash/codegen">
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
        <.button_link variant="outline" color="natural" navigate="/tasks/ash/gen/domain">
          ash.gen.domain
        </.button_link>
      </li>

      <li>
        <.button_link variant="outline" color="primary" navigate="/tasks/ash/gen/resource">
          ash.gen.resource
        </.button_link>
      </li>
    </.menu>
    """
  end
end
