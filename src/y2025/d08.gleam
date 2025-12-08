import gleam/option
import gleam/pair
import gleam/set
import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub type Coord {
  Coord(x: Int, y: Int, z: Int)
}

pub type Distance {
  Distance(c1: Coord, c2: Coord, distance_sqr: Int)
}

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "8"))

  use coords <- result.try(input
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.split(",")
      |> list.map(int.parse)
      |> result.all
      |> result.try(fn(l) {
        case l {
          [x, y, z] -> Ok(Coord(x, y, z))
          _ -> Error(Nil)
        }
      })
    })
    |> result.all
  )

  io.println("Part 1: " <> part1(coords) |> int.to_string())
  io.println("Part 2: " <> part2(coords) |> int.to_string())

  Ok(Nil)
}

fn part1(coords: List(Coord)) -> Int {
  let distances = coords
  |> list.index_map(fn (c1, i) {
    coords
    |> list.drop(i + 1)
    |> list.map(fn (c2) {
      let dx = c1.x - c2.x
      let dy = c1.y - c2.y
      let dz = c1.z - c2.z
      Distance(c1, c2, dx * dx + dy * dy + dz * dz)
    })
  })
  |> list.flatten
  |> list.sort(fn(d1, d2) {
    int.compare(d1.distance_sqr, d2.distance_sqr)
  })

  distances
  |> list.take(1000)
  |> list.fold(set.new(), fn(acc, dist) {
    let acc_list = acc |> set.to_list
    let group1 = acc_list |> list.find(set.contains(_, dist.c1))
    let group2 = acc_list |> list.find(set.contains(_, dist.c2))
    case group1 {
      Ok(g1) -> {
        case group2 {
          Ok(g2) -> {
            case g1 == g2 {
              True  -> acc
              False -> acc
                |> set.delete(g1)
                |> set.delete(g2)
                |> set.insert(set.union(g1, g2))
            }
          }
          Error(_) -> acc
            |> set.delete(g1)
            |> set.insert(set.insert(g1, dist.c2))
        }
      }
      Error(_) -> {
        case group2 {
          Ok(g2) -> acc
            |> set.delete(g2)
            |> set.insert(set.insert(g2, dist.c1))
          Error(_) -> acc
            |> set.insert(set.new() |> set.insert(dist.c1) |> set.insert(dist.c2))
        }
      }
    }
  })
  |> set.to_list
  |> list.map(set.size)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, fn(a, b) { a * b })
}

fn part2(coords: List(Coord)) -> Int {
  let distances = coords
  |> list.index_map(fn(c1, i) {
    coords
    |> list.drop(i + 1)
    |> list.map(fn(c2) {
      let dx = c1.x - c2.x
      let dy = c1.y - c2.y
      let dz = c1.z - c2.z
      Distance(c1, c2, dx * dx + dy * dy + dz * dz)
    })
  })
  |> list.flatten
  |> list.sort(fn(d1, d2) {
    int.compare(d1.distance_sqr, d2.distance_sqr)
  })

  let groups = coords
  |> set.from_list
  |> set.map(fn(c) { set.new() |> set.insert(c) })

  distances
  |> list.fold_until(#(option.None, groups), fn(acc, dist) {
    case acc |> pair.second |> set.size {
      1 -> list.Stop(acc)
      _ -> list.Continue(
        #(
          option.Some(dist),
          {
            let groups_acc = acc |> pair.second
            let acc_list = groups_acc |> set.to_list
            let group1 = acc_list |> list.find(set.contains(_, dist.c1))
            let group2 = acc_list |> list.find(set.contains(_, dist.c2))
            case group1 {
              Ok(g1) -> {
                case group2 {
                  Ok(g2) -> {
                    case g1 == g2 {
                      True  -> groups_acc
                      False -> groups_acc
                      |> set.delete(g1)
                      |> set.delete(g2)
                      |> set.insert(set.union(g1, g2))
                    }
                  }
                  Error(_) -> groups_acc
                  |> set.delete(g1)
                  |> set.insert(set.insert(g1, dist.c2))
                }
              }
              Error(_) -> {
                case group2 {
                  Ok(g2) -> groups_acc
                  |> set.delete(g2)
                  |> set.insert(set.insert(g2, dist.c1))
                  Error(_) -> groups_acc
                  |> set.insert(set.new() |> set.insert(dist.c1) |> set.insert(dist.c2))
                }
              }
            }
          }
        )
      )
    }
  })
  |> pair.first
  |> option.map(fn (dist) {
    dist.c1.x * dist.c2.x
  })
  |> option.unwrap(0)
}
