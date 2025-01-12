package wlroots
import "core:c"
ColorTransform :: struct {
	ref_count: c.int,
	addons:    AddonSet,
	type:      ColorTransformType,
}
ColorTransformType :: enum c.int {
	SRGB,
	Lut_3D,
}
