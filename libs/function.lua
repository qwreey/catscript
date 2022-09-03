
local module = {};

local gsub = string.gsub;
local format = string.format;
local match = string.match

local function normalFormatter(head,prefix1,fnname,prefix2,str,set)
	if set == "-" then
		if head == "local" and fnname then
			return format("local function %s(%s)",fnname,str);
		end
		return format("%s%s%s = function(%s)",head or "",prefix1 or "",fnname or "",str);
	end

	return format("%s%s%s%s%sfunction(%s)",
		head or "",prefix1 or "",fnname or "",prefix2 or "",
		(((prefix2 == "" and fnname ~= "" and fnname)
		or (prefix1 == "" and head ~= "" and head))) and " " or "",
		str
	);
end

local function normalFormatterNoBracket(head,prefix1,fnname,prefix2,str,set)
	if str == "" and fnname == "" then
		str = head;
		head = "";
	elseif str == "" then
		str = fnname;
		fnname = head;
		head = "";
	end
	if set == "-" then
		if head == "local" and fnname then
			return format("local function %s(%s)",fnname,str);
		end
		return format("%s%s%s = function(%s)",head or "",prefix1 or "",fnname or "",str);
	end

	return format("%s%s%s%s%sfunction(%s)",
		head or "",prefix1 or "",fnname or "",prefix2 or "",
		(((prefix2 == "" and fnname ~= "" and fnname)
		or (prefix1 == "" and head ~= "" and head))) and " " or "",
		str
	);
end

local function selfFormatter(head,prefix1,fnname,prefix2,str,set)
	local comma = gsub(str,"\n \t","") == "" and "" or ",";
	if set == "=" then
		if head == "local" and fnname then
			return format("local function %s(self%s%s)",fnname,comma,str);
		end
		return format("%s%s%s = function(self%s%s)",head or "",prefix1 or "",fnname or "",comma,str);
	end
	return format("%s%s%s%s%sfunction(self%s%s)",
		head or "",prefix1 or "",fnname or "",prefix2 or "",
		(((prefix2 == "" and fnname ~= "" and fnname)
		or (prefix1 == "" and head ~= "" and head))) and " " or "",
		comma,str
	);
end

local function selfFormatterNoBracket(head,prefix1,fnname,prefix2,str,set)
	if str == "" and fnname == "" then
		str = head;
		head = "";
	elseif str == "" then
		str = fnname;
		fnname = head;
		head = "";
	end
	local comma = gsub(str,"\n \t","") == "" and "" or ",";
	if set == "=" then
		if head == "local" and fnname then
			return format("local function %s(self%s%s)",fnname,comma,str);
		end
		return format("%s%s%s = function(self%s%s)",head or "",prefix1 or "",fnname or "",comma,str);
	end
	return format("%s%s%s%s%sfunction(self%s%s)",
		head or "",prefix1 or "",fnname or "",prefix2 or "",
		(((prefix2 == "" and fnname ~= "" and fnname)
		or (prefix1 == "" and head ~= "" and head))) and " " or "",
		comma,str
	);
end

function module.arrow(str)
	return gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(str,
		"(%w*)( ?)([%w_]*)( ?)%(([^%(%)%-%%%+=%?:'\\\"\n]-)%) ?%-(%-?)>",normalFormatter),
		"(%w*)( ?)([%w_]*)( ?)([%w_]*) ?%-(%-?)>",normalFormatterNoBracket),
		"(%w*)( ?)([%w_]*)( ?)%(([^%(%)%-%%%+=%?:'\\\"\n]-)%) ?=(=?)>",selfFormatter),
		"(%w*)( ?)([%w_]*)( ?)([%w_]*) ?=(=?)>",selfFormatterNoBracket),
		" ?%-%->"," = function()"),
		" ?==>"," = function(self)"),
		" ?%->"," function()"), -- not used? idk
		" ?=>"," function(self)" -- not used? idk
	)
end

local ignoreHeads = {
	["class"] = true;
	["not"] = true;
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
	if ignoreHeads[head] or ignoreHeads[func] then return; end
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
		local await,prefix,func,start,mode = match(str,"()([|%)}%]; \n\t=%({%[])await[ \t]+([:%._%w]+)[ \t\n]*()([%({])");
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
				-- we need to fix await asdf().asdf => asdf():await().asdf to asdf().asdf:await()
				-- local indexerStart,indexerEnd,indexerPrefix,indexer
				-- = find(str,"^([ \n]*)([%.:%[])",st);
				endat = ed;
				break;
			end
		end
		local args = sub(str,start,endat);
		local front = sub(str,1,await-1);
		local back = sub(str,endat+1,-1);
		str = concat{prefix or "",front,func,args,":await()",back};
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
		local st,prefix,fnSetted,fnName,argsStart = match(str,"()([,|%)}%]; \n\t=%({%[])async[ \t]+([%._%w]*[ \t]*=?[ \t]*)function[ \t\n]*([%.:_%w]*)[ \t\n]*%(()");
		local isNoneNamed = fnName == "";
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
		str = concat{sub(str,1,st-1),
			prefix or "",
			fnSetted or "",
			isNoneNamed and "" or gsub(fnName,":","."),
			isNoneNamed and "" or " = ",
			(fnSelf and fnSelf ~= "") and (haveArgs and haveArgs ~= "" and "async(function(self," or "async(function(self") or "async(function(",
			sub(str,argsStart,endat),
			")",
			sub(str,endat+1,-1)
		};
	end
	return (enabled and "local promise = promise or require\"promise\";local async = promise.async " or "") .. str;
end

local function tableDefFormatter(head,name,args)
	if head == "local" then return; end
	if match(name,":") then
		return format("%s = function (self%s%s)",gsub(name,":","."),args:gsub(" \t\n","") == "" and "" or ",",args);
	end
	return format("%s = function (%s)",name,args);
end
function module.tableDef(str)
	return gsub(str,"(%w*) *function[ \t\n]+([_%.:%w]+)[ \t\n]*%(([^%)]*)%)",tableDefFormatter);
end

return module;
