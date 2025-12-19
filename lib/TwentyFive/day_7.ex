defmodule TwentyFive.Day7 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> IO.inspect(label: "Parsed Data")
  end

  def problem_two(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> IO.inspect(label: "Parsed Data")
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&Enum.filter(&1, fn el -> el != "" end))
    |> IO.inspect(label: "Pre parse")
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d06/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d06/test_input.txt")
end
