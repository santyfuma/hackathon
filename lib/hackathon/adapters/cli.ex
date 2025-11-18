defmodule Hackathon.Adapters.CLI do
  @moduledoc """
  Interfaz de línea de comandos del sistema.

  Aquí se interpretan los comandos del usuario y se
  delega el trabajo a los distintos managers.
  """

  alias Hackathon.Processes.{
    SessionManager,
    TeamManager,
    ProjectManager
  }

  ## Punto de entrada

  def start do
  IO.puts("""
  =====================================
    Hackathon CLI
    Escribe /help para ver comandos.
  =====================================
  """)

  # Creamos un proceso listener para mensajes del chat
  listener = spawn_link(fn -> message_listener() end)

  loop(%{username: nil, listener: listener, current_room: nil})
end


  ## Bucle principal

  defp loop(state) do
    prompt =
      case state.username do
        nil -> "> "
        name -> "#{name}> "
      end

    case IO.gets(prompt) do
      nil ->
        :ok

      line ->
        new_state =
          line
          |> String.trim()
          |> handle_input(state)

        loop(new_state)
    end
  end

  ## Manejo de comandos

  defp handle_input("", state), do: state

  defp handle_input("/help", state) do
    IO.puts("""
    Comandos disponibles:
      /login NOMBRE
      /logout
      /users
      /teams
      /create_team NOMBRE CATEGORIA
      /join_team NOMBRE
      /project_create EQUIPO CATEGORIA DESCRIPCION...
      /project EQUIPO
      /exit
    """)

    state
  end

  defp handle_input("/exit", state) do
    if state.username, do: SessionManager.logout()
    IO.puts("Hasta luego.")
    # Terminamos el proceso del loop
    exit(:normal)
  end

  ## Sesiones

  defp handle_input(<<"\/login ", rest::binary>>, state) do
    username = String.trim(rest)

    case SessionManager.login(username) do
      {:ok, ^username} ->
        IO.puts("Sesión iniciada como #{username}")
        %{state | username: username}

      {:error, :username_taken} ->
        IO.puts("Ese nombre ya está en uso.")
        state
    end
  end

  defp handle_input("/logout", state) do
    case SessionManager.logout() do
      {:ok, username} when not is_nil(username) ->
        IO.puts("Sesión cerrada: #{username}")
        %{state | username: nil}

      _ ->
        IO.puts("No había sesión activa.")
        state
    end
  end

  defp handle_input("/users", state) do
    users = SessionManager.list_users()

    case users do
      [] ->
        IO.puts("No hay usuarios conectados.")

      _ ->
        IO.puts("Usuarios conectados:")
        Enum.each(users, &IO.puts("  - " <> &1))
    end

    state
  end

  ## Equipos

  defp handle_input("/teams", state) do
    teams = TeamManager.list_teams()

    case teams do
      [] ->
        IO.puts("Todavía no hay equipos registrados.")

      _ ->
        IO.puts("Equipos:")
        Enum.each(teams, fn team ->
          IO.puts("  - #{team.name} (#{team.category}) miembros: #{Enum.join(team.members, ", ")}")
        end)
    end

    state
  end

  defp handle_input(<<"\/create_team ", rest::binary>>, state) do
    case String.split(rest, " ", parts: 2) do
      [name, category] ->
        case TeamManager.create_team(name, category) do
          {:ok, _team} ->
            IO.puts("Equipo '#{name}' creado en categoría '#{category}'.")

          {:error, :team_exists} ->
            IO.puts("Ya existe un equipo con ese nombre.")
        end

      _ ->
        IO.puts("Uso: /create_team NOMBRE CATEGORIA")
    end

    state
  end

  defp handle_input(<<"\/join_team ", rest::binary>>, state) do
    team_name = String.trim(rest)

    case state.username do
      nil ->
        IO.puts("Primero debes hacer /login NOMBRE.")
        state

      username ->
        case TeamManager.join_team(team_name, username) do
          {:ok, _team} ->
            IO.puts("Te uniste al equipo '#{team_name}'.")

          {:error, :team_not_found} ->
            IO.puts("No existe el equipo '#{team_name}'.")
        end

        state
    end
  end

  ## Proyectos

  defp handle_input(<<"\/project_create ", rest::binary>>, state) do
    # /project_create EQUIPO CATEGORIA DESCRIPCION...
    case String.split(rest, " ", parts: 3) do
      [team_name, category, description] ->
        case ProjectManager.create_project(team_name, description, category) do
          {:ok, _project} ->
            IO.puts("Proyecto creado para el equipo '#{team_name}'.")

          {:error, :project_exists} ->
            IO.puts("Ese equipo ya tiene un proyecto registrado.")
        end

      _ ->
        IO.puts("Uso: /project_create EQUIPO CATEGORIA DESCRIPCION...")
    end

    state
  end

  defp handle_input(<<"\/project ", rest::binary>>, state) do
    team_name = String.trim(rest)

    case ProjectManager.get_project(team_name) do
      nil ->
        IO.puts("El equipo '#{team_name}' no tiene proyecto registrado.")

      project ->
        IO.puts("""
        Proyecto de #{project.team_name}
          Categoría: #{project.category}
          Estado:    #{project.status}
          Descripción:
            #{project.description}
        """)
    end

    state
  end



#/chat_join

defp handle_input(<<"\/chat_join ", rest::binary>>, state) do
  room = String.trim(rest)

  case state.username do
    nil ->
      IO.puts("Debes iniciar sesión primero (/login NOMBRE).")
      state

    username ->
      case Hackathon.Chat.ChatHub.join(room, username, state.listener) do
        :ok ->
          IO.puts("Te uniste a la sala #{room}.")
          %{state | current_room: room}

        {:error, reason} ->
          IO.puts("No se pudo unir a la sala: #{inspect(reason)}")
          state
      end
  end
end


#/chat_send MENSAJE
defp handle_input(<<"\/chat_send ", rest::binary>>, state) do
  case state.current_room do
    nil ->
      IO.puts("No estás en ninguna sala. Usa /chat_join NOMBRE.")
      state

    room ->
      case state.username do
        nil ->
          IO.puts("Debes iniciar sesión.")
          state

        username ->
          Hackathon.Chat.ChatHub.send_message(room, username, rest)
          state
      end
  end
end


#/chat_leave
defp handle_input("/chat_leave", state) do
  case state.current_room do
    nil ->
      IO.puts("No estás en ninguna sala.")
      state

    room ->
      Hackathon.Chat.ChatHub.leave(room, state.listener)
      IO.puts("Saliste de la sala #{room}.")
      %{state | current_room: nil}
  end
end


  ## Entrada que no coincide con ningún comando

  defp handle_input(other, state) do
    IO.puts("Comando no reconocido: #{other}")
    IO.puts("Usa /help para ver las opciones disponibles.")
    state
  end




# ============================================
#  Listener: recibe mensajes enviados a la CLI
# ============================================
defp message_listener do
  receive do
    {:chat_message, room, msg} ->
      IO.puts("\n[#{room}] #{msg.from}: #{msg.content}")
      message_listener()

    _other ->
      message_listener()
  end
end
end



# Probar la CLI

# iex -S mix
# Hackathon.start_cli()
# /login juan
# /create_team team1 web
# /join_team team1
# /teams
# /project_create team1 web "Plataforma IA para hackathon"
# /project team1
# /users
# /logout
# /exit



# Prueba rapida

# /login juan
# /create_team team1 web
# /join_team team1
# /teams
