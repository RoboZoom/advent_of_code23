defmodule TwentyFive.Day6 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> IO.inspect(label: "Parsed Data")
    |> create_problems()
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  def problem_two(test_data \\ false) do
    # Note: Need to optimize.

    fetch_data(test_data)
    |> parse_coarse()
    |> create_vertical_problem()
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  def create_vertical_problem(input) do
    len = length(List.first(input))
    [ops | numbers] = Enum.reverse(input) |> Enum.map(&String.graphemes/1)
    # numbers = Enum.reverse(numbers_reversed)

    Enum.reduce(
      0..(len - 1),
      %{
        built_problems: [],
        current_problem: {"", []}
      },
      fn ind, acc ->
        chars =
          Enum.reduce(numbers, [], fn row, list ->
            [Enum.at(row, ind) | list]
          end)

        case Enum.all?(chars, fn a -> a == " " end) do
          false ->
            {i, _} = Integer.parse(Enum.join(chars))
            {op, map} = acc

            b =
              Map.update!(map, :current_problem, fn a ->
                [i | a]
              end)

            o = Enum.at(ops, ind)

            cond do
              o == " " ->
                {op, b}

              true ->
                {o, b}
            end

          true ->
            %{
              current_problem: {c, nums},
              built_problems: b
            } = acc

            %{
              current_problem: {"", []},
              built_problems: [[c | nums] | b]
            }
        end
      end
    )
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&Enum.filter(&1, fn el -> el != "" end))
    |> IO.inspect(label: "Pre parse")
    |> parse_ints([])
  end

  def parse_coarse(input) do
    input
    |> String.trim()
    |> String.split("\n")
  end

  def parse_ints([last], finished), do: [last | finished]

  def parse_ints([l | rest], finished) do
    new_line =
      Enum.map(l, fn el ->
        {i, _} = Integer.parse(el)
        i
      end)

    IO.inspect(new_line, label: "New Line")

    parse_ints(rest, [new_line | finished])
  end

  def create_problems([ops | numbers]) do
    len = length(ops)

    Enum.reduce(0..(len - 1), [], fn ind, acc ->
      nums =
        Enum.reduce(numbers, [], fn el, acc ->
          {:ok, n} = Enum.fetch(el, ind)
          [n | acc]
        end)

      {:ok, op} = Enum.fetch(ops, ind)

      item = [op | nums]

      [item | acc]
    end)
  end

  def solve_problem([op | numbers]) do
    case op do
      "+" -> Enum.sum(numbers)
      "*" -> Enum.product(numbers)
    end
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d06/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d06/test_input.txt")
end
