import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type Error {
  ParseError(message: String)
}

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

pub type Overlap {
  None
  Left
  Right
  Middle
  Full
}

pub fn overlap(a: Range, b: Range) -> Overlap {
  case a.start < b.start, a.end < b.start, a.start > b.end, a.end > b.end {
    True, True, _, _ -> None
    _, _, True, True -> None
    True, False, _, False -> Right
    False, False, False, True -> Left
    True, _, _, True -> Middle
    False, False, False, False -> Full
    _, _, _, _ -> panic
  }
}

fn split_range(range: Range, b: Map) -> #(Range, List(Range)) {
  case b {
    Map([]) -> #(range, [])
    Map([first, ..rest]) -> {
      case overlap(range, first) {
        None -> split_range(range, Map(rest))
        Left -> #(Range(range.start, first.end, range.offset + first.offset), [
          Range(first.end + 1, range.end, range.offset),
        ])
        Right -> #(Range(first.start, range.end, range.offset + first.offset), [
          Range(range.start, first.start - 1, range.offset),
        ])
        Middle -> #(Range(..first, offset: range.offset + first.offset), [
          Range(range.start, first.start - 1, range.offset),
          Range(first.end + 1, range.end, range.offset),
        ])
        Full -> #(Range(..range, offset: range.offset + first.offset), [])
      }
    }
  }
}

fn reducer_impl(a: Map, b: Map, acc: Map) -> Map {
  case a {
    Map([]) -> acc
    Map([first, ..rest]) -> {
      let #(mapped, remaining) = split_range(first, b)
      reducer_impl(
        Map(list.append(rest, remaining)),
        b,
        Map([mapped, ..acc.ranges]),
      )
    }
  }
}

fn reducer(a: Map, b: Map) -> Map {
  reducer_impl(a, b, Map([]))
}

fn find_lowest(maps: List(Map)) -> Int {
  let Map(ranges) =
    maps
    |> list.reduce(reducer)
    |> io.debug
    |> result.unwrap(Map([]))

  ranges
  |> list.map(fn(range) { range.start + range.offset })
  // |> io.debug
  |> list.reduce(int.min)
  |> result.unwrap(0)
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
