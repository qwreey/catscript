local module = {};

local gsub = string.gsub;

local function letFormat(str)
	return ("%slocal "):format(str or "");
end

function module.let(str)
	return gsub(gsub(str,"([|%)}%]; \n\t])let ",str),"$ ?","local ");
end

local function globalFormat(front,back)
	return ("%sG_%s"):format(
		(front and front ~= "") and front or " ",
		(back and back ~= "") and back or " "
	)
end

function module.global(str)
	return gsub(gsub(str,"([|%)}%]; \n\t=%({%[])global[ %.]",globalFormat),"$$ ?","_G.");
end

return module;
