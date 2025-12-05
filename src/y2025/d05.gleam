import gleam/pair
import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "5"))

  use ranges <- result.try(
    input
    |> string.split("\n")
    |> list.take_while(fn (l) { l != "" })
    |> list.map(fn (l) {
      case string.split(l, "-") {
        [a, b] ->
        result.try(int.parse(a), fn(i) {
          result.map(int.parse(b), fn(j) {
            #(i, j)
          })
        })
        _ -> Error(Nil)
      }
    })
    |> result.all
  )

  use ingredients <- result.try(
    input
    |> string.split("\n")
    |> list.drop_while(fn (l) { l != "" })
    |> list.drop(1)
    |> list.map(int.parse)
    |> result.all
  )

  io.println("Part 1: " <> part1(ranges, ingredients) |> int.to_string())
  io.println("Part 2: " <> part2(ranges) |> int.to_string())

  Ok(Nil)
}

fn part1(ranges: List(#(Int, Int)), ingredients: List(Int)) -> Int {
  ingredients
  |> list.filter(fn (ingredient) {
    list.any(ranges, fn(range) {
      pair.first(range) <= ingredient && ingredient <= pair.second(range)
    })
  })
  |> list.length
}

fn part2(ranges: List(#(Int, Int))) -> Int {
  ranges
  |> simplify_ranges
  |> list.map(fn (range) {
    pair.second(range) - pair.first(range) + 1
  })
  |> list.fold(0, fn (a, b) { a + b })
}

fn simplify_ranges(ranges: List(#(Int, Int))) -> List(#(Int, Int)) {
  let expanded_ranges = ranges
  |> list.map(fn (range) {
    case ranges
      |> list.filter(fn (range2) {
        pair.second(range2) > pair.second(range)
        && pair.first(range2) <= pair.second(range)
      })
      |> list.map(pair.second)
      |> list.max(int.compare) {
      Ok(max) -> #(pair.first(range), max)
      Error(_) -> range
    }
  })

  let filtered_ranges = expanded_ranges
  |> list.filter(fn (range1) {
    !list.any(expanded_ranges, fn (range2) {
      range1 != range2
      && pair.first(range2) <= pair.first(range1)
      && pair.second(range1) <= pair.second(range2)
    })
  })
  |> list.unique

  case ranges == filtered_ranges {
    True -> filtered_ranges
    False -> simplify_ranges(filtered_ranges)
  }
}
