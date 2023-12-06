defmodule Day6 do
  def a() do
    File.read!("assets/day_six_input.txt")
    |> parse_race()
    |> Enum.map(&find_records/1)
    |> IO.inspect(label: "Items")
    |> Enum.product()
  end

  def parse_race(input) do
    lines = String.split(input, "\n")

    times =
      Regex.scan(~r"\d+", List.first(lines))
      |> List.flatten()
      |> Enum.map(fn a -> Integer.parse(a) |> elem(0) end)
      |> IO.inspect(label: "Times")

    distances =
      Regex.scan(~r"\d+", List.last(lines))
      |> List.flatten()
      |> Enum.map(fn a -> Integer.parse(a) |> elem(0) end)
      |> IO.inspect(label: "Distances")

    Enum.zip_with([times, distances], fn items ->
      %{
        time: List.first(items),
        distance: List.last(items)
      }
    end)
  end

  def find_records(race) do
    first = check_race_record_fwd(race, 0) |> IO.inspect(label: "First")
    last = check_race_record_back(race, race.time) |> IO.inspect(label: "Last")
    last - first + 1
  end

  def check_time_distance(race, button_press_time) do
    speed = button_press_time

    (race.time - button_press_time) * speed
  end

  def check_race_record_fwd(race, index) do
    case check_time_distance(race, index) > race.distance do
      true -> index
      false -> check_race_record_fwd(race, index + 1)
    end
  end

  def check_race_record_back(race, index) do
    case check_time_distance(race, index) > race.distance do
      true -> index
      false -> check_race_record_back(race, index - 1)
    end
  end
end
