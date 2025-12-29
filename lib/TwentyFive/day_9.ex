defmodule TwentyFive.Day9 do
  def problem_one(test_data \\ false) do
    fetch_data(test_data)
    |> parse_data()
    |> get_pairs()
    |> Enum.map(fn {a, b} -> {a, b, get_area(a, b)} end)
    |> IO.inspect()
    |> Enum.max_by(fn {a, b, area} -> area end)
  end

  def problem_two(test_data \\ false) do
    all_coords =
      fetch_data(test_data)
      |> parse_data()

    env =
      all_coords
      |> create_paths(nil, [])
      |> optimize_path(nil, [])

    all_coords
    |> get_pairs()
  end

  def parse_data(input_stream) do
    input_stream
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s ->
      l =
        String.split(s, ",")
        |> Enum.map(fn n ->
          {i, _} = Integer.parse(n)
          i
        end)

      {Enum.at(l, 0), Enum.at(l, 1)}
    end)
  end

  def check_valid_pair({a, b} = pair, env) do
    {ax, ay} = a
    {bx, by} = b

    Enum.find()

    cond check_inside()
  end

  def check_inside(segment, coord) do
    {_, {tx, ty}} = segment
    {ax, ay} = coord

    cond segment.inside do
      :up -> ay >= ty
      :down -> ay <= ty
      :right -> ax >= tx
      :left -> ax <= tx
    end
  end

  def create_paths([coord | rest], nil, path), do: create_paths(rest, coord, path)

  def create_paths([], previous_coord, path) do
    {_, first_coord} = List.last(path)
    Enum.reverse([{previous_coord, first_coord} | path])
  end

  def create_paths([coord | rest] = _coords, previous_coord, path) do
    new_path = [{previous_coord, coord} | path]
    create_paths(rest, coord, new_path)
  end

  def optimize_path(segment_list, last_segment, path)

  def optimize_path([next_segment], last_segment, path) do
    dir = get_segment_direction(next_segment)

    obj_segment = %{
      direction: dir,
      segment_details: next_segment,
      left_inside: last_segment.left_inside,
      right_inside: last_segment.right_inside
    }

    t = get_turn(obj_segment, last_segment)

    new_obj =
      case t do
        :straight ->
          obj_segment

        k ->
          update_inside(obj_segment, k)
      end

    new_obj = Map.put(new_obj, :turn, t)
    p = Enum.reverse([new_obj | path])

    total_right =
      Enum.count(p, fn %{turn: t} ->
        t == :right
      end)

    total_left = length(p) - total_right

    cond do
      total_left > total_right ->
        Enum.map(p, fn s ->
          Map.take(s, [:direction, :segment_details])
          |> Map.put(:inside, s.left_inside)
        end)

      total_right > total_left ->
        Enum.map(p, fn s ->
          Map.take(s, [:direction, :segment_details])
          |> Map.put(:inside, s.right_inside)
        end)
    end
  end

  def optimize_path([segment | rest], nil, []) do
    dir = get_segment_direction(segment)

    {{a, b}, {c, d}} = segment

    {left_in, right_in} =
      case dir do
        :horizontal ->
          if a > c do
            {:down, :up}
          else
            {:up, :down}
          end

        :vertical ->
          if d > b do
            {:left, :right}
          else
            {:right, :left}
          end
      end

    obj_segment = %{
      direction: dir,
      segment_details: segment,
      left_inside: left_in,
      right_inside: right_in
    }

    optimize_path(rest, obj_segment, [obj_segment])
  end

  def optimize_path([next_segment | rest], last_segment, path) do
    dir = get_segment_direction(next_segment)

    obj_segment = %{
      direction: dir,
      segment_details: next_segment,
      left_inside: last_segment.left_inside,
      right_inside: last_segment.right_inside
    }

    t = get_turn(obj_segment, last_segment)

    new_obj =
      case t do
        :straight ->
          obj_segment

        k ->
          update_inside(obj_segment, k)
      end

    new_obj = Map.put(new_obj, :turn, t)

    optimize_path(rest, new_obj, [new_obj | path])
  end

  def update_inside(%{direction: :horizontal} = segment, turn_direction) do
    case turn_direction do
      :right ->
        segment
        |> Map.update(:left_inside, nil, fn x ->
          case x do
            :left -> :up
            :right -> :down
          end
        end)
        |> Map.update(:right_inside, nil, fn y ->
          case y do
            :left -> :up
            :right -> :down
          end
        end)

      :left ->
        segment
        |> Map.update(:left_inside, nil, fn x ->
          case x do
            :left -> :down
            :right -> :up
          end
        end)
        |> Map.update(:right_inside, nil, fn y ->
          case y do
            :left -> :down
            :right -> :up
          end
        end)
    end
  end

  def update_inside(%{direction: :vertical} = segment, turn_direction) do
    case turn_direction do
      :right ->
        segment
        |> Map.update(:left_inside, nil, fn x ->
          case x do
            :up -> :left
            :down -> :right
          end
        end)
        |> Map.update(:right_inside, nil, fn y ->
          case y do
            :up -> :left
            :down -> :right
          end
        end)

      :left ->
        segment
        |> Map.update(:left_inside, nil, fn x ->
          case x do
            :up -> :right
            :down -> :left
          end
        end)
        |> Map.update(:right_inside, nil, fn y ->
          case y do
            :up -> :right
            :down -> :left
          end
        end)
    end
  end

  def get_turn(next_seg, last_seg) do
    {last_start, _} = last_seg.segment_details
    {_, next_end} = next_seg.segment_details

    cond do
      next_seg.direction == last_seg.direction ->
        :straight

      next_seg.direction == :horizontal ->
        {a, b} = next_end
        {c, d} = last_start

        if (a > c and b > d) or (a < c and b < d) do
          :right
        else
          :left
        end

      next_seg.direction == :vertical ->
        {a, b} = next_end
        {c, d} = last_start

        if (a > c and b < d) or (a < c and b > d) do
          :right
        else
          :left
        end
    end
  end

  def get_segment_direction({a, b}) do
    {ax, ay} = a
    {bx, by} = b

    cond do
      ax == bx -> :horizontal
      ay == by -> :vertical
      true -> :diagonal
    end
  end

  def segment_intersect({a, b, dir} = segment_a, {c, d, _} = segment_b) do
    # Assumes Dir_A != Dir_B

    case dir do
      :horizontal ->
        {a_x, a_y} = a
        {b_x, _} = b

        {test_x, c_y} = c
        {_, d_y} = d
        h = test_overlap(a_x, b_x, test_x)
        v = test_overlap(c_y, d_y, a_y)

        not (h and v)

      :vertical ->
        {a_x, a_y} = a
        {_, b_y} = b

        {c_x, c_y} = c
        {d_x, _} = d
        h = test_overlap(c_x, d_x, a_x)
        v = test_overlap(a_y, b_y, c_y)

        not (h and v)

      _ ->
        raise("Error: Segment Intersect Failed")
    end
  end

  def test_overlap(start, stop, test_var) do
    (test_var >= start and test_var >= stop) or (test_var <= start and test_var <= stop)
  end

  def get_pairs([_item]), do: []

  def get_pairs([h | rest]) do
    h_coords = Enum.map(rest, fn a -> {h, a} end)
    h_coords ++ get_pairs(rest)
  end

  def get_area({x1, y1}, {x2, y2}) do
    l = abs(y2 - y1) + 1
    h = abs(x2 - x1) + 1

    l * h
  end

  def fetch_data(test) when test == false, do: File.read!("assets/2025/d09/compute_input.txt")
  def fetch_data(test) when test == true, do: File.read!("assets/2025/d09/test_input.txt")
end
