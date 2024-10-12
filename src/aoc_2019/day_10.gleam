import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

pub type Coord {
  Coord(x: Int, y: Int)
}

pub fn parse(input: String) -> List(Coord) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(c, x) {
      case c {
        "#" -> Ok(Coord(x, y))
        _ -> Error(Nil)
      }
    })
    |> result.values
  })
  |> list.flatten
}

pub fn pt_1(asteroids: List(Coord)) -> Int {
  asteroids
  |> get_distances
  |> dict.values
  |> list.map(dict.size)
  |> list.fold(0, int.max)
}

pub fn pt_2(asteroids: List(Coord)) -> Int {
  todo
}

fn get_distances(
  asteroids: List(Coord),
) -> Dict(Coord, Dict(Float, List(Float))) {
  asteroids
  |> full_combination_pairs
  |> list.fold(dict.new(), fn(acc, pair) {
    let #(p1, p2) = pair

    let dx = int.to_float(p2.x - p1.x)
    let dy = int.to_float(p2.y - p1.y)

    let assert Ok(r) = float.square_root(dx *. dx +. dy *. dy)
    let theta = atan2(dy, dx)

    acc
    |> dict.upsert(p1, fn(maybe_distances) {
      case maybe_distances {
        Some(distances) -> distances
        None -> dict.new()
      }
      |> dict.upsert(theta, fn(maybe_rs) {
        case maybe_rs {
          Some(rs) -> [r, ..rs] |> list.sort(float.compare)
          None -> [r]
        }
      })
    })
  })
}

fn full_combination_pairs(list: List(a)) -> List(#(a, a)) {
  let pairs = list |> list.combination_pairs
  list.append(pairs, pairs |> list.map(pair.swap))
  |> set.from_list
  |> set.to_list
}

// gladvent only supports erlang, so not bothering with JS implementation
@external(erlang, "math", "atan2")
fn atan2(a: Float, b: Float) -> Float
