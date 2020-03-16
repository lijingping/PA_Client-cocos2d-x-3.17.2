if nil == cc.CCBReader then
    return
end

local function bindingCode(userdata, className)

    local status, ccbCode = xpcall(
        function() return require("app.views." .. className) end, 
        function() print("cann't find app.views." .. className) end)

    if not status then
        return
    end

    for k, v in pairs(ccbCode) do
        if not userdata[k] then
            userdata[k] = v
        end
    end
end

function CCBLoader(strFilePath)

    local proxy     = cc.CCBProxy:create()
    local ccbReader = proxy:createCCBReader()
    local node      = ccbReader:load(strFilePath)
    
    local nodesWithAnimationManagers = ccbReader:getNodesWithAnimationManagers()
    local animationManagersForNodes  = ccbReader:getAnimationManagersForNodes()

    for i = 1 , table.getn(nodesWithAnimationManagers) do

        local animationManager = tolua.cast(animationManagersForNodes[i], "cc.CCBAnimationManager")
        local documentControllerName = animationManager:getDocumentControllerName()
        local rootNode = animationManager:getRootNode()

        bindingCode(rootNode, documentControllerName)

        --Callbacks
        local documentCallbackNames = animationManager:getDocumentCallbackNames()
        local documentCallbackNodes = animationManager:getDocumentCallbackNodes()
        local documentCallbackControlEvents = animationManager:getDocumentCallbackControlEvents()

        for i = 1, table.getn(documentCallbackNames) do
            local callbackName = documentCallbackNames[i]
            local callbackNode = tolua.cast(documentCallbackNodes[i],"cc.Node")

            if "" ~= documentControllerName and nil ~= rootNode then
                if "function" == type(rootNode[callbackName]) then
                    proxy:setCallback(callbackNode, function() rootNode[callbackName](rootNode) end , documentCallbackControlEvents[i])
                else
                    print("Warning: Cannot found lua function [" .. documentControllerName .. ":" .. callbackName .. "] for docRoot selector")
                end
            end
        end

        --Variables
        local documentOutletNames = animationManager:getDocumentOutletNames()
        local documentOutletNodes = animationManager:getDocumentOutletNodes()

        for i = 1, table.getn(documentOutletNames) do
            local outletName = documentOutletNames[i]
            local outletNode = tolua.cast(documentOutletNodes[i],"cc.Node")

            if nil ~= rootNode then
                -- print(proxy:getNodeTypeName(outletNode), outletName)
                rootNode[outletName] = tolua.cast(outletNode, proxy:getNodeTypeName(outletNode))
            end 
        end
    end

    return node
end