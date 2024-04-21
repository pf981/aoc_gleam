import gleam/int
import gleam/list
import gleam/order.{type Order}
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

pub fn pt_1(plays: Result(List(Play), Error)) -> Result(Int, Error) {
  use plays <- result.map(plays)
  plays
  |> list.map(score)
  |> list.sort(fn(pair1, pair2) { int.compare(pair1.1, pair2.1) })
  |> list.index_map(fn(pair, i) { i * { pair.0 }.bid })
  |> int.sum
  // plays
  // |> list.sort(compare_play)
  // |> list.index_map(fn(play, i) { i * play.bid })
  // |> int.sum
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
      "A" -> Ok(14)
      "K" -> Ok(13)
      "Q" -> Ok(12)
      "J" -> Ok(11)
      "T" -> Ok(10)
      "9" -> Ok(9)
      "8" -> Ok(8)
      "7" -> Ok(7)
      "6" -> Ok(6)
      "5" -> Ok(5)
      "4" -> Ok(4)
      "3" -> Ok(3)
      "2" -> Ok(2)
      _ -> Error(ParseError("Hand contains unknown character"))
    }
  })
  |> result.all
}

fn count(hand: Hand) -> #(Int, Int, Int, Int, Int) {
  todo
}

fn get_primary_score(hand: Hand) -> Int {
  case count(hand) {
    #(1, 1, 1, 1, 1) -> 0
    #(2, 1, 1, 1, 0) -> 1
    #(2, 2, 1, 0, 0) -> 2
    #(3, 1, 1, 0, 0) -> 3
    #(3, 2, 0, 0, 0) -> 4
    #(4, 1, 0, 0, 0) -> 5
    #(5, 0, 0, 0, 0) -> 6
    _ -> panic
  }
}

fn get_secondary_score(acc: Int, hand: Hand) -> Int {
  case hand {
    [] -> acc
    [first, ..rest] -> get_secondary_score(10 * acc + first, rest)
  }
}

fn score(play: Play) -> #(Play, Int) {
  let primary_score = get_primary_score(play.hand)
  let secondary_score = get_secondary_score(0, play.hand)

  #(play, 1_000_000 * primary_score + secondary_score)
}
// fn play_comparer(cmp: fn(Hand, Hand) -> Order) -> fn(Play, Play) -> Order {
//   fn(a: Play, b: Play) { cmp(a.hand, b.hand) }
// }

// fn compare_play(a: Play, b: Play) -> Order {
//   compare_hand(a.hand, b.hand)
// }

// fn compare_hand(a: Hand, b: Hand) -> Order {
//   todo
// }
