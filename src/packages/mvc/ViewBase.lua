local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(scene, name)
    self:enableNodeEvents()
    self.m_strFullName = name   --这个view的name有点鸡肋
   
    self:setPosition(cc.p(0,0))

    self.m_bottom = 0;
    self.m_top = display.size.height;
    self.m_left = 0;
    self.m_right = display.size.width;

    self.m_height = display.size.height;
    self.m_width = display.size.width;

    if self.onCreate then 
        self:onCreate()
    end
end

function ViewBase:getName()
    local function split(szFullString, szSeparator)
        local nFindStartIndex = 1  
        local nSplitIndex = 1  
        local nSplitArray = {}  
        while true do  
           local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
           if not nFindLastIndex then  
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
            break  
           end  
           nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
           nFindStartIndex = nFindLastIndex + 1 --点号为特殊符号，长度设为1，其他情况用string.len(szSeparator)  
           nSplitIndex = nSplitIndex + 1  
        end  
        return nSplitArray 
    end
    -- 传过来的name一般格式为"***.***"，例如"loginView.LoginView"，后半部分为view的lua文件名
    local nameList = split(self.m_strFullName, "%.");
    return nameList[2];
end

function ViewBase:addContent(contentNode)
	self:add(contentNode)
end

function ViewBase:createFrameLayer()
    print("ViewBase:createFrameLayer()")

    local width, height = display.getFullScreenSize() -- 1280 720

    local frameLayer = cc.Layer:create()
    frameLayer:setContentSize(cc.size(width, 960))

    frameLayer:ignoreAnchorPointForPosition(false)
    frameLayer:setAnchorPoint(cc.p(0.5, 0.5))
    frameLayer:move(cc.p(640, 480))
    frameLayer:setScale(display.scale)

    frameLayer.center = cc.p(512 , 384)

    local configHeight = display.designHeight;
    local heightDown = display.heightDown

    frameLayer.bottom = 0 - heightDown*0.5
    frameLayer.top = height + heightDown*0.5
    
    frameLayer.left = 0
    frameLayer.right = display.size.width--1136

    frameLayer.width = display.size.width
    frameLayer.height = display.size.height

    return frameLayer
end

return ViewBase
