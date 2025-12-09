defmodule TwentyFive.Day4 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> Enum.map(&max_joltage(&1, 2, ""))
    |> Enum.sum()
  end

  def problem_two(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> Enum.map(&max_joltage(&1, 12, ""))
    |> Enum.sum()
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(
      &Enum.map(&1, fn el ->
        {i, _} = Integer.parse(el)
        i
      end)
    )
  end

  def max_joltage(_batteries_bank, 0, acc) do
    {i, _} = Integer.parse(acc)
    iv
  end

  def max_joltage(batteries_bank, length, acc) do
    # IO.puts("Max Joltage: #{batteries_bank} - #{length}")

    available_batteries =
      case length do
        1 ->
          batteries_bank

        _ ->
          {useable_batteries, _reserved_batteries} = Enum.split(batteries_bank, -(length - 1))
          useable_batteries
      end

    {max_num, index} =
      available_batteries
      |> Enum.with_index()
      |> Enum.max_by(fn {val, _index} ->
        val
      end)

    result = acc <> Integer.to_string(max_num)
    {_front, back} = Enum.split(batteries_bank, index + 1)

    max_joltage(back, length - 1, result)
  end

  defp fetch_data(test) when test == false, do: File.read!("assets/2025/d04/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.read!("assets/2025/d04/test_input.txt")
end
