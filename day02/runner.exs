Code.require_file("main.exs", "day02/")
Code.require_file("advent_utils.exs")

input = AdventUtils.read_and_split_file("day02/input")

IO.puts("PART 1: Got the number of results: #{Solution.run_part1(input)}")
IO.puts("PART 2: Got the number of results: #{Solution.run_part2(input)}")
