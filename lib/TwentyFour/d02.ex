defmodule TwentyFour.D02 do
  def d_a() do
    # Test answer: 2
    #
    fetch_data(false)
    |> parse_input()
    |> IO.inspect(label: "Source Data")
    |> Enum.map(&check_safe(&1))
    |> Enum.filter(&check_for_safety(&1))
    |> Enum.count()
  end

  def d_b() do
    fetch_data(false)
  end

  defp fetch_data(test) when test == false, do: File.stream!("assets/2024/d02/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.stream!("assets/2024/d02/test_input.txt")

  defp parse_input(input) do
    input
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
  end

  defp check_sign({safety, previous, sign} = acc, new_sign) do
    # {sign, new_sign} |> IO.inspect(label: "Check Sign")

    cond do
      sign == :unknown ->
        {safety, previous, new_sign}

      sign == :equal or sign !== new_sign ->
        # IO.puts("Sign Check Failed")
        {:unsafe, previous, sign}

      sign == new_sign ->
        acc
    end
  end

  defp check_gradient({_safety, previous, sign} = acc, diff) do
    d = abs(diff)

    cond do
      d >= 1 and d <= 3 ->
        acc

      d <= 0 or d > 3 ->
        # IO.puts("Gradient Check Failed")
        {:unsafe, previous, sign}
    end
  end

  defp replace_previous({a, _, b}, new_prev), do: {a, new_prev, b}

  defp check_for_safety({:safe, _, _}), do: true
  defp check_for_safety({:unsafe, _, _}), do: false

  defp check_safe(line) do
    Enum.reduce(line, {:safe, :nan, :unknown}, fn num, acc ->
      {safety, previous, sign} = acc

      case acc do
        {:unsafe, _, _} ->
          {:unsafe, previous, sign}

        {_, :nan, _} ->
          {safety, num, sign}

        _ ->
          diff = num - previous

          new_sign =
            cond do
              diff > 0 ->
                :positive

              diff < 0 ->
                :negative

              diff == 0 ->
                :equal
            end

          acc
          |> check_sign(new_sign)
          |> check_gradient(diff)
          |> replace_previous(num)
      end
    end)
  end
end
