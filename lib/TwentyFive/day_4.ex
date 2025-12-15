defmodule TwentyFive.Day4 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> create_grid()
    |> Enum.sum()
  end

  def problem_two(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()

    # |> Enum.map(&max_joltage(&1, 12, ""))
    # |> Enum.sum()
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n")
  end

  def create_grid(starter_grid) do
    starter_grid
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.map(fn {line, y_index} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {sym, x_index} ->
        {sym, 0, {x_index, y_index}}
      end)
    end)
    |> IO.inspect(label: "Starter Grid")

    # |> Enum.reduce()
  end

  def populate_grid(grid, {_x, y} = _coord, _max_x, max_y) when y >= max_y, do: grid

  def populate_grid(grid, {x, y} = _coord, max_x, max_y) when x >= max_x,
    do: populate_grid(grid, {0, y + 1}, max_x, max_y)

  def populate_grid(grid, {x, y} = coord, max_x, max_y) do
    coord
    |> get_adjacent_grid_coords(max_x, max_y)
    |> Enum.reduce()
  end

  defp get_adjacent_grid_coords({x, y} = coord, max_x, max_y) do
    [
      {x + 1, y},
      {x + 1, y - 1},
      {x + 1, y + 1},
      {x, y + 1},
      {x, y - 1},
      {x - 1, y},
      {x - 1, y - 1},
      {x - 1, y + 1}
    ]
    |> Enum.filter(&check_valid_coord(&1, max_x, max_y))
  end

  defp check_valid_coord({x, y} = coord, max_x, max_y) do
    cond do
      x >= max_x -> false
      x < 0 -> false
      y >= max_y -> false
      y < 0 -> false
      true -> true
    end
  end

  defp fetch_data(test) when test == false, do: File.read!("assets/2025/d04/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.read!("assets/2025/d04/test_input.txt")
end
