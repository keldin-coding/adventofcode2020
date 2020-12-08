defmodule Instruction do
  defstruct [:action, :value, :visited]

  def parse(str) do
    [action, raw_dist] = String.split(str, " ")

    %Instruction{action: action, value: String.to_integer(raw_dist), visited: false}
  end
end

defmodule Solution do
  def run_part1(input) do
    instruction_set = input |> Enum.map(&Instruction.parse/1)

    find_accumulator_before_loop(
      instruction_set,
      Enum.at(instruction_set, 0),
      0,
      0
    )
  end

  def run_part2(input) do
    instruction_set = input |> Enum.map(&Instruction.parse/1)

    index_to_change = find_replacement_index(
      instruction_set,
      Enum.at(instruction_set, 0),
      nil,
      0
    )

    IO.puts("#{index_to_change}")
    inst = Enum.at(instruction_set, index_to_change)
    instruction_set = List.replace_at(instruction_set, index_to_change, %{inst | visited: true})

    find_accumulator_before_loop(instruction_set, Enum.at(instruction_set, 0), 0, 0)
  end

  # PART 1 HELPER
  defp find_accumulator_before_loop(instruction_set, _, current_index, current_acc) when length(instruction_set) == current_index, do: current_acc
  defp find_accumulator_before_loop(_, %Instruction{visited: true}, _, current_acc), do: current_acc

  defp find_accumulator_before_loop(instruction_set, %Instruction{action: "jmp", value: value} = i, current_index, current_acc) do
    new_index = current_index + value

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})
    find_accumulator_before_loop(instruction_set, Enum.at(instruction_set, new_index), new_index, current_acc)
  end

  defp find_accumulator_before_loop(instruction_set, %Instruction{action: "acc", value: value} = i, current_index, current_acc) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})
    find_accumulator_before_loop(instruction_set, Enum.at(instruction_set, new_index), new_index, current_acc + value)
  end

  defp find_accumulator_before_loop(instruction_set, %Instruction{action: "nop"} = i, current_index, current_acc) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})
    find_accumulator_before_loop(instruction_set, Enum.at(instruction_set, new_index), new_index, current_acc)
  end

  # PART 2 HELPER
  defp find_replacement_index(_, %Instruction{visited: true}, prev_index, _) do
    prev_index
  end

  defp find_replacement_index(instruction_set, %Instruction{action: "jmp", value: value} = i, _prev_index, current_index) do
    new_index = current_index + value

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})
    find_replacement_index(instruction_set, Enum.at(instruction_set, new_index), current_index, new_index)
  end

  defp find_replacement_index(instruction_set, %Instruction{action: "acc"} = i, _prev_index, current_index) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})
    find_replacement_index(instruction_set, Enum.at(instruction_set, new_index), current_index, new_index)
  end

  defp find_replacement_index(instruction_set, %Instruction{action: "nop"} = i, _prev_index, current_index) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})
    find_replacement_index(instruction_set, Enum.at(instruction_set, new_index), current_index, new_index)
  end

end
