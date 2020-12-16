Code.require_file("main.exs", "day16/")
Code.require_file("advent_utils.exs")

input = AdventUtils.read_and_split_file("day16/input")

parsed_input = Solution.parse_input(input)

part_1_task = Task.async(fn -> Solution.run_part1(parsed_input) end)
part_2_task = Task.async(fn -> Solution.run_part2(parsed_input) end)

IO.puts("PART 1: Got the following answer: #{Task.await(part_1_task)}")
IO.puts("PART 2: Got the following answer: #{Task.await(part_2_task)}")
