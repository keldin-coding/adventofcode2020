defmodule Passport do
  @required_fields [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]
  @struct_fields @required_fields ++ [:cid]

  @valid_eye_colors ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]

  defstruct @struct_fields

  def parse(str) do
    fields = String.split(str, [" ", "\n"])

    Enum.reduce(fields, %Passport{}, fn field, passport ->
      parse_field(passport, field)
    end)
  end

  def required_not_nil?(%Passport{} = passport) do
    Enum.all?(@required_fields, fn field ->
      !is_nil(Map.get(passport, field))
    end)
  end

  def valid?(%Passport{} = passport) do
    Enum.all?(@struct_fields, fn field ->
      valid_field?(field, Map.get(passport, field))
    end)
  end

  # This is a bit unnecessary but I like it so it stays
  defp parse_field(%Passport{} = passport, "byr:" <> value), do: %{passport | byr: value}
  defp parse_field(%Passport{} = passport, "iyr:" <> value), do: %{passport | iyr: value}
  defp parse_field(%Passport{} = passport, "eyr:" <> value), do: %{passport | eyr: value}
  defp parse_field(%Passport{} = passport, "hgt:" <> value), do: %{passport | hgt: value}
  defp parse_field(%Passport{} = passport, "hcl:" <> value), do: %{passport | hcl: value}
  defp parse_field(%Passport{} = passport, "ecl:" <> value), do: %{passport | ecl: value}
  defp parse_field(%Passport{} = passport, "pid:" <> value), do: %{passport | pid: value}
  defp parse_field(%Passport{} = passport, "cid:" <> value), do: %{passport | cid: value}

  # Two catch-alls: :cid is always valid, existing or not, and otherwise nil values
  defp valid_field?(:cid, _), do: true
  defp valid_field?(_, value) when is_nil(value), do: false

  defp valid_field?(:byr, value) do
    num = String.to_integer(value)

    length(Integer.digits(num)) == 4 && Enum.member?(1920..2002, num) # num >= 1920 && num <= 2002
  end

  defp valid_field?(:iyr, value) do
    num = String.to_integer(value)

    length(Integer.digits(num)) == 4 && Enum.member?(2010..2020, num) # && num >= 2010 && num <= 2020
  end

  defp valid_field?(:eyr, value) do
    num = String.to_integer(value)

    length(Integer.digits(num)) == 4 && Enum.member?(2010..2030, num) #num >= 2010 && num <= 2030
  end

  defp valid_field?(:hgt, value) do
    {raw_height, units} = String.split_at(value, -2)

    if raw_height == "" do
      false
    else
      height = String.to_integer(raw_height)

      case units do
        "cm" ->
          Enum.member?(150..193, height)

        "in" ->
          Enum.member?(59..76, height)

        _ ->
          false
      end
    end
  end

  defp valid_field?(:hcl, "#" <> color) do
    String.match?(color, ~r/\A[a-f0-9]{6}\z/)
  end

  defp valid_field?(:hcl, _), do: false

  defp valid_field?(:ecl, value) when value in @valid_eye_colors, do: true
  defp valid_field?(:ecl, _), do: false

  defp valid_field?(:pid, value), do: String.match?(value, ~r/\A[0-9]{9}\z/)
end

defmodule Solution do
  def run_part1(input) do
    input
    |> Enum.map(&Passport.parse/1)
    |> Enum.count(&Passport.required_not_nil?/1)
  end

  def run_part2(input) do
    input
    |> Enum.map(&Passport.parse/1)
    |> Enum.count(&Passport.valid?/1)
  end
end
