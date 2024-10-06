import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(Int) {
  input
  |> string.split("\n")
  |> list.map(fn(s) { int.parse(s) |> result.unwrap(0) })
}

pub fn pt_1(fuel_needed: List(Int)) {
  fuel_needed |> list.map(fn(fuel) { fuel / 3 - 2 }) |> int.sum
}

pub fn pt_2(fuel_needed: List(Int)) {
  fuel_needed |> list.map(get_total_fuel(_, 0)) |> int.sum
}

fn get_total_fuel(fuel: Int, acc: Int) -> Int {
  let fuel = fuel / 3 - 2
  case fuel <= 0 {
    True -> acc
    False -> {
      get_total_fuel(fuel, acc + fuel)
    }
  }
}
