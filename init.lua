local strParser = require("str").run;
local formatter = require("str").formatter;

-- todo
-- extend 문법
-- using 문법
-- *= 문법 우선순위 지정. 즉 () 넣기
-- await 문법 수정 (파일참조 ./libs/function.lua)
-- try 문법

local extensions = {
	require("newlines").newlineEscaper;
	require("operator").operator;
	require("operator").whenopt;
	require("self").self;
	require("variable").global;
	require("variable").let;
	require("function").arrow;
	require("logical").compare;
	require("logical").null;
	require("logical").operator;
	require("end").eof;
	require("comment").comment;
	require("function").async;
	require("function").await;
	require("function").headerCall;
	require("function").tableDef;
	require("classer").class;
	require("pointer").ptr;
	require("newlines").newlineUnescaper;
	-- require("using").using;
};

local module = {};
local insert = table.insert;
local concat = table.concat;

function module.compile(str,env)
	env = env or {};

	-- parse string
	local strParsed = strParser(str);

	-- run extensions and make output
	local full,strs,stri = {" "},{},1;
	for _,this in ipairs(strParsed) do
		local m,tstr = this.m,this.s;
		tstr:gsub("\r","");
		if not m then
			insert(full,tstr);
		elseif m == 1 then -- "
			local newlineCount = 0;
			for _ in tstr:gmatch("\n") do
				newlineCount = newlineCount + 1;
			end
			insert(strs,('("%s")%s'):format(
				tstr:gsub("\n","\\n"),
				("\n"):rep(newlineCount)
			));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		elseif m == 2 then -- '
			local newlineCount = 0;
			for _ in tstr:gmatch("\n") do
				newlineCount = newlineCount + 1;
			end
			insert(strs,("('%s')%s"):format(
				tstr:gsub("\n","\\n"),
				("\n"):rep(newlineCount)
			));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		elseif m == 3 then -- `
			-- local spec = tstr:match("(\n *)$");
			-- tstr = tstr:gsub(spec or "\n","\n");
			local newlineCount = 0;
			for _ in tstr:gmatch("\n") do
				newlineCount = newlineCount + 1;
			end
			local estr = ("\"%s\"%s"):format(
				tstr:gsub("\n","\\n"):gsub("'","\\'"):gsub('"','\\"'),
				("\n"):rep(newlineCount)
			);
			insert(strs,formatter(estr));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		elseif m == 4 then -- [[
			insert(strs,("([[%s]])"):format(tstr));
			insert(full,("\27%d\27"):format(stri));
			stri = stri + 1;
		end
	end

	insert(full," ");
	local stro = concat(full);
	for _,func in ipairs(extensions) do
		stro = func(stro,env);
	end
	stro = stro:gsub("^ ",""):gsub(" $","");

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
