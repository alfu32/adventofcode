module main

import math
import arrays

struct Interval{
	pub mut:
	start u64
	end u64
	// step u64 = 1
}
pub fn (r Interval) str() string {
	return "[${r.start},${r.end})"
}
const interval_null = Interval{1,0}
pub fn (r Interval) index_of(k u64) u64 {
	return k - r.start
}
pub fn (r Interval) value_at_index(nth u64) u64 {
	return r.start + nth
}
pub fn (r Interval) len () u64 {
	return r.end - r.start
}
pub fn (r Interval) contains (a u64) bool {
	return (a>=r.start) && (a<= r.end )
}
pub fn (r Interval) intersects (b Interval) bool {
	return r.contains(b.start) || r.contains(b.end)
	|| b.contains(r.start) || b.contains(r.end)
}
pub fn (r []Interval) intersects (b Interval) bool {
	for r0 in r {
		if r0.intersects(b) {
			return true
		}
	}
	return false
}
pub fn (r Interval) merge (r1 Interval) []Interval {
	if r.intersects(r1) {
		return [Interval {
			start: math.min(r.start,r1.start)
			end: math.max(r.end,r1.end)
		}]
	} else {
		return [r,r1]
	}
}
pub fn (r []Interval) merge (r1 Interval) []Interval {
	mut ranges := []Interval{}
	for r0 in r {
		ranges << r0.merge(r1)
	}
	return ranges
}
pub fn (r []Interval) merge_all (r1 []Interval) []Interval {
	mut ranges := []Interval{}
	for r0 in r {
		ranges << r1.merge(r0)
	}
	return ranges
}
pub fn (r Interval) intersect (r1 Interval) Interval {
	if r.intersects(r1) {
		return Interval {
			start: math.max(r.start,r1.start)
			end: math.min(r.end,r1.end)
		}
	} else {
		return Interval{start:0,end:0}
	}
}
pub fn (r []Interval) intersect (r1 Interval) []Interval {
	mut ranges := []Interval{}
	for r0 in r {
		ranges << r0.intersect(r1)
	}
	return ranges
}
pub fn (r []Interval) intersect_all (r1 []Interval) []Interval {
	mut ranges := [][]Interval{}
	for r0 in r {
		ranges << r1.intersect(r0)
	}
	return arrays.flatten(ranges)
}
pub fn (r Interval) subtract(r1 Interval) Interval {
	if r.intersects(r1) {
		intersection := r.intersect(r1)
		unyon := r.merge(r1)[0]
		left := Interval{start:unyon.start,end:intersection.start}
		right := Interval{start:intersection.end,end:unyon.end}
		if left.intersects(r1) {
			return left
		} else {
			return right
		}
	} else {
		return r
	}
}
pub fn (r []Interval) compact() []Interval {
	mut intervals := r.map(it)
	mut buffer := []Interval{}
	mut limit :=20
	for limit >= 0{
		println(buffer)
		for i,i0 in r {
			mut j:=i+1
			for j<r.len {
				i1:= r[j]
				if i0.intersects(i1) {
					buffer << i0.merge(i1)
				}
				j++
			}
		}
		if buffer.len == intervals.len {
			return buffer
		}
		intervals = buffer.map(it)
		limit--
	}
	return buffer
}
pub fn (r Interval) each (tf fn(i u64) ) {
	for i in r.start .. r.end {
		tf(i)
	}
}
pub fn (r Interval) fold [T](init T,tf fn(a T,i u64) T ) T {
	mut acc := init
	for i in r.start .. r.end {
		acc = tf(acc,i)
	}
	return acc
}
pub fn (r Interval) map [T](tf fn(i u64) T) []T {
	mut acc := []T{}
	for i in r.start .. r.end {
		acc << tf(i)
	}
	return acc
}
pub fn (r Interval) filter (tf fn(i u64) bool ) []u64 {
	mut acc := []u64{}
	for i in r.start .. r.end {
		if tf(i) {
			acc << i
		}
	}
	return acc
}
pub fn (r Interval) all () []u64 {
	mut acc := []u64{}
	for i in r.start .. r.end {
		acc << i
	}
	return acc
}