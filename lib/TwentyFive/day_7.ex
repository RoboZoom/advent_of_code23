defmodule TwentyFive.Day7 do
  def problem_one(test_data \\ false) do
    input =
      fetch_data(test_data)
      |> parse_data()

    start = Enum.find_index(List.first(input), fn a -> a == "S" end)
    {_beams, splits} = process_beam(input, {MapSet.new([start]), 0}, 1)
    splits
  end

  def problem_two(test_data \\ false) do
    input =
      fetch_data(test_data)
      |> parse_data()

    start_index = Enum.find_index(List.first(input), fn a -> a == "S" end)
    start_map = Map.put(%{}, start_index, 1)

    process_beam_paths(input, start_map, 1)
    |> Enum.map(fn {_, a} -> a end)
    |> Enum.sum()
  end

  def process_beam_paths(input, beams, row_index) do
    case Enum.fetch(input, row_index) do
      {:ok, row} ->
        new_beams =
          Enum.reduce(beams, %{}, fn {beam_index, beam_count}, beam_hash ->
            case Enum.at(row, beam_index) do
              "." ->
                Map.update(beam_hash, beam_index, beam_count, fn a -> a + beam_count end)

              "^" ->
                beam_hash
                |> Map.update(beam_index + 1, beam_count, fn a -> a + beam_count end)
                |> Map.update(beam_index - 1, beam_count, fn a -> a + beam_count end)
            end
          end)

        process_beam_paths(input, new_beams, row_index + 1)

      :error ->
        beams
    end
  end

  def process_beam(input, {beams, splits} = data, row_index) do
    case Enum.fetch(input, row_index) do
      {:ok, row} ->
        {new_splits, new_beams} =
          Enum.reduce(beams, {0, MapSet.new()}, fn beam, {count, split_beams} ->
            case Enum.at(row, beam) do
              "." ->
                {count, MapSet.put(split_beams, beam)}

              "^" ->
                new_set =
                  split_beams
                  |> MapSet.put(beam + 1)
                  |> MapSet.put(beam - 1)

                {count + 1, new_set}
            end
          end)

        process_beam(input, {new_beams, splits + new_splits}, row_index + 1)

      :error ->
        data
    end
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d07/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d07/test_input.txt")
end
