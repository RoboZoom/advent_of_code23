defmodule TwentyFour.D03 do
  def d_a() do
    fetch_data(true)
  end

  def d_b() do
    fetch_data(false)
  end

  defp fetch_data(test) when test == false, do: File.stream!("assets/2024/d03/compute_input.txt")
  defp fetch_data(test) when test == true, do: File.stream!("assets/2024/d03/test_input.txt")
end
