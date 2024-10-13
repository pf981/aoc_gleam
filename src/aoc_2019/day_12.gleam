import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/regex
import gleam/result
import gleam/set.{type Set}

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
  |> list.map(calculate_energy)
  |> list.fold(0, fn(acc, energy) { acc + energy })
}

pub fn pt_2(dimensions: List(Dimension)) -> Int {
  dimensions |> list.map(find_cycle(_, set.new(), 0)) |> list.fold(1, lcm)
}

fn calculate_energy(moon: Dimension) -> Int {
  let Vector(potential_energy, kinetic_energy) =
    moon
    |> list.fold(Vector(0, 0), fn(acc, dimension: Vector) {
      Vector(
        acc.pos + int.absolute_value(dimension.pos),
        acc.vel + int.absolute_value(dimension.vel),
      )
    })
  potential_energy * kinetic_energy
}

fn simulate_n(dimensions: List(Dimension), n: Int) -> List(Dimension) {
  case n {
    0 -> dimensions
    _ if n < 0 -> panic
    _ -> dimensions |> list.map(simulate_dimension) |> simulate_n(n - 1)
  }
}

fn simulate_dimension(dimension: Dimension) -> Dimension {
  // Update velocities
  let dimension =
    dimension
    |> list.map(fn(vector) {
      let dv =
        dimension
        |> list.fold(0, fn(acc, other) {
          case int.compare(vector.pos, other.pos) {
            Eq -> acc
            Gt -> acc - 1
            Lt -> acc + 1
          }
        })

      Vector(vector.pos, vector.vel + dv)
    })

  // Update positions
  dimension
  |> list.map(fn(vector) { Vector(vector.pos + vector.vel, vector.vel) })
}

fn find_cycle(dimension: Dimension, seen: Set(Dimension), acc: Int) -> Int {
  case set.contains(seen, dimension) {
    True -> acc
    False ->
      dimension
      |> simulate_dimension
      |> find_cycle(set.insert(seen, dimension), acc + 1)
  }
}

fn gcd(a: Int, b: Int) -> Int {
  case b {
    0 -> a
    _ -> gcd(b, a % b)
  }
}

fn lcm(a: Int, b: Int) -> Int {
  a * b / gcd(a, b)
}
