import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) -> Result(List(Int), Nil) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
  |> result.all
}

pub fn pt_1(input: Result(List(Int), Nil)) -> Result(Int, Nil) {
  use wins <- result.map(input)

  wins
  |> list.map(fn(n) {
    case n {
      0 -> 0
      _ -> pow(2, n - 1)
    }
  })
  |> int.sum
}

pub fn pt_2(input: Result(List(Int), Nil)) -> Result(Int, Nil) {
  use wins <- result.map(input)
  count_scratchcards(wins, list.map(wins, fn(_) { 1 }), 0)
}

fn parse_numbers(s: String) -> Result(Set(Int), Nil) {
  s
  |> string.to_graphemes
  |> list.sized_chunk(3)
  |> list.map(string.concat)
  |> list.map(string.replace(_, " ", ""))
  |> list.map(int.base_parse(_, 10))
  |> result.all
  |> result.map(set.from_list)
}

fn parse_line(line: String) -> Result(Int, Nil) {
  use #(_, right) <- result.try(string.split_once(line, ": "))
  use #(left, right) <- result.try(string.split_once(right, " | "))

  use have <- result.try(parse_numbers(left))
  use want <- result.map(parse_numbers(right))

  set.intersection(have, want)
  |> set.size
}

fn pow(base: Int, exponent: Int) -> Int {
  case exponent % 2 == 0 {
    _ if exponent == 0 -> 1
    True -> {
      let half_exp = pow(base, exponent / 2)
      half_exp * half_exp
    }
    False -> {
      let half_exp = pow(base, { exponent - 1 } / 2)
      half_exp * half_exp * base
    }
  }
}

fn update_multipliers(
  multipliers: List(Int),
  mult: Int,
  n_wins: Int,
) -> List(Int) {
  case multipliers, n_wins {
    [], _ -> []
    _, 0 -> multipliers
    [first, ..rest], _ -> [
      first + mult,
      ..update_multipliers(rest, mult, n_wins - 1)
    ]
  }
}

fn count_scratchcards(wins: List(Int), multipliers: List(Int), acc: Int) -> Int {
  let mult =
    multipliers
    |> list.first
    |> result.unwrap(1)
  let multipliers =
    multipliers
    |> list.rest
    |> result.unwrap([])

  case wins {
    [] -> acc
    [first, ..rest] ->
      count_scratchcards(
        rest,
        update_multipliers(multipliers, mult, first),
        acc + mult,
      )
  }
}
