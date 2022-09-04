local module = {};

local function class(prefix,str,footer,mode)
    return ("%s%s.__index=%s;%s.new=function(t,...)local i,c,r=,%s.init,%s.constructor;if(c)then;r=c(t,...)else;c=t;end;setmetatable(r,%s);if(i)then;i(r,...)end%s")
    :format(
        prefix,str,str,str,str,str,str,
        footer or ""
    );
end

local find = string.find;
local concat = table.concat;
local sub = string.sub;
local format = string.format;
function module.class(str)
    while true do
        local startAt, endAt, prefix, name, footer, mode =
        find(str,"([|%)}%]; \n\t=%({%[])class[ \n\t]+([_%w%.]+)([\n\t ]*)({?)");

        if not startAt then break; end

        if mode == "{" then
            local findAt = endAt + 1;
            local lev = 1;
            while true do
                local st,ed,this = find(str,"([{}])",findAt);
                if not st then break; end
                this = this or sub(str,st,ed);
                findAt = ed + 1;
                if this == mode then
                    lev = lev + 1;
                else
                    lev = lev - 1;
                end
                if lev <= 0 then break; end
            end
            str = concat{
                sub(str,0,startAt-1),prefix or "",name," = ",sub(str,endAt,findAt-1)," ",
                name,".__index=",name,";",name,".new=function(t,...)local i,c,r=",name,
                ".init,",name,".constructor;if(c)then;r=c(t,...)else;r=t or{};end;setmetatable(r,",name,
                ");if(i)then;i(r,...)end;return(r);end",footer or "",
                sub(str,findAt,-1)
            };
        else
            str = concat{
                sub(str,0,startAt-1),
                format("%s%s.__index=%s;%s.new=function(t,...)local i,c,r=%s.init,%s.constructor;if(c)then;r=c(t,...)else;r=t or{};end;setmetatable(r,%s);if(i)then;i(r,...)end;return(r);end%s",
                    prefix,name,name,name,name,name,name,
                    footer or ""
                ),
                sub(str,endAt+1,-1)
            };
        end
    end

    return str:gsub("([|%)}%]; \n\t=%({%[])class[ \n\t]+([_%w%.]+)([\n\t ]*)({)",class);
end

return module;
