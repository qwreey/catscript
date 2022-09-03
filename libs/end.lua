local module = {};

local gsub = string.gsub;

local function eof(front,back)
	return ("%send%s"):format(
		(front and front ~= "") and front or " ",
		(back and back ~= "") and back or " "
	);
end

function module.eof(str)
	return
	gsub(
		gsub(
			str,
			"([%)}%]; \n\t=%({%[]?)|([%)}%]; \n\t=%({%[]?)",
			eof
		)
		,"end\n end",
		"end\nend"
	);
end

return module;
