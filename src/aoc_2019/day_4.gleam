import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  let assert [Ok(min), Ok(max)] =
    input
    |> string.split("-")
    |> list.map(int.parse)
  list.range(min, max)
  |> list.map(fn(num) {
    let assert Ok(digits) = num |> int.digits(10)
    digits
  })
}

pub fn pt_1(candidates: List(List(Int))) -> Int {
  candidates |> list.filter(satisfies_criteria) |> list.length
}

pub fn pt_2(candidates: List(List(Int))) -> Int {
  candidates
  |> list.map(remove_triples)
  |> list.filter(satisfies_criteria)
  |> list.length
}

fn satisfies_criteria(digits: List(Int)) -> Bool {
  let pairs = digits |> list.window_by_2
  let contains_double = pairs |> list.any(fn(pair) { pair.0 == pair.1 })
  let non_decreasing = pairs |> list.all(fn(pair) { pair.0 <= pair.1 })

  contains_double && non_decreasing
}

fn remove_triples(digits: List(Int)) -> List(Int) {
  case digits {
    [] -> []
    [first, second, third, ..rest] if first == second && first == third -> [
      first,
      ..remove_triples(list.drop_while(rest, fn(num) { num == first }))
    ]
    [first, ..rest] -> [first, ..remove_triples(rest)]
  }
}
