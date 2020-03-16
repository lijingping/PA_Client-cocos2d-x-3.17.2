local ClientUpdate = import(".ClientUpdate");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local ResourceMgr = require("app.utils.ResourceMgr");
local NetworkConst = require("app.constants.NetworkConst")

local fileUtils = cc.FileUtils:getInstance();

--下载信息
DOWN_PRO_INFO = 1 --下载进度
DOWN_COMPELETED = 3 --下载结果
DOWN_ERROR_PATH = 4 --路径出错
DOWN_ERROR_CREATEFILE = 5 --文件创建出错
DOWN_ERROR_CREATEURL = 6 --创建连接失败
DOWN_ERROR_NET = 7--下载失败
DOWN_ERROR_UNZIP=8

local INSTALL_ASSETS_UNZIP_FILE = "installAssetsUnzip.json"
local VERSION_FILE = "version.manifest.json"
local OLD_PROJECT_MANIFEST_FILE = "old.project.manifest.json";

local CCBWelcomeView = class("CCBWelcomeView", cc.Node);

local this;
function CCBWelcomeView:ctor()
	self:enableNodeEvents();

	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end

	this = self;

	self._savepath = fileUtils:getSearchPaths()[1];

	self._assetsSize = "";

   	local width, height = display.getFullScreenSize();
	cc.Sprite:create("res/resources/loginView/ui_login1_bg1.png")
		:setPosition(width/2, height/2)
		:addTo(self)

	local layoutTips = ccui.Layout:create()
	    :setAnchorPoint(cc.p(0, 0))
	    :setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		:setBackGroundColor(cc.c3b(0,0,0))
		:setBackGroundColorOpacity(200)
		:setPosition(cc.p(0, 0))
	    :addTo(self)

	self.m_progressLayer = display.newLayer(cc.c4b(0, 0, 0, 0));
	self:addChild(self.m_progressLayer);
	self.m_progressLayer:setVisible(false);

	--总进度
	self.m_totalBar = ccui.Slider:create()
    	:setScale9Enabled(true)
    	:setTouchEnabled(false)
    	:setAnchorPoint(cc.p(0.5,0))
    	:setContentSize(cc.size(width*0.9, 32))
		:setPosition(width/2, 80)
    	:loadBarTexture(ResourceMgr:getSliderBarBg());
    self.m_totalBar:loadProgressBarTexture(ResourceMgr:getSliderBar());
    self.m_totalBar:loadSlidBallTextures(ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall());
    self.m_progressLayer:addChild(self.m_totalBar);

	local barSize = self.m_totalBar:getContentSize();

	--下载速度
	self._txtSpeed = cc.Label:createWithTTF("", "res/font/simhei.ttf", 20)
		:setAnchorPoint(cc.p(0,0))
		:setPosition(width/2-barSize.width/2, 2)
		:setString("")
		:setTextColor(cc.c4b(255,255,255,255))
		:addTo(self.m_progressLayer)

	--提示文本
	self._txtTips = cc.Label:createWithTTF("", "res/font/simhei.ttf", 24)
		:setAnchorPoint(cc.p(0,0))
		:enableOutline(cc.c4b(255,255,255,255), 1)
		:setPosition(width/2-barSize.width/2, self._txtSpeed:getLineHeight())
		:setString("")
		:setTextColor(cc.c4b(255,255,255,255))
		:addTo(self.m_progressLayer)

	self.m_totalBar:setPositionY(self._txtTips:getPositionY()+self._txtTips:getLineHeight())
	    
	layoutTips:setContentSize(cc.size(width, self.m_totalBar:getPositionY()+barSize.height))

	self._totalTips = cc.Label:createWithTTF("", "res/font/simhei.ttf", 18)
		:setAnchorPoint(cc.p(1,1))
		:setPosition(barSize.width-8, 0)
		:setTextColor(cc.c4b(255,255,255,255))
		:addTo(self.m_totalBar)
	self:updateBar(0);

	--tips
	local firstTips = cc.Label:createWithTTF(Str[23016], "res/font/simhei.ttf", 14)
		:setTextColor(cc.c4b(20,250,0,255))
		:setAnchorPoint(cc.p(0.5, 0))
		--:enableOutline(cc.c4b(0,0,0,255), 1)
		:setPosition(width/2, layoutTips:getContentSize().height+8)
		:addTo(self)
	cc.Label:createWithTTF(Str[23015], "res/font/simhei.ttf", 14)
		:setTextColor(cc.c4b(0,250,0,255))
		:setAnchorPoint(cc.p(0.5, 0))
		--:enableOutline(cc.c4b(0,0,0,255), 1)
		:setPosition(width/2, firstTips:getPositionY()+firstTips:getLineHeight())
		:addTo(self)
end

function CCBWelcomeView:onEnter()
	self.m_tabUpdateQueue = {};

	self:createVersionTxt();
	--self:synchroVersion();
	self:onInstallUnZip();
end

function CCBWelcomeView:createVersionTxt()
	local oldJsonData = Utils:readJsonData(self._savepath..VERSION_FILE);

	local strVersion = cc.Label:createWithTTF("v"..(oldJsonData.version and oldJsonData.version or "0.0.0.0"),
		"res/font/simhei.ttf", 18)
		:setTextColor(cc.c4b(255,250,255,255))
		:setAnchorPoint(cc.p(0.5, 0.5))

	local _, height = display.getFullScreenSize();
	local size = strVersion:getContentSize();
	ccui.Layout:create()
	    :setAnchorPoint(cc.p(0, 1))
	    :setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		:setBackGroundColor(cc.c3b(0,0,0))
		:setBackGroundColorOpacity(200)
		:setContentSize(cc.size(size.width*1.2, size.height*2))
		:setPosition(cc.p(0, height))
	    :addTo(self)
		:addChild(strVersion)
	strVersion:setPosition(cc.p(size.width*1.2/2, size.height))
end

--进入登录界面
function  CCBWelcomeView:EnterClient()
	--重置大厅与游戏
	for k ,v in pairs(package.loaded) do
		if k ~= nil then
			if type(k) == "string" then
				if string.find(k,"mainView.") ~= nil then
					package.loaded[k] = nil;
				end
			end
		end
	end

	--场景切换
	App:enterScene("LoginScene");
end

function CCBWelcomeView:synchroVersion()
	self:showLoading();
	self._txtTips:setString(Str[23002]);

	local remoteVersionUrl = NetworkConst.REMOTE_VERSION_URL..VERSION_FILE;
	downFileAsync(remoteVersionUrl, VERSION_FILE, self._savepath, function(main, sub)
		--下载回调
		if main == DOWN_PRO_INFO then --进度信息
		elseif main == DOWN_COMPELETED then --下载完毕
			this:hideLoading();

			local curServerVersion = Utils:readJsonData(this._savepath..VERSION_FILE);
			curServerVersion.newRemoteManifestFile = "new.project.manifest.json";
			self._curServerVersion = curServerVersion;
			--debug Install Assets Unzip
			if curServerVersion and curServerVersion.isDeleteInstallAssetsUnzipFile then
				fileUtils:removeFile(this._savepath..INSTALL_ASSETS_UNZIP_FILE)
			end

			local serverVersion = string.split(curServerVersion.version, ".");
			local localVersion = string.split(cc.UserDefault:getInstance():getStringForKey("VERSION", "0.0.0.0"), ".") or {};

			if tonumber(localVersion[1]) < tonumber(serverVersion[1]) then--更新整个app
				local ccbMessageBox = CCBMessageBox:create(Str[3036], Str[23012], MB_YESNO);
				ccbMessageBox.onBtnOK = function ()
					ccbMessageBox:removeSelf();
					this:upDateBaseApp();
				end
				ccbMessageBox.onBtnCancel = function ()
					ccbMessageBox:removeSelf();					
					os.exit(0);
				end
				return;
			end

			local isUpdate = false;
			for i=2, #localVersion do
				if tonumber(localVersion[i]) < tonumber(serverVersion[i]) then
					isUpdate = true;
					break;
				end
			end

			if isUpdate then
				local ccbMessageBox = CCBMessageBox:create(Str[3036], Str[23006], MB_YESNO);
				ccbMessageBox.onBtnOK = function ()
					ccbMessageBox:removeSelf();
					this:downRemoteManifestFile();
				end
				ccbMessageBox.onBtnCancel = function ()
					ccbMessageBox:removeSelf();	
					--this:EnterClient();
					os.exit(0);
				end
			else
				this:EnterClient();
			end
		else
			this:hideLoading();

			local ccbMessageBox = CCBMessageBox:create(Str[3036], Str[23003].."\n"..remoteVersionUrl.."\n"..Str[23004], MB_YESNO);
			ccbMessageBox.onBtnOK = function ()
				ccbMessageBox:removeSelf();

				this:synchroVersion();
			end
			ccbMessageBox.onBtnCancel = function ()
				ccbMessageBox:removeSelf();	
				os.exit(0)
			end
		end
	end)
end

function CCBWelcomeView:downRemoteManifestFile()
	this:showLoading();
	downFileAsync(self._curServerVersion.remoteManifestUrl, self._curServerVersion.newRemoteManifestFile, this._savepath, function(main, sub)
		--下载回调
		if main == DOWN_PRO_INFO then --进度信息
		elseif main == DOWN_COMPELETED then --下载完毕
			--this:hideLoading();
			--[[
			local ccbMessageBox = CCBMessageBox:create(Str[3036], "下载成功:"..self._savepath..self._curServerVersion.newRemoteManifestFile, MB_OK);
			ccbMessageBox.onBtnOK = function ()
				ccbMessageBox:removeSelf();
			end
			]]
			local updateConfig = {};
			updateConfig.savepath = this._savepath;
			updateConfig.oldFile = this._savepath..OLD_PROJECT_MANIFEST_FILE;
			updateConfig.newFile = this._savepath..this._curServerVersion.newRemoteManifestFile;
			updateConfig.downUrl = this._curServerVersion.downUrl;
			updateConfig.versionNO = this._curServerVersion.version;
			table.insert(this.m_tabUpdateQueue, updateConfig);

			this:goUpdate();
		else
			this:hideLoading();

			local ccbMessageBox = CCBMessageBox:create(Str[3036], Str[23003].."\n"..self._curServerVersion.remoteManifestUrl.."\n"..Str[23004], MB_YESNO);
			ccbMessageBox.onBtnOK = function ()
				ccbMessageBox:removeSelf();

				this:downRemoteManifestFile();
			end
			ccbMessageBox.onBtnCancel = function ()
				ccbMessageBox:removeSelf();	
				os.exit(0);
			end
		end
	end)
end

function CCBWelcomeView:upDateBaseApp()
	self.m_progressLayer:setVisible(true)

	if device.platform == "android" then
		local url = ""
		if isDebug() then
			url = self._curServerVersion.debugApkUrl;
			self:setAssetsSize(self._curServerVersion.debugApkSize);
		else			
			url = self._curServerVersion.apkUrl;
			self:setAssetsSize(self._curServerVersion.apkSize);
		end

	    --调用C++下载
	    local luaj = require "cocos.cocos2d.luaj";
		local className = "org/cocos2dx/lua/AppActivity";

	    local sigs = "()Ljava/lang/String;"
   		local ok,ret = luaj.callStaticMethod(className,"getSDCardDocPath",{},sigs)
   		if ok then
   			local dstpath = ret .. "/com.gamerboom.pademo/"
   			local filepath = dstpath .. "PA_Client.apk"
		    if fileUtils:isFileExist(filepath) then
		    	fileUtils:removeFile(filepath)
		    end
		    if false == fileUtils:isDirectoryExist(dstpath) then
		    	fileUtils:createDirectory(dstpath)
		    end

		    self:updateBar(0);
		    this:showLoading();

			downFileAsync(url,"PA_Client.apk",dstpath,function(main,sub,speed)
					--下载回调
					if main == DOWN_PRO_INFO then --进度信息
						self:updateBar(sub);
						self:setSpeedTxt(speed)
					elseif main == DOWN_COMPELETED then --下载完毕
						this:hideLoading();

						self._txtTips:setString(Str[23007]);
						self.m_progressLayer:setVisible(false);

						cc.UserDefault:getInstance():setStringForKey("VERSION", this._curServerVersion.version);
						cc.UserDefault:getInstance():flush();

						--安装apk						
						local args = {filepath};
						sigs = "(Ljava/lang/String;)V";
		   				ok,ret = luaj.callStaticMethod(className, "installClient",args, sigs);
		   				if ok then
		   					os.exit(0);
		   				end
					else
						this:hideLoading();

						local ccbMessageBox = CCBMessageBox:create(Str[3036], Str[23008]..",code:".. main .."\n"..Str[23004], MB_YESNO);
						ccbMessageBox.onBtnOK = function ()
							this:upDateBaseApp()

							ccbMessageBox:removeSelf();
						end
						ccbMessageBox.onBtnCancel = function ()
							ccbMessageBox:removeSelf();	
							os.exit(0)
						end
					end
				end)
		else
			os.exit(0)
   		end
	elseif device.platform == "ios" then
		--this:showLoading();
		self:setAssetsSize(self._curServerVersion.ipaSize);

		local luaoc = require "cocos.cocos2d.luaoc"
		local ok,ret  = luaoc.callStaticMethod("AppController","updateBaseClient", {url = self._curServerVersion.ipaUrl})
	    if not ok then
     		print("--------luaoc error:" .. ret);
     	else
			cc.UserDefault:getInstance():setStringForKey("VERSION", this._curServerVersion.version);
			cc.UserDefault:getInstance():flush();
	    end
		
		--this:hideLoading();
	elseif device.platform == "mac" then
		self:setAssetsSize("");

		local ccbMessageBox = CCBMessageBox:create(Str[3036], "mac dev test", MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
		cc.UserDefault:getInstance():setStringForKey("VERSION", this._curServerVersion.version);
		cc.UserDefault:getInstance():flush();	
	end
end

--开始下载
function CCBWelcomeView:goUpdate()
	self.m_progressLayer:setVisible(true)

	local config = self.m_tabUpdateQueue[1]
	if nil == config then
		self.m_progressLayer:setVisible(false);
		self._txtTips:setString("");
		self:EnterClient();
	else
        if self.clientUpdate then
            self.clientUpdate:upDateClient(nil)
        end
		self.clientUpdate = ClientUpdate:create(config.savepath, config.oldFile, config.newFile, 
			config.downUrl, config.versionNO, function(isShowLoading)
				if isShowLoading then
					this:showLoading();
				else
					this:hideLoading();
				end
			end);

		self.clientUpdate:upDateClient(self)
	end	
end

--下载进度
function CCBWelcomeView:updateProgress(main)
	self:updateBar(main);
end

function CCBWelcomeView:setAssetsSize(assetsSize)
	self._assetsSize = assetsSize
end

function CCBWelcomeView:setSpeedTxt(speed)
	self._txtSpeed:setString(string.format(Str[23014], self._assetsSize)..speed.."(v"..self._curServerVersion.version..")");
end

--下载结果
function CCBWelcomeView:updateResult(result, msg)
	if result == true then
		self:updateBar(0);

		local config = self.m_tabUpdateQueue[1]
		if nil ~= config then
			table.remove(self.m_tabUpdateQueue, 1)
			self:goUpdate()
		else
			--进入登录界面
			self._txtTips:setString("")
			self:runAction(cc.Sequence:create(
				cc.DelayTime:create(1),
				cc.CallFunc:create(function()
					this:EnterClient()
				end)
			))	
		end
	else
		self.m_progressLayer:setVisible(false)
		self:updateBar(0);

		--重试询问
		self._txtTips:setString("")

		local ccbMessageBox = CCBMessageBox:create(Str[3036],msg .. "\n" .. Str[23004], MB_YESNO);
		ccbMessageBox.onBtnOK = function ()
			this:goUpdate()

			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();	
			os.exit(0)
		end
	end
end

function CCBWelcomeView:updateBar(percent)
	self._totalTips:setString(string.format("%d%%", percent))
	self.m_totalBar:setPercent(percent);
end

-- 显示Loading动画
function CCBWelcomeView:showLoading()
	if self.m_armatureLoading == nil then
	   	self.m_armatureLoading = ResourceMgr:getCommonArmature("waitting_message");
	    self:addChild(self.m_armatureLoading);

   		local width, height = display.getFullScreenSize();
	    self.m_armatureLoading:setPosition(width/2, height/2);
	    self.m_armatureLoading:getAnimation():play("anim01");
	else
		self.m_armatureLoading:getAnimation():play("anim01");
		self.m_armatureLoading:setVisible(true);
  	end
end

-- 隐藏Loading动画
function CCBWelcomeView:hideLoading()
	if self.m_armatureLoading then
		self.m_armatureLoading:setVisible(false);
  	end
end

function CCBWelcomeView:writeUnzipConfigfile(path, mode)
    local file = io.open(path, mode or "w")
    file:write("{")
	file:write("\n    \"isUnzip\":true")
	file:write("\n}")
    io.close(file)
end

--解压自带ZIP
function CCBWelcomeView:onInstallUnZip()
	self._txtSpeed:setString("");

	if self._installUnzip == nil then
		if not Utils:readJsonData(self._savepath..INSTALL_ASSETS_UNZIP_FILE).isUnzip then
		    self:updateBar(0);
			self._txtTips:setString(Str[23001])
			self._installUnzip = 1

			local assets_path = fileUtils:fullPathForFilename("installAssets.zip");
			self.m_progressLayer:setVisible(assets_path and string.len(assets_path) > 0)

			unZipAsync(assets_path, self._savepath, function(main, sub)
				if main == DOWN_PRO_INFO then
					self:updateBar(sub);
				elseif main == DOWN_COMPELETED or main == DOWN_ERROR_UNZIP then
					if main == DOWN_COMPELETED then
						self:writeUnzipConfigfile(self._savepath..INSTALL_ASSETS_UNZIP_FILE)
					end
					self:onInstallUnZip();
				end
			end)
		else
			self._installUnzip = -1;
			self:onInstallUnZip();
		end
	else-- 解压完成
		self._txtTips:setString(self._installUnzip == -1 and "" or Str[23005])
		self._installUnzip = nil
		self.m_progressLayer:setVisible(false);

	    self:onHotUpdateUnZip(function()
		    self:synchroVersion();--版本同步			
	    end);
		return	
	end
end

function CCBWelcomeView:onHotUpdateUnZip(callFunc)
	self._txtSpeed:setString("");

	if self._hotUpdateUnzip == nil then
		local assets_zip = "hotUpdateAssets.zip";
		if fileUtils:isFileExist(self._savepath..assets_zip) then
		    self:updateBar(0);
			self._txtTips:setString(Str[23001])
			self._hotUpdateUnzip = 1

			local assets_path = fileUtils:fullPathForFilename(assets_zip);
			self.m_progressLayer:setVisible(assets_path and string.len(assets_path) > 0)

			unZipAsync(assets_path, self._savepath, function(main, sub)
				if main == DOWN_PRO_INFO then
					self:updateBar(sub);
				elseif main == DOWN_COMPELETED or main == DOWN_ERROR_UNZIP then
		    		fileUtils:removeFile(self._savepath..assets_zip)
					self:onHotUpdateUnZip(callFunc);
				end
			end)
		else
			self._hotUpdateUnzip = -1;
			self:onHotUpdateUnZip(callFunc);
		end
	else-- 解压完成
		self._txtTips:setString(self._hotUpdateUnzip == -1 and "" or Str[23005])
		self._hotUpdateUnzip = nil
		self.m_progressLayer:setVisible(false);

		if callFunc then callFunc() end
	end
end

return CCBWelcomeView