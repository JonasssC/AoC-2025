import gleam/option
import gleam/dict
import gleam/set
import gleam/pair
import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "7"))

  let splitters = input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.to_graphemes
    |> list.index_fold(list.new(), fn(acc, tile, col) {
      case tile {
        "^" -> [col, ..acc]
        _ -> acc
      }
    })
    |> set.from_list
  })

  use start <- result.try(input
    |> string.split("\n")
    |> list.first
    |> result.map(fn(line) {
      line
      |> string.to_graphemes
      |> list.index_fold(list.new(), fn(acc, tile, col) {
        case tile {
          "S" -> [col, ..acc]
          _ -> acc
        }
      })
      |> set.from_list
    })
  )


  io.println("Part 1: " <> part1(start, splitters) |> int.to_string())
  io.println("Part 2: " <> part2(start, splitters) |> int.to_string())

  Ok(Nil)
}

fn part1(beams: set.Set(Int), splitters: List(set.Set(Int))) -> Int {
  splitters
  |> list.fold(#(0, beams), fn(acc, splitters_line) {
    let hits = acc
    |> pair.second
    |> set.intersection(splitters_line)

    let left = hits
    |> set.map(fn(col) { col - 1 })

    let right = hits
    |> set.map(fn(col) { col + 1 })

    let non_hits = acc
    |> pair.second
    |> set.difference(splitters_line)

    #(
      pair.first(acc) + set.size(hits),
      non_hits
      |> set.union(left)
      |> set.union(right)
    )
  })
  |> pair.first
}

fn part2(beams: set.Set(Int), splitters: List(set.Set(Int))) -> Int {
  let beam_dict = beams
  |> set.map(fn(beam) { #(beam, 1) })
  |> set.to_list
  |> dict.from_list

  splitters
  |> list.fold(beam_dict, fn(acc, splitters_line) {
    let hits = acc
    |> dict.keys
    |> set.from_list
    |> set.intersection(splitters_line)

    acc
    |> dict.keys
    |> set.from_list
    |> set.difference(splitters_line)
    |> set.to_list
    |> dict.take(acc, _)
    |> set.fold(hits, _, fn(new_acc, hit_coord) {
      let hit_count = acc
      |> dict.get(hit_coord)
      |> result.unwrap(0)

      new_acc
      |> dict.upsert(hit_coord - 1, fn(n) { option.unwrap(n, 0) + hit_count })
      |> dict.upsert(hit_coord + 1, fn(n) { option.unwrap(n, 0) + hit_count })
    })
  })
  |> dict.fold(0, fn(acc, _k , v) { acc + v })
}
