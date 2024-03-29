import gleeunit/should
import aoc_2023/day_5

fn r(start: Int, end: Int) -> day_5.Range {
  day_5.Range(start, end, 0)
}

pub fn overlap_none_left_test() {
  day_5.overlap(r(5, 10), r(11, 12))
  |> should.equal(day_5.None)
}

pub fn split_none_left_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(11, 12)]))
  |> should.equal(#(r(5, 10), []))
}

pub fn overlap_none_right_test() {
  day_5.overlap(r(11, 12), r(5, 10))
  |> should.equal(day_5.None)
}

pub fn split_none_right_test() {
  day_5.split_range(r(11, 12), day_5.Map([r(5, 10)]))
  |> should.equal(#(r(11, 12), []))
}

pub fn overlap_left_test() {
  day_5.overlap(r(5, 10), r(4, 6))
  |> should.equal(day_5.Left)
}

pub fn split_left_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(4, 6)]))
  |> should.equal(#(r(5, 6), [r(7, 10)]))
}

pub fn overlap_left_touching_test() {
  day_5.overlap(r(5, 10), r(5, 9))
  |> should.equal(day_5.Left)
}

pub fn split_left_touching_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(5, 9)]))
  |> should.equal(#(r(5, 9), [r(10, 10)]))
}

pub fn overlap_right_test() {
  day_5.overlap(r(0, 2), r(1, 3))
  |> should.equal(day_5.Right)
}

pub fn split_right_test() {
  day_5.split_range(r(0, 2), day_5.Map([r(1, 3)]))
  |> should.equal(#(r(1, 2), [r(0, 0)]))
}

pub fn overlap_right_touching_test() {
  day_5.overlap(r(0, 2), r(1, 2))
  |> should.equal(day_5.Right)
}

pub fn split_right_touching_test() {
  day_5.split_range(r(0, 2), day_5.Map([r(1, 2)]))
  |> should.equal(#(r(1, 2), [r(0, 0)]))
}

pub fn overlap_middle_test() {
  day_5.overlap(r(5, 10), r(6, 9))
  |> should.equal(day_5.Middle)
}

pub fn split_middle_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(6, 9)]))
  |> should.equal(#(r(6, 9), [r(5, 5), r(10, 10)]))
}

pub fn overlap_full_test() {
  day_5.overlap(r(5, 10), r(4, 11))
  |> should.equal(day_5.Full)
}

pub fn split_full_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(4, 11)]))
  |> should.equal(#(r(5, 10), []))
}

pub fn overlap_full_touching_left_test() {
  day_5.overlap(r(5, 10), r(5, 11))
  |> should.equal(day_5.Full)
}

pub fn split_full_touching_left_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(5, 11)]))
  |> should.equal(#(r(5, 10), []))
}

pub fn overlap_full_touching_right_test() {
  day_5.overlap(r(5, 10), r(4, 10))
  |> should.equal(day_5.Full)
}

pub fn split_full_touching_right_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(4, 10)]))
  |> should.equal(#(r(5, 10), []))
}

pub fn overlap_full_touching_both_test() {
  day_5.overlap(r(5, 10), r(5, 10))
  |> should.equal(day_5.Full)
}

pub fn split_full_touching_both_test() {
  day_5.split_range(r(5, 10), day_5.Map([r(5, 10)]))
  |> should.equal(#(r(5, 10), []))
}

pub fn split_nothing_test() {
  day_5.split_range(r(5, 10), day_5.Map([]))
  |> should.equal(#(r(5, 10), []))
}

import gleam/io

// pub fn wip_test() {
//   io.debug("\n")
//   day_5.reducer(
//     day_5.Map([day_5.Range(79, 82, -5)]),
//     day_5.Map([day_5.Range(77, 99, -32)]),
//   )
//   |> io.debug
//   io.debug("\n")
//   //   |> should.equal(day_5.Map([]))
// }
pub fn wip_test() {
  io.debug("=======================================")
  //   day_5.split_range(r(74, 77), day_5.Map([r(77, 79)]))
  day_5.split_range(day_5.Range(79, 82, -5), day_5.Map([r(77, 79)]))
  |> io.debug
  io.debug("=======================================")
  //   |> should.equal(day_5.Map([]))
}
