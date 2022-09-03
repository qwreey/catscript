local module = {};

local gsub = string.gsub;

local function selfFormatter(front,all,st,mid,ed)
	if (not front) or front == "" then return; end
	if st == "[" then
		return ("%sself%s"):format(front,all);
	end
	return ("%sself.%s"):format(front,all);
end

function module.self(str)
	return gsub(str,"([%)}%]; \n\t=%({%[]?)@((%[?)([^ ]*)(%]?))",selfFormatter);
end

return module;
