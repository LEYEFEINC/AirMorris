local Log = import("log");
local FileInfo = {};
function FileInfo.new(file, dir)
	local self   = {};
	self.file    = file;
	self.dir     = dir;
	self.metaDir = "/uploader/data/fileinfo";
	self.meta    = {};
	self.meta.lastCheck = 0;
	self.meta.exists = false;

	local metaPath = self.metaDir .. "/" .. file .. '.info.json';

	Log:write("Meta file... " .. metaPath)

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
		Log:write("Saving file " .. metaPath)
		local metaFile, err = io.open(metaPath, 'a');
		if metaFile == nil then
		    Log:write("Couldn't open file: "..err)
		else
			local encoded = cjson.encode(self.meta);
			metaFile:write(encoded);
			metaFile:close();
		end
	end;

	return self;
end;

return FileInfo;
