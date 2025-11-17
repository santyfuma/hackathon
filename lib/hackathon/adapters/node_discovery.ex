defmodule Hackathon.Adapters.NodeDiscovery do
  @moduledoc """
  Utilidades relacionadas con la conexión entre nodos distribuidos.

  Este módulo se usará cuando activemos la parte distribuida.
  """

  def connect_to(node_name) do
    Node.connect(node_name)
  end
end
