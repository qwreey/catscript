
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

local find = string.find;
local match = string.match;
local sub = string.sub;
local concat = table.concat;
function module.await(str)
	local lev = 0;
  while true do
    local await,func,start = match(str,"()await[ \n\t]+([:%._%w]+)%()(");
    if not await then
      break;
    end
    local endat;
    local findat = start;
    while true do
	  	local _,ed,this = find(str,"[%(%)]",findat);
      findat = ed + 1;
	  	if this == "(" then
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

local keywords = [
  ["function"] = 1;
  ["do"] = 1;
  ["then"] = 1;
  ["end"] = - 1;
];

function module.async(str)
  while true do
    local st,fnName,fnArgs = match("()async[ \t\n]+function[ \t\n]-([%.:_%w]+)%(()");
    if not st then break; end
    local fnSelf = match(str,":");
    fnName = gsub(fnName,":",".");
    local lev = 1;
    local findat = fnArgs;
    local endat;
    while true do
      local stThis,edThis,this = find(str,"%a+",);
      local keyword = keywords[this];
      if keyword then
        lev = lev + keyword;
        if lev == 0 then
          endat = edThis + 1;
        end
      end
    end
    
  end
  
  local st,ed, = find(str);
end

return module;

