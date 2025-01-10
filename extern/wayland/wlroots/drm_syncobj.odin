package wlroots
import "core:c"

DRMSyncObjTimeline :: struct {
	drm_fd:      c.int,
	handle:      c.uint32_t,
	addons:      AddonSet,
	WLR_PRIVATE: struct {
		n_refs: c.size_t,
	},
}

