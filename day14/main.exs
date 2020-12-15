# These solution could probably be faster without expanding the strings way past
# what's needed in many cases, but it works so...meh.

defmodule Bitmask do
  defstruct mask: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

  def create(bitmask) do
    %Bitmask{mask: String.graphemes(bitmask)}
  end

  def mask_value(%Bitmask{mask: mask}, value) do
    value
    |> Integer.to_string(2)
    |> String.pad_leading(36, "0")
    |> String.graphemes()
    |> mask_bits(mask, [])
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp mask_bits([], [], acc), do: Enum.reverse(acc)

  defp mask_bits([val_bit | value], ["X" | mask], acc),
    do: mask_bits(value, mask, [val_bit | acc])

  defp mask_bits([_ | value], [mask_bit | mask], acc),
    do: mask_bits(value, mask, [mask_bit | acc])
end

defmodule DecodedAddress do
  defstruct [:decoded]

  def generate_possible_address(%DecodedAddress{decoded: pattern}) do
    pattern
    |> do_generate_possible_address("")
    |> List.flatten()
    |> Enum.map(&String.reverse/1)
    |> Enum.map(fn i -> String.to_integer(i, 2) end)
  end

  defp do_generate_possible_address([], address), do: address

  defp do_generate_possible_address(["X" | rest], address) do
    [
      do_generate_possible_address(rest, "1" <> address),
      do_generate_possible_address(rest, "0" <> address)
    ]
  end

  defp do_generate_possible_address([item | rest], address) do
    do_generate_possible_address(rest, item <> address)
  end
end

defmodule AddressDecoder do
  defstruct pattern: "000000000000000000000000000000000000"

  def create(address_pattern) do
    %AddressDecoder{pattern: String.graphemes(address_pattern)}
  end

  def decode_address(%AddressDecoder{pattern: pattern}, address) do
    decoded =
      address
      |> Integer.to_string(2)
      |> String.pad_leading(36, "0")
      |> String.graphemes()
      |> decode_address_bits(pattern, [])

    %DecodedAddress{decoded: decoded}
  end

  defp decode_address_bits([], [], acc), do: Enum.reverse(acc)

  defp decode_address_bits([_ | address], ["X" | pattern], acc) do
    decode_address_bits(address, pattern, ["X" | acc])
  end

  defp decode_address_bits([_ | address], ["1" | pattern], acc) do
    decode_address_bits(address, pattern, ["1" | acc])
  end

  defp decode_address_bits([add_bit | address], ["0" | pattern], acc) do
    decode_address_bits(address, pattern, [add_bit | acc])
  end
end

defmodule Solution do
  @mem_regex ~r/^mem\[(\d+)\]\s+=\s+(\d+)$/

  def run_part1(input) do
    {memory_map, _} =
      input
      |> Enum.reduce({%{}, %Bitmask{}}, fn line, {memory, current_bitmask} ->
        inspect_evaluate_line(line, memory, current_bitmask)
      end)

    memory_map
    |> Map.values()
    |> Enum.reduce(0, fn number, acc -> acc + number end)
  end

  def run_part2(input) do
    {memory_map, _} =
      input
      |> Enum.reduce({%{}, %AddressDecoder{}}, fn line, {memory, current_decoder} ->
        inspect_evaluate_line_part2(line, memory, current_decoder)
      end)

    memory_map
    |> Map.values()
    |> Enum.reduce(0, fn number, acc -> acc + number end)
  end

  defp inspect_evaluate_line_part2(line, memory, current_decoder) do
    evaluate_line_part2(line, memory, current_decoder)
  end

  defp evaluate_line_part2("mask = " <> bitmask, memory, _) do
    {memory, AddressDecoder.create(bitmask)}
  end

  defp evaluate_line_part2(line, memory, current_decoder) do
    [addr, number] = Regex.run(@mem_regex, line, capture: :all_but_first)

    val = String.to_integer(number)

    new_memory_map =
      AddressDecoder.decode_address(current_decoder, String.to_integer(addr))
      |> DecodedAddress.generate_possible_address()
      |> Enum.reduce(memory, fn address, acc ->
        Map.put(acc, address, val)
      end)

    {new_memory_map, current_decoder}
  end

  #
  # =========
  #

  defp inspect_evaluate_line(line, memory, current_bitmask) do
    evaluate_line(line, memory, current_bitmask)
  end

  defp evaluate_line("mask = " <> bitmask, memory, _) do
    {memory, Bitmask.create(bitmask)}
  end

  defp evaluate_line(line, memory, current_bitmask) do
    [addr, number] = Regex.run(@mem_regex, line, capture: :all_but_first)

    masked_value = Bitmask.mask_value(current_bitmask, String.to_integer(number))

    {Map.put(memory, addr, masked_value), current_bitmask}
  end
end
