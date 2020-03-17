local ResourceMgr = require("app.utils.ResourceMgr");

local IMAGE_RES_PATH = "res/resources/demo";
local ICON_RES_PATH = "res/planeIcon";
local BULLET_RES_PATH = "res/bullet";
local ANIMA_RES_PATH = "res/anims/demo";
local MAX_ARMS = 6;
local table_insert = table.insert;

local this

local CCBDemoBattlePreView = class("CCBDemoBattlePreView", function ()
	return CCBLoader("ccbi/loginView/CCBDemoBattlePreView.ccbi")
end)

function CCBDemoBattlePreView:ctor()
	if display.resolution >= 2 then
   		self.m_ccbNodeCenter:setScale(display.reduce);
   	end

    self:enableNodeEvents();
    this = self

	local size = cc.size(636.0, 53);
	local playerBox = cc.Scale9Sprite:create("res/resources/loginView/login_input.png");
	playerBox:setContentSize(size);

	self.m_playerCount = cc.EditBox:create(size, playerBox, nil, nil);
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
		self.m_playerCount:setFontName("simhei")
	else
		self.m_playerCount:setFontName("fonts/simhei.ttf")
	end
    self.m_playerCount:setFontSize(28)
    self.m_playerCount:setPlaceholderFontSize(20)
    self.m_playerCount:setFontColor(cc.c3b(255,255,255))
    self.m_playerCount:setPlaceHolder("请输入战机数量")
    self.m_playerCount:setPlaceholderFontColor(cc.c3b(128,128,128))
    self.m_playerCount:setMaxLength(16);
    self.m_playerCount:setText(6);
    self.m_playerCount:setPosition(0, -size.height);
    self.m_ccbNodePlayer:addChild(self.m_playerCount);


	local enemyBox = cc.Scale9Sprite:create("res/resources/loginView/login_input.png");
	enemyBox:setContentSize(size);

	self.m_enemyCount = cc.EditBox:create(size, enemyBox, nil, nil);
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
		self.m_enemyCount:setFontName("simhei")
	else
		self.m_enemyCount:setFontName("fonts/simhei.ttf")
	end
    self.m_enemyCount:setFontSize(28)
    self.m_enemyCount:setPlaceholderFontSize(20)
    self.m_enemyCount:setFontColor(cc.c3b(255,255,255))
    self.m_enemyCount:setPlaceHolder("请输入战机数量")
    self.m_enemyCount:setPlaceholderFontColor(cc.c3b(128,128,128))
    self.m_enemyCount:setMaxLength(16);
    self.m_enemyCount:setText(6);
    self.m_enemyCount:setPosition(0, -size.height);
    self.m_ccbNodEnemy:addChild(self.m_enemyCount);
end

function CCBDemoBattlePreView:onExit()
    this = nil;
end

function CCBDemoBattlePreView:onBtnEnter()
	self.m_ccbNodeCenter:removeSelf();
    self:ViewLoad();
end

function CCBDemoBattlePreView:onBtnPlayer1()
	self.m_playerCount:setText(6);
end

function CCBDemoBattlePreView:onBtnPlayer2()
	self.m_playerCount:setText(12);
end

function CCBDemoBattlePreView:onBtnPlayer3()
	self.m_playerCount:setText(36);
end

function CCBDemoBattlePreView:onBtnEnemy1()
	self.m_enemyCount:setText(6);
end

function CCBDemoBattlePreView:onBtnEnemy2()
	self.m_enemyCount:setText(12);
end

function CCBDemoBattlePreView:onBtnEnemy3()
	self.m_enemyCount:setText(36);
end

function CCBDemoBattlePreView:loadingUI()
    self.m_percent = self.m_percent + 1;
    self.m_loadingBar:setPercent((self.m_percent / self.m_resCount) * 100);
    if self.m_percent >= self.m_resCount then
		App:enterScene("ZZTestScene"):setArmsCount(
			tonumber(self.m_playerCount:getText()), tonumber(self.m_enemyCount:getText()));
    end
end

function CCBDemoBattlePreView:ViewLoad()
	self.m_layoutMarks = ccui.Layout:create()
	    :setAnchorPoint(cc.p(0, 0))
	    :setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		:setBackGroundColor(cc.c3b(0,0,0))
		:setBackGroundColorOpacity(200)
		:setPosition(cc.p(0, 0))
		:setContentSize(cc.size(display.width, display.height))
	    :addTo(self)
   	if display.resolution >= 2 then
   		self.m_layoutMarks:setScale(display.reduce);
   	end

   	--总进度
    self.m_percent = 0;
	self.m_loadingBar = ccui.Slider:create()
    	:setScale9Enabled(true)
    	:setTouchEnabled(false)
    	:setAnchorPoint(cc.p(0.5,0))
    	:setContentSize(cc.size(display.width*0.9, 32))
		:setPosition(display.width/2, 80)
    	:loadBarTexture(ResourceMgr:getSliderBarBg());
    self.m_loadingBar:loadProgressBarTexture(ResourceMgr:getSliderBar());
    self.m_loadingBar:loadSlidBallTextures(ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall());
    self.m_loadingBar:setPercent(self.m_percent);
    self.m_layoutMarks:addChild(self.m_loadingBar);

	self.m_resCount = 0;
	local image = getAllFileNameByDirectory(IMAGE_RES_PATH) or {};
	for k,v in pairs(image) do
        display.loadImage(IMAGE_RES_PATH .. "/" .. v, function (args)
            if this then
        	   this:loadingUI();
            end
        end);--//先异步加载纹理
    end
    self.m_resCount = #image;

	local icon = getAllFileNameByDirectory(ICON_RES_PATH) or {};
	for k,v in pairs(icon) do
        display.loadImage(ICON_RES_PATH .. "/" .. v, function()
        	if this then
               this:loadingUI();
            end
        end);--//先异步加载纹理
    end
    self.m_resCount = self.m_resCount + #icon;

	local bullet = getAllFileNameByDirectory(BULLET_RES_PATH) or {};
	for k,v in pairs(bullet) do
        display.loadImage(BULLET_RES_PATH .. "/" .. v, function()
        	if this then
               this:loadingUI();
            end
        end);--//先异步加载纹理
    end
    self.m_resCount = self.m_resCount + #bullet;

	local exportJson = getAllFileNameByDirectory(ANIMA_RES_PATH)
	if #exportJson <= 0 then
		exportJson = {"explosion","ship1_1"};
		for i=1,MAX_ARMS do
			table_insert(exportJson, "pvp_plane".. i);
		end
	end
	local ArmatureDataManager = ccs.ArmatureDataManager:getInstance();
	for k,v in pairs(exportJson) do
		local animPath = ANIMA_RES_PATH .. "/" .. v .. "/" .. v .. ".ExportJson";
		ArmatureDataManager:addArmatureFileInfoAsync(animPath, function()
        	if this then
               this:loadingUI();
            end
        end);--//先异步加载纹理 
	end
    self.m_resCount = self.m_resCount + #exportJson;

    if self.m_resCount <= 0 then
		App:enterScene("ZZTestScene"):setArmsCount(
			tonumber(self.m_playerCount:getText()), tonumber(self.m_enemyCount:getText()));
    end
end

return CCBDemoBattlePreView