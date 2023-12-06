module main

pub fn test_iterators(){
	r0:=Interval{10,20}
	println(r0.all())
	assert r0.all() == [u64(10), 11, 12, 13, 14, 15, 16, 17, 18, 19]
	r1 := Interval{1,11}
	sum_r1 := r1.fold[u64](u64(0),fn(a u64,n u64) u64 {
		return a+n
	})
	println(sum_r1)
	assert sum_r1 == 55

	r2 := Interval{1,11}.map(fn(a u64) string {return "Sooo 2^$a=${1<<a}}"})
	println(r2)

	Interval{2,5}.each(fn(n u64) {
		println("$n bottles of beer hanging on the wall")
	})

	ri0 := Interval{2,75}.intersect(Interval{50,150})
	println(ri0)

	ri1 := Interval{2,10}.intersect(Interval{50,150})
	println(ri1)

	ru0 := Interval{2,75}.merge(Interval{50,150})
	println(ru0)

	ru1 := Interval{2,10}.merge(Interval{50,150})
	println(ru1)
}
pub fn test_set_operations(){
	ri0 := Interval{2,75}.intersect(Interval{50,150})
	println(ri0)

	ri1 := Interval{2,10}.intersect(Interval{50,150})
	println(ri1)

	ru0 := Interval{2,75}.merge(Interval{50,150})
	println(ru0)

	ru1 := Interval{2,10}.merge(Interval{50,150})
	println(ru1)

	rs0 := Interval{2,75}.subtract(Interval{50,150})
	println(rs0)

	rs1 := Interval{2,10}.subtract(Interval{50,150})
	println(rs1)

}
pub fn test_compact(){
	intv := [
		Interval{1,6},
		Interval{2,8},
		Interval{10,26},
		Interval{29,48},
	]
	println(intv.compact())
}
