import gleam/regexp
import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "2"))

  use parsed_input <- result.try(input
    |> string.split(",")
    |> list.map(parse)
    |> result.all()
    |> result.map(list.flatten)
  )

  io.println("Part 1: " <> part1(parsed_input) |> int.to_string())
  io.println("Part 2: " <> part2(parsed_input) |> int.to_string())

  Ok(Nil)
}

fn parse(inp: String) -> Result(List(Int), Nil) {
  case string.split(inp, "-") {
    [a, b] ->
      result.try(int.parse(a), fn(i) {
        result.map(int.parse(b), fn(j) {
          list.range(i, j)
        })
      })
    _ -> Error(Nil)
  }
}

fn part1(input: List(Int)) -> Int {
  let assert Ok(re) = regexp.from_string("^(.+)\\1$")
  input
  |> list.filter(fn (id) {
    let id_str = int.to_string(id)
    regexp.check(re, id_str)
  })
  |> list.fold(0, fn (a, b) { a + b })
}

fn part2(input: List(Int)) -> Int {
  let assert Ok(re) = regexp.from_string("^(.+)\\1+$")
  input
  |> list.filter(fn (id) {
    let id_str = int.to_string(id)
    regexp.check(re, id_str)
  })
  |> list.fold(0, fn (a, b) { a + b })
}
