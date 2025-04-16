defmodule AshStudioWeb.IndexLive do
  alias Phoenix.HTML.Form
  alias LangChain.Chains.LLMChain

  use AshStudioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_new_chat()
     |> assign_chat_form()
     |> assign_old_chat_messages()
     |> maybe_add_migrations_message()}
  end

  def maybe_add_migrations_message(socket) do
    codegen_check = AshStudio.Tasks.codegen_check!()

    [command | args] = String.split(codegen_check.command, " ")

    llmchain =
      System.cmd(command, args)
      |> case do
        {_, 0} ->
          socket.assigns.llmchain

        {_, 1} ->
          LLMChain.add_message(socket.assigns.llmchain, %LangChain.Message{
            content: "I ran `#{codegen_check.command}` and you have migrations to generate.",
            processed_content: nil,
            index: 0,
            status: :complete,
            role: :assistant,
            name: nil,
            tool_calls: [],
            tool_results: nil,
            metadata: nil
          })

        _ ->
          socket.assigns.llmchain
      end

    assign(socket, llmchain: llmchain)
  end

  defp assign_new_chat(socket) do
    otp_app = Application.get_env(:ash_studio, :host_app)

    open_api_key = System.get_env("open_api_key")

    my_personal_key =
      case open_api_key do
        nil ->
          false

        key ->
          :crypto.hash(:sha256, key)
          |> Base.encode16(case: :lower) ==
            "e38a1dd133f2eb10a553c7226f3a368b931cb8ccaa1266a2eda140f699dd8021"
      end

    open_api_key_found = open_api_key != nil

    llmchain =
      case open_api_key do
        nil ->
          nil

        open_api_key ->
          %{
            llm:
              LangChain.ChatModels.ChatOpenAI.new!(%{
                model: Application.get_env(:ash_studio, :open_ai_model),
                stream: true,
                api_key: open_api_key
              }),
            verbose?: true
          }
          |> LLMChain.new!()
          |> AshAi.setup_ash_ai(otp_app: otp_app)
      end

    assign(socket,
      open_api_key_found: open_api_key_found,
      llmchain: llmchain,
      my_personal_key: my_personal_key
    )
  end

  defp assign_old_chat_messages(socket) do
    llmchain =
      [
        %LangChain.Message{
          content: "Hello?",
          processed_content: nil,
          index: 0,
          status: :complete,
          role: :user,
          name: nil,
          tool_calls: [],
          tool_results: nil,
          metadata: nil
        },
        %LangChain.Message{
          content: "How can I help you today?",
          processed_content: nil,
          index: 0,
          status: :complete,
          role: :assistant,
          name: nil,
          tool_calls: [],
          tool_results: nil,
          metadata: nil
        }
      ]
      |> Enum.reduce(socket.assigns.llmchain, fn message, llmchain ->
        LLMChain.add_message(llmchain, message)
      end)

    assign(socket, llmchain: llmchain)
  end

  defp assign_chat_form(socket, opts \\ []) do
    assign(socket,
      form: to_form(%{"message" => ""}, opts)
    )
  end

  @impl true
  def handle_event("validate", %{"message" => message}, socket) do
    errors =
      case message do
        "" -> [message: {"Message is required", []}]
        _ -> []
      end

    {:noreply, assign_chat_form(socket, errors: errors, action: :validated)}
  end

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
      <.about />
      <div class="flex flex-row gap-4">
        <div class="flex-auto space-y-8">
          <.missing_open_api_key_alert :if={not @open_api_key_found} />
          <.chat_interface :if={@open_api_key_found} llmchain={@llmchain} form={@form} />
          <.personal_account_alert :if={@open_api_key_found and @my_personal_key} />
          <.chat_suggestions :if={@open_api_key_found} />
        </div>
        <div class="flex-1 space-y-8">
          <div class="p-4 shadow-lg">
            <h2 class="text-lg font-semibold mb-2">Task Forms</h2>
            <div class="space-y-4">
              <p style="color: #6b7280;">Forms for mix tasks</p>
              <.ash_gen_menu />
              <.ash_codegen_menu />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp about(assigns) do
    ~H"""
    <details class="shadow-lg p-4">
      <summary>About Ash Studio</summary>
      <div class="space-y-4">
        <p>
          This is an experimental or starter site aimed at building AI development tools for the Ash Framework.
          It is not an official Ash module.
        </p>

        <p>The premise is to have a single set of Ash resources that can be used by</p>
        <ul class="list-disc space-y-2">
          <li>✅ Forms</li>
          <li>🟡 AI Chat Bots - tools mostly work but not for ash.gen.resource</li>
          <li>❌ AI Code Agents</li>
        </ul>
        <p>❌ In all cases, enable executing the operation on your behalf.</p>
      </div>
    </details>
    """
  end

  def message_styles(%{role: :user}),
    do:
      "background-color: #15803d; color: white; padding: 0.25rem; border-radius: 0 0.75rem 0.75rem 0.75rem; margin: 0.25rem; text-align: left;"

  def message_styles(%{role: :assistant}),
    do:
      "background-color: #153d80; color: white; padding: 0.25rem; border-radius: 0.75rem 0 0.75rem 0.75rem; margin: 0.25rem; text-align: right;"

  def message_styles(%{role: :tool}),
    do:
      "background-color: #888888; color: black; padding: 0.25rem; border-radius: 0.75rem 0 0.75rem 0.75rem; margin: 0.25rem; text-align: right;"

  attr :form, Form, required: true
  attr :llmchain, LLMChain, required: true

  defp chat_interface(assigns) do
    ~H"""
    <div class="space-y-4">
      <h2 class="text-lg font-semibold mb-2">Ash AI Chat</h2>
      <div class="space-y-4">
        <div style="max-height: 50vh; overflow-y: auto; overflow-x: hidden; display: grid; grid-template-columns: 36px 1fr 36px; width: 100%;">
          <%= for message <- @llmchain.messages do %>
            <%!-- user avatar --%>
            <div>
              <.icon :if={message.role == :user} name="hero-user" class="size-6" />
            </div>

            <%!-- message content --%>
            <div style={message_styles(message)}>
              <span :if={message.content}>{message.content}</span>
              <span :if={Enum.any?(message.tool_calls)}>
                Called {Enum.map_join(message.tool_calls, ",", & &1.name)}
              </span>
              <span :if={message.tool_results != nil}>
                Executed {Enum.map_join(message.tool_results, ",", & &1.name)}
              </span>
            </div>

            <%!-- assistant or tool avatar  --%>
            <div>
              <.icon :if={message.role == :tool} name="hero-wrench" class="size-6" />
              <span :if={message.role == :assistant} class="text-3xl">🤖</span>
            </div>
          <% end %>
        </div>
      </div>
      <div class="space-y-4">
        <.simple_form for={@form} phx-change="validate" phx-submit="send" id="my_form">
          <.input
            field={@form[:message]}
            phx-keydown={JS.dispatch("submit", to: "#my_form")}
            phx-key="Enter"
            required
          />
          <:actions>
            <.button
              type="submit"
              phx-disabled_with="Sending..."
              disabled={@form.action == nil or @form.errors != []}
            >
              Send
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  defp missing_open_api_key_alert(assigns) do
    ~H"""
    <div class="p-4 rounded-lg border border-2" style="border-color: #ef4444; color: #ef4444;">
      Did not find an OpenAI API key.  Please set one in the config.
    </div>
    """
  end

  defp personal_account_alert(assigns) do
    ~H"""
    <div class="p-4 rounded-lg border border-2" style="border-color: #ef4444; color: #ef4444;">
      The Chat feature uses my personal OpenAI account with $5 credit.  Absolutely try the chat feature - that's the point of this site! Be kind, leave credits for other users.
    </div>
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
    <div class="space-y-2">
      <p style="color: #6b7280;"><.icon name="hero-beaker" class="size-6" /> Suggestions</p>
      <div
        :for={{suggestion, index} <- Enum.with_index(@suggestions)}
        class="max-w-[24ch]"
        phx-hook="CopyToClipboardHook"
        data-target={"suggestion_#{index}_content"}
        id={"suggestion_#{index}"}
      >
        <span class="text-lg">📋</span>
        <span id={"suggestion_#{index}_content"}>
          {suggestion}
        </span>
      </div>
      <div :for={suggestion <- @failing_suggestions} class="max-w-[24ch]">
        ❌ {suggestion}
      </div>
    </div>
    """
  end

  defp ash_codegen_menu(assigns) do
    ~H"""
    <div class="space-y-4">
      <ul>
        <li>
          <.link navigate="/studio/tasks/ash/codegen" style="text-decoration: underline">
            ash.codegen
          </.link>
        </li>
      </ul>
    </div>
    """
  end

  defp ash_gen_menu(assigns) do
    ~H"""
    <div class="space-y-4">
      <ul>
        <li>
          <.link navigate="/studio/tasks/ash/gen/domain" style="text-decoration: underline">
            ash.gen.domain
          </.link>
        </li>

        <li>
          <.link navigate="/studio/tasks/ash/gen/resource" style="text-decoration: underline">
            ash.gen.resource
          </.link>
        </li>
      </ul>
    </div>
    """
  end
end
