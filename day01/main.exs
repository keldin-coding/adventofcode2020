defmodule Solution do
  def read_file() do
    File.read!("input")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def run(how_many, goal) do
    list = read_file()

    result = search(how_many, goal, list)
    IO.inspect(result)

    result |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def search(how_many, _, list) when length(list) < how_many do
    []
  end

  def search(how_many, goal, [item | remaining_list]) when how_many == 2 do
    with true <- item < goal,
         final <- Enum.find(remaining_list, nil, fn x -> x == goal - item end),
         true <- is_integer(final) do
      [final, item]
    else
      _ -> search(how_many, goal, remaining_list)
    end
  end

  def search(how_many, goal, [head | rest]) do
    with true <- head < goal,
         others <- search(how_many - 1, goal - head, rest),
         true <- length(others) != 0 do
      [head | others]
    else
      _ -> search(how_many, goal, rest)
    end
  end
end

answer = Solution.run(4, 2020)

IO.puts("The answer is #{answer}")
