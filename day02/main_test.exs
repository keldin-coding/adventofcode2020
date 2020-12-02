ExUnit.start()

Code.require_file("main.exs", "day02/")

defmodule PasswordTest do
  use ExUnit.Case, async: true

  test "parse/1" do
    str = "1-3 a: abcdef"

    pw = Password.parse(str)

    assert pw.range == 1..3
    assert pw.required_character == "a"
    assert pw.value == "abcdef"

    str = "1-33 a: abcdef"

    pw = Password.parse(str)

    assert pw.range == 1..33
    assert pw.required_character == "a"
    assert pw.value == "abcdef"
  end

  describe "valid?/1" do
    test "true if includes minimum number of character required" do
      pw = "2-4 a: aa" |> Password.parse()

      assert Password.valid?(pw)
    end

    test "true if includes middling number of character required" do
      pw = "2-4 a: aaa" |> Password.parse()

      assert Password.valid?(pw)
    end

    test "true if includes maximum number of character required" do
      pw = "2-4 a: aaaa" |> Password.parse()

      assert Password.valid?(pw)
    end

    test "false if less than minimum required" do
      pw = "2-4 a: a" |> Password.parse()

      refute Password.valid?(pw)
    end

    test "false if more than maximum required" do
      pw = "2-4 a: aaaaa" |> Password.parse()

      refute Password.valid?(pw)
    end
  end
end
