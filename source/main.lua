function __DIR__()
	local path = debug.getinfo(2,'S').source:match("@?(.*/)");
	if(path) then return path; end;
	return '';
end;

function import(file)
	return require(__DIR__() .. file);
end;

function fileExists(file)
	local f = io.open(file, "rb");
	if f then f:close() end;
	return f ~= nil;
end

function readFile(file)
    local f = io.open(file, "rb");
    local content = f:read("*all");
    f:close();
    return content;
end

local Log = import("log");
local FileInfo = import("fileinfo");

Log:write("Script started");

local uploadDir = "/DCIM";
local infoDir   = "./" .. __DIR__() .. "../data/fileinfo";
local tokenFile = __DIR__() .. "auth.token";

Log:write("Auth token...");

if(not fileExists(tokenFile)) then
	Log:write("Getting token...");
	Log:write(tokenFile);
else
	Log:write("Token exists, removing.");
	Log:write(tokenFile);
	os.remove(tokenFile);
end;

result = fa.HTTPGetFile("http://subspace2.seanmorr.is/auth?api", tokenFile);

Log:write("Connecting to socket...");

res = fa.websocket{mode = "open", address = "ws://subspace2.seanmorr.is:9998/"}

Log:write("Connected!");

for token in io.lines(tokenFile) do
	Log:write("Sending auth...");
	res = fa.websocket{mode = "send", payload = "auth " .. token, type = 1}	
	res, type, payload = fa.websocket{mode = "recv", tout = 5000};
	Log:write(payload);
end;

Log:write("Sending hello...");

res, type, payload = fa.websocket{mode = "recv", tout = 5000};

Log:write(payload);

res = fa.websocket{mode = "send", payload = "pub flashair:0 hello from FlashAir LUA!", type = 1}

Log:write("Checking dir '" .. uploadDir .. "'...");

for file in lfs.dir(uploadDir) do
	local filepath = uploadDir ..  '/' .. file;
	local filemode = lfs.attributes(filepath, 'mode');

	Log:write("File " .. filepath);
	Log:write("mode " .. filemode);

	if (filemode == 'file' and string.sub(file, 1, 1) ~= ".") then
		Log:write("Sending file '" .. filepath .. "'.");
		res = fa.websocket{mode = "send", payload = "pub flashair:0 " .. filepath, type = 1}
		res = fa.websocket{mode = "send", payload = "pub 0 " .. readFile(filepath), type = 1}
	end;

	-- 	fileInfo = FileInfo.new(file, uploadDir, infoDir);

	-- 	if(not fileInfo.meta.exists) then
	-- 		Log:write("Uploading '" .. uploadDir .. file .. "'.");
	-- 		fileInfo:save();
	-- 	end;
end;

Log:write("Script Completed.");
