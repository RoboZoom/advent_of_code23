defmodule TwentyFive.Day2 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> Enum.map(&get_doubles/1)
    |> Enum.filter(&(&1 !== nil))
    |> List.flatten()
    |> Enum.filter(&(&1 !== nil))
    |> IO.inspect(label: "Final List")
    |> Enum.sum()
    |> IO.inspect(label: "Result")
  end

  def problem_two(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> Enum.map(&get_repeats/1)
    # |> IO.inspect(label: "Pre-arranged List")
    |> List.flatten()
    |> Enum.filter(&(&1 !== nil))
    |> IO.inspect(label: "Final List")
    |> Enum.sum()
    |> IO.inspect(label: "Result")
  end

  def parse_data(input_stream) do
    input_stream
    |> separate_ranges()
    |> parse_range()
  end

  defp separate_ranges(line), do: String.split(line, ",")

  defp parse_range(line) do
    line
    |> Enum.map(fn range ->
      [a, b] =
        range
        |> String.trim()
        |> String.split("-")

      {a, b}
    end)
  end

  def get_repeats({lower, upper} = input) when is_binary(lower) do
    IO.puts("Get Repeats  - {#{lower}, #{upper}}")
    l_digits = String.length(lower) |> check_len()
    h_digits = String.length(upper)

    cond do
      l_digits == h_digits and l_digits > 1 ->
        get_repeats_same_digits(input)

      l_digits !== h_digits and h_digits > 1 ->
        # IO.puts("Phase 2 Called")
        init = get_repeats_same_digits({lower, nines(l_digits)})
        start = l_digits + 1

        Enum.reduce(start..h_digits, init, fn digits, acc ->
          top =
            if digits == h_digits do
              upper
            else
              nines(digits)
            end

          [get_repeats_same_digits({digit_start(digits), top}) | acc]
        end)

      true ->
        []
    end
    |> List.flatten()
    |> MapSet.new()
    |> MapSet.to_list()
    |> Enum.filter(&dummy_check(&1, input))
    |> IO.inspect()
  end

  defp dummy_check(item, {lower, upper}) do
    {l, _} = Integer.parse(lower)
    {h, _} = Integer.parse(upper)

    val = item >= l and item <= h

    if val == false do
      IO.puts("Bad Item Found - #{item} - {#{lower}, #{upper}}")
    end

    val
    # true
  end

  def check_len(1), do: 2
  def check_len(x), do: x

  def get_repeats_same_digits({lower, upper}) do
    # IO.puts("Get Repeats Same Digit - {#{lower}, #{upper}}")

    digit_range = get_digit_range(upper)
    total_digits = String.length(upper)
    {l, _} = Integer.parse(lower)
    {h, _} = Integer.parse(upper)

    Enum.reduce(digit_range, [], fn digits, acc ->
      digit_divisor = rem(total_digits, digits) == 0

      if digit_divisor do
        total_patterns = Integer.floor_div(total_digits, digits)
        start_pattern = String.slice(lower, 0..(digits - 1))

        init_guess = n_pattern_repeat_num(start_pattern, total_patterns)

        init_list =
          if init_guess >= l and init_guess <= h do
            [init_guess | acc]
          else
            acc
          end

        new_pattern = str_int_incr(start_pattern)

        if String.length(new_pattern) > String.length(start_pattern) do
          init_list
        else
          reduce_n_pattern(new_pattern, init_list, h)
        end
      else
        acc
      end
    end)
  end

  defp reduce_n_pattern(start_pattern, initial_list, upper) do
    # IO.puts("Reducing N Pattern: {#{start_pattern}, #{initial_list}, #{upper}}")
    upper_bound = get_upper_bound_from_pattern(start_pattern, upper)
    len = String.length(Integer.to_string(upper))
    pattern_repeats = Integer.floor_div(len, String.length(start_pattern))

    {start_int, _} = Integer.parse(start_pattern)

    Enum.reduce_while(start_int..upper_bound, initial_list, fn num, acc ->
      test_num = n_pattern_repeat_num(Integer.to_string(num), pattern_repeats)
      # IO.puts("Test Num: #{test_num} | Number: #{num} | Pattern Repeats: #{pattern_repeats}")

      cond do
        test_num <= upper ->
          {:cont, [test_num | acc]}

        true ->
          {:halt, acc}
      end
    end)
  end

  def get_upper_bound_from_pattern(pattern, upper) do
    upper_str = Integer.to_string(upper)
    patt_len = String.length(pattern)
    {result, _} = String.slice(upper_str, 0..(patt_len - 1)) |> Integer.parse()
    result
  end

  defp get_digit_range(num) do
    half_l = Integer.floor_div(String.length(num), 2)

    if half_l == 0 do
      1..1
    else
      1..half_l
    end
  end

  def n_pattern_repeat(pattern, n) when is_binary(pattern) do
    1..n
    |> Enum.to_list()
    |> Enum.map(fn _x -> pattern end)
    |> Enum.reduce("", fn el, acc ->
      acc <> el
    end)
  end

  defp n_pattern_repeat_num(pattern, n) when is_binary(pattern) do
    {num, _} = Integer.parse(n_pattern_repeat(pattern, n))
    num
  end

  def get_doubles({lower, upper} = input) when is_binary(lower) do
    IO.puts("Starting Doubles Reduce: {#{lower}, #{upper}}")
    l_digits = String.length(lower)
    h_digits = String.length(upper)

    cond do
      l_digits == h_digits and l_digits > 1 ->
        get_doubles_equal(input)

      l_digits !== h_digits and l_digits >= 1 ->
        init = get_doubles_equal({lower, nines(l_digits)})
        start = l_digits + 1

        Enum.reduce(start..h_digits, init, fn digits, acc ->
          top =
            if digits == h_digits do
              upper
            else
              nines(digits)
            end

          [get_doubles_equal({digit_start(digits), top}) | acc]
        end)

      true ->
        []
    end
  end

  def get_doubles_equal({lower, upper}) do
    if String.length(lower) !== String.length(upper),
      do: raise("Error: Get Doubles Equal improperly called - {#{lower}, #{upper}}")

    {l, _} = Integer.parse(lower)
    {h, _} = Integer.parse(upper)

    if check_even(lower) do
      front_half = front_half_str(lower)
      double_front = double_str_int(front_half)
      incremented_front = str_int_incr(front_half)

      front_start =
        if String.length(incremented_front) == String.length(front_half) do
          incremented_front
        else
          nil
        end

      {start, init} =
        cond do
          double_front < l ->
            {front_start, []}

          double_front >= l and double_front <= h ->
            {front_start, [double_front]}

          true ->
            {nil, []}
        end

      reduce_doubles(start, init, h)
    else
      []
    end
  end

  def check_even(str) when is_binary(str), do: rem(String.length(str), 2) == 0

  defp double_str(str) when is_binary(str), do: str <> str

  defp double_str_int(str) when is_binary(str) do
    {int, _} = Integer.parse(double_str(str))
    int
  end

  defp front_half_str(str) when is_binary(str) do
    half_length = Integer.floor_div(String.length(str), 2) - 1
    String.slice(str, 0..half_length)
  end

  defp str_int_incr(str_int) when is_binary(str_int) do
    {i, _} = Integer.parse(str_int)
    Integer.to_string(i + 1)
  end

  defp reduce_doubles(start, initial_list, _) when is_nil(start), do: initial_list

  defp reduce_doubles(start, initial_list, upper) when is_integer(upper) do
    IO.puts("Reducing Doubles: {#{start}, #{upper}}")

    {front_upper_int, _} =
      front_half_str(Integer.to_string(upper))
      |> Integer.parse()

    {start_int, _} = Integer.parse(start)

    cond do
      double_str_int(start) > upper ->
        initial_list

      double_str_int(start) <= upper ->
        Enum.reduce_while(start_int..front_upper_int, initial_list, fn num, acc ->
          dbl_num = double_str_int(Integer.to_string(num))

          if dbl_num <= upper do
            {:cont, [dbl_num | acc]}
          else
            {:halt, acc}
          end
        end)

      true ->
        []
    end
  end

  def nines(num) do
    1..num
    |> Enum.to_list()
    |> Enum.map(fn _x -> 9 end)
    |> Enum.reduce("", fn el, acc ->
      acc <> Integer.to_string(el)
    end)
  end

  def digit_start(num_digits) do
    zeroes =
      1..(num_digits - 1)
      |> Enum.to_list()
      |> Enum.map(fn _x -> 0 end)
      |> Enum.reduce("", fn el, acc ->
        acc <> Integer.to_string(el)
      end)

    "1" <> zeroes
  end

  defp fetch_data(test) when test == false, do: File.read!("assets/2025/d02/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.read!("assets/2025/d02/test_input.txt")
end
