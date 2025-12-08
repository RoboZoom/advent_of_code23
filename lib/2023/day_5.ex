defmodule Day5 do
  def a() do
    # File.read!("assets/test.txt")
    File.read!("assets/day_five_input.txt")
    |> parse_input()
    |> check_seed_list()
    |> Enum.min()
  end

  def b() do
    # File.read!("assets/test.txt")
    File.read!("assets/day_five_input.txt")
    |> parse_input()
    |> check_reverse_range()
  end

  def parse_input(input) do
    split_input = String.split(input, "\n")

    t =
      split_input
      |> List.first()
      |> String.trim()
      |> IO.inspect(label: "T")

    seeds =
      Regex.scan(~r"\d+", t)
      |> List.flatten()
      |> Enum.map(
        &(&1
          |> Integer.parse()
          |> elem(0))
      )

    seed_soil = "seed-to-soil map:"
    soil_fert = "soil-to-fertilizer map:"
    fert_wat = "fertilizer-to-water map:"
    water_light = "water-to-light map:"
    light_temp = "light-to-temperature map:"
    temp_humid = "temperature-to-humidity map:"
    humid_loc = "humidity-to-location map:"

    maps =
      [seed_soil, soil_fert, fert_wat, water_light, light_temp, temp_humid, humid_loc]
      |> Enum.map(fn a ->
        # r_key = ~r"#{a}\s(\d+\s+)+"
        r_key = ~r"#{a}\s*(\d+\s*)+\s*"

        Regex.run(r_key, input)
        |> List.first()
        |> parse_map()
      end)

    {seeds, maps}
  end

  def parse_map(map_input) do
    String.split(map_input, "\n")
    |> Enum.map(&Regex.scan(~r"\d+", &1))
    |> Enum.map(fn x ->
      %{
        source: get_item(x, 1),
        destination: get_item(x, 0),
        size: get_item(x, 2)
      }
    end)
    |> Enum.filter(&(&1.size !== nil))
  end

  def get_item(arr, index) do
    case Enum.at(arr, index) do
      nil ->
        nil

      a ->
        a
        |> List.first()
        |> Integer.parse()
        |> elem(0)
    end
  end

  def check_seed_list({seeds, maps}) do
    Enum.map(seeds, &traverse(&1, maps))
  end

  def check_seed_ranges({seeds, maps}) do
    make_seed_pairs(seeds)
    # |> IO.inspect(label: "Seed Pairs")
    |> Enum.map(fn {start, range} ->
      top = start + range

      Enum.to_list(start..top)
      |> Enum.reduce(:err, fn el, min ->
        v = traverse(el, maps)

        if min == :err or v < min do
          v
        else
          min
        end
      end)
    end)
  end

  def check_reverse_range({seeds, maps}) do
    seed_pairs = make_seed_pairs(seeds)
    reversed_maps = Enum.reverse(maps)
    check_num(1, reversed_maps, seed_pairs)
  end

  def check_num(index, reversed_maps, seeds) do
    if(rem(index, 10000) == 0) do
      IO.inspect(index, label: "Index")
    end

    included =
      reverse_traversal(index, reversed_maps)
      |> check_seed_bounds(seeds)

    case included do
      true -> index
      false -> check_num(index + 1, reversed_maps, seeds)
    end
  end

  def check_seed_bounds(value, seeds) do
    Enum.any?(seeds, fn {start, inc} -> check_bounds(value, start, inc) end)
  end

  def make_seed_pairs(seeds) do
    Enum.reduce(seeds, {[], {0, 0}, 1}, fn seed_item, {l, {a, b} = _active, index} ->
      case rem(index, 2) == 0 do
        true -> {[{a, seed_item} | l], {0, 0}, index + 1}
        false -> {l, {seed_item, b}, index + 1}
      end
    end)
    |> elem(0)
  end

  def traverse(seed, maps) do
    Enum.reduce(maps, seed, fn map, val ->
      case Enum.find(map, &check_bounds(val, &1.source, &1.size)) do
        %{source: s, size: _size, destination: d} ->
          x = val - s
          d + x

        nil ->
          val
      end
    end)
  end

  def reverse_traversal(location, reversed_maps) do
    Enum.reduce(reversed_maps, location, fn map, val ->
      case Enum.find(map, &check_bounds(val, &1.destination, &1.size)) do
        %{source: s, size: _size, destination: d} ->
          x = val - d
          s + x

        nil ->
          val
      end
    end)
  end

  def check_bounds(val, start, inc) do
    val >= start and val <= start + inc
  end
end
