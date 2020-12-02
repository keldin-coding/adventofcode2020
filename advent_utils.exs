defmodule AdventUtils do
  def read_and_split_file(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
  end
end
