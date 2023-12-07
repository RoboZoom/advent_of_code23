defmodule Day7 do
  def sort_hand(a, b) do
    aa = Enum.chunk_by(a, fn x -> x end)
    bb = Enum.chunk_by(b, fn x -> x end)
  end

  def build_chunk(str) do
    str
    |> String.graphemes()
    |> Enum.sort()
    |> Enum.chunk_by(fn x -> x end)
    |> Enum.sort()
  end
end
