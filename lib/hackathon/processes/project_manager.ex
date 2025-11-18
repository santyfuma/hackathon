defmodule Hackathon.Processes.ProjectManager do
  @moduledoc """
  Administra los proyectos registrados para cada equipo.

  Maneja un mapa:
      team_name => %Project{}
  """

  use GenServer

  alias Hackathon.Domain.Project
  alias Hackathon.Services.ProjectService

  ## =================
  ##  API PÚBLICA
  ## =================

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Crea el proyecto de un equipo.
  """
  def create_project(team_name, description, category) do
    GenServer.call(__MODULE__, {:create_project, team_name, description, category})
  end

  @doc """
  Actualiza el estado del proyecto de un equipo.
  """
  def update_status(team_name, new_status) do
    GenServer.call(__MODULE__, {:update_status, team_name, new_status})
  end

  @doc """
  Devuelve el proyecto de un equipo.
  """
  def get_project(team_name) do
    GenServer.call(__MODULE__, {:get_project, team_name})
  end


  ## =================
  ##  CALLBACKS OTP
  ## =================

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call({:get_project, team_name}, _from, state) do
    {:reply, Map.get(state, team_name), state}
  end

  def handle_call({:create_project, team_name, description, category}, _from, state) do
    if Map.has_key?(state, team_name) do
      {:reply, {:error, :project_exists}, state}
    else
      project = ProjectService.new_project(team_name, description, category)
      new_state = Map.put(state, team_name, project)

      {:reply, {:ok, project}, new_state}
    end
  end

  def handle_call({:update_status, team_name, new_status}, _from, state) do
    case Map.get(state, team_name) do
      nil ->
        {:reply, {:error, :project_not_found}, state}

      %Project{} = project ->
        updated = ProjectService.update_status(project, new_status)
        new_state = Map.put(state, team_name, updated)

        {:reply, {:ok, updated}, new_state}
    end
  end
end

# Probar ProjectManager

# Hackathon.Processes.ProjectManager.create_project("team1", "Plataforma IA", "Innovación")
# Hackathon.Processes.ProjectManager.update_status("team1", "progreso")
# Hackathon.Processes.ProjectManager.get_project("team1")
