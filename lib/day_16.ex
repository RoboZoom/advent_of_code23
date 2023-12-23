defmodule Day16 do
  def a(test_data \\ true) when is_boolean(test_data) do
    get_test_data(test_data)
    |> parse_input()
  end

  def b(test_data \\ true) when is_boolean(test_data) do
  end

  @spec parse_input(
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | char(),
              binary() | []
            )
        ) :: list()
  def parse_input(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def build_grid(two_d_arr) do
    Enum.reduce(two_d_arr, {0, []}, fn row, {x_index, rows} ->
      Enum.reduce(row, {0, []}, fn el, {y_index, items} ->
        nil
      end)
    end)
  end

  def get_test_data(true), do: "assets/test.txt"
  def get_test_data(false), do: "assets/day_16_input.txt"
end
