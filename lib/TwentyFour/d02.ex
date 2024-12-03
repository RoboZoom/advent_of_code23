defmodule TwentyFour.D02 do
  def d_a() do
    # Test answer: 2
    #
    fetch_data(false)
    |> parse_input()
    |> Enum.map(&check_safe(&1))
    |> Enum.filter(&check_for_safety(&1))
    |> Enum.count()
  end

  def d_b() do
    fetch_data(true)
    |> parse_input()
    |> Enum.map(&check_safe_b(&1))
    |> Enum.filter(&check_for_safety(&1))
    |> Enum.count()
  end

  defp fetch_data(test) when test == false, do: File.stream!("assets/2024/d02/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.stream!("assets/2024/d02/test_input.txt")

  defp parse_input(input) do
    input
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
  end

  defp check_sign({safety, previous, sign, flag} = acc, new_sign) do
    # {sign, new_sign} |> IO.inspect(label: "Check Sign")

    cond do
      sign == :unknown ->
        {safety, previous, new_sign, flag}

      sign == :equal or sign !== new_sign ->
        IO.puts("Sign Check Failed")
        {safety, previous, sign, 1}

      sign == new_sign ->
        acc
    end
  end

  defp check_gradient({safety, previous, sign, _flag} = acc, diff) do
    d = abs(diff)

    cond do
      d >= 1 and d <= 3 ->
        acc

      d <= 0 or d > 3 ->
        IO.puts("Gradient Check Failed - #{d}")
        {safety, previous, sign, 1}
    end
  end

  defp replace_previous({_, _, _, 1} = acc, _new_prev), do: acc
  defp replace_previous({a, _, b, _}, new_prev), do: {a, new_prev, b, 0}

  defp check_for_safety({:unsafe, _, _, _}), do: false
  defp check_for_safety(_any), do: true

  defp check_safe(line) do
    Enum.reduce(line, {:safe, :nan, :unknown, 0}, fn num, acc ->
      {safety, previous, sign, flag} = acc

      case acc do
        {:unsafe, _, _, _} ->
          {:unsafe, previous, sign, flag}

        {_, :nan, _, _} ->
          {safety, num, sign, flag}

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
          |> resolve_unsafe_flag_a()
          |> replace_previous(num)
      end
    end)
  end

  defp resolve_unsafe_flag_a({_, _, _, 0} = acc), do: acc
  defp resolve_unsafe_flag_a({:unsafe, _, _, _} = acc), do: acc
  defp resolve_unsafe_flag_a({:safe, a, b, 1}), do: {:unsafe, a, b, 0}

  defp resolve_unsafe_flag_b({_, _, _, 0} = acc), do: acc
  defp resolve_unsafe_flag_b({:unsafe, _, _, _} = acc), do: acc
  defp resolve_unsafe_flag_b({:safe, a, b, 1}), do: {:strike, a, b, 0}
  defp resolve_unsafe_flag_b({:strike, a, b, 1}), do: {:unsafe, a, b, 0}

  defp check_safe_b(line) do
    first =
      Enum.reduce(line, {:safe, :nan, :unknown, 0}, fn num, acc ->
        {safety, previous, sign, unsafe_flag} = acc

        case acc do
          {:unsafe, _, _, _} ->
            {:unsafe, previous, sign, unsafe_flag}

          {_, :nan, _, _} ->
            {safety, num, sign, unsafe_flag}

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
            |> resolve_unsafe_flag_b()
        end
      end)

    case first do
      {:unsafe, _, _, _} ->
        [_h | new_line] = line

        IO.inspect(line, label: "Failed Line")
        IO.inspect(new_line, label: "Modified Line")

        Enum.reduce(new_line, {:strike, :nan, :unknown, 0}, fn num, acc ->
          {safety, previous, sign, unsafe_flag} = acc

          case acc do
            {:unsafe, _, _, _} ->
              {:unsafe, previous, sign, unsafe_flag}

            {_, :nan, _, _} ->
              {safety, num, sign, unsafe_flag}

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
              |> resolve_unsafe_flag_b()
          end
        end)

      a ->
        a
    end
  end
end
