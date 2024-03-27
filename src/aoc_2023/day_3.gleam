import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Symbol {
  Symbol(character: String, row: Int, col: Int)
}

// Letter, #(row, col),  number
// Actually, this won't work... It needs to SEE the other lines..
fn parse_line(line: String, row: Int) -> List(#(Symbol, Int)) {
  // [#("", #(0, 0), 0)]
  []
}

fn parse(input: String) -> Dict(Symbol, List(Int)) {
  input
  |> string.split("\n")
  |> list.index_map(parse_line)
  |> list.flatten
  |> list.fold(dict.new(), fn(acc, pair) {
    let #(symbol, num) = pair
    case dict.get(acc, symbol) {
      Ok(l) -> dict.insert(acc, symbol, [num, ..l])
      Error(_) -> acc
    }
  })
}

fn solve(input: String, f: fn(#(Symbol, List(Int))) -> Int) -> Int {
  input
  |> parse
  |> dict.to_list
  |> list.map(f)
  |> int.sum
}

pub fn pt_1(input: String) {
  solve(input, fn(pair) { int.sum(pair.1) })
}

pub fn pt_2(input: String) {
  solve(input, fn(pair) {
    case pair {
      #(Symbol("*", ..), [a, b]) -> a * b
      _ -> 0
    }
  })
}
