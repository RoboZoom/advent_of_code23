defmodule Day8 do
  def a() do
    parse_input("assets/day_eight_input.txt")
    |> navigate({"AAA", 0})
  end

  def b() do
    parse_input("assets/day_eight_input.txt")
    |> do_b()
  end

  def parse_input(file) do
    f = File.read!(file)

    [h | data] =
      String.split(f, "\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 !== ""))

    %{
      directions: h,
      path: Enum.map(data, &parse_fork/1)
    }
  end

  def parse_fork(fork) do
    [start, left, right] = Regex.scan(~r"\w\w\w", fork) |> List.flatten()

    %{
      start: start,
      left: left,
      right: right
    }
  end

  def get_direction(index, directions) when is_binary(directions) do
    l = String.length(directions)
    i = rem(index, l)
    String.at(directions, i)
  end

  def get_fork(start, path) do
    Enum.find(path, &(&1.start == start))
  end

  def navigate(%{directions: d, path: p} = a, {start, index}) do
    IO.puts("Navigate - #{index}")
    f = get_fork(start, p)
    d = get_direction(index, d)

    nxt =
      case d do
        "L" -> f.left
        "R" -> f.right
      end

    if nxt == "ZZZ" do
      {:ok, index}
    else
      navigate(a, {nxt, index + 1})
    end
  end

  def navigate_end(%{directions: d, path: p} = a, {start, index}) do
    f = get_fork(start, p)
    d = get_direction(index, d)

    nxt =
      case d do
        "L" -> f.left
        "R" -> f.right
      end

    if check_last(nxt, "Z") do
      {:ok, index}
    else
      navigate_end(a, {nxt, index + 1})
    end
  end

  def do_b(%{directions: _d, path: p} = s) do
    start = get_all_x(p, "A") |> IO.inspect(label: "A Starters")
    multi_nav_two(s, {start, 0})
  end

  def multi_nav(%{directions: d, path: p} = a, {start, index}) when is_list(start) do
    f = Enum.map(start, &get_fork(&1, p))
    d = get_direction(index, d)

    nxt =
      case d do
        "L" -> Enum.map(f, & &1.left)
        "R" -> Enum.map(f, & &1.right)
      end

    if Enum.all?(nxt, &check_last(&1, "Z")) do
      {:ok, index}
    else
      multi_nav(a, {nxt, index + 1})
    end
  end

  def multi_nav_two(%{directions: d, path: p} = _a, {start, _index}) do
    Enum.map(start, fn a ->
      {:ok, val} = navigate_end(%{directions: d, path: p}, {a, 0})
      val
    end)
    |> IO.inspect()
    |> lcm()
  end

  def get_all_x(path, key) do
    path
    |> Enum.map(& &1.start)
    |> Enum.filter(&check_last(&1, key))
  end

  def check_last(item, key) do
    String.at(item, 2) == key
  end

  def large_gcd([h | t] = _arr) do
    case t do
      [] -> h |> IO.inspect()
      _ -> Integer.gcd(h, large_gcd(t))
    end
  end

  def lcm(list) do
    num = Enum.product(list)
    den = large_gcd(list)
    num / den
  end
end
