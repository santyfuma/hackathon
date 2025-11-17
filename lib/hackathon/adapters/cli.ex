defmodule Hackathon.Adapters.CLI do
  @moduledoc """
  Interfaz de línea de comandos del sistema.

  De momento solo muestra un mensaje de bienvenida.
  """

  def start do
    spawn_link(fn -> loop(%{user: nil}) end)
  end

  defp loop(state) do
    IO.puts("""
    Bienvenido a la CLI del hackathon.
    Esta parte aún está en construcción.
    Estado actual: #{inspect(state)}
    """)

    # Por ahora terminamos aquí para no bloquear el shell.
    :ok
  end
end
