local AppBase = class("AppBase")

local SCENE_ROOT = "app.scenes"
-- local DEFAULT_SCENE = (CC_ENABLE_HOT_UPDATE and "WelcomeScene" or "LoginScene")
local DEFAULT_SCENE = "WelcomeScene" --"ZZTestScene" "DemoBattlePreScene"

function AppBase:ctor()
    self.m_runningScene = nil;      --当前的场景
    self.m_runningSceneName = "";   --当前场景的名称

    -- self.m_lastScene = nil;      --上一个场景
    self.m_lastSceneName = "";   --上一个场景的名称

    -- if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS);
    -- end

    if self.onCreate then
        self:onCreate()
    end
end

-- 启动应用
function AppBase:run()
    self:enterScene(DEFAULT_SCENE)
end

function AppBase:getRunningScene()
    return self.m_runningScene;
end

function AppBase:getRunningSceneName()
    return self.m_runningSceneName;
end

-- function AppBase:getLastScene()
--     return self.m_lastScene;
-- end

function AppBase:getLastSceneName()
    return self.m_lastSceneName;
end

-- 进入场景
function AppBase:enterScene(sceneName, transition, time, more)
    local scene = self:createScene(sceneName)
    if scene == nil then
        print("创建场景" .. sceneName .. "失败。")
        return
    end
    
    if self.m_runningScene and self.m_runningSceneName ~= "" then
        --self.m_lastScene = self.m_runningScene;
        self.m_lastSceneName = self.m_runningSceneName;
    end

    self.m_runningScene = scene;
    self.m_runningSceneName = sceneName;

    display.runScene(scene, transition, time, more)
    return scene
end

function AppBase:createScene(name)
    local packageName = string.format("%s.%s", SCENE_ROOT, name)
    local status, scene = xpcall(
        function()
            return require(packageName)
        end, 
        function(msg)
            print(string.format("%s相关的Lua文件读取失败，文件存在问题。", packageName))--查看是否有中文符号或者多余的符号，是否多存在多余字母，再查语法错误
        end
    )

    if not status then
        return nil
    end

    local t = type(scene)
    if t == "table" or t == "userdata" then
        return scene:create(name)
    end
end


return AppBase
