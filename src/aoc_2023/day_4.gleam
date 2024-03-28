import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

fn parse_numbers(s: String) -> Result(Set(Int), Nil) {
  s
  |> string.to_graphemes
  |> list.sized_chunk(3)
  |> list.map(string.concat)
  |> list.map(string.replace(_, " ", ""))
  |> list.map(int.base_parse(_, 10))
  |> result.all
  |> result.map(set.from_list)
  //   |> result.all
  //   |> result.map(set.from_list)
  //   |> string.split(" ")
  //   |> list.map(int.base_parse(_, 10))
  //   |> result.all
  //   |> result.map(set.from_list)
}

fn parse_line(line: String) -> Result(Int, Nil) {
  use #(_, right) <- result.try(string.split_once(line, ": "))
  io.debug(right)
  use #(left, right) <- result.try(string.split_once(right, " | "))

  use have <- result.try(parse_numbers(left))
  use want <- result.map(parse_numbers(right))

  set.intersection(have, want)
  |> set.size
}

fn parse(input: String) -> Result(List(Int), Nil) {
  input
  |> string.split("\n")
  // |> list.filter(fn(line) { line != "" })
  |> list.map(parse_line)
  |> io.debug
  |> result.all
}

fn pow(base: Int, exponent: Int) -> Int {
  // io.debug(#(base, exponent))
  case exponent % 2 == 0 {
    _ if exponent == 0 -> 1
    True -> {
      let half_exp = pow(base, exponent / 2)
      half_exp * half_exp
    }
    False -> {
      let half_exp = pow(base, { exponent - 1 } / 2)
      half_exp * half_exp * base
    }
  }
}

pub fn pt_1(input: String) -> Result(Int, Nil) {
  input
  |> parse
  |> result.map(list.map(_, fn(n) {
    case n {
      0 -> 0
      _ -> pow(2, n - 1)
    }
  }))
  |> result.map(int.sum)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

import gleam/io
