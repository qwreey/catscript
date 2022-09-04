local module = {};

local gsub = string.gsub;

function module.newlineEscaper(str)
    return gsub(str,"\\\n","\27n");
end

function module.newlineUnescaper(str)
    return gsub(str,"\27n","\n");
end

return module;
