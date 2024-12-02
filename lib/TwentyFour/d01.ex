defmodule TwentyFour.D01 do
  def d01_a() do
    fetch_data(false)
    |> parse_input_to_lists()
    |> sort_lists()
    |> get_differences()
    |> Enum.sum()
  end

  def d01_b() do
    fetch_data(false)
    |> parse_input_to_lists()
    |> Enum.map(&Enum.frequencies(&1))
    |> get_similarity()
    |> Enum.sum()
  end

  defp fetch_data(test) when test == false, do: File.stream!("assets/2024/d01/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.stream!("assets/2024/d01/test_input.txt")

  defp parse_input_to_lists(input_stream) do
    input_stream
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [h, t] -> {h, t} end)
    |> Enum.map(fn {a, b} -> {String.to_integer(a), String.to_integer(b)} end)
    # |> IO.inspect(label: "Parsing 1")
    |> Enum.reduce([[], []], fn {a, b}, [x, y] ->
      [[a | x], [b | y]]
    end)
  end

  defp sort_lists(lists) do
    Enum.map(lists, &Enum.sort(&1))
  end

  defp get_differences(lists) do
    lists
    |> Enum.zip()
    |> Enum.map(fn {a, b} -> abs(a - b) end)
  end

  defp get_similarity([a, b]) do
    IO.puts("Getting Similarity...")
    # IO.inspect(b)

    Enum.reduce(a, [], fn {num, freq}, acc ->
      new_entry =
        case(Map.get(b, num)) do
          nil -> 0
          b_freq -> num * freq * b_freq
        end

      [new_entry | acc]
    end)
  end
end
