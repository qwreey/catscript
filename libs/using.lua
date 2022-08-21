local module = {};

-- using {error,warn,@} from logger
-- =>
-- local logger=_G.logger or require"logger";_G.logger=logger;local error,warn = logger.error,logger.warn
function module.using(str)
    return str:gsub("using[ \n\t]*{[ %w_,]+}[ \n\t]*from[ \n\t]*[%w_.]+");
end

return module;
