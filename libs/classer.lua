local module = {};

local function class(prefix,str)
    return ("%s%s.__index=%s;%s.new=function(t)local r,i=setmetatable(t,%s),%s.init;if(i)then;i(r)end;return r;end")
    :format(prefix,str,str,str,str,str);
end

function module.class(str)
    return str:gsub("([|%)}%]; \n\t=%({%[])class[ \n\t]+([_%w%.]+)",class);
end

return module;