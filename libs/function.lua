
local module = {};

local gsub = string.gsub;
local format = string.format;

local function normalFormatter(str,set)
	if set == "-" then return format(" = function(%s)",str); end
	return format("function(%s)",str);
end

local function selfFormatter(str,set)
	local comma = str:gsub("\n \t","") == "" and "" or ",";
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
	["in"] = true;
};
local function headerFormatter(head,func,mode)
	if ignoreHeads[head] then return; end
	return format("%s.%s%s",func,head,mode);
end
function module.headerCall(str)
	return gsub(str,"([%w_]+)[ \t]+([%w_%.]+)[ \t\n]*([%({])",headerFormatter);
end

local find = string.find;
local match = string.match;
local sub = string.sub;
local concat = table.concat;
function module.await(str)
	local lev = 0;
	while true do
		local await,func,start,mode = match(str,"()await[ \t]+([:%._%w]+)[ \t\n]*()([%({])");
		local pattern = mode == "{" and "[{}]" or "[%(%)]";
		if not await then
			break;
		end
		local endat;
		local findat = start;
		while true do
			local st,ed,this = find(str,pattern,findat);
			if not st then break; end
			this = this or sub(str,st,ed);
			findat = ed + 1;
			if this == mode then
				lev = lev + 1;
			else
				lev = lev - 1;
			end
			if lev == 0 then
				endat = ed;
				break;
			end
		end
		local args = sub(str,start,endat);
		local front = sub(str,1,await-1);
		local back = sub(str,endat+1,-1);
		str = concat{front,func,args,":await()",back};
	end
	return str;
end

local keywords = {
	["function"] = 1;
	["do"] = 1;
	["if"] = 1;
	["end"] = -1;
};

function module.async(str)
	local enabled;
	while true do
		local st,fnName,argsStart = match(str,"()async[ \t]+function[ \t\n]*([%.:_%w]+)[ \t\n]*%(()");
		if not st then break; end
		enabled = true;
		local argsEnd = find(str,")",argsStart+1);
		local args = sub(str,argsStart,argsEnd);
		local fnSelf = match(fnName,":");
		local lev = 1;
		local findat = argsStart;
		local endat;
		while true do
			local stThis,edThis,this = find(str,"%a+",findat);
			if not stThis then break; end
			this = this or sub(str,stThis,edThis);
			local keyword = keywords[this];
			findat = edThis + 1;
			if keyword then
				lev = lev + keyword;
				if lev == 0 then
					endat = edThis;
					break;
				end
			end
		end
		if not endat then break; end
		local haveArgs = match(args,"[_%w]");
		str = concat{sub(str,1,st-1),gsub(fnName,":",".")," = ",(fnSelf and fnSelf ~= "") and (haveArgs and haveArgs ~= "" and "async(function(self," or "async(function(self") or "async(function(",sub(str,argsStart,endat),")",sub(str,endat+1,-1)};
	end
	return (enabled and "local promise = promise or require\"promise\"\nlocal async = promise.async\n" or "") .. str;
end

local function tableDefFormatter(name,args)
	if match(name,":") then
		return format("%s = function (self%s%s)",gsub(name,":","."),args:gsub(" \t\n","") == "" and "" or ",",args);
	end
	return format("%s = function (%s)",name,args);
end
function module.tableDef(str)
	return gsub(str,"function[ \t\n]+([_%.:%w]+)[ \t\n]*%(([^%)]*)%)",tableDefFormatter);
end

return module;

