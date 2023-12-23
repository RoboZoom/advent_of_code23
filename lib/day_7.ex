defmodule Day7 do
  def sort_hand(a, b) do
    aa = Enum.chunk_by(a, fn x -> x end)
    bb = Enum.chunk_by(b, fn x -> x end)
  end

  def build_chunk(str) do
    str
    |> String.graphemes()
    |> Enum.map(&replace_letters/1)
    |> Enum.sort()
    |> Enum.chunk_by(fn x -> x end)
    |> Enum.sort()
  end

  def replace_letters(str) do
    case str do
      "T" -> 10
      "J" -> 11
      "Q" -> 12
      "K" -> 13
      "A" -> 14
      _ -> Integer.parse(str) |> elem(0)
    end
  end

  # def check_four
end
