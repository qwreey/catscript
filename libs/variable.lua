local module = {};

local gsub = string.gsub;
local format = string.format;

local function letFormat(str)
	return format("%slocal ",str or "");
end

function module.let(str)
	return
	gsub(
		gsub(
			str,
			"([|%)}%]; \n\t])let ",
			letFormat
		),
		"$ ?",
		"local "
	);
end

local function globalFormat(front)
	return format("%s_G.",
		(front and front ~= "") and front or " "
	)
end

function module.global(str)
	return
	gsub(
		gsub(
			str,
			"([|%)}%]; \n\t=%({%[])global[ %.]",
			globalFormat
		),
		"$$ ?",
		"_G."
	);
end

return module;
