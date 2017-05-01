local Utils = {}

--[[
---------------------------------------------------
                   L O G G I N G
---------------------------------------------------
--]]

function Utils.log(...)
	-- Isaac.DebugString("- - " .. Isaac.GetTime() .. " -- " .. tostring(str))
	-- Isaac.DebugString("- - - - - " .. tostring(str))
	local args = table.pack(...)
	local result = ""
	
	if #args > 1 then
		result = tostring(args[1]) .. ": "
	end
	
	for i = #args>1 and 2 or 1, #args, 1 do
		result = result .. tostring(args[i])
	end
	
	Isaac.DebugString(result)
end

function Utils.logTable(...)
	local args = table.pack(...)
	local result = ""
	
	if #args > 1 then
		result = tostring(args[1]) .. ": "
	end
	
	for i = #args>1 and 2 or 1, #args, 1 do
		result = result .. "\n  TABLE :\n" .. Utils.table_print(args[i], 2)
	end
	
	Isaac.DebugString(result)
	-- Isaac.DebugString("\n----------\n  TABLE :\n" .. Utils.table_print(tab, 2) .. "----------")
end

function Utils.table_print (tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == "table" then
		local sb = {}
		for key, value in pairs (tt) do
			table.insert(sb, string.rep ("  ", indent)) -- indent it
			if type (value) == "table" and not done [value] then
				done [value] = true
				table.insert(sb, "{\n");
				table.insert(sb, Utils.table_print (value, indent + 2, done))
				table.insert(sb, string.rep ("  ", indent)) -- indent it
				table.insert(sb, "}\n");
			elseif "number" == type(key) then
				table.insert(sb, string.format("\"%s\"\n", tostring(value)))
			else
				table.insert(sb, string.format(
				"%s = \"%s\"\n", tostring (key), tostring(value)))
			end
		end
		return table.concat(sb)
	else
		return " -- " .. tostring(tt) .. "\n"
	end
end

function Utils.to_string(tbl)
	if "nil" == type(tbl) then
		return tostring(nil)
	elseif "table" == type(tbl) then
		return Utils.table_print(tbl)
	elseif "string" == type(tbl) then
		return tbl
	else
		return tostring(tbl)
	end
end

--[[
---------------------------------------------------
                   U T I L S
---------------------------------------------------
--]]

function Utils.table_val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
		  return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and Utils.table_tostring( v ) or tostring( v )
	end
end

function Utils.table_key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. Utils.table_val_to_str( k ) .. "]"
	end
end

function Utils.table_tostring( tbl )
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, Utils.table_val_to_str( v ) )
		done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] then
			table.insert( result,
			Utils.table_key_to_str( k ) .. "=" .. Utils.table_val_to_str( v ) )
		end
	end
	return "{" .. table.concat( result, "," ) .. "}"
end

return Utils