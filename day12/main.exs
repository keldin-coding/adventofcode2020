defmodule Instruction do
  defstruct [:command, :value]

  def parse(str) do
    {command, raw_value} = String.split_at(str, 1)

    %Instruction{command: command, value: String.to_integer(raw_value)}
  end
end

defmodule Ship do
  defstruct [:facing_index, x: 0, y: 0]

  @direction_order {"N", "E", "S", "W"}

  def move(%Ship{} = ship, %Instruction{command: "R", value: turn}) do
    # Assumes only 90 degree turns or intervals therein
    rotations = div(turn, 90)
    new_index = rem(ship.facing_index + rotations, 4)

    %{ship | facing_index: new_index}
  end

  def move(%Ship{} = ship, %Instruction{command: "L", value: turn}) do
    # Assumes only 90 degree turns or intervals therein
    rotations = div(turn, 90)
    new_index = rem(ship.facing_index - rotations, 4)

    if new_index < 0 do
      %{ship | facing_index: 4 + new_index}
    else
      %{ship | facing_index: new_index}
    end
  end

  def move(%Ship{y: y} = ship, %Instruction{command: "N", value: movement}) do
    %{ship | y: y + movement}
  end

  def move(%Ship{y: y} = ship, %Instruction{command: "S", value: movement}) do
    %{ship | y: y - movement}
  end

  def move(%Ship{x: x} = ship,  %Instruction{command: "E", value: movement}) do
    %{ship | x: x + movement}
  end

  def move(%Ship{x: x} = ship, %Instruction{command: "W", value: movement}) do
    %{ship | x: x - movement}
  end

  def move(%Ship{} = ship,  %Instruction{command: "F"} = inst) do
    move(ship, %{inst | command: ship_direction(ship)})
  end

  defp ship_direction(%Ship{facing_index: index}), do: elem(@direction_order, index)
end

defmodule Waypoint do
  defstruct [:x, :y]
end

defmodule ShipWithWaypoint do
  defstruct [:waypoint, x: 0, y: 0]

  @quadrant_multipliers %{
    0 => {1, 1},
    1 => {-1, 1},
    2 => {-1, -1},
    3 => {1, -1}
  }

  def inspect_move(ship, order) do
    # IO.inspect ship
    # IO.puts "Order: #{order}\n"

    move(ship, order)
  end

  def move(%ShipWithWaypoint{waypoint: waypoint} = ship, %Instruction{command: "R"} = inst) do
    new_waypoint = rotate_waypoint(waypoint, inst)
    %{ship | waypoint: new_waypoint}
  end

  def move(%ShipWithWaypoint{waypoint: waypoint} = ship, %Instruction{command: "L"} = inst) do
    new_waypoint = rotate_waypoint(waypoint, inst)
    %{ship | waypoint: new_waypoint}
  end

  def move(%ShipWithWaypoint{waypoint: waypoint} = ship, %Instruction{command: "N", value: movement}) do
    new_waypoint = %{waypoint | y: waypoint.y + movement}

    %{ship | waypoint: new_waypoint}
  end

  def move(%ShipWithWaypoint{waypoint: waypoint} = ship, %Instruction{command: "S", value: movement}) do
    new_waypoint = %{waypoint | y: waypoint.y - movement}

    %{ship | waypoint: new_waypoint}
  end

  def move(%ShipWithWaypoint{waypoint: waypoint} = ship, %Instruction{command: "E", value: movement}) do
    new_waypoint = %{waypoint | x: waypoint.x + movement}

    %{ship | waypoint: new_waypoint}
  end

  def move(%ShipWithWaypoint{waypoint: waypoint} = ship, %Instruction{command: "W", value: movement}) do
    new_waypoint = %{waypoint | x: waypoint.x - movement}

    %{ship | waypoint: new_waypoint}
  end

  def move(%ShipWithWaypoint{waypoint: waypoint} = ship, %Instruction{command: "F", value: movement}) do
    %{ship | x: ship.x + movement * waypoint.x, y: ship.y + movement * waypoint.y}
  end

  # I'm making life harder by making R == subtraction and L == addition. Also
  # these are all cartesian quadrants - 1
  defp waypoint_quadrant(%Waypoint{x: x, y: y}) do
    cond do
      x >= 0 && y > 0 ->
        0

      x < 0 && y >= 0 ->
        1

      x <= 0 && y < 0 ->
        2

      x > 0 && y <= 0 ->
        3
    end
  end

  defp rotate_waypoint(%Waypoint{} = waypoint, %Instruction{value: 0}), do: waypoint
  defp rotate_waypoint(%Waypoint{x: 0, y: 0} = waypoint, _), do: waypoint

  defp rotate_waypoint(%Waypoint{} = waypoint, %Instruction{command: "L", value: amount} = inst) do
    current_quadrant = waypoint_quadrant(waypoint)
    next_quadrant = rem(current_quadrant + 1, 4)

    {x_multiply, y_multiply} = Map.get(@quadrant_multipliers, next_quadrant)

    # IO.puts "x mult = #{x_multiply}, y mult = #{y_multiply}"
    new_x = abs(waypoint.y) * x_multiply
    new_y = abs(waypoint.x) * y_multiply

    rotate_waypoint(%{waypoint | x: new_x, y: new_y}, %{inst | value: amount - 90})
  end

  defp rotate_waypoint(%Waypoint{} = waypoint, %Instruction{command: "R", value: amount} = inst) do
    current_quadrant = waypoint_quadrant(waypoint)
    possible_quadrant = rem(current_quadrant - 1, 4)

    next_quadrant = if possible_quadrant < 0, do: 3, else: possible_quadrant

    {x_multiply, y_multiply} = Map.get(@quadrant_multipliers, next_quadrant)

    new_x = abs(waypoint.y) * x_multiply
    new_y = abs(waypoint.x) * y_multiply

    rotate_waypoint(%{waypoint | x: new_x, y: new_y}, %{inst | value: amount - 90})
  end
end

defmodule Solution do
  def run_part1(input) do
    result =
      input
      |> Enum.map(&Instruction.parse/1)
      |> Enum.reduce(%Ship{facing_index: 1}, fn command, ship ->
        new_ship = Ship.move(ship, command)

        new_ship
      end)

    abs(result.x) + abs(result.y)
  end

  def run_part2(input) do
    result =
      input
      |> Enum.map(&Instruction.parse/1)
      |> Enum.reduce(%ShipWithWaypoint{waypoint: %Waypoint{x: 10, y: 1}}, fn command, ship ->
        ShipWithWaypoint.inspect_move(ship, command)
      end)

    abs(result.x) + abs(result.y)
  end
end
