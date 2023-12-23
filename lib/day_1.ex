defmodule Day1 do
  def day_one_a() do
    File.stream!("assets/day_one_input.txt")
    |> Enum.map(&get_line_nums/1)
    |> Enum.sum()
  end

  def day_one_b() do
    # File.stream!("assets/day_one_input.txt")
    File.stream!("assets/test.txt")
    |> Enum.map(&get_line_nums_spelled/1)
    |> Enum.sum()
  end

  defp get_line_nums(str) when is_binary(str) do
    num_list =
      Regex.scan(~r"\d", str)
      |> List.flatten()

    {f, _} = List.first(num_list) |> Integer.parse()
    {l, _} = List.last(num_list) |> Integer.parse()

    f * 10 + l
  end

  def get_line_nums_spelled(str) when is_binary(str) do
    regex_match = ~r"(?=(\d|one|two|three|four|five|six|seven|eight|nine))"

    num_list =
      Regex.scan(regex_match, str)
      |> Enum.map(&List.last/1)
      |> List.flatten()

    f = List.first(num_list) |> number_from_match()
    l = List.last(num_list) |> number_from_match()

    f * 10 + l
  end

  defp number_from_match(x) do
    case x do
      "one" ->
        1

      "two" ->
        2

      "three" ->
        3

      "four" ->
        4

      "five" ->
        5

      "six" ->
        6

      "seven" ->
        7

      "eight" ->
        8

      "nine" ->
        9

      _ ->
        {y, _} = Integer.parse(x)
        y
    end
  end
end
