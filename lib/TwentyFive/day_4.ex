defmodule TwentyFive.Day4 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> create_grid()
    |> pop_grid()
    |> IO.inspect(label: "Populated grid")
    |> Enum.filter(fn {_, {sym, count}} ->
      sym == "@" and count < 4
    end)
    |> IO.inspect(
      label: "Filtered Grid",
      pretty: true,
      syntax_colors: [number: :blue, string: :yellow]
    )
    |> Enum.count()

    # |> Enum.sum()
  end

  def problem_two(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> create_grid()
    |> reduce_paper(0)
  end

  def reduce_paper(grid, count) do
    valid_spaces =
      grid
      |> reset_grid()
      |> pop_grid()
      |> Enum.filter(fn {_, {sym, count}} ->
        sym == "@" and count < 4
      end)

    total_found = Enum.count(valid_spaces)

    cond do
      total_found > 0 ->
        grid
        |> replace_grid(valid_spaces)
        |> reduce_paper(total_found + count)

      total_found == 0 ->
        IO.puts("Done: #{count}")
        count
    end
  end

  def replace_grid(grid, coord_list) do
    Enum.reduce(coord_list, grid, fn {coord, _el}, g ->
      Map.update!(g, coord, fn _el ->
        {".", 0}
      end)
    end)
  end

  def reset_grid(grid) do
    Enum.map(grid, fn {key, {sym, _c}} ->
      {key, {sym, 0}}
    end)
    |> Map.new()
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
    |> List.flatten()
    |> Enum.map(fn {a, b, c} -> {c, {a, b}} end)
    |> Enum.into(%{})
  end

  def pop_grid(grid) do
    all_coords = Map.keys(grid)
    {max_x, _} = Enum.max_by(all_coords, fn {x, _} -> x end)
    {_, max_y} = Enum.max_by(all_coords, fn {_, y} -> y end)
    # IO.puts("Max X: #{max_x} | Max Y: #{max_y}")
    populate_grid(grid, {0, 0}, max_x, max_y)
  end

  def populate_grid(grid, {_x, y} = _coord, _max_x, max_y) when y > max_y, do: grid

  def populate_grid(grid, {x, y} = _coord, max_x, max_y) when x > max_x,
    do: populate_grid(grid, {0, y + 1}, max_x, max_y)

  def populate_grid(grid, {x, y} = coord, max_x, max_y) do
    {sym, _} = Map.fetch!(grid, coord)

    if sym == "@" do
      coord
      |> get_adjacent_grid_coords(max_x, max_y)
      |> Enum.reduce(grid, fn el, new_grid ->
        Map.update!(new_grid, el, &increment_coord_basic/1)
      end)
      |> populate_grid({x + 1, y}, max_x, max_y)
    else
      populate_grid(grid, {x + 1, y}, max_x, max_y)
    end
  end

  def increment_coord_basic({symbol, count}) do
    {symbol, count + 1}
  end

  def get_adjacent_grid_coords({x, y} = _coord, max_x, max_y) do
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

  defp check_valid_coord({x, y} = _coord, max_x, max_y) do
    cond do
      x > max_x -> false
      x < 0 -> false
      y > max_y -> false
      y < 0 -> false
      true -> true
    end
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d04/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d04/test_input.txt")
end
