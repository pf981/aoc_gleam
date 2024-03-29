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

pub fn parse(input: String) -> Result(Almanac, Error) {
  case string.split(input, "\n\n") {
    [seed_line, ..maps_lines] -> {
      let seed = parse_seed(seed_line)
      let maps =
        maps_lines
        |> list.map(parse_map)
        |> result.all

      case seed, maps {
        Ok(seed), Ok(maps) -> Ok(Almanac(seed, maps))
        Error(e), _ | _, Error(e) -> Error(e)
      }
    }
    _ -> Error(ParseError("Unable to split input into seed and maps"))
  }
}

pub fn pt_1(almanac: Result(Almanac, Error)) -> Result(Int, Error) {
  use almanac <- result.map(almanac)
  almanac.seeds
  |> list.map(fn(start) { Range(start, start, 0) })
  |> Map
  |> list.prepend(almanac.maps, _)
  |> find_lowest
}

pub fn pt_2(almanac: Result(Almanac, Error)) -> Result(Int, Error) {
  use almanac <- result.map(almanac)
  almanac.seeds
  |> list.sized_chunk(2)
  |> list.map(fn(l) {
    let assert [start, length] = l
    Range(start, start + length - 1, 0)
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
  let start1 = a.start + a.offset
  let end1 = a.end + a.offset
  let start2 = b.start
  let end2 = b.end

  case start1 < start2, end1 < start2, start1 > end2, end1 > end2 {
    True, True, _, _ -> None
    _, _, True, True -> None
    True, False, _, False -> Right
    False, False, False, True -> Left
    True, _, _, True -> Middle
    False, False, False, False -> Full
    _, _, _, _ -> panic
  }
}

pub fn split_range(range: Range, b: Map) -> #(Range, List(Range)) {
  case b {
    Map([]) -> #(range, [])
    Map([first, ..rest]) -> {
      case overlap(range, first) {
        None -> split_range(range, Map(rest))
        Left -> #(
          Range(
            range.start,
            first.end - range.offset,
            range.offset + first.offset,
          ),
          [Range(first.end + 1 - range.offset, range.end, range.offset)],
        )
        Right -> #(
          Range(
            first.start - range.offset,
            range.end,
            range.offset + first.offset,
          ),
          [Range(range.start, first.start - 1 - range.offset, range.offset)],
        )
        Middle -> #(
          Range(
            first.start - range.offset,
            first.end - range.offset,
            offset: range.offset + first.offset,
          ),
          [
            Range(range.start, first.start - 1 - range.offset, range.offset),
            Range(first.end + 1 - range.offset, range.end, range.offset),
          ],
        )
        Full -> #(Range(..range, offset: range.offset + first.offset), [])
      }
    }
  }
}

pub fn reducer_impl(a: Map, b: Map, acc: Map) -> Map {
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

pub fn reducer(a: Map, b: Map) -> Map {
  // io.debug(#(a, b))
  reducer_impl(a, b, Map([]))
}

fn find_lowest(maps: List(Map)) -> Int {
  let Map(ranges) =
    maps
    |> list.reduce(reducer)
    |> result.unwrap(Map([]))

  ranges
  |> list.map(fn(range) { range.start + range.offset })
  |> list.reduce(int.min)
  |> result.unwrap(0)
}

fn parse_numbers(line: String) -> Result(List(Int), Error) {
  line
  |> string.split(" ")
  |> list.map(int.base_parse(_, 10))
  |> result.all
  |> result.replace_error(ParseError("Unable to parse numbers"))
}

fn parse_seed(line: String) -> Result(List(Int), Error) {
  line
  |> string.split_once(": ")
  |> result.map(pair.second)
  |> result.replace_error(ParseError("Unable to split seed line"))
  |> result.map(parse_numbers)
  |> result.flatten
}

fn parse_map(lines: String) -> Result(Map, Error) {
  lines
  |> string.split("\n")
  |> list.rest
  |> result.replace_error(ParseError("Map missing body"))
  |> result.map(list.map(_, fn(line) {
    case parse_numbers(line) {
      Ok([dest_start, start, length]) ->
        Ok(Range(start, start + length - 1, dest_start - start))
      Error(e) -> Error(e)
      Ok(_) -> Error(ParseError("Map line did not contain three numbers"))
    }
  }))
  |> result.map(result.all)
  |> result.flatten
  |> result.map(Map)
}
