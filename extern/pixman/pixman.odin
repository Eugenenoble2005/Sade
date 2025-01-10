package pixman
import "core:c"

pixman_fixed_16_16_t :: c.uint32_t
FixedT :: pixman_fixed_16_16_t

Color :: struct {
	red:   c.uint16_t,
	green: c.uint16_t,
	blue:  c.uint16_t,
	alpha: c.uint16_t,
}

PointFixed :: struct {
	x: FixedT, // pixman_fixed_t,
	y: FixedT, // pixman_fixed_t,
}

LineFixed :: struct {
	pi, p2: PointFixed,
}

Vector :: struct {
	vector: [3]FixedT,
}

Transform :: struct {
	mat: [3][3]FixedT,
}

FVector :: struct {
	v: [3]c.double,
}

FTransform :: struct {
	m: [3][3]c.double,
}

Region16Data :: struct {
	size:     c.long,
	numRects: c.long,
}

Rectangle16 :: struct {
	x, y:          c.int16_t,
	width, height: c.uint16_t,
}

Box16 :: struct {
	x1, y1, x2, y2: c.int16_t,
}

Region16 :: struct {
	extents: Box16,
	data:    ^Region16Data,
}


Region32Data :: struct {
	size:     c.long,
	numRects: c.long,
}

Rectangle32 :: struct {
	x, y:          c.int32_t,
	width, height: c.uint32_t,
}

Box32 :: struct {
	x1, y1, x2, y2: c.int32_t,
}

Region32 :: struct {
	extents: Box32,
	data:    ^Region32Data,
}

