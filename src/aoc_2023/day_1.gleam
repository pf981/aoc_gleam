import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn first_value(line: String, m: List(#(String, String))) -> Result(String, Nil) {
  case line {
    "" -> Error(Nil)
    _ ->
      m
      |> list.drop_while(fn(key_value) {
        !string.starts_with(line, key_value.0)
      })
      |> list.first()
      |> result.map(fn(key_value) { key_value.1 })
      |> result.try_recover(fn(_) { first_value(string.drop_left(line, 1), m) })
  }
}

fn calibration_value(
  line: String,
  m: List(#(String, String)),
) -> Result(Int, Nil) {
  let m_rev =
    m
    |> list.map(fn(key_value) { #(string.reverse(key_value.0), key_value.1) })

  case first_value(line, m), first_value(string.reverse(line), m_rev) {
    Ok(first), Ok(last) -> int.parse(first <> last)
    _, _ -> Error(Nil)
  }
}

pub fn pt_1(input: String) -> Result(Int, Nil) {
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

  input
  |> string.split("\n")
  |> list.map(calibration_value(_, m))
  |> result.all()
  |> result.map(int.sum)
}

pub fn pt_2(input: String) -> Result(Int, Nil) {
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
    #("one", "1"),
    #("two", "2"),
    #("three", "3"),
    #("four", "4"),
    #("five", "5"),
    #("six", "6"),
    #("seven", "7"),
    #("eight", "8"),
    #("nine", "9"),
  ]

  input
  |> string.split("\n")
  |> list.map(calibration_value(_, m))
  |> result.all()
  |> result.map(int.sum)
}
