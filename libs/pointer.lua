local module = {};

local format = string.format;
local gsub = string.gsub;
local function ptr(front,name,back)
    return format("%s{read=function()return(%s);end;write=function(_PTR)%s=_PTR;end}%s",front,name,name,back);
end

function module.ptr(str)
    return gsub(str,"([|%)}%]; \n\t=%({%[])ptr ([_%w%.%[%]]+)([|%)}%]; \n\t=%({%[])",ptr);
end

return module;
