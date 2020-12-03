defmodule SnowMap do
  defstruct [:rows, :height, :width]

  @tree "#"

  def parse(input) do
    %SnowMap{
      rows: Enum.map(input, &String.graphemes/1),
      height: length(input),
      width: Enum.at(input, 0) |> String.length()
    }
  end

  def traverse_count_trees(%SnowMap{} = map, right, down) do
    do_count_trees(map, right, down, 0, 0, 0)
  end

  defp do_count_trees(%SnowMap{height: map_height}, _, _, _, down_pos, trees)
       when down_pos >= map_height - 1,
       do: trees

  defp do_count_trees(%SnowMap{} = map, right, down, right_pos, down_pos, trees) do
    new_column = rem(right_pos + right, map.width)
    new_row = down_pos + down

    spot = map.rows |> Enum.at(new_row) |> Enum.at(new_column)

    if spot == @tree do
      do_count_trees(map, right, down, new_column, new_row, trees + 1)
    else
      do_count_trees(map, right, down, new_column, new_row, trees)
    end
  end
end

defmodule Solution do
  def run_part1(input) do
    input
    |> SnowMap.parse()
    |> SnowMap.traverse_count_trees(3, 1)
  end

  def run_part2(input) do
    slopes = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

    map = SnowMap.parse(input)

    Enum.reduce(slopes, 1, fn {right, down}, acc ->
      acc * SnowMap.traverse_count_trees(map, right, down)
    end)
  end
end
