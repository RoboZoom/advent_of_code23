defmodule TwentyFive.Day5 do
  def problem_one(test_data \\ false) do
    [fresh_list, require_list] =
      fetch_data(test_data)
      |> parse_data()

    f = condition_fresh_list(fresh_list)
    r = condition_requirements_list(require_list)

    Enum.reduce(r, [], fn el, acc ->
      found =
        Enum.any?(f, fn fresh_range ->
          el in fresh_range
        end)

      if found == true do
        [el | acc]
      else
        acc
      end
    end)
    |> Enum.count()
  end

  def problem_two(test_data \\ false) do
    # Note: Need to optimize.
    [fresh_list, _require_list] =
      fetch_data(test_data)
      |> parse_data()

    f =
      fresh_list
      |> condition_fresh_list()

    process_list([], f)
    |> Enum.map(&Range.size(&1))
    |> Enum.sum()
  end

  def process_list(good_list, []), do: good_list

  def process_list(good_list, [h | rest]) do
    {g, checked} = fix_disjoint(h, [], rest)
    process_list(g ++ good_list, checked)
  end

  def fix_disjoint(active_range, checked_list, []), do: {[active_range], checked_list}

  def fix_disjoint(active_range, checked_list, [h | tail] = _list_to_go) do
    if Range.disjoint?(active_range, h) do
      fix_disjoint(active_range, [h | checked_list], tail)
    else
      a_start..a_end//_ = active_range
      h_start..h_end//_ = h

      new_checked_list = [h | checked_list]

      cond do
        # A: --**********--
        # H: -************-
        a_start >= h_start and a_end <= h_end ->
          {[], new_checked_list ++ tail}

        a_start <= h_start and a_end >= h_end ->
          fix_disjoint(active_range, checked_list, tail)

        # A: -----*******--
        # H: -******-------
        a_start >= h_start ->
          n_start = h_end + 1
          fix_disjoint(n_start..a_end, new_checked_list, tail)

        # A: -******-------
        # H: -----*******--
        a_end <= h_end ->
          n_end = h_start - 1
          fix_disjoint(a_start..n_end, new_checked_list, tail)

        true ->
          IO.puts("Error Fall through: #{a_start} .. #{a_end} | #{h_start}.. #{h_end} ")
      end
    end
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n"))
  end

  def condition_requirements_list(l) do
    l
    |> Enum.map(fn el ->
      {i, _} = Integer.parse(el)
      i
    end)
  end

  def condition_fresh_list(l) do
    l
    |> Enum.map(fn item ->
      temp = String.split(item, "-")
      {List.first(temp), List.last(temp)}
    end)
    |> Enum.map(fn {start, enn} ->
      {s, _} = Integer.parse(start)
      {e, _} = Integer.parse(enn)
      Range.new(s, e)
    end)
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d05/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d05/test_input.txt")
end
