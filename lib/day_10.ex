defmodule Day10 do
  def a() do
    parse_input("assets/test.txt")
    # parse_input("assets/day_ten_input.txt")
    |> find_routes()
    |> IO.inspect()
    |> check_max_length()
  end

  def b() do
    parse_input("assets/test.txt")
    # parse_input("assets/day_ten_input.txt")
    |> find_routes()
    |> IO.inspect()
    |> check_contained_squares()
  end

  def parse_input(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.graphemes(&1))
  end

  def check_max_length(route) do
    Integer.floor_div(length(route), 2)
  end

  def check_contained_squares(route) do
    [_ | clean_route] =
      route
      |> Enum.filter(fn {_, _, d} -> !String.contains?(d, "|") end)

    Enum.group_by(clean_route, &elem(&1, 1))
    |> Enum.map(fn a ->
      a
      |> elem(1)
      |> Enum.sort_by(&elem(&1, 0))
    end)
    |> IO.inspect()
    |> Enum.map(&count_squares/1)
    |> IO.inspect(label: "Squares by Col")
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def count_squares(col) do
    init_el = {0, 0, "*"}

    Enum.reduce(col, {0, 0, init_el}, fn {row, _col, d} = c,
                                         {count, index, {last_row, _last_col, last_el}} ->
      case should_count?(index, d, last_el) do
        true -> {count + (row - last_row) - 1, index + 1, c}
        false -> {count, index + 1, row}
      end
    end)
  end

  def should_count?(index, d, sym) do
    r = rem(index, 2) == 1

    case d do
      "F" -> false
      "J" -> false
      _ -> r
    end
  end

  def is_turn(dir) do
    String.contains?(dir, "N") or String.contains?("S")
  end

  def parse_direction(dir) do
    d = String.split(dir, "|")

    %{
      entry_direction: List.last(d),
      exit_direction: List.first(d)
    }
  end

  def find_routes(field) do
    origin = first_coord(field, &(&1 == "S"))

    case traverse(field, move_coord(origin, "N"), "S", [origin]) do
      :stop ->
        case traverse(field, move_coord(origin, "S"), "N", [origin]) do
          :stop ->
            a = traverse(field, move_coord(origin, "E"), "W", [origin])
            [a]

          v ->
            v |> elem(1)
        end

      {direction, route} ->
        case direction do
          "S" ->
            case traverse(field, move_coord(origin, "W"), "E", [origin]) do
              :stop ->
                route

              v ->
                second_route = v |> elem(1)
                [route, second_route]
            end

          _ ->
            case traverse(field, move_coord(origin, "S"), "N", [origin]) do
              :stop ->
                route

              v ->
                second_route = v |> elem(1)
                [route, second_route]
            end
        end
    end
  end

  def read_coord(field, {r, col, _}) do
    row = Enum.at(field, r)
    # Value
    Enum.at(row, col)
  end

  def first_coord(field, comp_fn) do
    row = Enum.find_index(field, &Enum.any?(&1, comp_fn))
    col = Enum.find_index(Enum.at(field, row), comp_fn)
    {row, col, "*"}
  end

  def move_coord({row, col, d}, "N"), do: {row - 1, col, "N|#{parse_old_direction(d)}"}
  def move_coord({row, col, d}, "E"), do: {row, col + 1, "E|#{parse_old_direction(d)}"}
  def move_coord({row, col, d}, "S"), do: {row + 1, col, "S|#{parse_old_direction(d)}"}
  def move_coord({row, col, d}, "W"), do: {row, col - 1, "W|#{parse_old_direction(d)}"}

  def traverse(field, coord, origin_direction, route) do
    current_coord = read_coord(field, coord)

    # IO.inspect({coord, current_coord}, label: "Current Coord")

    d = get_direction(current_coord, origin_direction)
    # IO.inspect({d, current_coord, coord}, label: "Get Direction")

    case d do
      :stop ->
        :stop

      :finish ->
        {:finish, [coord | route] |> Enum.reverse()}

      _ ->
        traverse(
          field,
          move_coord(coord, d) |> put_elem(2, current_coord),
          direction_complement(d),
          [coord | route]
        )
    end
  end

  def parse_old_direction(d) do
    d
    |> parse_direction()
    |> Map.fetch!(:exit_direction)
  end

  def get_direction(symbol, from_direction)
  def get_direction("J", "N"), do: "W"
  def get_direction("J", "W"), do: "N"
  def get_direction("|", "N"), do: "S"
  def get_direction("|", "S"), do: "N"
  def get_direction("F", "E"), do: "S"
  def get_direction("F", "S"), do: "E"
  def get_direction("L", "N"), do: "E"
  def get_direction("L", "E"), do: "N"
  def get_direction("-", "W"), do: "E"
  def get_direction("-", "E"), do: "W"
  def get_direction("7", "W"), do: "S"
  def get_direction("7", "S"), do: "W"
  def get_direction("S", _), do: :finish
  def get_direction(_, _), do: :stop

  def check_valid_origin(symbol, direction) do
    case symbol do
      "|" -> direction == "N" or "S"
      "F" -> direction == "S" or "E"
      "L" -> direction == "N" or "E"
      "-" -> direction == "E" or "W"
      "J" -> direction == "N" or "W"
      "7" -> direction == "W" or "S"
    end
  end

  def direction_complement("N"), do: "S"
  def direction_complement("S"), do: "N"
  def direction_complement("E"), do: "W"
  def direction_complement("W"), do: "E"
end
