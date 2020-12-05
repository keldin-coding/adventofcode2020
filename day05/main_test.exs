ExUnit.start()

Code.require_file("main.exs", "day05/")

defmodule AirplaneSeatsTest do
  use ExUnit.Case

  describe "row_number/2" do
    test "FBFBBFF results in 44" do
      assert AirplaneSeats.row_number("FBFBBFF") == 44
    end

    test "FFFFFFF results in 0" do
      assert AirplaneSeats.row_number("FFFFFFF") == 0
    end

    test "BBBBBBB results in 127" do
      assert AirplaneSeats.row_number("BBBBBBB") == 127
    end
  end

  describe "seat_number/2" do
    test "LLL results in 0" do
      assert AirplaneSeats.seat_number("LLL") == 0
    end

    test "RRR results in 7" do
      assert AirplaneSeats.seat_number("RRR") == 7
    end

    test "RLR results in 5" do
      assert AirplaneSeats.seat_number("RLR") == 5
    end
  end

  test "seat_id/1" do
    assert AirplaneSeats.seat_id("BFFFBBFRRR") == 567
    assert AirplaneSeats.seat_id("FFFBBBFRRR") == 119
    assert AirplaneSeats.seat_id("BBFFBBFRLL") == 820
  end
end
