defmodule Hackathon.Processes.SessionManager do
  @moduledoc """
  Gestiona las sesiones de usuarios conectados.

  Mantiene dos mapas en memoria:
    - by_pid: pid -> username
    - by_username: username -> pid

  La idea es poder saber quién está usando la CLI y
  evitar nombres de usuario duplicados.
  """

  use GenServer

  ## ============
  ##  API PÚBLICA
  ## ============

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Inicia sesión con el nombre de usuario indicado.

  Por defecto usa el pid del proceso que llama.
  """
  def login(username, pid \\ self()) when is_binary(username) do
    GenServer.call(__MODULE__, {:login, pid, username})
  end

  @doc """
  Cierra la sesión del proceso actual o del pid dado.
  """
  def logout(pid \\ self()) do
    GenServer.call(__MODULE__, {:logout, pid})
  end

  @doc """
  Lista todos los usuarios conectados actualmente.
  Devuelve una lista de usernames.
  """
  def list_users do
    GenServer.call(__MODULE__, :list_users)
  end

  @doc """
  Obtiene el usuario asociado a un pid.
  """
  def username_for(pid \\ self()) do
    GenServer.call(__MODULE__, {:username_for, pid})
  end

  @doc """
  Obtiene el pid asociado a un nombre de usuario.
  """
  def pid_for(username) when is_binary(username) do
    GenServer.call(__MODULE__, {:pid_for, username})
  end

  ## ============
  ##  CALLBACKS
  ## ============

  @impl true
  def init(_initial_state) do
    state = %{by_pid: %{}, by_username: %{}}
    {:ok, state}
  end

  @impl true
  def handle_call(:list_users, _from, state) do
    users = Map.keys(state.by_username)
    {:reply, users, state}
  end

  def handle_call({:username_for, pid}, _from, state) do
    {:reply, Map.get(state.by_pid, pid), state}
  end

  def handle_call({:pid_for, username}, _from, state) do
    {:reply, Map.get(state.by_username, username), state}
  end

  def handle_call({:login, pid, username}, _from, state) do
    case Map.get(state.by_username, username) do
      nil ->
        # Monitorizamos al proceso para limpiar la sesión si muere
        Process.monitor(pid)

        new_state =
          state
          |> put_in([:by_pid, pid], username)
          |> put_in([:by_username, username], pid)

        {:reply, {:ok, username}, new_state}

      ^pid ->
        # Ya estaba logueado con ese nombre, no cambiamos nada
        {:reply, {:ok, username}, state}

      _other_pid ->
        {:reply, {:error, :username_taken}, state}
    end
  end

  def handle_call({:logout, pid}, _from, state) do
    {username, new_state} = drop_pid(pid, state)
    {:reply, {:ok, username}, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {_username, new_state} = drop_pid(pid, state)
    {:noreply, new_state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  ## ============
  ##  Helpers
  ## ============

  defp drop_pid(pid, state) do
    username = Map.get(state.by_pid, pid)

    new_state =
      state
      |> update_in([:by_pid], &Map.delete(&1, pid))
      |> update_in([:by_username], fn map ->
        case username do
          nil -> map
          name -> Map.delete(map, name)
        end
      end)

    {username, new_state}
  end
end



# Probar SessionManager

# # Loguear el proceso actual
# Hackathon.Processes.SessionManager.login("juan")

# # Ver usuario actual
# Hackathon.Processes.SessionManager.username_for()

# # Listar todos los usuarios conectados
# Hackathon.Processes.SessionManager.list_users()

# # Cerrar sesión
# Hackathon.Processes.SessionManager.logout()
