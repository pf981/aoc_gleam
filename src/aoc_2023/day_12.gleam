import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
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
  reports |> list.map(count_arrangements) |> int.sum
}

pub fn pt_2(reports: List(Report)) {
  let reports =
    list.map(reports, fn(report) {
      let assert Ok(conditions) =
        [Unknown, ..report.conditions] |> x5 |> list.rest
      Report(conditions, x5(report.contiguous_damaged))
    })
  reports |> list.map(count_arrangements) |> int.sum
}

fn x5(l: List(a)) -> List(a) {
  list.range(0, 4)
  |> list.map(fn(_) { l })
  |> list.concat
}

fn count_arrangements(report: Report) -> Int {
  count_arrangements_impl(report, dict.new()).0
}

fn count_arrangements_impl(
  report: Report,
  cache: Dict(Report, Int),
) -> #(Int, Dict(Report, Int)) {
  case dict.get(cache, report) {
    Ok(value) -> #(value, cache)
    Error(Nil) -> {
      let f = count_arrangements_impl
      let cache_value = fn(value, cache) {
        #(value, dict.insert(cache, report, value))
      }

      case report.conditions, report.contiguous_damaged {
        [], [] -> cache_value(1, cache)
        [], _ -> cache_value(0, cache)
        [Damaged, ..], [] -> cache_value(0, cache)
        [Damaged, ..rest], [contiguous_damaged_first, ..contiguous_damaged] -> {
          case split_first(rest, contiguous_damaged_first - 1) {
            Ok(#(conditions1, conditions2)) ->
              case
                list.all(conditions1, fn(c) { c == Damaged || c == Unknown })
              {
                True ->
                  case conditions2 {
                    [] | [Operational, ..] ->
                      f(Report(conditions2, contiguous_damaged), cache)
                    [Unknown, ..rest] ->
                      f(
                        Report([Operational, ..rest], contiguous_damaged),
                        cache,
                      )
                    _ -> cache_value(0, cache)
                  }
                False -> cache_value(0, cache)
              }
            Error(Nil) -> cache_value(0, cache)
          }
        }
        [Operational, ..rest], contiguous_damaged ->
          f(Report(rest, contiguous_damaged), cache)
        [Unknown, ..rest], contiguous_damaged -> {
          let #(damaged, cache) =
            f(Report([Damaged, ..rest], contiguous_damaged), cache)
          let #(operational, cache) =
            f(Report([Operational, ..rest], contiguous_damaged), cache)
          cache_value(damaged + operational, cache)
        }
      }
    }
  }
}

fn split_first(l: List(a), n: Int) -> Result(#(List(a), List(a)), Nil) {
  split_first_impl([], l, n)
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
// // Example of memoization
// fn fib(n: Int) -> Int {
//   fib_impl(n, dict.from_list([#(0, 0), #(1, 1)])).0
// }
//
// fn fib_impl(n: Int, cache: Dict(Int, Int)) -> #(Int, Dict(Int, Int)) {
//   let f = fib_impl
//   let cache_value = fn(value, cache) { #(value, dict.insert(cache, n, value)) }
//   case dict.get(cache, n) {
//     Ok(value) -> #(value, cache)
//     Error(Nil) -> {
//       let #(prev, cache) = f(n - 1, cache)
//       let #(prev2, cache) = f(n - 2, cache)
//       cache_value(prev + prev2, cache)
//     }
//   }
// }
