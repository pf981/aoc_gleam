import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type Range {
  Range(start: Int, end: Int, offset: Int)
}

pub type Map {
  Map(ranges: List(Range))
}

pub type Almanac {
  Almanac(seeds: List(Int), maps: List(Map))
}

import gleam/io

pub fn parse(input: String) -> Almanac {
  let #(seed_line, map_lines) =
    input
    |> string.split("\n\n")
    |> pop("")

  Almanac(parse_seed(seed_line), list.map(map_lines, parse_map))
}

pub fn pt_1(almanac: Almanac) -> Int {
  almanac
  |> io.debug
  almanac.seeds
  |> list.map(fn(start) { Range(start, start + 1, 0) })
  |> Map
  |> list.prepend(almanac.maps, _)
  |> find_lowest
}

pub fn pt_2(almanac: Almanac) -> Int {
  almanac.seeds
  |> list.sized_chunk(2)
  |> list.map(fn(l) {
    let assert [start, length] = l
    Range(start, start + length, 0)
  })
  |> Map
  |> list.prepend(almanac.maps, _)
  |> find_lowest
}

fn find_lowest(maps: List(Map)) -> Int {
  0
}

fn pop(l: List(a), default: a) -> #(a, List(a)) {
  case l {
    [first, ..rest] -> #(first, rest)
    [] -> #(default, [])
  }
}

fn parse_numbers(line: String) -> List(Int) {
  line
  |> string.split(" ")
  |> list.filter_map(int.base_parse(_, 10))
}

fn parse_seed(line: String) -> List(Int) {
  line
  |> string.split(": ")
  |> pop("")
  |> pair.second
  |> pop("")
  |> pair.first
  |> parse_numbers
}

fn parse_map(lines: String) -> Map {
  lines
  |> string.split("\n")
  |> pop("")
  |> pair.second
  |> list.filter_map(fn(line) {
    case parse_numbers(line) {
      [dest_start, start, length] ->
        Ok(Range(start, start + length, dest_start - start))
      _ -> Error(Nil)
    }
  })
  |> Map
}
