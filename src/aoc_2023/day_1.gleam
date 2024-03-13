import gleam/dict
import gleam/io
import gleam/int
import gleam/list
import gleam/result
import gleam/string

// , m: dict.Dict(String, Int)
// let scores = dict.from_list([#("Lucy", 13), #("Drew", 15)])
// // for i, _ in enumerate(line):
// //   for text, val in m.items():
// //     if line[i:].startswith(text):
// //       return val
// line
// |> string.drop_left(1)
// fn first_value(line: String) -> Result(String, String) {
//   // case list.any(line, string.starts_with(_)) do
//   case line {
//     "" -> Error("Empty string")
//     "1" <> _ | "one" <> _ -> Ok("1")
//     "2" <> _ -> Ok("2")
//     "3" <> _ -> Ok("3")
//     "4" <> _ -> Ok("4")
//     "5" <> _ -> Ok("5")
//     "6" <> _ -> Ok("6")
//     "7" <> _ -> Ok("7")
//     "8" <> _ -> Ok("8")
//     "9" <> _ -> Ok("9")
//     _ -> first_value(string.drop_left(line, 1))
//   }
// }
// fn first_value(line: String, m: List(#(String, String))) {
//   let match = dict.filter(m, fn(key, _) { string.starts_with(line, key) })

//   m
//   |> list.take_while(string.starts_with(line, key))
//   |> list.first()

//   case dict.size(match) == 0 {
//     dict.Dict([#(1, 1)]) -> first_value(string.drop_left(line, 1), m)
//     dict.Dict([]) -> first_value(string.drop_left(line, 1), m)
//   }
//   // case list.any(dict.keys(m), fn(k) { string.starts_with(line, k) }) {
//   //   True -> dict.get(m, )
//   //   False -> first_value(string.drop_left(line, 1), m)
//   // }
// }
fn first_value(line: String, m: List(#(String, String))) {
  // io.debug(line)
  // case line {
  //   "" -> panic
  //   _ -> ""
  // }
  // io.debug(string.starts_with(line, "5"))
  // io.debug(result.unwrap(list.first(m), #("x", "x")).0)
  // io.debug(string.starts_with(line, result.unwrap(list.first(m), #("x", "x")).0))
  m
  |> list.take_while(fn(key_value) { string.starts_with(line, key_value.0) })
  |> list.first()
  |> result.map(fn(key_value) { key_value.1 })
  |> result.lazy_unwrap(fn() { first_value(string.drop_left(line, 1), m) })
}

fn calibration_value(line: String, m: List(#(String, String))) {
  first_value(line, m)
  // first_value(line) <> first_value(line)
}

// |> list.map(fn(line) { list.map(string.to_graphemes(line), int.parse) })
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
  |> list.take(1)
  |> list.map(calibration_value(_, m))
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
