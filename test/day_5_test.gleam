import gleeunit/should
import aoc_2023/day_5

fn r(start: Int, end: Int) -> day_5.Range {
  day_5.Range(start, end, 0)
}

pub fn overlap_none_left_test() {
  day_5.overlap(r(5, 10), r(11, 12))
  |> should.equal(day_5.None)
}

pub fn overlap_none_right_test() {
  day_5.overlap(r(11, 12), r(5, 10))
  |> should.equal(day_5.None)
}

pub fn overlap_left_test() {
  day_5.overlap(r(5, 10), r(4, 6))
  |> should.equal(day_5.Left)
}

pub fn overlap_left_touching_test() {
  day_5.overlap(r(5, 10), r(5, 9))
  |> should.equal(day_5.Left)
}

pub fn overlap_right_test() {
  day_5.overlap(r(0, 2), r(1, 3))
  |> should.equal(day_5.Right)
}

pub fn overlap_right_touching_test() {
  day_5.overlap(r(0, 2), r(1, 2))
  |> should.equal(day_5.Right)
}
