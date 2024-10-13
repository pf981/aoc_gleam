import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
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
  computer
  |> run
  |> get_output_values
  |> list.sized_chunk(3)
  |> list.map(get_output_instruction)
  |> list.filter(is_tile(_, Block))
  |> list.length
}

pub fn pt_2(computer: Computer) -> Int {
  let assert Ok(Score(score)) =
    computer
    |> set_int(0, 2)
    |> play(0, 0)
    |> get_output_values
    |> list.sized_chunk(3)
    |> list.map(get_output_instruction)
    |> list.last
  score
}

type Tile {
  Empty
  Wall
  Block
  HorizontalPaddle
  Ball
}

type OutputInstruction {
  OutputInstruction(x: Int, y: Int, tile: Tile)
  Score(Int)
}

fn get_output_instruction(output: List(Int)) -> OutputInstruction {
  let assert [x, y, tile] = output
  use <- bool.guard(x == -1, Score(tile))
  let tile = case tile {
    0 -> Empty
    1 -> Wall
    2 -> Block
    3 -> HorizontalPaddle
    4 -> Ball
    _ -> panic
  }
  OutputInstruction(x:, y:, tile:)
}

fn play(computer: Computer, ball_x: Int, paddle_x: Int) -> Computer {
  case computer.state {
    Running -> computer |> run |> play(ball_x, paddle_x)
    WaitingForInput -> {
      let output_instructions =
        computer
        |> get_output_values
        |> list.sized_chunk(3)
        |> list.map(get_output_instruction)

      let ball_x = output_instructions |> locate(Ball) |> result.unwrap(ball_x)
      let paddle_x =
        output_instructions
        |> locate(HorizontalPaddle)
        |> result.unwrap(paddle_x)
      let input =
        bool.to_int(ball_x > paddle_x) - bool.to_int(ball_x < paddle_x)

      computer
      |> extend_input([input])
      |> clear_output_values
      |> run
      |> play(ball_x, paddle_x)
    }
    Halted -> computer
  }
}

fn locate(
  output_instructions: List(OutputInstruction),
  tile: Tile,
) -> Result(Int, Nil) {
  case output_instructions |> list.find(is_tile(_, tile)) {
    Ok(OutputInstruction(x, _, _)) -> Ok(x)
    _ -> Error(Nil)
  }
}

fn is_tile(output_instruction: OutputInstruction, tile: Tile) -> Bool {
  case output_instruction {
    OutputInstruction(_, _, t) -> t == tile
    Score(_) -> False
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
