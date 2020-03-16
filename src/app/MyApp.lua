if CC_ENABLE_HOT_UPDATE then
	local savepath = device.writablePath.."com.gamerboom.pademo/";
	cc.FileUtils:getInstance():addSearchPath(device.writablePath, true);
	cc.FileUtils:getInstance():addSearchPath(savepath.."res", true);
	cc.FileUtils:getInstance():addSearchPath(savepath.."src", true);
	cc.FileUtils:getInstance():addSearchPath(savepath, true);
end
------------------------
-- 定义MyApp，继承AppBase
------------------------
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
end

return MyApp
