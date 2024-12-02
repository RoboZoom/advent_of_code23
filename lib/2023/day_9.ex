defmodule Day9 do
  def a() do
    parse_input("assets/test_2.txt")
    |> IO.inspect()
    |> predict_series()
  end

  def parse_input(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(fn a ->
      String.split(a)
      |> Enum.map(fn b ->
        Integer.parse(b)
        |> elem(0)
      end)
    end)
  end

  def predict_series(num_list) do
    Enum.map(num_list, fn x ->
      build_row(x)
      |> IO.inspect()
    end)
  end

  def build_pyramid(num_list) do
    active_list = List.last(num_list) |> IO.inspect()

    {_, diff_list} =
      Enum.reduce(active_list, {0, []}, fn el, {prev, result} ->
        diff = (el - prev) |> IO.inspect(label: "Diff")
        {el, result <> diff}
      end)

    [_ | _new_list] = diff_list
    num_list <> diff_list
  end

  def build_row(num_list) do
    IO.inspect(num_list, label: "List Row Input")

    new_row = make_row(num_list)

    if Enum.all?(new_row, &(&1 == 0)) do
      new_row
    else
      [new_row | build_row(new_row)]
    end
  end

  def make_row(num_list) do
    Enum.reduce(num_list, {0, []}, fn el, {prev, result} ->
      diff = (el - prev) |> IO.inspect(label: "Diff")
      {el, [diff | result]} |> IO.inspect(label: "Reduction Step")
    end)
    |> elem(1)
    |> Enum.reverse()
    |> List.delete_at(0)
    |> IO.inspect()
  end
end
