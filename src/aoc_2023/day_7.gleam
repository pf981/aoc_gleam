import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub type Error {
  ParseError(message: String)
  InvalidHand
}

pub type Hand =
  List(Int)

pub type Play {
  Play(hand: Hand, bid: Int)
}

pub fn parse(input: String) -> Result(List(Play), Error) {
  string.split(input, "\n")
  |> list.map(parse_play)
  |> result.all
}

pub fn pt_1(plays: Result(List(Play), Error)) -> Result(Int, Error) {
  result.try(plays, calculate_winnings(_, standard_score))
}

pub fn pt_2(plays: Result(List(Play), Error)) -> Result(Int, Error) {
  result.try(plays, calculate_winnings(_, jokers_wild_score))
}

type HandType {
  HighCard
  OnePair
  TwoPair
  ThreeOfAKind
  FullHouse
  FourOfAKind
  FiveOfAKind
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

fn calculate_winnings(
  plays: List(Play),
  scorer: fn(Play) -> Result(#(Play, Int), Error),
) -> Result(Int, Error) {
  use scores <- result.map(
    plays
    |> list.map(scorer)
    |> result.all,
  )

  scores
  |> list.sort(fn(pair1, pair2) { int.compare(pair1.1, pair2.1) })
  |> list.index_map(fn(pair, i) { { i + 1 } * { pair.0 }.bid })
  |> int.sum
}

fn get_hand_type(hand: Hand) -> Result(HandType, Error) {
  let counts =
    list.fold(hand, dict.new(), fn(acc, el) {
      dict.update(acc, el, fn(value) { option.unwrap(value, 0) + 1 })
    })
    |> dict.values
    |> list.sort(int.compare)

  case counts {
    [1, 1, 1, 1, 1] -> Ok(HighCard)
    [1, 1, 1, 2] -> Ok(OnePair)
    [1, 2, 2] -> Ok(TwoPair)
    [1, 1, 3] -> Ok(ThreeOfAKind)
    [2, 3] -> Ok(FullHouse)
    [1, 4] -> Ok(FourOfAKind)
    [5] -> Ok(FiveOfAKind)
    _ -> Error(InvalidHand)
  }
}

fn standard_score(play: Play) -> Result(#(Play, Int), Error) {
  use hand_type <- result.map(get_hand_type(play.hand))
  let primary_score = case hand_type {
    HighCard -> 0
    OnePair -> 1
    TwoPair -> 2
    ThreeOfAKind -> 3
    FullHouse -> 4
    FourOfAKind -> 5
    FiveOfAKind -> 6
  }
  let secondary_score = list.fold(play.hand, 0, fn(acc, el) { 100 * acc + el })

  #(play, 10_000_000_000 * primary_score + secondary_score)
}

fn jokers_wild_score(play: Play) -> Result(#(Play, Int), Error) {
  let play =
    Play(
      list.map(play.hand, fn(el) {
        case el == 11 {
          True -> 1
          False -> el
        }
      }),
      play.bid,
    )
  let jokers =
    play.hand
    |> list.filter(fn(el) { el == 1 })
    |> list.length

  use hand_type <- result.map(get_hand_type(play.hand))
  let primary_score = case hand_type, jokers {
    HighCard, 0 -> 0
    OnePair, 0 | HighCard, _ -> 1
    TwoPair, 0 -> 2
    ThreeOfAKind, 0 | OnePair, _ -> 3
    FullHouse, 0 | TwoPair, 1 -> 4
    FourOfAKind, 0 | ThreeOfAKind, _ | TwoPair, _ -> 5
    _, _ -> 6
  }
  let secondary_score = list.fold(play.hand, 0, fn(acc, el) { 100 * acc + el })

  #(play, 10_000_000_000 * primary_score + secondary_score)
}
