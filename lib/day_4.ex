defmodule Day4 do
  alias Scratcher

  def a() do
    File.stream!("assets/day_four_input.txt")
    # File.stream!("assets/test.txt")
    |> Enum.map(&parse_ticket/1)
    |> Enum.map(&score_game/1)
    |> Enum.sum()
  end

  def b() do
    File.stream!("assets/day_four_input.txt")
    # File.stream!("assets/test.txt")
    |> Enum.map(&parse_ticket_better/1)
    |> Map.new()
    |> IO.inspect()
    |> make_winner_map()
    # |> increment_index(1, 1)
    |> execute_scratch_map(1)
    # |> IO.inspect(label: "Ex complete")
    |> Map.values()
    |> Enum.map(& &1.total_execution)
    |> Enum.sum()
  end

  def parse_ticket(ticket) do
    matches =
      ticket
      |> String.split(":")
      |> List.last()
      |> String.split("|")
      |> Enum.map(fn a ->
        String.trim(a)
        |> String.split(" ")
        |> Enum.filter(fn b -> b != "" end)
        |> Enum.map(fn b ->
          b |> String.trim() |> Integer.parse() |> elem(0)
        end)
      end)

    {List.first(matches), List.last(matches)}
  end

  def score_game({winners, bucket}) do
    Enum.reduce(winners, 0, fn winner, points ->
      case Enum.any?(bucket, &(&1 == winner)) do
        true ->
          if points == 0 do
            1
          else
            points * 2
          end

        false ->
          points
      end
    end)
  end

  def parse_ticket_better(ticket) do
    split_ticket =
      ticket
      |> String.split(":")

    matches =
      split_ticket
      |> List.last()
      |> String.split("|")
      |> Enum.map(fn a ->
        String.trim(a)
        |> String.split(" ")
        |> Enum.filter(fn b -> b != "" end)
        |> Enum.map(fn b ->
          b |> String.trim() |> Integer.parse() |> elem(0)
        end)
      end)
      |> IO.inspect()

    game_number =
      split_ticket
      |> List.first()
      |> String.trim()
      |> String.split(" ")
      |> List.last()
      |> String.trim()
      |> Integer.parse()
      |> elem(0)
      |> IO.inspect()

    # Enum.into(%{}, {game_number, {List.first(matches), List.last(matches)}})
    {game_number,
     %Scratcher{winners: List.first(matches), chosen: List.last(matches), game_id: game_number}}
  end

  def recurse_count(all_tickets, index) do
    # IO.puts("Game #{index}:")
    my_ticket = Map.fetch!(all_tickets, index)
    winners = num_matches(my_ticket)

    case winners do
      0 ->
        winners

      _ ->
        child_wins =
          Enum.to_list(1..winners)
          # |> IO.inspect()
          |> Enum.map(fn a ->
            # {a, index} |> IO.inspect()
            recurse_count(all_tickets, index + a)
          end)
          # |> IO.inspect(label: "Output - Game #{index}")
          |> Enum.sum()

        winners + child_wins
    end
  end

  def make_winner_map(scratchers) do
    Enum.reduce(Map.values(scratchers), scratchers, fn %Scratcher{
                                                         game_id: id,
                                                         winners: w,
                                                         chosen: c
                                                       },
                                                       sk ->
      winners = num_matches({w, c})
      Map.update!(sk, id, &%{&1 | total_matches: winners})
    end)
  end

  def execute_scratch_map(scratchers, index) do
    scratchers
    |> Map.values()
    |> Enum.sort(&scratcher_sort/2)
    |> Enum.reduce(scratchers, fn %Scratcher{
                                    game_id: g
                                  } = _s,
                                  sk ->
      {:ok, new_s} = Map.fetch(sk, g)
      %{total_execution: ex, total_matches: m} = new_s

      if m > 0 do
        Enum.to_list(1..m)
        |> Enum.reduce(sk, &increment_index(&2, g + &1, ex))
        |> IO.inspect(label: "Completed Increment")
      else
        sk
      end
    end)
  end

  defp scratcher_sort(a, b) do
    a.game_id < b.game_id
  end

  defp increment_index(scratchers, index, count) do
    IO.puts("Increment Vals: #{index} - #{count}")

    Map.update!(scratchers, index, fn %{total_execution: tex} = x ->
      # IO.puts("Total Prior: #{tex}")
      # IO.puts("Count: #{count}")
      new_ex = tex + count
      %{x | total_execution: new_ex} |> IO.inspect()
    end)
  end

  def num_matches({winners, bucket}) do
    Enum.reduce(winners, 0, fn winner, points ->
      case Enum.any?(bucket, &(&1 == winner)) do
        true -> points + 1
        false -> points
      end
    end)

    # |> IO.inspect(label: "Total Winners")
  end
end
