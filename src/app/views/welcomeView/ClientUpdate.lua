--[[
 	下载更新
 	功能：下载替换文件资源
]]
local fileUtil = cc.FileUtils:getInstance();
local this;

local ClientUpdate = class("ClientUpdate");

-- url:下载list地址 
-- wirtepath:保存路径
-- oldFile:当前list路径
function ClientUpdate:ctor(savepath, oldFile, newFile, downUrl, versionNO, callFunc)
	self._savepath = savepath;
	self._oldFile = oldFile;
	self._newFile = newFile;
	self._downUrl = downUrl;
	self._versionNO = versionNO;
	self._callFunc = callFunc;

    this = self;
end

--开始更新 
--listener回调目标
function ClientUpdate:upDateClient(listener)
	--监听
	self._listener = listener;
	self._downList = {};--下载列表

	local result = false;
	local msg = nil;
	while(not result)
	do
		--创建文件夹
		if not fileUtil:createDirectory(self._savepath) then
			msg = Str[23009];--创建文件夹失败！

			this._callFunc(false);
			break;
		end

		--this._callFunc(true);

		--获取当前文件列表
		local oldlist = Utils:readJsonData(self._oldFile);
		oldlist = oldlist["assets"] or {};

		--记录新的list
		local newlist, newJsonData = Utils:readJsonData(self._newFile);
		newlist = newlist["assets"] or {};
		this._oldJsonData = newJsonData;

		--删除判断
		for k,v in pairs(oldlist) do
			local oldpath = v["path"];
			local oldname = v["name"];
			if  oldpath then
				local bdel = true
				for newk,newv in pairs(newlist) do
					if oldpath == newv["path"] and oldname == newv["name"] then
						bdel = false
						break
					end
				end
				--删除文件
				if bdel == true then
					fileUtil:removeFile(self._savepath..oldpath..oldname);
				end
			end
		end

		--下载判断
		for k ,v in pairs(newlist) do
			local newpath = v["path"];
			if newpath then
				local needupdate = true;
				local newname = v["name"];
				local newmd5 = v["md5"];
				for oldk,oldv in pairs(oldlist) do
					local oldpath = oldv["path"];
					local oldname = oldv["name"];
					local oldmd5 = oldv["md5"];
					
					if oldpath == newpath and newname == oldname then 
						if newmd5 == oldmd5 then
							needupdate = false;
						end
						break;
					end
				end
				--保存到下载列队
				if needupdate == true then
					table.insert(this._downList , {newpath, newname, v["size"]});
				end
			end
		end

		this._callFunc(false);

		--开始下载
		if #this._downList > 0 then
			this._retryCount = 3;
			this._downIndex = 1;
			this:UpdateFile();
		else
			fileUtil:writeStringToFile(this._oldJsonData, this._oldFile);
			cc.UserDefault:getInstance():setStringForKey("VERSION", this._versionNO);
			cc.UserDefault:getInstance():flush();
            if this._listener then
			    this._listener:updateResult(true, "");
            end
		end

		result = true;
	end
	if not result and this._listener then
		this._listener:updateResult(false, msg);
	end
end

--下载
function ClientUpdate:UpdateFile()
    if nil == self._listener then
        return;
    end

	if not self._downIndex or not self._downList  then
		self._listener:updateResult(false, Str[23011]);--下载信息损坏！
		return;
	end
	--列表完成
	if self._downIndex == (#self._downList + 1) then
		--更新本地MD5
		fileUtil:writeStringToFile(self._oldJsonData,self._oldFile);
		cc.UserDefault:getInstance():setStringForKey("VERSION", self._versionNO);
		cc.UserDefault:getInstance():flush();
        --通知完成
		--self._listener:updateResult(true, "");
		this._listener:updateProgress(100);
		this._listener:onHotUpdateUnZip(function()
			this._listener._txtTips:setString(Str[23017]);
			this._listener.m_progressLayer:setVisible(true);

			this._listener:runAction(cc.Sequence:create(
				cc.DelayTime:create(1),
				cc.CallFunc:create(function()
					this:restart();
				end)
			))
	    end);

		return;
	end
	--下载参数
	local fileinfo = self._downList[self._downIndex];
	local url;
	local dstpath

	url = self._downUrl..fileinfo[1]..fileinfo[2];
	dstpath = self._savepath..fileinfo[1];

	this._listener:setAssetsSize(fileinfo[3]);
	this._listener:updateProgress(0);

	--调用C++下载
	downFileAsync(url,fileinfo[2],dstpath,function(main,sub,speed)
        if nil == self._listener then
            return;
        end

		--下载回调
		if main == DOWN_PRO_INFO then --进度信息
			this._listener:updateProgress(sub);
			this._listener:setSpeedTxt(speed);
		elseif main == DOWN_COMPELETED then --下载完毕
			self._retryCount = 3;
			this._downIndex = this._downIndex +1;
			this._listener:runAction(cc.CallFunc:create(function()
				this:UpdateFile();
			end))
		else
			if sub == 28 and self._retryCount > 0 then
				self._retryCount = self._retryCount - 1;
				this._listener:runAction(cc.CallFunc:create(function()
					this:UpdateFile();
				end))
			else--失败信息
				print(Str[23008]..":" .. "["..url.."]")
				this._listener:updateResult(false, Str[23008]..", main:" .. main.. "["..fileinfo[1]..fileinfo[2].."]" .. " ## sub:" .. sub);
			end
		end
	end)
end

function ClientUpdate:restart()
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj";
	    luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","restart",{}, "()V");
	elseif device.platform == "ios" then
		local luaoc = require "cocos.cocos2d.luaoc";
		local ok = luaoc.callStaticMethod("AppController","suspend",{});
	    if ok then
			this._listener:EnterClient();
	    end
	    luaoc.callStaticMethod("AppController","openApp",{});	
	elseif device.platform == "mac" then
		restart();
	elseif device.platform == "windows" then
	end
end

return ClientUpdate;