defmodule Solution do
  def run_part1(input) do
    adapters = input |> Enum.map(&String.to_integer/1) |> Enum.sort()

    {ones, _, threes} = reduce_for_differences([0 | adapters], {0, 0, 1})

    ones * threes
  end

  # Definitely watched LizTheGrey do this one because I was confused.
  def run_part2(input) do
    # Turn this into a map for faster access because we're going to be doing a lot of random access
    adapters =
      input
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {x, index}, acc ->
        Map.put(acc, index, x)
      end)

    # Start with the base case of there is only one way of really reaching the
    # last item from the last item. The 1 to last works because we've
    # reversed the list above.
    ways =
      Enum.reduce(1..(map_size(adapters) - 1), %{0 => 1}, fn index, acc ->
        current_item = adapters[index]

        next_sum =
          Enum.reduce(1..3, 0, fn diff, sum ->
            index_to_check = index - diff
            # Ensure we're about to pull a sum path that exists first. This is
            # mainly useful when starting and after the first two iterations there
            # should always be a value.
            val_to_check = Map.get(adapters, index_to_check, nil)

            # If we're within 3 with the next value, add it in! Otherwise, keep what
            # we had.
            if val_to_check && val_to_check - current_item <= 3 do
              sum + acc[index_to_check]
            else
              sum
            end
          end)

        Map.put(acc, index, next_sum)
      end)

    # Similar to above, we need the routes from the first three possible
    # starting points. Given the problem constraints, that means we need the
    # sum of the number of paths if our first three adapters are any of 1, 2, 3
    (map_size(ways) - 3)..(map_size(ways) - 1)
    |> Enum.reduce(0, fn index, sum ->
      adapter_value = Map.get(adapters, index)

      if adapter_value <= 3 do
        sum + Map.get(ways, index)
      else
        sum
      end
    end)
  end

  # PART 1 HELPERS
  defp reduce_for_differences([_], acc), do: acc

  defp reduce_for_differences([first, second | rest], {ones, twos, threes}) do
    case second - first do
      3 ->
        reduce_for_differences([second | rest], {ones, twos, threes + 1})

      2 ->
        reduce_for_differences([second | rest], {ones, twos + 1, threes})

      1 ->
        reduce_for_differences([second | rest], {ones + 1, twos, threes})
    end
  end
end
