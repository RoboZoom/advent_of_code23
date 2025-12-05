defmodule TwentyFive.Day1 do
  def problem_one() do
    fetch_data(true)
    |> tokenize_by_line()
    |> get_code()
    |> IO.inspect(label: "Result")
  end

  def problem_two() do
    fetch_data(false)
    |> tokenize_by_line()
    |> get_code_part_two()
    |> IO.inspect(label: "Result")
  end

  def parse_data(input_stream) do
    input_stream
    |> tokenize_by_line()
  end

  def tokenize_by_line(input_stream) do
    input_stream
    |> Enum.to_list()
    |> Enum.map(&String.trim(&1, "\n"))
    # |> Enum.map(&String.split(&1, " ", trim: true))
    |> IO.inspect()
    |> Enum.map(&token_to_number/1)
  end

  def token_to_number(token) do
    number = String.slice(token, 1, 3)
    dir = String.slice(token, -10, 1)

    case dir do
      "L" ->
        {i, _} = Integer.parse(number)
        i * -1

      "R" ->
        {i, _} = Integer.parse(number)
        i
    end
  end

  def get_code(inputs) do
    {_pos, z} =
      Enum.reduce(inputs, {50, 0}, fn el, acc ->
        {position, zeroes} = acc
        new_position = position + el

        new_zeroes =
          if rem(new_position, 100) == 0 do
            zeroes + 1
          else
            zeroes
          end

        {new_position, new_zeroes}
      end)

    z
  end

  def get_code_part_two(inputs) do
    {_pos, z} =
      Enum.reduce(inputs, {50, 0}, fn el, acc ->
        {position, zeroes} = acc
        new_position = position + el
        calculated_zeroes = check_hundreds_crossover(position, new_position)
        new_zeroes = zeroes + calculated_zeroes
        IO.puts("El: #{el} | Calc Zeroes: #{calculated_zeroes}")

        {new_position, new_zeroes}
      end)

    z
  end

  def check_hundreds_crossover(old, new) do
    old_h = Integer.floor_div(old, 100)
    new_h = Integer.floor_div(new, 100)

    hundreds_interval = new_h - old_h

    sign =
      cond do
        new - old >= 0 -> "+"
        true -> "-"
      end

    # IO.puts("Old: #{old} New: #{new} Sign: #{sign}")

    case sign do
      "+" ->
        hundreds_interval

      "-" ->
        h = abs(hundreds_interval)
        m = 0

        m =
          if check_on_zero(old) do
            m - 1
          else
            m
          end

        m =
          if check_on_zero(new) do
            m + 1
          else
            m
          end

        # IO.inspect(m, label: "m")
        h + m
    end

    # old_h !== new_h and not check_on_zero(old)
  end

  def check_on_zero(position) do
    rem(position, 100) == 0
  end

  defp fetch_data(test) when test == false, do: File.stream!("assets/2025/d01/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.stream!("assets/2025/d01/test_input.txt")
end
