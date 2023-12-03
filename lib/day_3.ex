defmodule Day3 do
  def d3_a() do
    # file = File.read!("assets/day_three_input.txt")
    file =
      File.read!("assets/day_three_input.txt") |> String.split("\n") |> Enum.map(&String.trim(&1))

    symbol_coords = get_symbol_coords(file)
    number_info = get_number_info(file) |> List.flatten() |> IO.inspect(label: "Number Info")

    Enum.reduce(number_info, 0, fn num, sum ->
      if is_adjacent(num, symbol_coords) do
        sum + num.number
      else
        sum
      end
    end)
  end

  def d3_b() do
    # file = File.read!("assets/day_three_input.txt")
    file =
      File.read!("assets/day_three_input.txt") |> String.split("\n") |> Enum.map(&String.trim(&1))

    symbol_coords = get_asteriks_coords(file) |> IO.inspect(label: "Asteriks Coords")
    number_info = get_number_info(file) |> List.flatten()

    Enum.map(symbol_coords, &adjacent_twice_val(&1, number_info))
    |> Enum.sum()
  end

  defp get_symbol_coords(grid) do
    Enum.reduce(grid, {0, []}, fn line, {row, vals} = acc ->
      l =
        Regex.scan(~r"(?!(\.|\d)+).", line, return: :index)
        |> List.flatten()
        |> IO.inspect()
        |> Enum.map(&elem(&1, 0))
        |> IO.inspect()
        |> Enum.map(fn index ->
          {row, index}
        end)
        |> List.flatten()
        |> Enum.concat(vals)
        |> IO.inspect(label: "Vals after row #{row}")

      {row + 1, l}
    end)
    |> elem(1)
  end

  defp get_asteriks_coords(grid) do
    Enum.reduce(grid, {0, []}, fn line, {row, vals} = acc ->
      l =
        Regex.scan(~r"\*", line, return: :index)
        |> List.flatten()
        |> Enum.map(&elem(&1, 0))
        |> Enum.map(fn index ->
          {row, index}
        end)
        |> List.flatten()
        |> Enum.concat(vals)
        |> IO.inspect(label: "Vals after row #{row}")

      {row + 1, l}
    end)
    |> elem(1)
  end

  defp get_number_info(grid) do
    Enum.reduce(grid, {0, []}, fn line, {row, vals} ->
      num_capture = ~r"\d+"
      nums = Regex.scan(num_capture, line) |> List.flatten()

      indices =
        Regex.scan(num_capture, line, return: :index)
        |> List.flatten()
        # |> IO.inspect(label: "Number Info")
        |> Enum.map(&elem(&1, 0))

      z_map =
        Enum.zip_with(nums, indices, fn num, index ->
          l = String.length(num)

          %{
            coord: {row, index},
            length: l,
            number: Integer.parse(num) |> elem(0)
          }
        end)

      {row + 1, [z_map | vals]}
    end)
    |> elem(1)
  end

  defp check_zero(x) do
    case x < 0 do
      true -> 0
      false -> x
    end
  end

  defp is_adjacent(%{coord: coord, length: l} = num_item, symbols) do
    y = elem(coord, 0)
    min_y = (y - 1) |> check_zero()
    max_y = y + 1

    x = elem(coord, 1)
    min_x = (x - 1) |> check_zero()
    max_x = x + l

    Enum.any?(symbols, fn {row, index} ->
      row_check = row >= min_y and row <= max_y
      col_check = index >= min_x and index <= max_x

      row_check and col_check
    end)
  end

  defp adjacent_twice_val({row, index} = symbol, num_items) do
    {adj, prod} =
      Enum.reduce(num_items, {0, 1}, fn %{coord: coord, length: l, number: n} = _number,
                                        {count, product} = totals ->
        if count > 2 do
          totals
        else
          y = elem(coord, 0)
          min_y = (y - 1) |> check_zero()
          max_y = y + 1

          x = elem(coord, 1)
          min_x = (x - 1) |> check_zero()
          max_x = x + l

          row_check = row >= min_y and row <= max_y
          col_check = index >= min_x and index <= max_x

          case row_check and col_check do
            true -> {count + 1, product * n}
            false -> totals
          end
        end
      end)

    case adj == 2 do
      true -> prod
      false -> 0
    end
  end
end
