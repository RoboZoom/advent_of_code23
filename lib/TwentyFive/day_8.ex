defmodule TwentyFive.Day8 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> get_pairs()
    |> Enum.map(fn {a, b} -> {a, b, cubed_distance(a, b)} end)
    |> Enum.sort_by(fn {_a, _b, distance} -> distance end, :asc)
    # |> IO.inspect("Coord List by Distance")
    |> Enum.take(1000)
    |> Enum.reduce([], fn {a, b, _dist}, list -> make_connection({a, b}, list) end)
    |> Enum.map(fn a -> MapSet.size(a) end)
    |> Enum.sort(:desc)
    |> IO.inspect()
    |> Enum.take(3)
    |> Enum.product()
  end

  def problem_two(test_data \\ false) do
    coords =
      fetch_data(test_data)
      |> parse_data()

    total_size = length(coords)

    {a, b} =
      coords
      |> get_pairs()
      |> Enum.map(fn {a, b} -> {a, b, cubed_distance(a, b)} end)
      |> Enum.sort_by(fn {_a, _b, distance} -> distance end, :asc)
      # |> IO.inspect("Coord List by Distance")
      # |> Enum.take(1000)
      |> Enum.reduce_while([], fn {a, b, _dist}, list ->
        new_list = make_connection({a, b}, list)

        if length(new_list) == 1 and MapSet.size(Enum.at(new_list, 0)) == total_size do
          {:halt, {a, b}}
        else
          {:cont, new_list}
        end
      end)
      |> IO.inspect()

    {x1, _, _} = a
    {x2, _, _} = b

    x1 * x2
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s ->
      l =
        String.split(s, ",")
        |> Enum.map(fn n ->
          {i, _} = Integer.parse(n)
          i
        end)

      {Enum.at(l, 0), Enum.at(l, 1), Enum.at(l, 2)}
    end)
  end

  def make_connection({a, b}, current_connections) do
    a_index = Enum.find_index(current_connections, fn set -> MapSet.member?(set, a) end)
    b_index = Enum.find_index(current_connections, fn set -> MapSet.member?(set, b) end)

    cond do
      a_index == nil and b_index == nil ->
        [MapSet.new([a, b]) | current_connections]

      a_index == nil ->
        {set, list} = List.pop_at(current_connections, b_index)
        [MapSet.put(set, a) | list]

      b_index == nil ->
        {set, list} = List.pop_at(current_connections, a_index)
        [MapSet.put(set, b) | list]

      a_index == b_index ->
        current_connections

      true ->
        {aa, bb, cc} = a
        {dd, ee, ff} = b
        IO.puts("Merging Sets: {#{aa}, #{bb}, #{cc}} - {#{dd}, #{ee}, #{ff}}")
        merge_sets(current_connections, a_index, b_index)
    end
  end

  def merge_sets(connections, index_a, index_b) do
    bigger_index = max(index_a, index_b)
    smaller_index = min(index_a, index_b)

    {s_b, first} = List.pop_at(connections, bigger_index)
    {s_s, rest} = List.pop_at(first, smaller_index)

    [MapSet.union(s_b, s_s) | rest]
  end

  def cubed_distance({a, b, c}, {d, e, f}) do
    z = abs(f - c)
    y = abs(e - b)
    x = abs(d - a)

    z * z + y * y + x * x
  end

  def get_pairs([_item]), do: []

  def get_pairs([h | rest]) do
    h_coords = Enum.map(rest, fn a -> {h, a} end)
    h_coords ++ get_pairs(rest)
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d08/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d08/test_input.txt")
end
