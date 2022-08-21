local module = {};

local gsub = string.gsub;

local function letFormat(str)
	return ("%slocal "):format(str or "");
end

function module.let(str)
	return gsub(gsub(str,"([|%)}%]; \n\t])let ",str),"$ ?","local ");
end

-- function module.global(str)
-- 	return gsub(gsub(str,"global ","_G."),"$$ ?","_G.");
-- end

return module;
