import gleam/pair
import gleam/string
import util/input
import gleam/io
import gleam/list
import gleam/int
import gleam/result

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type VerticalEdge {
  VerticalEdge(x: Int, top: Int, bottom: Int)
}

pub type HorizontalEdge {
  HorizontalEdge(y: Int, left: Int, right: Int)
}

pub type State {
  Out
  In
  TopEdge
  BottomEdge
}

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(input.get_input("2025", "9"))

  use coords <- result.try(input
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.split(",")
      |> list.map(int.parse)
      |> result.all
      |> result.try(fn(l) {
        case l {
          [x, y] -> Ok(Coord(x, y))
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
  coords
  |> list.combination_pairs
  |> list.map(fn (p) {
    let c1 = pair.first(p)
    let c2 = pair.second(p)
    { int.absolute_value(c1.x - c2.x) + 1 } * { int.absolute_value(c1.y - c2.y) + 1 }
  })
  |> list.max(int.compare)
  |> result.unwrap(0)
}

fn part2(coords: List(Coord)) -> Int {
  let vertical_edges = get_vertical_edges(coords)
  let horizontal_edges = get_horizontal_edges(coords)

  coords
  |> list.combination_pairs
  |> list.filter_map(fn (p) {
    let c1 = pair.first(p)
    let c2 = pair.second(p)

    let c3 = Coord(c1.x, c2.y)
    let c4 = Coord(c2.x, c1.y)

    case coord_is_inside(c3, vertical_edges)
    && coord_is_inside(c4, vertical_edges)
    && !edge_crosses_rect(c1, c2, vertical_edges, horizontal_edges) {
      True -> Ok({ int.absolute_value(c1.x - c2.x) + 1 } * { int.absolute_value(c1.y - c2.y) + 1 })
      False -> Error(Nil)
    }
  })
  |> list.max(int.compare)
  |> result.unwrap(0)
}

fn get_vertical_edges(coords: List(Coord)) -> List(VerticalEdge) {
  let vertical_edges = coords
  |> list.window_by_2
  |> list.filter_map(fn(p) {
    let c1 = pair.first(p)
    let c2 = pair.second(p)
    case c1.x == c2.x {
      True -> Ok(VerticalEdge(c1.x, int.min(c1.y, c2.y) , int.max(c1.y, c2.y)))
      False -> Error(Nil)
    }
  })

  let first_coord = coords |> list.first |> result.unwrap(Coord(0,0))
  let last_coord = coords |> list.last |> result.unwrap(Coord(0,0))

  let res = case first_coord.x == last_coord.x {
    True -> [
      VerticalEdge(first_coord.x, int.min(first_coord.y, last_coord.y), int.max(first_coord.y, last_coord.y)),
      ..vertical_edges
    ]
    False -> vertical_edges
  }

  res
  |> list.sort(fn(e1, e2) { int.compare(e1.x, e2.x) })
}

fn get_horizontal_edges(coords: List(Coord)) -> List(HorizontalEdge) {
  let horizontal_edges = coords
  |> list.window_by_2
  |> list.filter_map(fn(p) {
    let c1 = pair.first(p)
    let c2 = pair.second(p)
    case c1.y == c2.y {
      True -> Ok(HorizontalEdge(c1.y, int.min(c1.x, c2.x) , int.max(c1.x, c2.x)))
      False -> Error(Nil)
    }
  })

  let first_coord = coords |> list.first |> result.unwrap(Coord(0,0))
  let last_coord = coords |> list.last |> result.unwrap(Coord(0,0))

  let res = case first_coord.y == last_coord.y {
    True -> [
    HorizontalEdge(first_coord.y, int.min(first_coord.x, last_coord.x), int.max(first_coord.x, last_coord.x)),
    ..horizontal_edges
    ]
    False -> horizontal_edges
  }

  res
  |> list.sort(fn(e1, e2) { int.compare(e1.y, e2.y) })
}

fn coord_is_inside(coord: Coord, vertical_edges: List(VerticalEdge)) -> Bool {
  vertical_edges
  |> list.fold_until(Out, fn(state, edge) {
    case coord.x <= edge.x && state == In {
      True -> list.Stop(state)
      False -> list.Continue(
        case edge.bottom >= coord.y && edge.top <= coord.y {
          True if edge.bottom == coord.y -> {
            case state {
              In -> TopEdge
              Out -> BottomEdge
              TopEdge -> In
              BottomEdge -> Out
            }
          }
          True if edge.top == coord.y -> {
            case state {
              In -> BottomEdge
              Out -> TopEdge
              TopEdge -> Out
              BottomEdge -> In
            }
          }
          True -> case state {
            Out -> In
            In -> Out
            _ -> Out
          }
          False -> state
        }
      )
    }
  }) != Out
}

fn edge_crosses_rect(corner1: Coord, corner2: Coord, ver_edges: List(VerticalEdge), hor_edges: List(HorizontalEdge)) -> Bool {
  let top_left = Coord(int.min(corner1.x, corner2.x), int.min(corner1.y, corner2.y))
  let bottom_right = Coord(int.max(corner1.x, corner2.x), int.max(corner1.y, corner2.y))

  ver_edges
  |> list.any(fn(ver_edge) {
    top_left.x < ver_edge.x
    && ver_edge.x < bottom_right.x
    && ver_edge.bottom > top_left.y
    && ver_edge.top < bottom_right.y
  })
  ||
  hor_edges
  |> list.any(fn(hor_edge) {
    top_left.y < hor_edge.y
    && hor_edge.y < bottom_right.y
    && hor_edge.right > top_left.x
    && hor_edge.left < bottom_right.x
  })
}