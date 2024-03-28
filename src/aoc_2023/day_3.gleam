import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/result
import gleam/set
import gleam/string

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

fn find_left(
  grid: Dict(#(Int, Int), String),
  row: Int,
  col: Int,
) -> Result(Int, Nil) {
  use c <- result.try(dict.get(grid, #(row, col)))
  use _ <- result.try(to_digit(c))
  result.or(find_left(grid, row, col - 1), Ok(col))
}

fn get_number(
  grid: Dict(#(Int, Int), String),
  row: Int,
  col: Int,
) -> Result(Int, Nil) {
  use left <- result.map(find_left(grid, row, col))
  iterator.iterate(left, fn(col) { col + 1 })
  |> iterator.fold_until(0, fn(acc, new_col) {
    case dict.get(grid, #(row, new_col)) {
      Ok(c) ->
        case to_digit(c) {
          Ok(num) -> list.Continue(10 * acc + num)
          _ -> list.Stop(acc)
        }
      Error(Nil) -> list.Stop(acc)
    }
  })
}

fn get_neighbours(
  grid: Dict(#(Int, Int), String),
  row: Int,
  col: Int,
) -> List(Int) {
  [
    #(-1, -1),
    #(-1, 0),
    #(-1, 1),
    #(0, -1),
    #(0, 1),
    #(1, -1),
    #(1, -0),
    #(1, 1),
  ]
  |> list.filter_map(fn(pos) {
    let #(dr, dc) = pos
    get_number(grid, row + dr, col + dc)
  })
  |> set.from_list
  |> set.to_list
}

fn parse(input: String) -> Dict(#(Int, Int), String) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, row) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(c, col) { #(#(row, col), c) })
  })
  |> list.flatten
  |> dict.from_list
}

fn extract_parts(grid: Dict(#(Int, Int), String)) -> List(#(String, List(Int))) {
  grid
  |> dict.filter(fn(_key, value) { !string.contains("1234567890.", value) })
  |> dict.map_values(fn(key, value) {
    #(value, get_neighbours(grid, key.0, key.1))
  })
  |> dict.values
}

fn solve(input: String, f: fn(#(String, List(Int))) -> Int) -> Int {
  input
  |> parse
  |> extract_parts
  |> list.map(f)
  |> int.sum
}

pub fn pt_1(input: String) {
  solve(input, fn(pair) { int.sum(pair.1) })
}

pub fn pt_2(input: String) {
  solve(input, fn(pair) {
    case pair {
      #("*", [a, b]) -> a * b
      _ -> 0
    }
  })
}
