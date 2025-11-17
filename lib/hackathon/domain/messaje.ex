defmodule Hackathon.Domain.Message do
  @moduledoc """
  Mensaje enviado en una sala de chat.
  """

  defstruct [:from, :room, :content, :timestamp]
end
