import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type Report {
  Report(conditions: List(Condition), contiguous_damaged: List(Int))
}

pub type Condition {
  Operational
  Damaged
  Unknown
}

pub fn parse(input: String) -> List(Report) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [conditions_str, contiguous_damaged_str] =
      string.split(line, " ")
    let conditions =
      string.to_graphemes(conditions_str)
      |> list.map(fn(s) {
        case s {
          "." -> Operational
          "#" -> Damaged
          "?" -> Unknown
          _ -> panic
        }
      })
    let contiguous_damaged =
      string.split(contiguous_damaged_str, ",")
      |> list.map(fn(s) { int.parse(s) |> result.unwrap(0) })
    Report(conditions, contiguous_damaged)
  })
}

pub fn pt_1(reports: List(Report)) {
  // io.debug(reports)
  reports |> list.map(count_arrangements) |> io.debug |> int.sum
}

pub fn pt_2(reports: List(Report)) {
  todo as "part 2 not implemented"
}

fn count_arrangements(report: Report) -> Int {
  // count_arrangements_impl(report, dict.new()).0
  let x = count_arrangements_impl(report, dict.new())
  // io.debug(x)
  x.0
}

fn count_arrangements_impl(
  report: Report,
  cache: Dict(Report, Int),
) -> #(Int, Dict(Report, Int)) {
  use <- memoize(report, cache)
  let f = fn(report) { count_arrangements_impl(report, cache).0 }

  case report.conditions, report.contiguous_damaged {
    [], [] -> 1
    [], _ -> 0
    [Damaged, ..], [] -> 0
    [Damaged, ..rest], [contiguous_damaged_first, ..contiguous_damaged] -> {
      case split_first(rest, contiguous_damaged_first - 1) {
        Ok(#(conditions1, conditions2)) ->
          case list.all(conditions1, fn(c) { c == Damaged || c == Unknown }) {
            True ->
              case conditions2 {
                [] | [Operational, ..] ->
                  f(Report(conditions2, contiguous_damaged))
                [Unknown, ..rest] ->
                  f(Report([Operational, ..rest], contiguous_damaged))
                _ -> 0
              }
            False -> 0
          }
        Error(Nil) -> 0
      }
    }
    [Operational, ..rest], contiguous_damaged ->
      f(Report(rest, contiguous_damaged))
    [Unknown, ..rest], contiguous_damaged ->
      f(Report([Damaged, ..rest], contiguous_damaged))
      + f(Report([Operational, ..rest], contiguous_damaged))
  }
}

fn split_first(l: List(a), n: Int) -> Result(#(List(a), List(a)), Nil) {
  // io.debug(#(l, n))
  split_first_impl([], l, n)
  //|> io.debug
}

fn split_first_impl(
  l1: List(a),
  l2: List(a),
  n: Int,
) -> Result(#(List(a), List(a)), Nil) {
  use <- bool.guard(n == 0, Ok(#(list.reverse(l1), l2)))
  case l2 {
    [first, ..rest] -> split_first_impl([first, ..l1], rest, n - 1)
    [] -> Error(Nil)
  }
}

fn memoize(key: a, cache: Dict(a, b), f: fn() -> b) -> #(b, Dict(a, b)) {
  case dict.get(cache, key) {
    Ok(value) -> #(value, cache)
    Error(Nil) -> {
      let value = f()
      #(value, dict.insert(cache, key, value))
    }
  }
}
// // How to use memoize
// fn fib(n: Int, cache: Dict(Int, Int)) -> #(Int, Dict(Int, Int)) {
//   use <- memoize(n, cache)
//   let f = fn(n) { fib(n, cache).0 }
//   case n {
//     0 -> 0
//     1 -> 1
//     n -> f(n - 1) + f(n - 2)
//   }
// }
