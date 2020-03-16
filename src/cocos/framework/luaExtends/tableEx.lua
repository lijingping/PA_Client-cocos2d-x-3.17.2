function table.clear(t)
	for i = #t, 1, -1 do
		table.remove(t, k)
	end
end

function table.hasValue(t, value)
	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end

	return false
end

function table.hasKey(t, key)
	for k, v in pairs(t) do
		if k == key then
			return true
		end
	end

	return false
end

function table.clone(t)
	if t == nil then print("table.clone got nil argument") return end
	
	local newTable = {}
	for k,v in pairs(t) do
		if type(v) == "table" then
			local newV = table.clone(v)
			newTable[k] = newV
		else
			newTable[k] = v
		end
	end

	return newTable
end

function table.find(t, obj)
	for k ,v in pairs(t) do 
		if v == obj then
			return k;
		end
	end
	return nil
end

function table.removeObject(t, obj)
	local key = table.find(t, obj)
	if key then
		table.remove(t, k)
	end
end