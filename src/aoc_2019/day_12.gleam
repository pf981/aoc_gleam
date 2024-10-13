import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/regex
import gleam/result
import gleam/string

pub type Vector {
  Vector(pos: Int, vel: Int)
}

pub type Dimension =
  List(Vector)

pub fn parse(input: String) -> List(Dimension) {
  let assert Ok(re) = regex.from_string("[+-]?\\d+")
  let assert Ok(nums) =
    regex.scan(re, input)
    |> list.map(fn(match) { match.content |> int.parse })
    |> result.all

  nums
  |> list.sized_chunk(3)
  |> list.transpose
  |> list.map(list.map(_, fn(pos) { Vector(pos, 0) }))
}

pub fn pt_1(dimensions: List(Dimension)) -> Int {
  dimensions
  |> simulate_n(1000)
  |> list.transpose
  |> list.map(list.fold(
    _,
    Vector(0, 0),
    fn(acc, dimension: Vector) {
      Vector(
        acc.pos + int.absolute_value(dimension.pos),
        acc.vel + int.absolute_value(dimension.vel),
      )
    },
  ))
  |> list.map(fn(dimension) { dimension.pos * dimension.vel })
  |> list.fold(0, fn(acc, energy) { acc + energy })
}

pub fn pt_2(dimensions: List(Dimension)) {
  todo as "part 2 not implemented"
}

pub fn simulate_n(dimensions: List(Dimension), n: Int) -> List(Dimension) {
  case n {
    0 -> dimensions
    _ -> dimensions |> list.map(simulate_dimension) |> simulate_n(n - 1)
  }
}

pub fn simulate_dimension(dimension: Dimension) -> Dimension {
  // Update velocities
  let dimension =
    dimension
    |> list.map(fn(vector) {
      let dv =
        dimension
        |> list.fold(0, fn(acc, other) {
          case int.compare(vector.pos, other.pos) {
            order.Eq -> acc
            order.Lt -> acc + 1
            order.Gt -> acc - 1
          }
        })

      Vector(vector.pos, vector.vel + dv)
    })

  // Update positions
  dimension
  |> list.map(fn(vector) { Vector(vector.pos + vector.vel, vector.vel) })
}
