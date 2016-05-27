local SEED = minetest.get_mapgen_params().seed

-- Returns a boolean for a seed. Use MAX to control the probability.
local cache = {}
local function get_randomseed_boolean(seed)
	local MAX = 0.2

	if cache[seed] ~= nil then
		return cache[seed]
	else
		math.randomseed(seed)
		if math.random() <= MAX then
			cache[seed] = true
			return true
		else
			cache[seed] = false
			return false
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
					if get_randomseed_boolean(SEED + x)
					or get_randomseed_boolean(SEED + y)
					or get_randomseed_boolean(SEED + z) then

						data[p_pos] = minetest.get_content_id("default:stone")
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


minetest.register_on_mapgen_init(function(params) -- Automatically turn on singlenode generator
	minetest.set_mapgen_params({
		mgname = "singlenode"
	})
end)
