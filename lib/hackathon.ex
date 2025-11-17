defmodule Hackathon do
  @moduledoc """
  Punto de entrada sencillo al proyecto.

  Desde iex se puede usar este módulo como fachada,
  por ejemplo para arrancar la interfaz de línea de comandos.
  """

  @doc """
  Arranca la CLI en un proceso separado.

  Se usa normalmente así:

      iex -S mix
      iex> Hackathon.start_cli()
  """
  def start_cli do
    Hackathon.Adapters.CLI.start()
  end
end
