import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Error {
  IntParseError
}

pub fn parse(input: String) -> Result(List(List(Int)), Error) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.all
    |> result.replace_error(IntParseError)
  })
  |> result.all
}

pub fn pt_1(seqs: Result(List(List(Int)), Error)) -> Result(Int, Error) {
  use seqs <- result.map(seqs)

  seqs
  |> list.map(extrapolate(0, _))
  |> int.sum
}

pub fn pt_2(seqs: Result(List(List(Int)), Error)) -> Result(Int, Error) {
  use seqs <- result.map(seqs)

  seqs
  |> list.map(list.reverse)
  |> list.map(extrapolate(0, _))
  |> int.sum
}

fn extrapolate(acc: Int, seq: List(Int)) -> Int {
  use <- bool.guard(list.all(seq, fn(el) { el == 0 }), acc)

  let deltas =
    seq
    |> list.window_by_2()
    |> list.map(fn(pair) { pair.1 - pair.0 })

  extrapolate(acc + result.unwrap(list.last(seq), 0), deltas)
}
