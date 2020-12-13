defmodule Solution do
  def run_part1([current_time, bus_list]) do
    current_time = String.to_integer(current_time)

    {id, diff} =
      bus_list
      |> String.split(",")
      |> Enum.filter(fn i -> i != "x" end)
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce(%{}, fn bus_id, acc ->
        {remainder, divided} = {rem(current_time, bus_id), div(current_time, bus_id)}

        if remainder == 0 do
          Map.put(acc, bus_id, 0)
        else
          Map.put(acc, bus_id, bus_id * (divided + 1) - current_time)
        end
      end)
      |> Enum.min_by(fn {_id, diff} -> diff end)

    id * diff
  end

  def run_part2([_, bus_list]) do
    minute_offset_with_id =
      bus_list
      |> String.split(",")
      |> Enum.map(fn id ->
        if id == "x", do: nil, else: String.to_integer(id)
      end)
      |> Enum.with_index()
      |> Enum.filter(fn {i, _} -> !is_nil(i) end)
      |> Enum.reduce(%{}, fn {i, index}, acc -> Map.put(acc, index, i) end)

    {start, _} = find_valid_starttime(minute_offset_with_id)
    start
  end

  # I'll be very honest, I don't yet understand these mathematics shenanigans
  # and so sought help from LizTheGrey's twitch, doubly so because I wasn't even
  # sure what to search for.
  defp find_valid_starttime(bus_by_index) do
    Enum.reduce(bus_by_index, {0, 1}, fn {offset, id}, {sum, product} ->
      new_sum = add_product_and_sum(sum, product, id, offset)
      new_product = product * id

      {new_sum, new_product}
    end)
  end

  defp add_product_and_sum(sum, product, id, offset) when rem(sum + offset, id) != 0,
    do: add_product_and_sum(sum + product, product, id, offset)

  defp add_product_and_sum(sum, _, _, _), do: sum
end
