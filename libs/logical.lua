
local module = {};

local gsub = string.gsub;

function module.operator(str)
	return gsub(gsub(gsub(str,
		" ?|| ?"," or "),
		" ?&& ?"," and "),
		"! ?","not "
	);
end

function module.compare(str)
	return gsub(str,"!=","~=");
end

local function nullFormatter(st,ed)
	return ("%snil%s"):format(st or "",ed or "");
end
function module.null(str)
	return gsub(str,"([,%)}%]; \n\t=%({%[]?)null([,%)}%]; \n\t=%({%[]?)",nullFormatter);
end

return module;
