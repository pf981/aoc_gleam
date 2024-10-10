import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

pub fn parse(input: String) -> Dict(String, String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(node_pair) =
      line
      |> string.split_once(")")
    pair.swap(node_pair)
  })
  |> dict.from_list
}

pub fn pt_1(orbits: Dict(String, String)) {
  let nodes =
    set.union(
      orbits |> dict.keys() |> set.from_list,
      orbits |> dict.values() |> set.from_list,
    )
    |> set.to_list

  nodes |> list.map(count_orbits(_, orbits)) |> int.sum
}

pub fn pt_2(orbits: Dict(String, String)) {
  let san_path = path_to_com("SAN", orbits, 0, dict.new())
  let you_path = path_to_com("YOU", orbits, 0, dict.new())

  let assert Ok(d) =
    san_path
    |> dict.map_values(fn(node, san_d) {
      you_path
      |> dict.get(node)
      |> result.map(fn(you_d) { you_d + san_d })
    })
    |> dict.values
    |> result.values
    |> list.reduce(int.min)

  d - 2
}

fn count_orbits(node: String, orbits: Dict(String, String)) -> Int {
  case dict.get(orbits, node) {
    Error(Nil) -> 0
    Ok(child) -> 1 + count_orbits(child, orbits)
  }
}

fn path_to_com(
  node: String,
  orbits: Dict(String, String),
  d: Int,
  path: Dict(String, Int),
) -> Dict(String, Int) {
  case dict.get(orbits, node) {
    Error(Nil) -> path
    Ok(child) -> path_to_com(child, orbits, d + 1, path |> dict.insert(node, d))
  }
}
