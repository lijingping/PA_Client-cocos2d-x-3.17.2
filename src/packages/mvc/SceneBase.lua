local SceneBase = class("SceneBase", cc.Scene)


local VIEW_ROOT = "app.views"

function SceneBase:ctor(name)
	if self.onCreate then 
        self:onCreate();
    end
end

-- 初始化view
function SceneBase:initView(name)
    if name == nil then
        print("SceneBase:initView name is nil")
        return
    end
    local view = self:createView(name)
    
    if view == nil then
        print("SceneBase:initView ".. name .. " is nil")
        return
    end

    self.m_viewBase = view;
    self:add(view);

    return view
end

function SceneBase:getViewBase()
    return self.m_viewBase;
end

function SceneBase:createView(name)
    local packageName = string.format("%s.%s", VIEW_ROOT, name)
    
    local status, view = xpcall(
        function()
            return require(packageName)
        end, 

        function(msg)
            if not string.find(msg, string.format("'%s' not found:", packageName)) then
                print("load view error: ", msg)
            end
        end)

    local t = type(view)
    if status and (t == "table" or t == "userdata") then
        return view:create(self, name)
    end
    error(string.format("SceneBase:createView() - not found view \"%s\" in search paths \"%s\"",
        name, table.concat(self.configs_.viewsRoot, ",")), 0)
end

return SceneBase
