import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string

import gleam/io

pub type Grid {
  Grid(m: Dict(Pos, Pipe), dimensions: Pos)
}

pub type Pipe {
  NS
  EW
  NE
  NW
  SW
  SE
  Ground
  Start
}

pub type Pos {
  Pos(row: Int, col: Int)
}

pub type Heading {
  N
  E
  S
  W
}

pub fn parse(input: String) -> Grid {
  let lines = string.split(input, "\n")

  let m =
    list.index_fold(lines, dict.new(), fn(m, line, row) {
      line
      |> string.to_graphemes
      |> list.index_fold(m, fn(m, c, col) {
        dict.insert(m, Pos(row, col), to_pipe(c))
      })
    })

  let dimensions =
    Pos(
      list.length(lines),
      lines
        |> list.first
        |> result.unwrap("")
        |> string.length,
    )

  Grid(m, dimensions)
}

pub fn pt_1(grid: Grid) {
  let #(start_pos, heading) = get_start(grid)

  count_pipes(grid, start_pos, heading) / 2 + 1
}

pub fn pt_2(grid: Grid) {
  todo as "part 2 not implemented"
}

fn to_pipe(c: String) -> Pipe {
  case c {
    "|" -> NS
    "-" -> EW
    "L" -> NE
    "J" -> NW
    "7" -> SW
    "F" -> SE
    "S" -> Start
    _ -> Ground
  }
}

fn get_start(grid: Grid) -> #(Pos, Heading) {
  let assert Ok(Pos(row, col)) =
    grid.m
    |> dict.filter(fn(_, pipe) { pipe == Start })
    |> dict.keys
    |> list.first

  let heading = case
    dict.get(grid.m, Pos(row - 1, col)),
    dict.get(grid.m, Pos(row, col + 1)),
    dict.get(grid.m, Pos(row + 1, col)),
    dict.get(grid.m, Pos(row, col - 1))
  {
    Ok(NS), _, _, _ -> N
    Ok(SW), _, _, _ -> N
    Ok(SE), _, _, _ -> N
    _, Ok(EW), _, _ -> E
    _, Ok(NW), _, _ -> E
    _, Ok(SW), _, _ -> E
    _, _, Ok(NS), _ -> S
    _, _, Ok(NE), _ -> S
    _, _, Ok(NW), _ -> S
    _, _, _, Ok(EW) -> W
    _, _, _, Ok(NE) -> W
    _, _, _, Ok(SE) -> W
    _, _, _, _ -> panic
  }

  #(Pos(row, col), heading)
}

fn count_pipes(grid: Grid, pos: Pos, heading: Heading) -> Int {
  let new_pos = case heading {
    N -> Pos(pos.row - 1, pos.col)
    E -> Pos(pos.row, pos.col + 1)
    S -> Pos(pos.row + 1, pos.col)
    W -> Pos(pos.row, pos.col - 1)
  }
  let assert Ok(pipe) = dict.get(grid.m, new_pos)

  use <- bool.guard(pipe == Start, 0)

  let new_heading = case pipe, heading {
    NS, S -> S
    NS, N -> N
    EW, W -> W
    EW, E -> E
    NE, S -> E
    NE, W -> N
    NW, S -> W
    NW, E -> N
    SW, N -> W
    SW, E -> S
    SE, N -> E
    SE, W -> S
    _, _ -> panic
  }

  1 + count_pipes(grid, new_pos, new_heading)
}
