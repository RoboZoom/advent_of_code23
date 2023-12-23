defmodule Day23 do
  def parse(file) do
    g =
      File.read!(file)
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> build_chart()
      |> IO.inspect(label: "Post Build")

    %{
      grid: g,
      start: get_start_from_grid(g),
      end: get_end_from_grid(g)
    }
  end

  def a(test_data \\ true) do
    init =
      get_test_data(test_data)
      |> parse()
      |> set_start()

    get_longest_path(init, get_coord(init.end), 0)
  end

  def b(test_data \\ true) when is_boolean(test_data) do
  end

  def get_longest_path(chart, current_coord, count) do
    {:ok, c} = get_coord_val(chart, current_coord)

    if(c.val == "S") do
      count
    else
      valid = get_valid_moves(chart, current_coord)

      if(length(valid) == 0) do
        -1
      else
        new_grid = set_visited(chart.grid, current_coord)
        new_chart = %{chart | grid: new_grid}

        Enum.map(valid, fn v -> get_longest_path(new_chart, v, count + 1) end)
        |> Enum.max()
      end
    end
  end

  def set_visited(grid, coord), do: Map.update!(grid, coord, fn a -> %{a | visited: true} end)

  def get_valid_moves(chart, {x, y} = coord) do
    # IO.puts("Checking {#{x}, #{y}}")
    {:ok, here} = get_coord_val(chart, coord)

    op_list = [{x, y + 1}, {x, y - 1}, {x + 1, y}, {x - 1, y}]
    # case here.val do
    #   "." -> [{x, y + 1}, {x, y - 1}, {x + 1, y}, {x - 1, y}]
    #   "^" -> [{x + 1, y}]
    #   "<" -> [{x, y + 1}]
    #   ">" -> [{x, y - 1}]
    #   "v" -> [{x - 1, y}]
    # end

    Enum.filter(op_list, &check_valid(chart, &1))
  end

  def check_valid(chart, coord) do
    with {:ok, i} <- Map.fetch(chart.grid, coord) do
      case i.val do
        "." ->
          !i.visited

        "^" ->
          !i.visited

        "v" ->
          !i.visited

        ">" ->
          !i.visited

        "<" ->
          !i.visited

        "S" ->
          true

        _ ->
          false
      end
    else
      _ -> false
    end
  end

  def set_start(%{grid: g, start: s} = chart) do
    new_start = %{s | val: "S"}
    new_grid = Map.put(g, get_coord(s), new_start)

    %{chart | grid: new_grid, start: new_start}
  end

  def get_coord(%{coord: %{x: x, y: y}}), do: {x, y}

  def get_coord_val(chart, {_, _} = k) do
    # IO.inspect(k, label: "Key")
    Map.fetch(chart.grid, k)
  end

  def build_chart(grid) do
    Enum.with_index(grid)
    |> Enum.reduce(%{}, fn {row, row_index} = r, acc ->
      IO.inspect(r, label: "Row")

      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {item, col_index}, row_map ->
        Map.put(row_map, {row_index, col_index}, %{
          val: item,
          visited: false,
          coord: %{x: row_index, y: col_index}
        })
      end)
    end)
  end

  def get_start_from_grid(grid) do
    grid
    |> Enum.filter(fn {_, a} ->
      a.coord.x == 0 and a.val == "."
    end)
    |> List.first()
    |> elem(1)
  end

  def get_end_from_grid(grid) do
    last_row =
      grid
      |> Map.values()
      |> Enum.map(& &1.coord.x)
      |> Enum.max()

    grid
    |> Enum.filter(fn {_, a} ->
      a.coord.x == last_row and a.val == "."
    end)
    |> List.first()
    |> elem(1)
  end

  def get_test_data(true), do: "assets/test.txt"
  def get_test_data(false), do: "assets/day_23_input.txt"
end
