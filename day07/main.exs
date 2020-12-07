defmodule Bag do
  defstruct [:bag_type, :contained_bags]

  @bag_pattern ~r/(?<number>\d+) (?<adj>\w+) (?<color>\w+)/
  @full_regex ~r/(?<adj>\w+) (?<color>\w+) bags contain (?<contained>.*)\./

  def from_line(line) do
    [[adj, color, contained]] = Regex.scan(@full_regex, line, capture: :all_but_first)

    %Bag{bag_type: "#{adj} #{color}", contained_bags: parse_contained(contained)}
  end

  defp parse_contained("no other bags"), do: %{}

  defp parse_contained(contained) do
    Regex.scan(@bag_pattern, contained, capture: :all_but_first)
    |> Enum.reduce(%{}, fn [num, adj, color], acc ->
      Map.put(acc, "#{adj} #{color}", String.to_integer(num))
    end)
  end
end

defmodule BagNode do
  defstruct [:bag, :visited]
end

defmodule Solution do
  @null_bag %Bag{bag_type: nil, contained_bags: %{}}

  # How many colors, at some point, have a shiny gold bag
  def run_part1(input, desired_type) do
    bag_map =
      Enum.reduce(input, %{}, fn line, acc ->
        bag = Bag.from_line(line)
        Map.put(acc, bag.bag_type, bag)
      end)

    Map.keys(bag_map)
    |> Enum.count(fn key ->
      result = contains_type?(bag_map[key], bag_map, desired_type, 0)

      # if result, do: IO.puts(key)

      result
    end)
  end

  def run_part2(input, root_type) do
    bag_map =
      Enum.reduce(input, %{}, fn line, acc ->
        bag = Bag.from_line(line)
        Map.put(acc, bag.bag_type, bag)
      end)

    count_contained(bag_map[root_type], bag_map)
  end

  ### PART 2 HELPER FUNCTION
  defp count_contained(current_bag, bag_map) do
    Enum.reduce(
      current_bag.contained_bags,
      # We start with "this bag contains X bags"
      Enum.sum(Map.values(current_bag.contained_bags)),
      fn {bag_type, number}, acc ->
        sub_bag = Map.get(bag_map, bag_type, @null_bag)

        acc + number * count_contained(sub_bag, bag_map)
      end
    )
  end

  ### PART 1 HELPER FUNCTIONS

  defp contains_type?(%Bag{contained_bags: _, bag_type: bag_type}, _, type, depth)
       when depth > 0 and bag_type == type,
       do: true

  defp contains_type?(%Bag{contained_bags: children} = _bag, bag_map, type, depth) do
    Enum.any?(children, fn {child_type, _} ->
      contains_type?(
        Map.get(bag_map, child_type, @null_bag),
        bag_map,
        type,
        depth + 1
      )
    end)
  end
end
