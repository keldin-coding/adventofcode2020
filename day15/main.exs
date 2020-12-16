defmodule Solution do
  def run_part1([input], limit) do
    numbers_list = input |> String.split(",") |> Enum.map(&String.to_integer/1)

    number_to_turns =
      numbers_list
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {i, turn}, acc ->
        current = Map.get(acc, i, [])
        Map.put(acc, i, [turn + 1 | current])
      end)

    elf_speak(number_to_turns, map_size(number_to_turns) + 1, List.last(numbers_list), limit)
  end

  def run_part2(input, limit) do
    run_part1(input, limit)
  end

  defp elf_speak(_, current_turn, last_number, limit) when current_turn > limit, do: last_number
  # There's probably a better way to do this bit but this is Fine.
  defp elf_speak(numbers, current_turn, last_number, limit) do
    found_turns = Map.get(numbers, last_number, [])

    spoken =
      if length(found_turns) < 2 do
        0
      else
        [a, b | _rest] = found_turns
        a - b
      end

    # IO.puts("Turn #{current_turn} says: #{spoken}")

    # This is dumb, but I want a List that doesn't have `nil` in it and this is
    # just the easiest way I can think of.
    spoken_turns = Map.get(numbers, spoken, []) |> Enum.slice(0..0)
    new_numbers = Map.put(numbers, spoken, [current_turn | spoken_turns])

    elf_speak(new_numbers, current_turn + 1, spoken, limit)
  end
end
