import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Symbol {
  Symbol(c: String, row: Int, col: Int)
}

fn to_digit(c: String) -> Result(Int, Nil) {
  case c {
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    "0" -> Ok(0)
    _ -> Error(Nil)
  }
}

// Note: No symbols on the edge
fn extract_parts(grid: List(List(String))) -> Dict(Symbol, List(Int)) {
  grid
  |> list.window(3)
  dict.new()
}

fn solve(input: String, f: fn(Symbol, List(Int)) -> Int) -> Int {
  input
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> extract_parts
  |> dict.map_values(f)
  |> dict.values
  |> int.sum
}

pub fn pt_1(input: String) {
  solve(input, fn(_symbol, neighbors) { int.sum(neighbors) })
}

pub fn pt_2(input: String) {
  solve(input, fn(symbol, neighbors) {
    case symbol.c, neighbors {
      "*", [a, b] -> a * b
      _, _ -> 0
    }
  })
}
