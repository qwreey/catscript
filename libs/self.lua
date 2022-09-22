local module = {};

local gsub = string.gsub;

local function selfFormatter(front,index,caller,all,st,mid,ed)
	if (not front) or front == "" then return; end
	if index ~= "" and index then
		return ("%sself.%s%s%s"):format(front,index,caller or "",all or "")
	elseif caller ~= "" and caller then
		return ("%sself%s%s"):format(front,caller,all or "")
	elseif st == "[" then
		return ("%sself%s"):format(front,all);
	end
	return ("%sself%s"):format(front,all);
end

function module.self(str)
	return gsub(str,"([,%)}%]; \n\t=%({%[%+%-%*%%%^=]?)@([%w_]*)([%.:]?)((%[?)([^ ]*)(%]?))",selfFormatter);
end

return module;
