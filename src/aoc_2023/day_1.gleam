import gleam/dict
import gleam/io
import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn first_value(line: String, m: List(#(String, String))) -> String {
  case line {
    "" -> panic
    _ -> ""
  }
  m
  |> list.drop_while(fn(key_value) { !string.starts_with(line, key_value.0) })
  |> list.first()
  |> result.map(fn(key_value) { key_value.1 })
  |> result.lazy_unwrap(fn() { first_value(string.drop_left(line, 1), m) })
}

fn calibration_value(line: String, m: List(#(String, String))) {
  int.parse(first_value(line, m) <> first_value(string.reverse(line), m))
}

pub fn pt_1(input: String) {
  let m = [
    #("1", "1"),
    #("2", "2"),
    #("3", "3"),
    #("4", "4"),
    #("5", "5"),
    #("6", "6"),
    #("7", "7"),
    #("8", "8"),
    #("9", "9"),
  ]

  //   #("one", "1"),
  //   #("two", "2"),
  //   #("three", "3"),
  //   #("four", "4"),
  //   #("five", "5"),
  //   #("six", "6"),
  //   #("seven", "7"),
  //   #("eight", "8"),
  //   #("nine", "9"),
  input
  |> string.split("\n")
  //|> list.take(1)
  |> list.map(calibration_value(_, m))
  |> result.all()
  |> result.map(int.sum)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
