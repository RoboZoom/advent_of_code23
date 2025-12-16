defmodule TwentyFive.Day6 do
  def problem_one(test_data \\ false) do
    [fresh_list, require_list] =
      fetch_data(test_data)
      |> parse_data()
  end

  def problem_two(test_data \\ false) do
    # Note: Need to optimize.
    [fresh_list, _require_list] =
      fetch_data(test_data)
      |> parse_data()
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n"))
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d05/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d05/test_input.txt")
end
