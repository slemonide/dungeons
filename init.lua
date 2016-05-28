local SEED = minetest.get_mapgen_params().seed
local MAX = 0.2
local AREA = 50 -- Controls the minumum sizes of the walls

-- Nodes that can make the walls
local NODES = {
	"default:stone",
	"default:cobble",
	"default:mossycobble",
	"default:stonebrick",
	"default:sandstonebrick",
	"default:desert_stonebrick",
	"default:obsidianbrick",
	"default:brick",
}

-- Returns a boolean for a seed. Use MAX to control the probability.
local cache = {}
local function get_randomseed_boolean(seed)
	if cache[seed] ~= nil then
		return cache[seed]
	else
		math.randomseed(seed)
		if math.random() <= MAX then
			cache[seed] = true
			get_randomseed_boolean(seed)
		else
			cache[seed] = false
			get_randomseed_boolean(seed)
		end
	end
end

minetest.register_on_generated(function(minp, maxp, seed)

	local t1 = os.clock()
	local geninfo = "[mg] generates..."
	minetest.chat_send_all(geninfo)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for x=minp.x,maxp.x do
		for z=minp.z,maxp.z do
			for y=minp.y,maxp.y do
				if x < 100 then -- for debug

					local p_pos = area:index(x, y, z)
					if get_randomseed_boolean(SEED + x + math.floor((y + z) / AREA))
					or get_randomseed_boolean(SEED + y + math.floor((x + z) / AREA))
					or get_randomseed_boolean(SEED + z + math.floor((x + y) / AREA)) then

						local node = NODES[math.random(#NODES)]
						data[p_pos] = minetest.get_content_id(node)
					end
				end
			end
		end
	end

	local t2 = os.clock()
	local calcdelay = string.format("%.2fs", t2 - t1)

	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	local t3 = os.clock()
	local geninfo = "[mg] done after ca.: "..calcdelay.." + "..string.format("%.2fs", t3 - t2).." = "..string.format("%.2fs", t3 - t1)
	print(geninfo)
	minetest.chat_send_all(geninfo)
end)

-- Minetest lightning system sucks
minetest.register_node("dungeons:light", {
    description = "Light",
    drawtype = "airlike",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    climbable = false,
    paramtype = "light",
    light_source = 12,
    sunlight_propagates = true,
    groups = {not_in_creative_inventory=1},
})

minetest.register_alias("mapgen_singlenode", "dungeons:light")
minetest.register_on_mapgen_init(function(params) -- Automatically turn on singlenode generator
	minetest.set_mapgen_params({
		mgname = "singlenode"
	})
end)
