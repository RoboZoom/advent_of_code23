defmodule Day15 do
  def a(test_data \\ true) when is_boolean(test_data) do
    get_test_data(test_data)
    |> parse_input()
    |> strings_to_nums()
    |> Enum.map(&check_val/1)
    |> Enum.sum()
  end

  def b(test_data \\ true) when is_boolean(test_data) do
    directions =
      get_test_data(test_data)
      |> parse_input()
      |> Enum.map(&separate_labels/1)
      |> IO.inspect(label: "Labels")

    init_box = init_boxes()

    lens_map =
      Enum.reduce(directions, init_box, fn item, boxes ->
        hash = item.label |> get_hash()

        IO.inspect(item, label: "Item")

        case item.op do
          :remove ->
            Map.update!(boxes, hash, fn a ->
              ind = Enum.find_index(a, &(&1.label == item.label))

              if(ind) do
                List.delete_at(a, ind)
              else
                a
              end
            end)

          :add ->
            Map.update!(boxes, hash, fn a ->
              ind = Enum.find_index(a, &(&1.label == item.label))

              if(ind) do
                List.replace_at(a, ind, item)
              else
                List.insert_at(a, -1, item)
              end
            end)
        end
      end)

    
    lens_map
    |> Enum.filter(&(elem(&1, 1) != []))
    |> IO.inspect(label: "Lens Map")
    |> Enum.into([], fn {key, val} ->
      new_key = (key + 1) |> IO.inspect(label: "Key")

      Enum.reduce(val, {1, 0}, fn el, {slot, prod} = acc ->
        IO.inspect(acc, label: "Reduction args")
        {slot + 1, prod + new_key * slot * el.val} |> IO.inspect(label: "Iteration")
      end)
      |> elem(1)
    end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def get_test_data(true), do: "assets/test.txt"
  def get_test_data(false), do: "assets/day_15_input.txt"

  def get_hash(data) do
    data
    |> String.to_charlist()
    |> check_val()
  end

  def separate_labels(str) do
    case String.match?(str, ~r"=") do
      false ->
        label = List.first(String.split(str, ~r"-")) |> String.trim()

        %{op: :remove, label: label, val: nil}

      true ->
        strs = String.split(str, ~r"=")
        label = List.first(strs) |> String.trim()
        val = List.last(strs) |> String.trim() |> Integer.parse() |> elem(0)

        %{
          op: :add,
          label: label,
          val: val
        }
    end
  end

  def parse_input(file) do
    File.read!(file)
    |> String.trim()
    |> String.split(~r",")
    |> Enum.map(&String.trim/1)
  end

  def strings_to_nums(str_list) do
    Enum.map(str_list, fn x -> String.to_charlist(x) end)
  end

  def check_val(char_list) do
    result = Enum.reduce(char_list, 0, &calc_hash/2)
    IO.puts("#{char_list} | #{result}")
    result
  end

  def calc_hash(el, previous) do
    x = (previous + el) * 17
    rem(x, 256)
  end

  def init_boxes() do
    0..255
    |> Enum.to_list()
    |> Map.new(&{&1, []})
  end
end
