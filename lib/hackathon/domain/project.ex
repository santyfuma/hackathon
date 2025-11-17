defmodule Hackathon.Domain.Project do
  @moduledoc """
  Representa el proyecto asociado a un equipo.
  """

  defstruct [:team_name, :description, :category, :status, history: []]
end
