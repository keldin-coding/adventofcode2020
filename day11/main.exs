defmodule Seat do
  defstruct [:row_number, :seat_number]
end

defmodule Layout do
  @floor "."
  @empty_seat "L"
  @occupied_seat "#"

  def parse(rows) do
    Enum.with_index(rows)
    |> Enum.reduce(%{}, fn {raw_row, row_num}, larger_map ->
      parsed_row =
        String.graphemes(raw_row)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {seat, seat_num}, seats ->
          Map.put(seats, %Seat{row_number: row_num, seat_number: seat_num}, seat)
        end)

      Map.merge(larger_map, parsed_row)
    end)
  end

  def num_occupied_adjacent_seats(
        seats,
        %Seat{row_number: row_number, seat_number: seat_number} = seat
      ) do
    [
      # Row above
      %{seat | row_number: row_number - 1, seat_number: seat_number - 1},
      %{seat | row_number: row_number - 1},
      %{seat | row_number: row_number - 1, seat_number: seat_number + 1},

      # Same row
      %{seat | seat_number: seat_number - 1},
      %{seat | seat_number: seat_number + 1},

      # Row below
      %{seat | row_number: row_number + 1, seat_number: seat_number - 1},
      %{seat | row_number: row_number + 1},
      %{seat | row_number: row_number + 1, seat_number: seat_number + 1}
    ]
    |> Enum.count(fn point -> occupied_seat?(Map.get(seats, point)) end)
  end

  def mutate(seats) do
    Enum.reduce(seats, %{}, fn {point, _}, acc ->
      if Map.get(seats, point) == @floor do
        Map.put(acc, point, @floor)
      else
        adjacent = num_occupied_adjacent_seats(seats, point)
        seat_value = Map.get(seats, point)

        cond do
          !occupied_seat?(seat_value) && adjacent == 0 ->
            Map.put(acc, point, @occupied_seat)

          occupied_seat?(seat_value) && adjacent >= 4 ->
            Map.put(acc, point, @empty_seat)

          true ->
            Map.put(acc, point, seat_value)
        end
      end
    end)
  end

  def mutate_until_rest(original_seats) do
    new_seats = mutate(original_seats)

    if Map.equal?(original_seats, new_seats), do: new_seats, else: mutate_until_rest(new_seats)
  end

  def occupied_seat?(@occupied_seat), do: true
  def occupied_seat?(_), do: false
end

# A copy-paste of Layout. Could probably split out the Map part and put the
# doing stuff bits into the Solution module but meh.
defmodule LayoutPart2 do
  @floor "."
  @empty_seat "L"
  @occupied_seat "#"

  def parse(rows) do
    Enum.with_index(rows)
    |> Enum.reduce(%{}, fn {raw_row, row_num}, larger_map ->
      parsed_row =
        String.graphemes(raw_row)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {seat, seat_num}, seats ->
          Map.put(seats, %Seat{row_number: row_num, seat_number: seat_num}, seat)
        end)

      Map.merge(larger_map, parsed_row)
    end)
  end

  def num_occupied_visible_seats(
        seats,
        %Seat{row_number: row_number, seat_number: seat_number} = seat
      ) do
    [
      # Row above
      find_seat(
        seats,
        %{seat | row_number: row_number - 1, seat_number: seat_number - 1},
        -1,
        -1
      ),
      find_seat(seats, %{seat | row_number: row_number - 1}, -1, 0),
      find_seat(seats, %{seat | row_number: row_number - 1, seat_number: seat_number + 1}, -1, 1),

      # Same row
      find_seat(seats, %{seat | seat_number: seat_number - 1}, 0, -1),
      find_seat(seats, %{seat | seat_number: seat_number + 1}, 0, 1),

      # Row below
      find_seat(seats, %{seat | row_number: row_number + 1, seat_number: seat_number - 1}, 1, -1),
      find_seat(seats, %{seat | row_number: row_number + 1}, 1, 0),
      find_seat(seats, %{seat | row_number: row_number + 1, seat_number: seat_number + 1}, 1, 1)
    ]
    |> Enum.count(fn seat -> occupied_seat?(seat) end)
  end

  defp find_seat(seats, %Seat{row_number: row, seat_number: col} = position, rise, run) do
    spot = Map.get(seats, position)

    if is_seat?(spot) do
      spot
    else
      find_seat(seats, %Seat{row_number: row + rise, seat_number: col + run}, rise, run)
    end
  end

  def mutate(seats) do
    Enum.reduce(seats, %{}, fn {point, _}, acc ->
      if Map.get(seats, point) == @floor do
        Map.put(acc, point, @floor)
      else
        visible = num_occupied_visible_seats(seats, point)
        seat_value = Map.get(seats, point)

        cond do
          !occupied_seat?(seat_value) && visible == 0 ->
            Map.put(acc, point, @occupied_seat)

          occupied_seat?(seat_value) && visible >= 5 ->
            Map.put(acc, point, @empty_seat)

          true ->
            Map.put(acc, point, seat_value)
        end
      end
    end)
  end

  def mutate_until_rest(original_seats) do
    new_seats = mutate(original_seats)

    if Map.equal?(original_seats, new_seats), do: new_seats, else: mutate_until_rest(new_seats)
  end

  def occupied_seat?(@occupied_seat), do: true
  def occupied_seat?(_), do: false

  # This is sort of counter intuitive but `nil` is an empty seat for our purposes
  def is_seat?(@floor), do: false
  def is_seat?(_), do: true
end

defmodule Solution do
  def run_part1(input) do
    map = Layout.parse(input)

    final_rest_map = Layout.mutate_until_rest(map)

    Enum.count(final_rest_map, fn {_, v} -> Layout.occupied_seat?(v) end)
  end

  def run_part2(input) do
    map = LayoutPart2.parse(input)

    final_rest_map = LayoutPart2.mutate_until_rest(map)

    Enum.count(final_rest_map, fn {_, v} -> LayoutPart2.occupied_seat?(v) end)
  end
end
