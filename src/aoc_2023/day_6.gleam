import gleam/float
import gleam/int
import gleam/list
import gleam/regex
import gleam/result
import gleam/string

pub type Error {
  RegexError
  ParseError
  MathError
}

pub type Race {
  Race(time: Int, distance: Int)
}

pub fn parse_races(input: String) -> Result(List(Race), Error) {
  use re <- result.try(
    regex.from_string("\\d+")
    |> result.replace_error(RegexError),
  )

  let lines =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> regex.scan(re, _)
      |> list.map(fn(match) { int.base_parse(match.content, 10) })
      |> result.all
    })
    |> result.all

  case lines {
    Ok([first, second]) ->
      list.zip(first, second)
      |> list.map(fn(pair) { Race(pair.0, pair.1) })
      |> Ok()
    _ -> Error(ParseError)
  }
}

pub fn pt_1(input: String) -> Result(Int, Error) {
  input
  |> parse_races
  |> result.try(process_races)
}

pub fn pt_2(input: String) -> Result(Int, Error) {
  input
  |> string.replace(" ", "")
  |> parse_races
  |> result.try(process_races)
}

fn process_races(races: List(Race)) -> Result(Int, Error) {
  races
  |> list.map(count_ways)
  |> result.all
  |> result.map(int.product)
}

fn count_ways(race: Race) -> Result(Int, Error) {
  let Race(t, d) = race

  case float.square_root(int.to_float(t * t - 4 * -1 * -d)) {
    Ok(root) -> {
      let upper = { int.to_float(-t) -. root } /. 2.0 *. -1.0
      let lower = { int.to_float(-t) +. root } /. 2.0 *. -1.0
      Ok(float.truncate(float.ceiling(upper)) - float.truncate(lower) - 1)
    }
    Error(_) -> Error(MathError)
  }
}
