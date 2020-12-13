defmodule Solution do
  def run_part1(input) do
    adapters = input |> Enum.map(&String.to_integer/1) |> Enum.sort()

    {ones, threes} = reduce_for_differences([0 | adapters], {0, 1})

    ones * threes
  end

  def run_part2(_input) do
    "N/A"
  end

  defp reduce_for_differences([_], acc), do: acc

  defp reduce_for_differences([first, second | rest], {ones, threes}) do
    case second - first do
      3 ->
        reduce_for_differences([second | rest], {ones, threes + 1})

      2 ->
        reduce_for_differences([second | rest], {ones, threes})

      1 ->
        reduce_for_differences([second | rest], {ones + 1, threes})
    end
  end
end
