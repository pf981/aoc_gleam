import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set
import gleam/string

pub type Instruction {
  Instruction(direction: Direction, distance: Int)
}

pub type Direction {
  U
  R
  D
  L
}

pub fn parse(input: String) -> #(List(Instruction), List(Instruction)) {
  let assert [instructions1, instructions2] =
    input
    |> string.split("\n")
    |> list.map(parse_line)

  #(instructions1, instructions2)
}

pub fn pt_1(instructions: #(List(Instruction), List(Instruction))) -> Int {
  let points1 = get_points(instructions.0)
  let points2 = get_points(instructions.1)
  let intersections =
    set.intersection(
      points1 |> dict.keys |> set.from_list,
      points2 |> dict.keys |> set.from_list,
    )
  intersections
  |> set.fold(10_000_000, fn(acc, pos) {
    int.min(int.absolute_value(pos.0) + int.absolute_value(pos.1), acc)
  })
}

pub fn pt_2(instructions: #(List(Instruction), List(Instruction))) -> Int {
  let points1 = get_points(instructions.0)
  let points2 = get_points(instructions.1)
  let intersections =
    set.intersection(
      points1 |> dict.keys |> set.from_list,
      points2 |> dict.keys |> set.from_list,
    )
  intersections
  |> set.fold(10_000_000, fn(acc, pos) {
    let assert Ok(d1) = dict.get(points1, pos)
    let assert Ok(d2) = dict.get(points2, pos)
    int.min(d1 + d2, acc)
  })
}

fn parse_line(line: String) -> List(Instruction) {
  line |> string.split(",") |> list.map(parse_instruction)
}

fn parse_instruction(s: String) -> Instruction {
  let assert Ok(#(direction_str, distance_str)) = string.pop_grapheme(s)
  let assert Ok(distance) = int.parse(distance_str)
  let direction = case direction_str {
    "U" -> U
    "R" -> R
    "D" -> D
    "L" -> L
    _ -> panic
  }
  Instruction(direction, distance)
}

fn get_points(instructions: List(Instruction)) -> Dict(#(Int, Int), Int) {
  get_points_impl(instructions, dict.new(), 0, #(0, 0))
}

fn get_points_impl(
  instructions: List(Instruction),
  points: Dict(#(Int, Int), Int),
  d: Int,
  pos: #(Int, Int),
) -> Dict(#(Int, Int), Int) {
  case instructions {
    [] -> points
    [Instruction(direction, distance), ..rest] -> {
      let #(dr, dc) = case direction {
        U -> #(-1, 0)
        R -> #(0, 1)
        D -> #(1, 0)
        L -> #(0, -1)
      }
      let new_points =
        list.range(1, distance)
        |> list.map(fn(i) { #(#(pos.0 + dr * i, pos.1 + dc * i), d + i) })
        |> dict.from_list
      get_points_impl(rest, dict.merge(new_points, points), d + distance, #(
        pos.0 + dr * distance,
        pos.1 + dc * distance,
      ))
    }
  }
}
