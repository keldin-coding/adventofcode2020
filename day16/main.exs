defmodule TicketField do
  defstruct [:name, :ranges, :position]

  @main_regex ~r/^([\w\s]+):\s+(\d+-\d+) or (\d+-\d+)$/
  @range_regex ~r/(\d+)-(\d+)/

  def parse(line) do
    [name | raw_ranges] = Regex.run(@main_regex, line, capture: :all_but_first)

    ranges =
      raw_ranges
      |> Enum.map(fn raw_range ->
        [begin, final] = Regex.run(@range_regex, raw_range, capture: :all_but_first)

        String.to_integer(begin)..String.to_integer(final)
      end)

    %TicketField{name: name, ranges: ranges}
  end

  def contains?(%TicketField{ranges: ranges}, ticket_value) do
    Enum.any?(ranges, fn range -> Enum.member?(range, ticket_value) end)
  end
end

defmodule Ticket do
  def valid_ticket?(ticket, ticket_fields) when is_list(ticket) do
    Enum.all?(ticket, fn ticket_value ->
      Enum.any?(ticket_fields, fn ticket_field ->
        TicketField.contains?(ticket_field, ticket_value)
      end)
    end)
  end

  def sum_invalid_values(ticket, ticket_fields) when is_list(ticket) do
    Enum.reduce(ticket, 0, fn ticket_value, sum ->
      valid_field =
        Enum.any?(ticket_fields, fn ticket_field ->
          TicketField.contains?(ticket_field, ticket_value)
        end)

      if valid_field do
        sum
      else
        ticket_value + sum
      end
    end)
  end
end

defmodule Solution do
  def run_part1({ticket_fields, _your_ticket, nearby_tickets}) do
    nearby_tickets
    |> Enum.reduce(0, fn ticket, acc -> acc + Ticket.sum_invalid_values(ticket, ticket_fields) end)
  end

  def run_part2({ticket_fields, your_ticket, nearby_tickets}) do
    filtered_tickets =
      nearby_tickets |> Enum.filter(fn ticket -> Ticket.valid_ticket?(ticket, ticket_fields) end)

    index_list = Enum.with_index(your_ticket) |> Enum.map(fn {_, index} -> index end)

    by_element = Enum.zip(filtered_tickets) |> Enum.map(&Tuple.to_list/1)

    big_map =
      Enum.reduce(ticket_fields, %{}, fn field, big_acc ->
        per_position =
          Enum.reduce(index_list, [], fn position, sub_acc ->
            ticket_values = Enum.at(by_element, position)

            count = Enum.count(ticket_values, fn v -> TicketField.contains?(field, v) end)

            if count == length(filtered_tickets), do: [position | sub_acc], else: sub_acc
          end)

        Map.put(big_acc, field, per_position)
      end)

    # IO.inspect(big_map)

    result = perform_logic_puzzle(big_map)

    IO.inspect(result)

    result
    |> Map.keys()
    |> Enum.filter(fn field -> String.starts_with?(field.name, "departure") end)
    |> Enum.reduce(1, fn field, acc -> Enum.at(your_ticket, field.position) * acc end)
  end

  defp perform_logic_puzzle(field_to_position_count_map) do
    if Enum.all?(field_to_position_count_map, fn {f, _} -> !is_nil(f.position) end) do
      field_to_position_count_map
    else
      {field, [position]} =
        Enum.find(field_to_position_count_map, fn {_, m} -> length(m) == 1 end)

      new_field = %{field | position: position}

      field_to_position_count_map =
        Map.delete(field_to_position_count_map, field) |> Map.put(new_field, [])

      Enum.reduce(field_to_position_count_map, field_to_position_count_map, fn {field, positions},
                                                                               map ->
        Map.put(map, field, List.delete(positions, position))
      end)
      |> perform_logic_puzzle()
    end
  end

  def parse_input(input_lines) do
    # Don't want that empty string at the start
    {raw_ticket_fields, [_ | remainder]} =
      Enum.split_while(input_lines, fn line -> line != "" end)

    ticket_fields = Enum.map(raw_ticket_fields, fn line -> TicketField.parse(line) end)

    [_, raw_your_ticket, _, _ | raw_nearby_tickets] = remainder

    your_ticket = raw_your_ticket |> String.split(",") |> Enum.map(&String.to_integer/1)

    nearby_tickets =
      raw_nearby_tickets
      |> Enum.map(fn x ->
        x |> String.split(",") |> Enum.map(&String.to_integer/1)
      end)

    {ticket_fields, your_ticket, nearby_tickets}
  end
end
