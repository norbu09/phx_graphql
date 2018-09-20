defmodule PhxGraphqlWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PhxGraphqlWeb.Schema
  require Logger
  alias PhxGraphqlWeb.Session

  ## Channels
  # channel "room:*", PhxGraphqlWeb.RoomChannel

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket) do
    context = parse_token(params)

    socket =
      Absinthe.Phoenix.Socket.put_options(
        socket,
        context: context
      )

    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PhxGraphqlWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil

  defp parse_token(%{"token" => token}) do
    case Session.parse_token(String.trim(token)) do
      {:ok, user} ->
        %{current_user: user}

      _ ->
        %{}
    end
  end
end
