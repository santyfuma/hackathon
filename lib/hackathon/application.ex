defmodule Hackathon.Application do
  @moduledoc """
  Módulo de arranque de la aplicación OTP del hackathon.

  Aquí se define el árbol de supervisión principal.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Registro general para procesos que necesiten nombres dinámicos
      {Registry, keys: :unique, name: Hackathon.Registry},

      # Managers de la capa de procesos / estado
      Hackathon.Processes.SessionManager,
      Hackathon.Processes.TeamManager,
      Hackathon.Processes.ProjectManager,
      Hackathon.Processes.MentorManager,

      # Subsistema de chat (supervisor propio)
      Hackathon.Chat.ChatHub
    ]

    opts = [strategy: :one_for_one, name: Hackathon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
