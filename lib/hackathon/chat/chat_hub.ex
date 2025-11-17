defmodule Hackathon.Chat.ChatHub do
  @moduledoc """
  Supervisor del subsistema de chat.

  Se encarga de levantar el registro de subscriptores
  y el supervisor dinámico de salas.
  """

  use Supervisor

  def start_link(init_arg \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # Registro para suscriptores de salas de chat
      {Registry, keys: :duplicate, name: Hackathon.Chat.Registry},

      # Supervisor dinámico de salas (una por equipo o canal)
      {DynamicSupervisor,
       name: Hackathon.Chat.RoomSupervisor,
       strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
