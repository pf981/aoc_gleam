import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/pair
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
    nodes: Dict(#(String, Direction), String),
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

pub fn pt_1(instructions: Result(Instructions, Error)) -> Result(Int, Error) {
  use instructions <- result.map(instructions)
  get_steps(instructions, "AAA")
}

pub fn pt_2(instructions: Result(Instructions, Error)) -> Result(Int, Error) {
  use instructions <- result.map(instructions)

  let start_nodes =
    instructions.nodes
    |> dict.keys
    |> list.map(pair.first)
    |> list.filter(string.ends_with(_, "A"))
    |> list.unique

  let steps = list.map(start_nodes, get_steps(instructions, _))

  list.fold(steps, 1, lcm)
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

fn parse_nodes(s: String) -> Result(Dict(#(String, Direction), String), Error) {
  use re <- result.try(
    regex.from_string("[A-Z]{3}")
    |> result.replace_error(RegexError),
  )

  s
  |> string.split("\n")
  |> list.flat_map(fn(line) {
    case regex.scan(re, line) {
      [label, left, right] -> [
        Ok(#(#(label.content, Left), left.content)),
        Ok(#(#(label.content, Right), right.content)),
      ]
      _ -> [Error(ParseError("Unable to parse node"))]
    }
  })
  |> result.all
  |> result.map(dict.from_list)
}

fn get_steps(instructions: Instructions, node: String) -> Int {
  instructions.directions
  |> iterator.from_list
  |> iterator.cycle
  |> iterator.fold_until(#(node, 0), fn(pair: #(String, Int), direction) {
    let #(node, steps) = pair
    case string.ends_with(node, "Z") {
      True -> list.Stop(pair)
      False -> {
        let new_node =
          instructions.nodes
          |> dict.get(#(node, direction))
          |> result.unwrap("")
        list.Continue(#(new_node, steps + 1))
      }
    }
  })
  |> pair.second
}

fn gcd(a: Int, b: Int) -> Int {
  case a == 0 {
    True -> b
    False -> {
      // Assert is safe as a != 0
      let assert Ok(c) = int.modulo(b, a)
      gcd(c, a)
    }
  }
}

pub fn lcm(a: Int, b: Int) -> Int {
  a * b / gcd(a, b)
}
