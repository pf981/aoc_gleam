import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/string

pub type Computer {
  Computer(instructions: Dict(Int, Int), i: Int, state: State)
}

pub type Opcode {
  Add
  Mul
  Halt
}

pub type State {
  Running
  Halted
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
  Computer(instructions, 0, Running)
}

pub fn pt_1(computer: Computer) {
  get_result(computer, 12, 2)
}

pub fn pt_2(computer: Computer) {
  let assert Ok(#(init1, init2)) =
    iterator.iterate(#(0, 0), fn(init) {
      case init.1 == 99 {
        True -> #(init.0 + 1, 0)
        False -> #(init.0, init.1 + 1)
      }
    })
    |> iterator.find(fn(init) {
      get_result(computer, init.0, init.1) == 19_690_720
    })

  init1 * 100 + init2
}

fn get_result(computer: Computer, init1: Int, init2: Int) -> Int {
  computer
  |> set_int(1, init1)
  |> set_int(2, init2)
  |> run
  |> get_int(0)
}

fn run_once(computer: Computer) -> Computer {
  case get_op(computer, computer.i) {
    Add -> {
      let p1 = get_int(computer, computer.i + 1)
      let p2 = get_int(computer, computer.i + 2)
      let p3 = get_int(computer, computer.i + 3)
      let value1 = get_int(computer, p1)
      let value2 = get_int(computer, p2)
      computer |> set_int(p3, value1 + value2) |> inc_i(4)
    }
    Mul -> {
      let p1 = get_int(computer, computer.i + 1)
      let p2 = get_int(computer, computer.i + 2)
      let p3 = get_int(computer, computer.i + 3)
      let value1 = get_int(computer, p1)
      let value2 = get_int(computer, p2)
      computer |> set_int(p3, value1 * value2) |> inc_i(4)
    }
    Halt -> Computer(..computer, state: Halted)
  }
}

fn run(computer: Computer) -> Computer {
  case computer.state {
    Running -> run(run_once(computer))
    Halted -> computer
  }
}

fn get_int(computer: Computer, i: Int) -> Int {
  case dict.get(computer.instructions, i) {
    Ok(value) -> value
    Error(Nil) -> panic
  }
}

fn get_op(computer: Computer, i: Int) -> Opcode {
  case get_int(computer, i) {
    1 -> Add
    2 -> Mul
    99 -> Halt
    _ -> panic
  }
}

fn set_int(computer: Computer, i: Int, value: Int) -> Computer {
  Computer(
    ..computer,
    instructions: dict.insert(computer.instructions, i, value),
  )
}

fn inc_i(computer: Computer, n: Int) -> Computer {
  Computer(..computer, i: computer.i + n)
}
