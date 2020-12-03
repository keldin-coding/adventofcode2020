defmodule Password do
  defstruct [:range, :required_character, :value]

  def parse(string) do
    [range_string, character_with_colon, password] = String.trim(string) |> String.split(" ")

    %Password{
      range: parse_range(range_string),
      required_character: parse_required_character(character_with_colon),
      value: password
    }
  end

  def valid?(%Password{} = password) do
    count =
      password.value
      |> String.codepoints()
      |> Enum.count(fn x -> x == password.required_character end)

    Enum.member?(password.range, count)
  end

  defp parse_range(range_string) do
    [first, second] = range_string |> String.split("-") |> Enum.map(&String.to_integer/1)

    first..second
  end

  # I have a feeling part 2 will require multiple characters or multiple rules
  defp parse_required_character(raw_characters) do
    raw_characters |> String.trim_trailing(":")
  end
end

defmodule PasswordPart2 do
  defstruct [:positions, :required_character, :value]

  def parse(string) do
    [position_string, character_with_colon, password] = String.trim(string) |> String.split(" ")

    %PasswordPart2{
      positions: parse_position(position_string),
      required_character: parse_required_character(character_with_colon),
      value: password
    }
  end

  def valid?(%PasswordPart2{} = password) do
    [first_pos, second_pos] = password.positions

    first = String.at(password.value, first_pos) == password.required_character
    second = String.at(password.value, second_pos) == password.required_character

    first != second
  end

  defp parse_position(position_string) do
    position_string |> String.split("-") |> Enum.map(&String.to_integer/1) |> Enum.map(&(&1 - 1))
  end

  defp parse_required_character(raw_characters) do
    raw_characters |> String.trim_trailing(":")
  end
end

defmodule Solution do
  def run_part1(input_list) when is_list(input_list) do
    input_list
    |> Enum.count(fn line ->
      Password.parse(line) |> Password.valid?()
    end)
  end

  def run_part2(input_list) when is_list(input_list) do
    input_list
    |> Enum.count(fn line ->
      PasswordPart2.parse(line) |> PasswordPart2.valid?()
    end)
  end
end
