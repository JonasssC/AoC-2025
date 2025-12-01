import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result
import gleam/pair

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "1"))

  use rotations <- result.try(input
    |> string.split("\n")
    |> list.map(parse)
    |> result.all()
  )

  io.println("Part 1: " <> part1(rotations) |> int.to_string())
  io.println("Part 2: " <> part2(rotations) |> int.to_string())

  Ok(Nil)
}

fn parse(inp: String) -> Result(Int, Nil) {
  case inp {
    "R" <> val -> int.parse(val)
    "L" <> val -> int.parse(val)
      |> result.map(fn(x) { -x })
    _ -> Error(Nil)
  }
}

fn part1(rotations: List(Int)) -> Int {
  rotations
  |> list.fold(#(0, 50), fn(acc, v) {
    let count = pair.first(acc)
    let dial = pair.second(acc)
    let new_dial = { dial + v } % 100
    #(
      case new_dial {
        0 -> count + 1
        _ -> count
      },
      { dial + v + 1000 } % 100
    )
  } )
  |> pair.first()
}


fn part2(rotations: List(Int)) -> Int {
  rotations
  |> list.fold(#(0, 50), fn(acc, v) {
    let count = pair.first(acc)
    let dial = pair.second(acc)
    #(
      count + count_zeroes(dial, v),
      { dial + v + 1000 } % 100
    )
  } )
  |> pair.first()
}

fn count_zeroes(dial: Int, rotate: Int) -> Int {
  case rotate {
    i if i >= 100 -> 1 + count_zeroes(dial, rotate - 100)
    i if i <= -100 -> 1 + count_zeroes(dial, rotate + 100)
    _ if dial == 0 -> 0
    i if dial + i == 0 -> 1
    i if i > 0 && dial + i > 99 -> 1
    i if i < 0 && dial + i < 0 -> 1
    _ -> 0
  }
}