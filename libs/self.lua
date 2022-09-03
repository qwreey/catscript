local module = {};

local gsub = string.gsub;

local function selfFormatter(front,caller,all,st,mid,ed)
	if (not front) or front == "" then return; end
	if caller ~= "" and caller then
		return ("%sself%s%s"):format(front,caller,all or "")
	elseif st == "[" then
		return ("%sself%s"):format(front,all);
	end
	return ("%sself.%s"):format(front,all);
end

function module.self(str)
	return gsub(str,"([%)}%]; \n\t=%({%[]?)@([%.:]?)((%[?)([^ ]*)(%]?))",selfFormatter);
end

return module;
