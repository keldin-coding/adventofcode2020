Code.require_file("main.exs", "day04/")
Code.require_file("advent_utils.exs")

# Day 4 is special unsurpsisingly
input = File.read!("day04/input") |> String.trim() |> String.split("\n\n")

IO.puts("PART 1: Got the following answer: #{Solution.run_part1(input)}")
IO.puts("PART 2: Got the following answer: #{Solution.run_part2(input)}")
