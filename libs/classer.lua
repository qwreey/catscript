local module = {};

local function class(prefix,str,footer,mode)
    return ("%s%s.__index=%s;%s.new=function(t,...)local i,c,r=,%s.init,%s.constructor;if(c)then;r=c(t,...)else;c=t;end;setmetatable(r,%s);if(i)then;i(r,...)end")
    :format(prefix,str,str,str,str,str,str);
end

function module.class(str)
    return str:gsub("([|%)}%]; \n\t=%({%[])class[ \n\t]+([_%w%.]+)([\n\t ]*)({)",class);
end

return module;
