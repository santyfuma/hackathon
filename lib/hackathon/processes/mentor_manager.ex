defmodule Hackathon.Processes.MentorManager do
  @moduledoc """
  Lleva el registro de mentores y posibles asignaciones.

  De momento es solo un esqueleto para que la app compile.
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
  