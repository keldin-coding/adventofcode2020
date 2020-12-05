defmodule AirplaneSeats do
  def seat_id(boarding_pass) do
    {row, seat} = String.split_at(boarding_pass, -3)

    (row_number(row) * 8) + seat_number(seat)
  end

  # The _.._ are to pattern match and ensure we're getting Ranges since there
  # is no is_range guard.
  def row_number(string, seats \\ 0..127)
  def row_number("F" <> rest, _.._ = rows), do: row_number(rest, binary_first_half(rows))
  def row_number("B" <> rest, _.._ = rows), do: row_number(rest, binary_second_half(rows))
  def row_number("", start.._), do: start

  def seat_number(string, seats \\ 0..7)
  def seat_number("L" <> rest, _.._ = seats), do: seat_number(rest, binary_first_half(seats))
  def seat_number("R" <> rest, _.._ = seats), do: seat_number(rest, binary_second_half(seats))
  def seat_number("", start.._), do: start

  defp binary_first_half(start..stop), do: start..div(start + stop, 2)
  defp binary_second_half(start..stop), do: (div(start + stop, 2) + 1)..stop
end

defmodule Solution do
  def run_part1(input) do
    input |> Enum.map(&AirplaneSeats.seat_id/1) |> Enum.max()
  end

  def run_part2(input) do
    input |> Enum.map(&AirplaneSeats.seat_id/1) |> Enum.sort() |> find_my_seat()
  end

  defp find_my_seat([first, second | _rest]) when first + 2 == second, do: first + 1
  defp find_my_seat([_, second | rest]), do: find_my_seat([second | rest])
  defp find_my_seat([_only_one]), do: nil
end
