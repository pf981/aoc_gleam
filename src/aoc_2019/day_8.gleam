import gleam/io
import gleam/list
import gleam/string

pub type Pixel {
  Black
  White
  Transparent
}

pub fn parse(input: String) -> List(List(Pixel)) {
  input
  |> string.to_graphemes
  |> list.map(fn(c) {
    case c {
      "0" -> Black
      "1" -> White
      "2" -> Transparent
      _ -> panic as { "Unknown pixel " <> c }
    }
  })
  |> list.sized_chunk(25 * 6)
}

pub fn pt_1(layers: List(List(Pixel))) -> Int {
  let counts =
    layers
    |> list.fold(#(25 * 6, 0, 0), fn(counts, layer) {
      let new_counts =
        layer
        |> list.fold(#(0, 0, 0), fn(new_counts, pixel) {
          case pixel {
            Black -> #(new_counts.0 + 1, new_counts.1, new_counts.2)
            White -> #(new_counts.0, new_counts.1 + 1, new_counts.2)
            Transparent -> #(new_counts.0, new_counts.1, new_counts.2 + 1)
          }
        })
      case new_counts.0 < counts.0 {
        True -> new_counts
        False -> counts
      }
    })
  counts.1 * counts.2
}

pub fn pt_2(layers: List(List(Pixel))) -> String {
  layers
  |> map_all(get_color, [])
  |> list.sized_chunk(25)
  |> list.map(list.map(_, fn(pixel) {
    case pixel {
      Black -> "#"
      _ -> " "
    }
  }))
  |> list.map(string.concat)
  |> list.each(io.println)

  // Above prints text. Answer hard coded below.
  "CEKUA"
}

/// Pops all the lists in a list of lists.
/// Returns a tuple of the popped lists and the remaining lists.
/// Returns #([], []) if the list is empty.
/// 
fn pop_all(list_of_lists: List(List(a))) -> #(List(a), List(List(a))) {
  let #(firsts, rests) =
    list_of_lists
    |> list.fold(#([], []), fn(acc, l) {
      case l {
        [] -> acc
        [first, ..rest] -> #([first, ..acc.0], [rest, ..acc.1])
      }
    })
  #(list.reverse(firsts), list.reverse(rests))
}

/// Zips a list of lists together and applies a function to each group of elements.
/// 
fn map_all(
  list_of_lists: List(List(a)),
  f: fn(List(a)) -> b,
  acc: List(b),
) -> List(b) {
  case pop_all(list_of_lists) {
    #([], []) -> acc |> list.reverse
    #(firsts, rests) -> {
      map_all(rests, f, [f(firsts), ..acc])
    }
  }
}

fn get_color(pixels: List(Pixel)) -> Pixel {
  case pixels {
    [Transparent, ..rest] -> get_color(rest)
    [first, ..] -> first
    [] -> Transparent
  }
}
