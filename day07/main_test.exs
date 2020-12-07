ExUnit.start()

Code.require_file("main.exs", "day07/")

defmodule BagTest do
  use ExUnit.Case

  describe "from_line/1" do
    test "based on examples" do
      test_grid = %{
        "light red bags contain 1 bright white bag, 2 muted yellow bags." => %Bag{
          bag_type: "light red",
          contained_bags: %{"bright white" => 1, "muted yellow" => 2}
        },
        "bright white bags contain 1 shiny gold bag." => %Bag{
          bag_type: "bright white",
          contained_bags: %{"shiny gold" => 1}
        },
        "faded blue bags contain no other bags." => %Bag{
          bag_type: "faded blue",
          contained_bags: %{}
        }
      }

      Enum.each(test_grid, fn {input, expected} ->
        assert Bag.from_line(input) == expected
      end)
    end
  end
end
