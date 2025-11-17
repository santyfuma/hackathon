defmodule Hackathon.Domain.Team do
  @moduledoc """
  Representa un equipo dentro del hackathon.
  """

  defstruct [:name, :category, members: []]
end
