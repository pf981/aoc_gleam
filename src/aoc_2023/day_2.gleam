import gleam/int
import gleam/list
import gleam/regex
import gleam/result
import gleam/string

pub type Error {
  RegexError
  ParseError
}

fn extract_color(color: String, line: String) -> Result(Int, Error) {
  regex.from_string("\\d+(?= " <> color <> ")")
  |> result.replace_error(RegexError)
  |> result.try(fn(re) {
    regex.scan(re, line)
    |> list.map(fn(match) { int.base_parse(match.content, 10) })
    |> result.all
    |> result.replace_error(ParseError)
    |> result.map(list.fold(_, 0, int.max))
  })
}

fn parse_line(line: String) -> Result(#(Int, Int, Int), Error) {
  let rgb =
    ["red", "green", "blue"]
    |> list.map(extract_color(_, line))
    |> result.all

  case rgb {
    Ok([r, g, b]) -> Ok(#(r, g, b))
    _ -> Error(ParseError)
  }
}

fn parse(input: String) -> Result(List(#(Int, Int, Int)), Error) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
  |> result.all
}

fn solve(
  input: String,
  aggregate: fn(#(Int, Int, Int), Int) -> Int,
) -> Result(Int, Error) {
  input
  |> parse
  |> result.map(list.index_map(_, aggregate))
  |> result.map(int.sum)
}

pub fn pt_1(input: String) -> Result(Int, Error) {
  input
  |> solve(fn(rgb, i) {
    let #(r, g, b) = rgb
    case r <= 12 && g <= 13 && b <= 14 {
      True -> i + 1
      False -> 0
    }
  })
}

pub fn pt_2(input: String) {
  input
  |> solve(fn(rgb, _i) {
    let #(r, g, b) = rgb
    r * g * b
  })
}
