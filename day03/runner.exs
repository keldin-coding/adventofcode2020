Code.require_file("main.exs", "day03/")
Code.require_file("advent_utils.exs")

input = AdventUtils.read_and_split_file("day03/input")

IO.puts("PART 1: Got the following answer: #{Solution.run_part1(input)}")
# IO.inspect(Solution.run_part1(input))
IO.puts("PART 2: Got the following answer: #{Solution.run_part2(input)}")
