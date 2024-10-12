import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
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
  |> get_best
  |> list.length
}

pub fn pt_2(asteroids: List(Coord)) -> Int {
  let assert Ok(#(Coord(x, y), _)) =
    asteroids
    |> get_distances
    |> get_best
    |> list.map(pair.second)
    |> list.interleave
    |> list.drop(199)
    |> list.first

  100 * x + y
}

fn get_distances(
  asteroids: List(Coord),
) -> Dict(Coord, Dict(Float, List(#(Coord, Float)))) {
  asteroids
  |> full_combination_pairs
  |> list.fold(dict.new(), fn(acc, pair) {
    let #(p1, p2) = pair

    let dx = int.to_float(p2.x - p1.x)
    let dy = int.to_float(p2.y - p1.y)

    let assert Ok(r) = float.square_root(dx *. dx +. dy *. dy)
    let theta = atan2(dy, dx)
    let assert Ok(theta) = float.modulo(theta +. pi() /. 2.0, 2.0 *. pi())

    acc
    |> dict.upsert(p1, fn(maybe_distances) {
      case maybe_distances {
        Some(distances) -> distances
        None -> dict.new()
      }
      |> dict.upsert(theta, fn(maybe_rs) {
        case maybe_rs {
          Some(rs) ->
            [#(p2, r), ..rs] |> list.sort(fn(a, b) { float.compare(a.1, b.1) })
          None -> [#(p2, r)]
        }
      })
    })
  })
}

fn get_best(
  distances: Dict(Coord, Dict(Float, List(#(Coord, Float)))),
) -> List(#(Float, List(#(Coord, Float)))) {
  distances
  |> dict.fold(dict.new(), fn(acc, _p, distances) {
    case dict.size(distances) > dict.size(acc) {
      True -> distances
      False -> acc
    }
  })
  |> dict.to_list
  |> list.sort(fn(a, b) { float.compare(a.0, b.0) })
}

fn full_combination_pairs(l: List(a)) -> List(#(a, a)) {
  list.flat_map(l, fn(a) {
    list.map(l, fn(b) {
      case a == b {
        False -> Ok(#(a, b))
        True -> Error(Nil)
      }
    })
    |> result.values
  })
}

// gladvent only supports erlang, so not bothering with JS implementation
@external(erlang, "math", "atan2")
fn atan2(a: Float, b: Float) -> Float

@external(erlang, "math", "pi")
fn pi() -> Float
