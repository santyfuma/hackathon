defmodule Hackathon.Chat.ChatHub do
  @moduledoc """
  Punto central del subsistema de chat.

  Se encarga de crear salas de forma dinámica y expone
  una API sencilla para unirse, salir, enviar mensajes
  y consultar el historial.
  """

  use Supervisor
  alias Hackathon.Chat.ChatRoom

  @room_sup Hackathon.Chat.RoomSupervisor

  ## Arranque del supervisor

  def start_link(init_arg \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Registro de salas (clave única por nombre)
      {Registry, keys: :unique, name: Hackathon.Chat.Registry},
      # Supervisor dinámico de salas
      {DynamicSupervisor, name: @room_sup, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  ## ============
  ##  API PÚBLICA
  ## ============

  @doc """
  Une un proceso a una sala de chat.

  Devuelve :ok o {:error, motivo}.
  """
  def join(room_name, username, pid \\ self()) do
    room_pid = ensure_room(room_name)
    GenServer.call(room_pid, {:join, pid, username})
  end

  @doc """
  Saca un proceso de una sala.
  """
  def leave(room_name, pid \\ self()) do
    case room_process(room_name) do
      nil -> :ok
      room_pid -> GenServer.call(room_pid, {:leave, pid})
    end
  end

  @doc """
  Envía un mensaje a la sala indicada.

  El mensaje se construye en el ChatRoom y se envía
  a todos los suscriptores.
  """
  def send_message(room_name, from, content) do
    case room_process(room_name) do
      nil ->
        {:error, :room_not_found}

      room_pid ->
        GenServer.cast(room_pid, {:send_message, from, content})
        :ok
    end
  end

  @doc """
  Devuelve el historial de mensajes de una sala.
  """
  def history(room_name) do
    case room_process(room_name) do
      nil -> []
      room_pid -> GenServer.call(room_pid, :history)
    end
  end

  @doc """
  Lista los nombres de las salas activas.
  """
  def list_rooms do
    Registry.select(Hackathon.Chat.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  ## ============
  ##  Helpers
  ## ============

  # Asegura que exista una sala para room_name y devuelve su pid.
  defp ensure_room(room_name) do
    case room_process(room_name) do
      nil ->
        {:ok, pid} =
          DynamicSupervisor.start_child(@room_sup, {ChatRoom, name: room_name})

        pid

      pid ->
        pid
    end
  end

  # Obtiene el pid de la sala por nombre, si existe.
  defp room_process(room_name) do
    GenServer.whereis(ChatRoom.via(room_name))
  end
end



# Probar sistemas de chat "Chathub" y "ChatRoom"   Esto ya aplica un pequeña persistencia.

# ya en el IEX

# alias Hackathon.Chat.ChatHub

# # Te unes a una sala como "juan"
# ChatHub.join("team1", "juan")

# # Envías un mensaje
# ChatHub.send_message("team1", "juan", "Hola equipo!")

# # Ver historial
# ChatHub.history("team1")

# ver el mensaje que te llegó como proceso suscriptor:
# flush()


# El ChatRoom guarda historial

# Envía mensajes al proceso suscrito

# ChatHub está creando y gestionando salas
