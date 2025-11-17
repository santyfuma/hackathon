defmodule Hackathon.Processes.ProjectManager do
  @moduledoc """
  Gestiona los proyectos asociados a cada equipo.
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
