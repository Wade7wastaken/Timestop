addr = {
	timestop = {-- 0x2 mask
		US = 0x8033D480,
		JP = 0x8033C110,
		size = 4
	},
	action = {
		US = 0x8033B17C,
		JP = 0x80339E0C,
		size = 4
	},
	levelIndex = {
		US = 0x8033BAC6,
		JP = 0x8033A756,
		size = 2
	},
	level = {
		US = 0x8033B249,
		JP = 0x80339ED9,
		size = 1
	}
}

function read(location)
	return memory.readsize(addr[location][version], addr[location].size)
end

function write(location, value)
	memory.writesize(addr[location][version], addr[location].size, value)
end

function determineVersion() -- from InputDirection
	if memory.readsize(0x00B22B24, 4) == 1174429700 then -- JP
		return 'JP'
	else -- US
		return 'US'
	end
end

function shouldTimeStop()
	local action = read('action')
	local level = read('level')
	local levelIndex = read('levelIndex')
	return (
	(not(action == 0)) and-- the action is not uninitialized
	(not((levelIndex == 16) and (level == 30))) and-- we aren't in the first bowser fight
	(not((levelIndex == 17) and (level == 33)))-- we aren't in the second bowser fight 
	)
	
end

function main()
	if shouldTimeStop() then
		write('timestop', (read('timestop') | 0x2))
	end
end

version = determineVersion()

print('Version: ' .. version)
emu.atinput(main)