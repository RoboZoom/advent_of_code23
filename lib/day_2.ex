defmodule Day2 do
  def day_two_a() do
    # File.stream!("assets/test.txt")
    File.stream!("assets/day_two_input.txt")
    |> Enum.map(&parse_game/1)
    |> Enum.map(&check_rgb_param(&1, 12, 14, 13))
    |> Enum.reduce(0, fn {id, valid}, acc ->
      case valid do
        false -> acc
        true -> id + acc
      end
    end)
  end

  def day_two_b() do
    # File.stream!("assets/test.txt")
    File.stream!("assets/day_two_input.txt")
    |> Enum.map(&parse_game/1)
    |> Enum.map(&get_power/1)
    |> Enum.sum()
  end

  def get_power({_id, games}) do
    [:red, :green, :blue]
    |> Enum.map(&local_max(games, &1))
    |> Enum.reduce(1, &(&1 * &2))
  end

  defp local_max(list, key) do
    list
    |> Enum.map(&Map.fetch!(&1, key))
    |> Enum.max()
  end

  defp check_rgb_param({id, games}, r_max, b_max, g_max) do
    {id,
     Enum.reduce(games, true, fn %{red: r, green: g, blue: b}, valid ->
       if r > r_max or g > g_max or b > b_max do
         false
       else
         true and valid
       end
     end)}
  end

  def parse_game(line) do
    game_id_regex = ~r"Game \d+"

    samples =
      line
      |> String.split(":")
      |> List.last()
      |> String.split(";")

    {id, _} =
      Regex.run(game_id_regex, line)
      |> List.first()
      |> String.split()
      |> List.last()
      |> Integer.parse()

    vals =
      samples |> Enum.map(&parse_sample/1)

    {id, vals}
  end

  defp parse_sample(sample_str) do
    red_regex = ~r"\d+ red"
    blue_regex = ~r"\d+ blue"
    green_regex = ~r"\d+ green"

    %{
      red: get_color_val(sample_str, red_regex),
      blue: get_color_val(sample_str, blue_regex),
      green: get_color_val(sample_str, green_regex)
    }
  end

  defp get_color_val(str, regex) do
    case Regex.run(regex, str) do
      [h | _] ->
        {n, _} =
          h
          |> String.split()
          |> List.first()
          |> Integer.parse()

        n

      _ ->
        0
    end
  end
end
