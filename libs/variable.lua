local module = {};

local gsub = string.gsub;

function module.let(str)
	return gsub(gsub(str,"let ","local "),"$ ?","local ");
end

function module.global(str)
	return gsub(gsub(str,"global ","_G."),"$$ ?","_G.");
end

return module;
