local cjson = require "cjson";
local FileInfo = {};
function FileInfo.new(file, dir, metaDir)
	local self   = {};
	self.file    = file;
	self.dir     = dir;
	self.metaDir = metaDir;
	self.meta    = {};
	self.meta.lastCheck = 0;
	self.meta.exists = false;

	metaPath = metaDir .. self.file .. '.info.json';

	if lfs.attributes(metaPath) then
		self.meta.exists = true;
	end

	self.set = function (self, key, value)
		if(self.meta[key] and not value) then
			return self.meta[key];
		end;
		if(value) then
			self.meta[key] = value;
		end;
	end;

	self.save = function (self)
		local metaFile, err = io.open(metaPath, 'w');
		if metaFile == nil then
		    print("Couldn't open file: "..err)
		else
			local encoded = cjson.encode(self.meta);
			metaFile:write(encoded);
			metaFile:close();
		end
	end;

	return self;
end;

return FileInfo;
