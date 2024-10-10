import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Computer {
  Computer(
    instructions: Dict(Int, Int),
    i: Int,
    state: State,
    input_values: List(Int),
    output_values: List(Int),
  )
}

pub type Opcode {
  Add
  Mul
  Inp
  Out
  JmpIfTrue
  JmpIfFalse
  Lt
  Eq
  Halt
}

pub type State {
  Running
  Halted
  WaitingForInput
}

pub type Param {
  Param(i: Int, val: Int)
}

pub fn parse(input: String) -> Computer {
  let assert Ok(nums) =
    string.split(input, ",")
    |> list.try_map(fn(s) { int.parse(s) })
  let instructions =
    nums
    |> list.index_fold(dict.new(), fn(acc, instruction, i) {
      dict.insert(acc, i, instruction)
    })
  Computer(instructions, 0, Running, [], [])
}

pub fn pt_1(computer: Computer) {
  // computer |> compute_thruster_output([4, 3, 2, 1, 0])
  list.range(0, 4)
  |> list.permutations()
  |> list.map(compute_thruster_output(_, computer))
  |> list.fold(0, int.max)
}

pub fn pt_2(computer: Computer) {
  // let computer =
  //   computer
  //   |> set_input(5)
  //   |> run
  // computer.output
  todo
}

fn run_once(computer: Computer) -> Computer {
  use <- bool.guard(computer.state == Halted, computer)

  let #(opcode, #(p1, p2, p3)) = get_op(computer)
  case opcode {
    Add -> computer |> set_int(p3.i, p1.val + p2.val) |> inc_i(4)
    Mul -> computer |> set_int(p3.i, p1.val * p2.val) |> inc_i(4)
    Inp ->
      case computer.input_values {
        [] -> Computer(..computer, state: WaitingForInput)
        [first, ..rest] ->
          Computer(..computer, input_values: rest)
          |> set_int(p1.i, first)
          |> inc_i(2)
      }
    Out -> computer |> extend_output([p1.val]) |> inc_i(2)
    JmpIfTrue ->
      case p1.val != 0 {
        True -> computer |> set_i(p2.val)
        False -> computer |> inc_i(3)
      }
    JmpIfFalse ->
      case p1.val != 0 {
        True -> computer |> inc_i(3)
        False -> computer |> set_i(p2.val)
      }
    Lt -> computer |> set_int(p3.i, bool.to_int(p1.val < p2.val)) |> inc_i(4)
    Eq -> computer |> set_int(p3.i, bool.to_int(p1.val == p2.val)) |> inc_i(4)
    Halt -> Computer(..computer, state: Halted)
  }
}

fn run(computer: Computer) -> Computer {
  case computer.state {
    Running | WaitingForInput -> run(run_once(computer))
    Halted -> computer
  }
}

fn get_int(computer: Computer, i: Int) -> Int {
  case dict.get(computer.instructions, i) {
    Ok(value) -> value
    Error(Nil) -> 0
  }
}

fn get_op(computer: Computer) -> #(Opcode, #(Param, Param, Param)) {
  let num = get_int(computer, computer.i)
  let opcode = case num % 100 {
    1 -> Add
    2 -> Mul
    3 -> Inp
    4 -> Out
    5 -> JmpIfTrue
    6 -> JmpIfFalse
    7 -> Lt
    8 -> Eq
    99 -> Halt
    _ -> panic as { "Unknown opcode " <> int.to_string(num) }
  }

  use <- bool.guard(
    opcode == Halt,
    #(Halt, #(Param(0, 0), Param(0, 0), Param(0, 0))),
  )

  let assert [p1, p2, p3] =
    list.range(1, 3)
    |> list.map(fn(di) {
      let param = get_int(computer, computer.i + di)
      case { num / pow(10, di + 1) } % 10 {
        0 -> Param(param, get_int(computer, param))
        1 -> Param(-1, param)
        _ -> panic as { "Unknown param mode " <> int.to_string(num) }
      }
    })

  #(opcode, #(p1, p2, p3))
}

fn pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    1 -> base
    _ -> base * pow(base, exp - 1)
  }
}

fn set_int(computer: Computer, i: Int, value: Int) -> Computer {
  Computer(
    ..computer,
    instructions: dict.insert(computer.instructions, i, value),
  )
}

fn extend_output(computer: Computer, values: List(Int)) -> Computer {
  Computer(
    ..computer,
    output_values: list.append(computer.output_values, values),
  )
}

fn extend_input(computer: Computer, values: List(Int)) -> Computer {
  Computer(..computer, input_values: list.append(computer.input_values, values))
}

fn get_output_values(computer: Computer) -> List(Int) {
  computer.output_values
}

fn set_i(computer: Computer, i: Int) -> Computer {
  Computer(..computer, i: i)
}

fn inc_i(computer: Computer, n: Int) -> Computer {
  set_i(computer, computer.i + n)
}

fn compute_thruster_output(phases: List(Int), base_computer: Computer) -> Int {
  let amplifiers =
    phases
    |> list.map(fn(phase) { Computer(..base_computer, input_values: [phase]) })

  let assert Ok(output) =
    amplifiers
    |> list.fold([0], fn(acc, amplifier) {
      amplifier |> extend_input(acc) |> run |> get_output_values
    })
    |> list.last

  output
}
