import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Pos {
  Pos(row: Int, col: Int)
}

pub type Space {
  Space(galaxies: List(Pos), empty_rows: Set(Int), empty_cols: Set(Int))
}

pub fn parse(input: String) -> Space {
  let lines = string.split(input, "\n")
  let n_rows = list.length(lines)
  let n_cols = lines |> list.first |> result.unwrap("") |> string.length

  list.index_fold(
    lines,
    Space(
      [],
      set.from_list(list.range(0, n_rows)),
      set.from_list(list.range(0, n_cols)),
    ),
    fn(space, line, row) {
      line
      |> string.to_graphemes
      |> list.index_fold(space, fn(s, c, col) {
        case c {
          "#" ->
            Space(
              [Pos(row, col), ..space.galaxies],
              set.delete(space.empty_rows, row),
              set.delete(space.empty_cols, col),
            )
          "." -> s
          _ -> panic
        }
      })
    },
  )
}

pub fn pt_1(space: Space) {
  get_distances_sum(space, 2)
}

pub fn pt_2(space: Space) {
  get_distances_sum(space, 1_000_000)
}

fn get_distances_sum(space: Space, empty_size: Int) -> Int {
  space.galaxies
  |> list.combination_pairs
  |> list.map(get_distance(_, space, empty_size))
  |> int.sum
}

fn get_distance(pair: #(Pos, Pos), space: Space, empty_size: Int) -> Int {
  let #(Pos(row1, col1), Pos(row2, col2)) = pair

  let blank_rows =
    space.empty_rows
    |> set.filter(fn(row) {
      int.min(row1, row2) < row && row < int.max(row1, row2)
    })
    |> set.size
  let d_row = int.absolute_value(row2 - row1) + blank_rows * { empty_size - 1 }

  let blank_cols =
    space.empty_cols
    |> set.filter(fn(col) {
      int.min(col1, col2) < col && col < int.max(col1, col2)
    })
    |> set.size
  let d_col = int.absolute_value(col2 - col1) + blank_cols * { empty_size - 1 }

  d_row + d_col
}
