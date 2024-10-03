import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

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

pub fn parse(input: String) -> Dict(Pos, Pipe) {
  let lines = string.split(input, "\n")

  list.index_fold(lines, dict.new(), fn(m, line, row) {
    line
    |> string.to_graphemes
    |> list.index_fold(m, fn(m, c, col) {
      dict.insert(m, Pos(row, col), to_pipe(c))
    })
  })
}

pub fn pt_1(grid: Dict(Pos, Pipe)) {
  list.length(get_vertices(grid)) / 2
}

pub fn pt_2(grid: Dict(Pos, Pipe)) {
  let vertices = get_vertices(grid)
  get_double_area(vertices)
  |> count_interior_points(list.length(vertices))
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

fn get_start(grid: Dict(Pos, Pipe)) -> #(Pos, Heading) {
  let assert Ok(Pos(row, col)) =
    grid
    |> dict.filter(fn(_, pipe) { pipe == Start })
    |> dict.keys
    |> list.first

  let heading = case
    dict.get(grid, Pos(row - 1, col)),
    dict.get(grid, Pos(row, col + 1)),
    dict.get(grid, Pos(row + 1, col)),
    dict.get(grid, Pos(row, col - 1))
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

fn get_vertices(grid: Dict(Pos, Pipe)) -> List(Pos) {
  let #(pos, heading) = get_start(grid)
  get_vertices_impl(grid, pos, heading, [])
}

fn get_vertices_impl(
  grid: Dict(Pos, Pipe),
  pos: Pos,
  heading: Heading,
  vertices: List(Pos),
) -> List(Pos) {
  let new_vertices = [pos, ..vertices]
  let new_pos = case heading {
    N -> Pos(pos.row - 1, pos.col)
    E -> Pos(pos.row, pos.col + 1)
    S -> Pos(pos.row + 1, pos.col)
    W -> Pos(pos.row, pos.col - 1)
  }
  let assert Ok(pipe) = dict.get(grid, new_pos)

  use <- bool.guard(pipe == Start, new_vertices)

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

  get_vertices_impl(grid, new_pos, new_heading, new_vertices)
}

fn get_double_area(vertices: List(Pos)) -> Int {
  // Shoelace formula: 2A = \sum_{i=1}^n x_i(y_{i+1} - y_{i-1})
  let n = list.length(vertices) - 1
  let x =
    vertices
    |> list.index_map(fn(pos, i) { #(i, pos.col) })
    |> dict.from_list()

  vertices
  |> list.index_map(fn(pos, i) {
    let y_i = pos.row
    let assert Ok(x_i_minus_one) = result.or(dict.get(x, i - 1), dict.get(x, n))
    let assert Ok(x_i_plus_one) = result.or(dict.get(x, i + 1), dict.get(x, 1))
    y_i * { x_i_minus_one - x_i_plus_one }
  })
  |> int.sum
}

fn count_interior_points(double_area: Int, n_vertices: Int) -> Int {
  // Pick's Theorem:
  //     A = i + b/2 - 1
  //  => i = (2A - b + 2) / 2
  { double_area - n_vertices + 2 } / 2
}
