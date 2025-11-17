defmodule Hackathon.Services.ProjectService do
  @moduledoc """
  Lógica de negocio para proyectos.
  """

  alias Hackathon.Domain.Project

  @doc """
  Crea un proyecto asociado a un equipo.
  """
  def new_project(team_name, description, category) do
    %Project{
      team_name: team_name,
      description: description,
      category: category,
      status: "inicial",
      history: []
    }
  end

  @doc """
  Actualiza el estado del proyecto y registra el cambio en el historial.
  """
  def update_status(%Project{} = project, new_status) do
    entry = {:status_change, project.status, new_status, now_ts()}

    project
    |> Map.put(:status, new_status)
    |> Map.update!(:history, fn history -> [entry | history] end)
  end

  defp now_ts do
    DateTime.utc_now()
  end
end
