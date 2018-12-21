local Log     = {};

local logPath = '/uploader/logs/log.txt';
local logFile = io.open (logPath, 'a');
local logId   = math.random(1000,9999);
local started = false;

math.randomseed(os.time());

local function write(self, line)
	if(not started) then
		started = true;
		logFile:write("--\n")
	end;

	logFile:write(string.format(
		"[%d]::[%d]\t%s\n"
		, logId
		, os.time()
		, line
	));
end;

Log.write = write;

return Log;