import gleam/bool
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list

pub type Quantity {
  Quantity(chemical: String, n: Int)
}

pub type Materials =
  Dict(String, Int)

pub type Reactions =
  Dict(String, Output)

pub type Output {
  Output(n_out: Int, reagents: Materials)
}

pub fn parse(input: String) -> Reactions {
  todo as "parse not implemented"
}

pub fn pt_1(reactions: Reactions) {
  caclulate_required_ore(reactions, dict.from_list([#("FUEL", 1)]), dict.new())
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

fn caclulate_required_ore(
  reactions: Reactions,
  targets: Materials,
  materials: Materials,
) -> Int {
  case targets |> pop {
    Error(Nil) -> materials |> get("ORE")
    Ok(#(target, targets)) -> {
      let #(materials, still_needed) = take(materials, target)

      // Make the remaining
      let assert Ok(Output(n_out, reagents)) =
        reactions |> dict.get(still_needed.chemical)

      let n_batches =
        float.ceiling(int.to_float(target.n) /. int.to_float(n_out))

      reactions |> make_batches(still_needed.chemical, n)

      caclulate_required_ore(
        reactions,
        targets |> dict.insert(still_needed.chemical, still_needed.n),
        materials,
      )
    }
  }

  todo
}

fn get(materials: Materials, chemical: String) -> Int {
  case dict.get(materials, chemical) {
    Ok(value) -> value
    Error(Nil) -> 0
  }
}

// fn take(materials: Materials, to_take: Materials) -> Result(Materials, Nil) {
//   todo
// }

fn take(materials: Materials, to_take: Quantity) -> #(Materials, Quantity) {
  let materials = todo
  let still_needed = todo
  #(materials, still_needed)
}

fn merge(a: Materials, b: Materials) -> Materials {
  todo
}

fn pop(materials: Materials) -> Result(#(Quantity, Materials), Nil) {
  todo
}
