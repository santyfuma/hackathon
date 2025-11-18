defmodule Hackathon.Chat.ChatRoom do
  @moduledoc """
  Representa una sala de chat.

  Mantiene una lista de suscriptores (pids) y un historial
  limitado de mensajes recientes.
  """

  use GenServer

  alias Hackathon.Services.ChatService

  @history_limit 50

  ## ============
  ##  API PÚBLICA
  ## ============

  def start_link(opts) do
    room_name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, %{room: room_name}, name: via(room_name))
  end

  @doc """
  Devuelve el nombre de la sala a partir de su pid.
  """
  def name(pid) do
    GenServer.call(pid, :name)
  end

  @doc """
  Tuple para registrar/buscar la sala en el Registry.
  """
  def via(room_name) do
    {:via, Registry, {Hackathon.Chat.Registry, room_name}}
  end

  ## ============
  ##  CALLBACKS
  ## ============

  @impl true
  def init(%{room: room} = _state) do
    state = %{
      room: room,
      subscribers: MapSet.new(),
      history: []
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:history, _from, state) do
    # Devolvemos en orden cronológico (el más viejo primero)
    {:reply, Enum.reverse(state.history), state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.room, state}
  end

  def handle_call({:join, pid, _username}, _from, state) do
    new_state = %{state | subscribers: MapSet.put(state.subscribers, pid)}
    {:reply, :ok, new_state}
  end

  def handle_call({:leave, pid}, _from, state) do
    new_state = %{state | subscribers: MapSet.delete(state.subscribers, pid)}
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_cast({:send_message, from, content}, state) do
    msg = ChatService.build_message(from, state.room, content)

    new_history =
      [msg | state.history]
      |> Enum.take(@history_limit)

    Enum.each(state.subscribers, fn pid ->
      send(pid, {:chat_message, state.room, msg})
    end)

    {:noreply, %{state | history: new_history}}
  end
end
