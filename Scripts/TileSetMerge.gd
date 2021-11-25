extends TileSet
# "tool" makes this also apply when placing tiles by hand in the tilemap editor too.
tool

const PLAINS = 0
const SEA = 3
const RIVER = 5
const SHOAL = 6

var binds = {
	SHOAL: [PLAINS],
	SEA: [RIVER, SHOAL],
	RIVER: [SEA, SHOAL],
}

func _is_tile_bound(id, neighbour_id):
	if id in binds:
		return neighbour_id in binds[id]
	return false
