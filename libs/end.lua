local module = {};

local gsub = string.gsub;

local function eof(front,back)
	return ("%send%s"):format(
		(front and front ~= "") and front or " ",
		(back and back ~= "") and back or " "
	);
end

function module.eof(str)
	return gsub(str,"([|%)}%]; \n\t=%({%[]?)|([|%)}%]; \n\t=%({%[]?)",eof);
end

return module;
