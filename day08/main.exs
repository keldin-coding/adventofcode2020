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

    # Don't mind me, just going to async brute force it.
    tasks =
      Enum.with_index(instruction_set)
      |> Enum.map(fn {%Instruction{action: action} = inst, index} ->
        case action do
          "jmp" ->
            new_set = List.replace_at(instruction_set, index, %{inst | action: "nop"})
            Task.async(fn -> find_accumulator_before_end(new_set, Enum.at(new_set, 0), 0, 0) end)

          "nop" ->
            new_set = List.replace_at(instruction_set, index, %{inst | action: "jmp"})
            Task.async(fn -> find_accumulator_before_end(new_set, Enum.at(new_set, 0), 0, 0) end)

          "acc" ->
            Task.async(fn -> nil end)
        end
      end)

    Enum.map(tasks, &Task.await/1) |> Enum.find(fn x -> !is_nil(x) end)
  end

  # PART 1 HELPER
  defp find_accumulator_before_loop(instruction_set, _, current_index, current_acc)
       when length(instruction_set) == current_index,
       do: current_acc

  defp find_accumulator_before_loop(_, %Instruction{visited: true}, _, current_acc),
    do: current_acc

  defp find_accumulator_before_loop(
         instruction_set,
         %Instruction{action: "jmp", value: value} = i,
         current_index,
         current_acc
       ) do
    new_index = current_index + value

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})

    find_accumulator_before_loop(
      instruction_set,
      Enum.at(instruction_set, new_index),
      new_index,
      current_acc
    )
  end

  defp find_accumulator_before_loop(
         instruction_set,
         %Instruction{action: "acc", value: value} = i,
         current_index,
         current_acc
       ) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})

    find_accumulator_before_loop(
      instruction_set,
      Enum.at(instruction_set, new_index),
      new_index,
      current_acc + value
    )
  end

  defp find_accumulator_before_loop(
         instruction_set,
         %Instruction{action: "nop"} = i,
         current_index,
         current_acc
       ) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})

    find_accumulator_before_loop(
      instruction_set,
      Enum.at(instruction_set, new_index),
      new_index,
      current_acc
    )
  end

  # PART 2 HELPER
  # Modified (re: copy pasted) version of above with different fallout cases
  defp find_accumulator_before_end(instruction_set, _, current_index, current_acc)
       when length(instruction_set) == current_index,
       do: current_acc

  defp find_accumulator_before_end(_, %Instruction{visited: true}, _, _), do: nil

  defp find_accumulator_before_end(
         instruction_set,
         %Instruction{action: "jmp", value: value} = i,
         current_index,
         current_acc
       ) do
    new_index = current_index + value

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})

    find_accumulator_before_end(
      instruction_set,
      Enum.at(instruction_set, new_index),
      new_index,
      current_acc
    )
  end

  defp find_accumulator_before_end(
         instruction_set,
         %Instruction{action: "acc", value: value} = i,
         current_index,
         current_acc
       ) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})

    find_accumulator_before_end(
      instruction_set,
      Enum.at(instruction_set, new_index),
      new_index,
      current_acc + value
    )
  end

  defp find_accumulator_before_end(
         instruction_set,
         %Instruction{action: "nop"} = i,
         current_index,
         current_acc
       ) do
    new_index = current_index + 1

    instruction_set = List.replace_at(instruction_set, current_index, %{i | visited: true})

    find_accumulator_before_end(
      instruction_set,
      Enum.at(instruction_set, new_index),
      new_index,
      current_acc
    )
  end
end
