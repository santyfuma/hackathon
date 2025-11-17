defmodule Hackathon.Services.ChatService do
  @moduledoc """
  Lógica auxiliar para mensajes de chat.
  """

  alias Hackathon.Domain.Message

  @doc """
  Construye un mensaje listo para usar en una sala.

  Por ahora solo arma la estructura, sin validaciones complejas.
  """
  def build_message(from, room, content) do
    %Message{
      from: from,
      room: room,
      content: String.trim(content),
      timestamp: DateTime.utc_now()
    }
  end
end
