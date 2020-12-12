defmodule Solution do
  def run_part1(input, preamble_length) do
    input |> Enum.map(&String.to_integer/1) |> find_first_invalid(preamble_length)
  end

  def run_part2(input, preamble_length) do
    numbers = input |> Enum.map(&String.to_integer/1)
    invalid_sum = numbers |> find_first_invalid(preamble_length)

    found_set = find_contiguous_set(numbers, invalid_sum)

    {smallest, largest} = Enum.min_max(found_set)
    smallest + largest
  end

  defp find_contiguous_set([_], _), do: []

  defp find_contiguous_set(list, required_sum) do
    {sum_left, the_set} =
      Enum.reduce_while(list, {required_sum, []}, fn x, {sum, items} ->
        new_sum = sum - x
        will_continue = if new_sum <= 0, do: :halt, else: :cont

        {will_continue, {new_sum, [x | items]}}
      end)

    if sum_left == 0 do
      the_set
    else
      find_contiguous_set(Enum.slice(list, 1..-1), required_sum)
    end
  end

  # HELPERS

  defp is_valid_sum?(preamble, num) do
    sorted_and_useful = Enum.filter(preamble, fn x -> x < num end) |> Enum.sort()

    if length(sorted_and_useful) < 2 do
      false
    else
      found_sum =
        Enum.slice(sorted_and_useful, 0..-2)
        |> Enum.with_index()
        |> Enum.any?(fn {outer, outer_index} ->
          slice = Enum.slice(sorted_and_useful, (outer_index + 1)..-1)
          slice |> Enum.any?(fn inner -> outer + inner == num end)
        end)

      found_sum
    end
  end

  # PART 1 HELPERS

  # Sort of a janky escape hatch but it works. This could be
  defp find_first_invalid(list, preamble_length) when length(list) <= preamble_length, do: nil

  defp find_first_invalid([first | rest], preamble_length) do
    next_nums = Enum.take(rest, preamble_length)

    {remaining_preamble, [number_under_eval]} = Enum.split(next_nums, preamble_length - 1)

    preamble = [first | remaining_preamble]

    if is_valid_sum?(preamble, number_under_eval) do
      find_first_invalid(rest, preamble_length)
    else
      number_under_eval
    end
  end
end
