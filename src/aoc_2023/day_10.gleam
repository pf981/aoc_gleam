import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string

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

  count_pipes(grid, start_pos, pos: Pos, heading: Heading)
}

pub fn pt_2(grid: List(List(String))) {
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

fn next_pipe(grid: Grid, pos: Pos, heading: Heading) -> #(Pos, Heading) {
  todo
}

fn count_pipes(grid: Grid, start_pos: Pos, pos: Pos, heading: Heading) -> Int {
  todo
}
