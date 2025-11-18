defmodule Hackathon.Adapters.Storage do
  @moduledoc """
  Módulo simple de persistencia en archivos.

  Por ahora se guarda el estado de equipos y proyectos
  en archivos binarios bajo la carpeta `data/`.
  """

  @data_dir "data"
  @teams_file Path.join(@data_dir, "teams.db")
  @projects_file Path.join(@data_dir, "projects.db")

  @doc """
  Carga el estado persistido para la clave dada.

  Si el archivo no existe o hay error, devuelve un mapa vacío.
  """
  def load(:teams) do
    load_file(@teams_file)
  end

  def load(:projects) do
    load_file(@projects_file)
  end

  @doc """
  Guarda el estado en disco para la clave indicada.
  """
  def save(:teams, state) when is_map(state) do
    save_file(@teams_file, state)
  end

  def save(:projects, state) when is_map(state) do
    save_file(@projects_file, state)
  end

  ## Helpers

  defp load_file(path) do
    case File.read(path) do
      {:ok, bin} ->
        try do
          :erlang.binary_to_term(bin)
        rescue
          _ -> %{}
        end

      {:error, _} ->
        %{}
    end
  end

  defp save_file(path, state) do
    :ok = File.mkdir_p(@data_dir)
    bin = :erlang.term_to_binary(state)
    File.write(path, bin)
  end
end
