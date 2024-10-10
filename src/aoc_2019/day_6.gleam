import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import helpers/heap

pub type Node

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
  let transfers =
    dict.fold(orbits, dict.new(), fn(acc, a, b) {
      acc |> dict.insert(a, b) |> dict.insert(b, a)
    })
  // transfers[from_node].append(to_node)
  // transfers[to_node].append(from_node)
  todo as "part 2 not implemented"
}

fn count_orbits(node: String, orbits: Dict(String, String)) -> Int {
  case dict.get(orbits, node) {
    Error(Nil) -> 0
    Ok(child) -> 1 + count_orbits(child, orbits)
  }
}

fn bfs(transfers: Dict(String, List(String))) -> Int {
  todo
}
// import collections

// def count_orbits(node, orbits):
//   if node not in orbits:
//     return 1
//   return 1 + sum(count_orbits(child, orbits) for child in orbits[node])

// orbits = collections.defaultdict(list)
// transfers = collections.defaultdict(list)
// nodes = set()

// for line in inp.splitlines():
//   from_node, to_node = line.split(')')
//   orbits[from_node].append(to_node)
//   transfers[from_node].append(to_node)
//   transfers[to_node].append(from_node)
//   nodes.add(from_node)
//   nodes.add(to_node)

// answer = sum(count_orbits(node, orbits) for node in nodes) - len(nodes)
// print(answer)
