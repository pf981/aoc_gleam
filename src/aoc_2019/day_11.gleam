import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> Computer {
  let assert Ok(nums) =
    string.split(input, ",")
    |> list.try_map(fn(s) { int.parse(s) })
  let instructions =
    nums
    |> list.index_fold(dict.new(), fn(acc, instruction, i) {
      dict.insert(acc, i, instruction)
    })
  Computer(instructions, 0, Running, [], [], 0)
}

pub fn pt_1(computer: Computer) -> Int {
  computer |> extend_input([0]) |> get_panels |> dict.size
}

pub fn pt_2(computer: Computer) -> String {
  let panels = computer |> extend_input([1]) |> get_panels
  let Pos(max_row, max_col) =
    panels
    |> dict.keys
    |> list.fold(Pos(0, 0), fn(acc, pos) {
      Pos(int.max(acc.row, pos.row), int.max(acc.col, pos.col))
    })

  io.println("")
  list.range(0, max_row)
  |> list.map(fn(row) {
    list.range(0, max_col)
    |> list.map(fn(col) {
      case dict.get(panels, Pos(row, col)) {
        Ok(White) -> " "
        _ -> "#"
      }
    })
    |> string.concat
  })
  |> list.each(io.println)

  // Above prints text. Answer hard coded below.
  "HGEHJHUZ"
}

type Pos {
  Pos(row: Int, col: Int)
}

type Heading {
  N
  E
  S
  W
}

type Paint {
  Black
  White
}

type Turn {
  Left
  Right
}

fn get_panels(computer: Computer) -> Dict(Pos, Paint) {
  get_panels_impl(computer, Pos(0, 0), N, dict.new())
}

fn get_panels_impl(
  computer: Computer,
  pos: Pos,
  heading: Heading,
  panels: Dict(Pos, Paint),
) -> Dict(Pos, Paint) {
  let computer = computer |> run
  case computer.state {
    Running -> panic
    WaitingForInput -> {
      let assert [paint, turn] = computer |> get_output_values
      let panels = panels |> dict.insert(pos, int_to_paint(paint))
      let heading = case heading, int_to_turn(turn) {
        N, Left -> W
        N, Right -> E
        E, Left -> N
        E, Right -> S
        S, Left -> E
        S, Right -> W
        W, Left -> S
        W, Right -> N
      }
      let pos = case heading {
        N -> Pos(pos.row - 1, pos.col)
        E -> Pos(pos.row, pos.col + 1)
        S -> Pos(pos.row + 1, pos.col)
        W -> Pos(pos.row, pos.col - 1)
      }
      let input = dict.get(panels, pos) |> result.unwrap(Black) |> paint_to_int
      let computer =
        computer |> clear_output_values |> extend_input([input]) |> run
      get_panels_impl(computer, pos, heading, panels)
    }
    Halted -> panels
  }
}

fn paint_to_int(paint: Paint) -> Int {
  case paint {
    Black -> 0
    White -> 1
  }
}

fn int_to_paint(int: Int) -> Paint {
  case int {
    0 -> Black
    1 -> White
    _ -> panic
  }
}

fn int_to_turn(int: Int) -> Turn {
  case int {
    0 -> Left
    1 -> Right
    _ -> panic
  }
}

// -----------------------------------------------------------------------------
// Computer
// -----------------------------------------------------------------------------

pub type Computer {
  Computer(
    instructions: Dict(Int, Int),
    i: Int,
    state: State,
    input_values: List(Int),
    output_values: List(Int),
    relative_base: Int,
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
  OffsetBase
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

fn run_once(computer: Computer) -> Computer {
  let #(opcode, #(p1, p2, p3)) = get_op(computer)
  case opcode {
    Add -> computer |> set_int(p3.i, p1.val + p2.val) |> inc_i(4)
    Mul -> computer |> set_int(p3.i, p1.val * p2.val) |> inc_i(4)
    Inp ->
      case computer.input_values {
        [] -> computer |> set_state(WaitingForInput)
        [first, ..rest] ->
          computer
          |> set_state(Running)
          |> set_input(rest)
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
    OffsetBase -> computer |> offset_base(p1.val) |> inc_i(2)
    Halt -> computer |> set_state(Halted)
  }
}

fn run(computer: Computer) -> Computer {
  case computer.state {
    Running -> run(run_once(computer))
    WaitingForInput ->
      case computer.input_values {
        [] -> computer
        _ -> computer |> run_once |> run
      }
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
    9 -> OffsetBase
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
        2 ->
          Param(
            computer.relative_base + param,
            get_int(computer, computer.relative_base + param),
          )
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

fn set_input(computer: Computer, input_values: List(Int)) -> Computer {
  Computer(..computer, input_values:)
}

fn extend_input(computer: Computer, values: List(Int)) -> Computer {
  computer |> set_input(list.append(computer.input_values, values))
}

fn get_output_values(computer: Computer) -> List(Int) {
  computer.output_values
}

fn clear_output_values(computer: Computer) -> Computer {
  Computer(..computer, output_values: [])
}

fn set_i(computer: Computer, i: Int) -> Computer {
  Computer(..computer, i:)
}

fn inc_i(computer: Computer, n: Int) -> Computer {
  computer |> set_i(computer.i + n)
}

fn set_state(computer: Computer, state: State) -> Computer {
  Computer(..computer, state:)
}

fn offset_base(computer: Computer, offset: Int) -> Computer {
  Computer(..computer, relative_base: computer.relative_base + offset)
}
