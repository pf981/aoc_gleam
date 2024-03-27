import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Symbol {
  Symbol(String)
  Number(Int)
}

// Letter, #(row, col),  number
// Actually, this won't work... It needs to SEE the other lines..
// fn parse_line(line: String, row: Int) -> List(#(Symbol, Int)) {
//   []
// }

// input
// |> string.split("\n")
// |> list.index_map(parse_line)
// |> list.flatten
// |> list.fold(dict.new(), fn(acc, pair) {
//   let #(symbol, num) = pair
//   case dict.get(acc, symbol) {
//     Ok(l) -> dict.insert(acc, symbol, [num, ..l])
//     Error(_) -> acc
//   }
// })

// fn extract_part_numbers(
//   m: Dict(#(Int, Int), Symbol),
// ) -> List(#(Symbol, List(Int))) {
//   let n_cols =
//     dict.keys(m)
//     |> list.map(pair.second)
//     |> list.fold(0, int.max)

//   let n_rows =
//     dict.keys(m)
//     |> list.map(pair.first)
//     |> list.fold(0, int.max)

//   []
// }

// fn parse(input: String) -> Dict(#(Int, Int), Symbol) {
//   input
//   |> string.split("\n")
//   |> list.index_map(fn(line, row) {
//     line
//     |> string.to_graphemes
//     |> list.index_map(fn(c, col) {
//       let value = case c {
//         "1" -> Ok(Number(1))
//         "2" -> Ok(Number(2))
//         "3" -> Ok(Number(3))
//         "4" -> Ok(Number(4))
//         "5" -> Ok(Number(5))
//         "6" -> Ok(Number(6))
//         "7" -> Ok(Number(7))
//         "8" -> Ok(Number(8))
//         "9" -> Ok(Number(9))
//         "0" -> Ok(Number(0))
//         "." -> Error(Nil)
//         _ -> Ok(Symbol(c))
//       }
//       case value {
//         Error(_) -> Error(Nil)
//         Ok(val) -> Ok(#(#(row, col), val))
//       }
//     })
//     |> result.values
//   })
//   |> list.flatten
//   |> dict.from_list
// }

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

fn get_neighbour_symbols(
  row: int,
  col: Int,
  m: List(List(String)),
) -> Set(#(Int, Int)) {
  todo
}

fn extract_part_numbers(m: List(List(String))) -> List(#(String, List(Int))) {
  m
  |> list.index_map(fn(line, row) {
    line
    |> list.index_fold(#([], 0, set.new()), fn(acc, c, col) {
      let #(acc, cur, neighbours) = acc
      case to_digit(c) {
        Ok(num) -> #(
          acc,
          cur * 10 + num,
          set.union(neighbours, get_neighbour_symbols(row, col, m)),
        )
        Error(Nil) -> #([#(cur, neighbours), ..acc], 0, set.new())
      }
    })
  })
  []
}

// acc is #(l, cur)
// where cur is (num, [neighbor symbol positions])
// l is (num, [neighbor symbol positions])

fn solve(input: String, f: fn(#(String, List(Int))) -> Int) -> Int {
  input
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> extract_part_numbers
  |> list.map(f)
  |> int.sum
  0
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
