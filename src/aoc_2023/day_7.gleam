import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Hand =
  List(Int)

pub type Play {
  Play(hand: Hand, bid: Int)
}

pub type Error {
  ParseError(message: String)
}

pub fn parse(input: String) -> Result(List(Play), Error) {
  string.split(input, "\n")
  |> list.map(parse_play)
  |> result.all
}

pub fn pt_1(hands: Result(List(Play), Error)) -> Result(Int, Error) {
  use hands <- result.map(hands)
  1
}

pub fn pt_2(hands: Result(List(Play), Error)) -> Result(Int, Error) {
  use hands <- result.map(hands)
  1
}

fn parse_play(line: String) -> Result(Play, Error) {
  case string.split(line, " ") {
    [hand, bid] -> {
      use hand <- result.try(parse_hand(hand))
      use bid <- result.try(
        bid
        |> int.base_parse(10)
        |> result.replace_error(ParseError("")),
      )
      Ok(Play(hand, bid))
    }
    _ -> Error(ParseError("Unable to split line into hand and bid"))
  }
}

fn parse_hand(line: String) -> Result(Hand, Error) {
  string.to_graphemes(line)
  |> list.map(fn(c) {
    case c {
      "A" -> Ok(12)
      "K" -> Ok(11)
      "Q" -> Ok(0)
      "J" -> Ok(9)
      "T" -> Ok(8)
      "9" -> Ok(7)
      "8" -> Ok(6)
      "7" -> Ok(5)
      "6" -> Ok(4)
      "5" -> Ok(3)
      "4" -> Ok(2)
      "3" -> Ok(1)
      "2" -> Ok(0)
      _ -> Error(ParseError("Hand contains unknown character"))
    }
  })
  |> result.all
}
