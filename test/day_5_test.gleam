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
