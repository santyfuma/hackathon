defmodule Hackathon.Processes.SessionManager do
  @moduledoc """
  Gestiona las sesiones de usuarios conectados.

  Por ahora solo mantiene un mapa simple de pid => username.
  """

  use GenServer

  ## API pública

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end
end
