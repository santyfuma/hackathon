defmodule Hackathon.Services.TeamService do
  @moduledoc """
  Lógica relacionada con equipos.
  """

  alias Hackathon.Domain.Team

  @doc """
  Crea un equipo nuevo a partir de nombre y categoría.

  No toca procesos, solo devuelve la estructura.
  """
  def new_team(name, category) do
    %Team{name: name, category: category, members: []}
  end

  @doc """
  Agrega un miembro al equipo si no está repetido.
  """
  def add_member(%Team{} = team, username) when is_binary(username) do
    if username in team.members do
      team
    else
      %{team | members: [username | team.members]}
    end
  end
end
