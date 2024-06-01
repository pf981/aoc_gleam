import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/regex
import gleam/result
import gleam/string

pub type Error {
  ParseError(message: String)
  RegexError
}

pub type Instructions {
  Instructions(
    directions: List(Direction),
    nodes: Dict(String, #(String, String)),
  )
}

pub type Direction {
  Left
  Right
}

pub fn parse(input: String) -> Result(Instructions, Error) {
  case string.split(input, "\n\n") {
    [directions_string, nodes_string] -> {
      use directions <- result.try(parse_directions(directions_string))
      use nodes <- result.try(parse_nodes(nodes_string))
      Ok(Instructions(directions, nodes))
    }
    _ -> Error(ParseError("Unable to split input into directions and nodes"))
  }
}

import gleam/io

pub fn pt_1(instructions: Result(Instructions, Error)) -> Result(Int, Error) {
  use instructions <- result.map(instructions)

  io.debug(instructions)
  0
}

pub fn pt_2(instructions: Result(Instructions, Error)) {
  use instructions <- result.map(instructions)

  io.debug(instructions)
  0
}

fn parse_directions(s: String) -> Result(List(Direction), Error) {
  s
  |> string.to_graphemes
  |> list.map(fn(c) {
    case c {
      "L" -> Ok(Left)
      "R" -> Ok(Right)
      _ -> Error(ParseError("Unexpected direction character"))
    }
  })
  |> result.all
}

fn parse_nodes(s: String) -> Result(Dict(String, #(String, String)), Error) {
  use re <- result.try(
    regex.from_string("[A-Z]{3}")
    |> result.replace_error(RegexError),
  )

  s
  |> string.split("\n")
  |> list.map(fn(line) {
    case regex.scan(re, line) {
      [label, left, right] ->
        Ok(#(label.content, #(left.content, right.content)))
      _ -> Error(ParseError("Unable to parse node"))
    }
  })
  |> result.all
  |> result.map(dict.from_list)
}
