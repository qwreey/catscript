local strParser = require("str").run;
local formatter = require("str").formatter;

local extensions = {
	require("newline").newline;
	require("operator").operator;
	require("operator").whenopt;
	require("function").arrow;
	require("self").self;
	require("variable").let;
	-- require("variable").global;
	require("logical").compare;
	require("logical").null;
	require("logical").operator;
	require("end").eof;
	require("comment").comment;
	require("function").async;
	require("function").await;
	require("function").headerCall;
	require("function").tableDef;
	require("newline").clean;
};

local module = {};
local insert = table.insert;
local concat = table.concat;

function module.compile(str,env)
	env = env or {};

	-- parse string
	local strParsed = strParser(str);

	-- run extensions and make output
	local full,strs,stri = {},{},1;
	for _,this in ipairs(strParsed) do
		local m,tstr = this.m,this.s;
		tstr:gsub("\r","");
		if not m then
			insert(full,tstr);
		elseif m == 1 then -- "
			insert(strs,('"%s"'):format(tstr:gsub("\n","\\n")));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		elseif m == 2 then -- '
			insert(strs,("'%s'"):format(tstr:gsub("\n","\\n")));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		elseif m == 3 then -- `
			-- local spec = tstr:match("(\n *)$");
			-- tstr = tstr:gsub(spec or "\n","\n");
			local estr = ("\"%s\""):format(tstr:gsub("\n","\\n"):gsub("'","\\'"):gsub('"','\\"'));
			insert(strs,formatter(estr));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		elseif m == 4 then -- [[
			insert(strs,("[[%s]]"):format(tstr));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		end
	end

	local stro = concat(full);
	for _,func in ipairs(extensions) do
		stro = func(stro,env);
	end

	return stro:gsub(
		"\27(%d+)\27",function (index)
			return strs[tonumber(index)];
		end
	),env;
end

function module.upgradeString()
	pcall(require,"upgradeString");
end

return module;
