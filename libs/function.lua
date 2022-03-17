
local module = {};

local gsub = string.gsub;
local format = string.format;

local function normalFormatter(str,set)
	if set == "-" then return format(" = function(%s)",str); end
	return format("function(%s)",str);
end

local function selfFormatter(str,set)
	local comma = str == "" and "" or ",";
	if set == "=" then return format(" = function(self%s%s)",comma,str); end
	return format("function(self%s%s)",comma,str);
end

function module.arrow(str)
	return gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(str,
		" ?%(([^%(%)%-%%%+=%?:'\\\"\n]-)%) ?%-(%-?)>",normalFormatter),
		" ?([%w_]-) ?%-(%-?)>",normalFormatter),
		" ?%(([^%(%)%-%%%+=%?:'\\\"\n]-)%) ?=(=?)>",selfFormatter),
		" ?([%w_]-) ?=(=?)>",selfFormatter),
		" ?%-%->"," = function()"),
		" ?==>"," = function(self)"),
		" ?%->"," function()"),
		" ?=>"," function(self)"
	)
end

local ignoreHeads = {
	["return"] = true;
	["function"] = true;
	["end"] = true;
	["or"] = true;
	["and"] = true;
	["then"] = true;
	["if"] = true;
	["do"] = true;
	["local"] = true;
	["else"] = true;
	["elseif"] = true;
	["while"] = true;
	["repeat"] = true;
	["until"] = true;
};
local function headerFormatter(head,func)
	if ignoreHeads[head] then return; end
	return format("%s.%s("):format(head,func);
end

function module.headerCall(str)
	return gsub(str,"([%w_]+) ([%w_%.]+) -%(")
end

function module.await(str)
	local lev = 0;
	while true do
		if this == "(" then
			lev = lev + 1;
		else
			lev = lev - 1;
		end
		if lev == 0 then
			break;
		end
		gmatch("[%(%)]");
	end
end

return module;
