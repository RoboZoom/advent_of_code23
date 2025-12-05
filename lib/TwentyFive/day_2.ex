defmodule TwentyFive.Day2 do
  def problem_one() do
    fetch_data(true)
    |> parse_data()
    |> IO.inspect(label: "Result")
  end

  def problem_two() do
    fetch_data(false)
    |> IO.inspect(label: "Result")
  end

  def parse_data(input_stream) do
    input_stream
    |> separate_ranges()
    |> parse_range()
  end

  defp separate_ranges(line), do: String.split(line, ",")

  defp parse_range(line) do
    line
    |> Enum.map(fn range ->
      [a, b] =
        range
        |> String.trim()
        |> String.split("-")

      {a, b}
    end)
  end

  def get_doubles({lower, upper}) do
    l_digits = length(lower)
    h_digits = length(upper)

    l_int = Integer.parse(lower)
    h_int = Integer.parse(upper)

    cond do
      l_digits == h_digits and l_digits > 1 ->
        if rem(l_digits, 2) == 1 do
          # Odd Digits - No need to compute
          []
        else
          # Even Digits
          half_digits = l_digits / 2
        end

      l_digits !== h_digits and l_digits > 1 ->
        # Do stuff
        []

      true ->
        []
    end
  end

  defp fetch_data(test) when test == false, do: File.read!("assets/2025/d02/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.read!("assets/2025/d02/test_input.txt")
end
