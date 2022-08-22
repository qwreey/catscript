local module = {};

local gsub = string.gsub;

local function letFormat(str)
	return ("%slocal "):format(str or "");
end

function module.let(str)
	return gsub(gsub(str,"([|%)}%]; \n\t])let ",letFormat),"$ ?","local ");
end

local function globalFormat(front)
	return ("%s_G."):format(
		(front and front ~= "") and front or " "
	)
end

function module.global(str)
	return gsub(gsub(str,"([|%)}%]; \n\t=%({%[])global[ %.]",globalFormat),"$$ ?","_G.");
end

return module;
