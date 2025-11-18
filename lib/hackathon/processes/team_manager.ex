defmodule Hackathon.Processes.TeamManager do
  @moduledoc """
  Gestiona los equipos registrados durante el hackathon.

  Mantiene un estado interno con un mapa:
      team_name => %Team{}

  Este módulo solo administra el estado; la lógica pura se
  delega a TeamService.
  """

  use GenServer

  alias Hackathon.Domain.Team
  alias Hackathon.Services.TeamService

  ## =================
  ##   API PÚBLICA
  ## =================

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Retorna todos los equipos registrados.
  """
  def list_teams do
    GenServer.call(__MODULE__, :list_teams)
  end

  @doc """
  Crea un equipo si no existe.
  """
  def create_team(name, category) do
    GenServer.call(__MODULE__, {:create_team, name, category})
  end

  @doc """
  Une un usuario a un equipo específico.
  """
  def join_team(team_name, username) do
    GenServer.call(__MODULE__, {:join_team, team_name, username})
  end

  @doc """
  Obtiene un equipo por nombre.
  """
  def get_team(name) do
    GenServer.call(__MODULE__, {:get_team, name})
  end


  ## =================
  ##  CALLBACKS OTP
  ## =================

  @impl true
  def init(initial_state) do
    # Estado inicial: %{"equipo1" => %Team{}, ...}
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:list_teams, _from, state) do
    {:reply, Map.values(state), state}
  end

  def handle_call({:get_team, name}, _from, state) do
    {:reply, Map.get(state, name), state}
  end

  def handle_call({:create_team, name, category}, _from, state) do
    case Map.has_key?(state, name) do
      true ->
        {:reply, {:error, :team_exists}, state}

      false ->
        team = TeamService.new_team(name, category)
        new_state = Map.put(state, name, team)
        {:reply, {:ok, team}, new_state}
    end
  end

  def handle_call({:join_team, team_name, username}, _from, state) do
    case Map.get(state, team_name) do
      nil ->
        {:reply, {:error, :team_not_found}, state}

      %Team{} = team ->
        updated = TeamService.add_member(team, username)
        new_state = Map.put(state, team_name, updated)

        {:reply, {:ok, updated}, new_state}
    end
  end
end



# Probar TeamManager

# Hackathon.Processes.TeamManager.create_team("team1", "categoria1")
# Hackathon.Processes.TeamManager.join_team("team1", "juan")
# Hackathon.Processes.TeamManager.list_teams()
# Hackathon.Processes.TeamManager.get_team("team1")

