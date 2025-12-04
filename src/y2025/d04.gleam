import gleam/pair
import gleam/set
import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "4"))

  let rolls = input
  |> string.split("\n")
  |> list.index_map(fn (line, row) {
    line
    |> string.to_graphemes
    |> list.index_fold(list.new(), fn (acc, tile, col) {
      case tile {
        "@" -> [#(row, col), ..acc]
        _ -> acc
      }
    })
  })
  |> list.flatten
  |> set.from_list

  io.println("Part 1: " <> part1(rolls) |> int.to_string())
  io.println("Part 2: " <> part2(rolls) |> int.to_string())

  Ok(Nil)
}

const directions = [
  #(0, 1),
  #(1, 1),
  #(1, 0),
  #(1, -1),
  #(0, -1),
  #(-1, -1),
  #(-1, 0),
  #(-1, 1),
]

fn part1(rolls: set.Set(#(Int, Int))) -> Int {
  rolls
  |> set.filter(fn (coord) {
    directions
    |> list.map(fn (dir) {
      #(
        pair.first(coord) + pair.first(dir),
        pair.second(coord) + pair.second(dir)
      )
    })
    |> set.from_list
    |> set.intersection(rolls)
    |> set.size < 4
  })
  |> set.size
}

fn part2(rolls: set.Set(#(Int, Int))) -> Int {
  let removeable = rolls
  |> set.filter(fn (coord) {
    directions
    |> list.map(fn (dir) {
      #(
        pair.first(coord) + pair.first(dir),
        pair.second(coord) + pair.second(dir)
      )
    })
    |> set.from_list
    |> set.intersection(rolls)
    |> set.size < 4
  })

  case set.size(removeable) {
    0 -> 0
    i -> i + part2(set.difference(rolls, removeable))
  }
}