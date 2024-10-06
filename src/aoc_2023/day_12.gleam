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
  // io.debug(report.contiguous_damaged)
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

// fn count_arrangements_impl(
//   report: Report,
//   cache: Dict(Report, Int),
// ) -> #(Int, Dict(Report, Int)) {
//   use <- memoize(report, cache)
//   let f = count_arrangements_impl

//   case report.conditions, report.contiguous_damaged {
//     [], [] -> 1
//     [], _ -> 0
//     [Damaged, ..], [] -> 0
//     [Damaged, ..rest], [contiguous_damaged_first, ..contiguous_damaged] -> {
//       case split_first(rest, contiguous_damaged_first - 1) {
//         Ok(#(conditions1, conditions2)) ->
//           case list.all(conditions1, fn(c) { c == Damaged || c == Unknown }) {
//             True ->
//               case conditions2 {
//                 [] | [Operational, ..] ->
//                   f(Report(conditions2, contiguous_damaged))
//                 [Unknown, ..rest] ->
//                   f(Report([Operational, ..rest], contiguous_damaged))
//                 _ -> 0
//               }
//             False -> 0
//           }
//         Error(Nil) -> 0
//       }
//     }
//     [Operational, ..rest], contiguous_damaged ->
//       f(Report(rest, contiguous_damaged))
//     [Unknown, ..rest], contiguous_damaged ->
//       f(Report([Damaged, ..rest], contiguous_damaged))
//       + f(Report([Operational, ..rest], contiguous_damaged))
//   }
// }
// fn count_arrangements_impl(
//   report: Report,
//   cache: Dict(Report, Int),
// ) -> #(Int, Dict(Report, Int)) {
//   use <- memoize(report, cache)
//   let f = fn(report) { count_arrangements_impl(report, cache).0 }
//   // FIXME: NEED TO ADD TO CACHE
//   // io.debug(report)

//   case report.conditions, report.contiguous_damaged {
//     [], [] -> 1
//     [], _ -> 0
//     [Damaged, ..], [] -> 0
//     [Damaged, ..rest], [contiguous_damaged_first, ..contiguous_damaged] -> {
//       case split_first(rest, contiguous_damaged_first - 1) {
//         Ok(#(conditions1, conditions2)) ->
//           case list.all(conditions1, fn(c) { c == Damaged || c == Unknown }) {
//             True ->
//               case conditions2 {
//                 [] | [Operational, ..] ->
//                   f(Report(conditions2, contiguous_damaged))
//                 [Unknown, ..rest] ->
//                   f(Report([Operational, ..rest], contiguous_damaged))
//                 _ -> 0
//               }
//             False -> 0
//           }
//         Error(Nil) -> 0
//       }
//     }
//     [Operational, ..rest], contiguous_damaged ->
//       f(Report(rest, contiguous_damaged))
//     [Unknown, ..rest], contiguous_damaged ->
//       f(Report([Damaged, ..rest], contiguous_damaged))
//       + f(Report([Operational, ..rest], contiguous_damaged))
//   }
// }

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

fn memoize(key: a, cache: Dict(a, b), f: fn() -> b) -> #(b, Dict(a, b)) {
  case dict.get(cache, key) {
    Ok(value) -> #(value, cache)
    Error(Nil) -> {
      let value = f()
      #(value, dict.insert(cache, key, value))
    }
  }
}

// How to use memoize
// fn fib(n: Int, cache: Dict(Int, Int)) -> #(Int, Dict(Int, Int)) {
//   use <- memoize(n, cache)
//   let f = fn(n) { fib(n, cache).0 }
//   case n {
//     0 -> 0
//     1 -> 1
//     n -> f(n - 1) + f(n - 2) // FIXME: This wouldn't update cache for n-1 and n-2 etc
//   }
// }
fn fib(n: Int) -> Int {
  fib_impl(n, dict.from_list([#(0, 0), #(1, 1)])).0
}

fn fib_impl(n: Int, cache: Dict(Int, Int)) -> #(Int, Dict(Int, Int)) {
  let #(prev, cache) = fib_impl(n - 1, cache)
  let #(prev2, cache) = fib_impl(n - 2, cache)
  let value = prev + prev2
  let cache = dict.insert(cache, n, value)
  #(value, cache)
}
// Could either return value or cache

// fn update_cache(n: Int, cache: Dict(Int, Int)) -> Dict(Int, Int) {
//   case dict.get(cache, n) {
//     Ok(value) -> cache
//     Error(Nil) -> {
//       let cache = update_cache(n - 1, cache)
//       let cache = update_cache(n - 2, cache)
//       let cache =
//         dict.insert(
//           cache,
//           n,
//           dict.get(cache, n).value + dict.get(cache, n - 1).value,
//         )
//       cache
//     }
//   }
// }
