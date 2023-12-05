module main

import math
import arrays

struct Range{
	pub mut:
	start u64
	end u64 // range is treated as a right-open interval
}
pub fn (r Range) len () u64 {
	return r.end - r.start
}
pub fn (r Range) contains (a u64) bool {
	return (a>=r.start) && (a<= r.end )
}
pub fn (r Range) intersects (b Range) bool {
	return r.contains(b.start) || r.contains(b.end)
	|| b.contains(r.start) || b.contains(r.end)
}
pub fn (r []Range) intersects (b Range) bool {
	for r0 in r {
		if r0.intersect(b) {
			return true
		}
	}
	return false
}
pub fn (r Range) merge (r1 Range) []Range {
	if r.intersects(r1) {
		return Range {
			start: math.min(r.start,r1.start)
			end: math.max(r.end,r1.end)
		}
	} else {
		return [r,r1]
	}
}
pub fn (r []Range) merge (r1 Range) []Range {
	mut ranges := []Range{}
	for r0 in r {
		ranges << r0.merge(r1)
	}
	return ranges
}
pub fn (r []Range) merge_all (r1 []Range) []Range {
	mut ranges := []Range{}
	for r0 in r {
		ranges << r1.merge(r1)
	}
	return ranges
}
pub fn (r Range) intersect (r1 Range) Range {
	if r.intersects(r1) {
		return Range {
			start: math.max(r.start,r1.start)
			end: math.min(r.end,r1.end)
		}
	} else {
		return range{start:0,end:0}
	}
}
pub fn (r []Range) intersect (r1 Range) []Range {
	mut ranges := []Range{}
	for r0 in r {
		ranges << r0.intersect(r1)
	}
	return ranges
}
pub fn (r []Range) intersect_all (r1 []Range) []Range {
	mut ranges := [][]Range{}
	for r0 in r {
		ranges << r1.intersect(r0)
	}
	return arrays.flatten(ranges)
}
pub fn (r Range) each (tf fn(i u64) ) {
	for i in r.start .. r.end {
		tf(i)
	}
}
pub fn (r Range) fold [T](init T,tf fn(a T,i u64)) T {
	mut acc := init
	for i in r.start .. r.end {
		acc = tf(acc,i)
	}
	return acc
}
pub fn (r Range) map [T](tf fn(i u64) T) []T {
	mut acc := []T{}
	for i in r.start .. r.end {
		acc << tf(i)
	}
	return acc
}
pub fn (r Range) filter (tf fn(i u64) bool ) []u64 {
	mut acc := []u64{}
	for i in r.start .. r.end {
		if tf(i) {
			acc << i
		}
	}
	return acc
}
pub fn (r Range) all () []u64 {
	mut acc := []u64{}
	for i in r.start .. r.end {
		acc << i
	}
	return acc
}
