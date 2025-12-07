import gleam/regexp
import gleam/pair
import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "6") |> result.map(string.split(_, "\n")))

  let assert Ok(re_split) = regexp.from_string(" +")
  let assert Ok(re_chunk) = regexp.from_string("\n +\n")

  use numbers1 <- result.try(
    input
    |> list.take(list.length(input) - 1)
    |> list.map(fn (line) {
      line
      |> string.trim
      |> regexp.split(re_split, _)
      |> list.map(int.parse)
      |> result.all
    })
    |> result.all
    |> result.map(list.transpose)
  )

  use operations <- result.try(
    input
    |> list.last
    |> result.map(regexp.split(re_split, _))
  )

  io.println("Part 1: " <> solve(numbers1, operations) |> int.to_string())

  use numbers2 <- result.try(
    input
    |> list.take(list.length(input) - 1)
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(string.join(_, ""))
    |> string.join("\n")
    |> regexp.split(re_chunk, _)
    |> list.map(fn (chunk) {
      chunk
      |> string.trim
      |> string.split("\n")
      |> list.map(string.trim)
      |> list.map(int.parse)
      |> result.all
    })
    |> result.all
  )

  io.println("Part 2: " <> solve(numbers2, operations) |> int.to_string())

  Ok(Nil)
}

fn solve(numbers: List(List(Int)), operations: List(String)) -> Int {
  numbers
  |> list.zip(operations)
  |> list.map(fn (p) {
    let nums = pair.first(p)
    case pair.second(p) {
      "+" -> nums
        |> list.fold(0, fn (a, b) { a + b })
      "*" -> nums
        |> list.fold(1, fn (a, b) { a * b })
      _ -> 0
    }
  })
  |> list.fold(0, fn (a, b) { a + b })
}
