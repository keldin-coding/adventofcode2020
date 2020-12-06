defmodule Solution do
  def run_part1(input) do
    input
    |> Enum.map(fn x -> count_group(x) end)
    # The -1 is for the :length key. Making a full fledged struct
    # would eliminate this but...i'm not doing that.
    |> Enum.reduce(0, fn group, acc -> acc + length(Map.keys(group)) - 1 end)
  end

  def run_part2(input) do
    input
    |> Enum.map(fn x -> count_group(x) end)
    |> Enum.reduce(0, fn group, acc -> acc + count_matches_length(group) end)
  end

  defp count_group(group_data) do
    lines = group_data |> String.split("\n")
    number_of_passengers = length(lines)

    lines
    |> Enum.map(&String.graphemes/1)
    |> List.flatten()
    |> Enum.reduce(%{length: number_of_passengers}, fn response, acc ->
      val = Map.get(acc, response, 0)

      Map.put(acc, response, val + 1)
    end)
  end

  defp count_matches_length(%{length: num} = group) do
    group
    |> Map.delete(:length)
    |> Enum.count(fn {_, v} -> v == num end)
  end
end
