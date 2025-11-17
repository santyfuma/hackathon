defmodule Hackathon.Chat.ChatRoom do
  @moduledoc """
  Representa una sala de chat.

  Más adelante aquí se gestionarán los mensajes y los suscriptores.
  """

  use GenServer

  ## API pública

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)

    GenServer.start_link(__MODULE__, %{name: name}, opts)
  end

  ## Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end
end
