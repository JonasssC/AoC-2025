import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "3"))

  use banks <- result.try(input
  |> string.split("\n")
  |> list.map(parse)
  |> result.all()
  )

  io.println("Part 1: " <> part1(banks) |> int.to_string())
  io.println("Part 2: " <> part2(banks) |> int.to_string())

  Ok(Nil)
}

fn parse(inp: String) -> Result(List(Int), Nil) {
  inp
  |> string.to_graphemes
  |> list.map(int.parse)
  |> result.all
}

fn part1(banks: List(List(Int))) -> Int {
  banks
  |> list.map(find_biggest_pair)
  |> list.fold(0, fn (a,b) { a + b })
}

fn find_biggest_pair(batteries: List(Int)) -> Int {
  let dec = batteries
  |> list.take(list.length(batteries) - 1)
  |> list.max(int.compare)
  |> result.unwrap(0)

  let unit = batteries
  |> list.drop_while(fn (x) { x != dec })
  |> list.drop(1)
  |> list.max(int.compare)
  |> result.unwrap(0)

  dec * 10 + unit
}


fn part2(banks: List(List(Int))) -> Int {
  banks
  |> list.map(find_biggest(_, 12, 0))
  |> list.fold(0, fn (a,b) { a + b })
}

fn find_biggest(batteries: List(Int), digit_count: Int, acc: Int) -> Int {
  case digit_count {
    0 -> acc
    _ -> {
      let digit = batteries
      |> list.take(list.length(batteries) - digit_count + 1)
      |> list.max(int.compare)
      |> result.unwrap(0)

      let remaining = batteries
      |> list.drop_while(fn (x) { x != digit })
      |> list.drop(1)

      find_biggest(
        remaining,
        digit_count - 1,
        acc * 10 + digit
      )
    }
  }
}