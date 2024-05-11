local addr = {
	timestop = {
		US = 0x8033D480,
		JP = 0x8033C110,
		size = 4,
	},
	action = {
		US = 0x8033B17C,
		JP = 0x80339E0C,
		size = 4,
	},
	levelIndex = {
		US = 0x8033BAC6,
		JP = 0x8033A756,
		size = 2,
	},
	level = {
		US = 0x8033B249,
		JP = 0x80339ED9,
		size = 1,
	},
}

local set_timestop_for = {
	[0] = false, -- unknown
	true, -- enabled
	false, -- dialog
	false, -- mario and doors
	false, -- all objects
	false, -- mario opened door
	false, -- active
}

local function determineVersion() -- from InputDirection
	if memory.readsize(0x00B22B24, 4) == 1174429700 then -- JP
		return "JP"
	else -- US
		return "US"
	end
end

local version = determineVersion()

local function read(location)
	return memory.readsize(addr[location][version], addr[location].size)
end

local function write(location, value)
	memory.writesize(addr[location][version], addr[location].size, value)
end

local function shouldntTimeStop()
	local action = read("action")

	local function uninitializedAction()
		return action == 0
	end

	local level = read("level")
	local levelIndex = read("levelIndex")

	local function inFirstBowserFight()
		return levelIndex == 16 and level == 30
	end
	local function inSecondBowserFight()
		return levelIndex == 17 and level == 33
	end
	local function inThirdBowserFight()
		return levelIndex == 18 and level == 34
	end

	return uninitializedAction() or
		inFirstBowserFight() or
		inSecondBowserFight() or
		inThirdBowserFight()
end

emu.atinput(function()
	if shouldntTimeStop() then return end

	local new_timestop = read("timestop")
	for k, v in pairs(set_timestop_for) do
		if v then
			new_timestop = new_timestop | 2 ^ k
		end
	end
	write("timestop", new_timestop)
end)
