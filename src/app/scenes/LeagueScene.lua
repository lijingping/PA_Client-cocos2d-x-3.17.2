local LeagueScene = class("LeagueScene", require("app.scenes.GameSceneBase"))

function LeagueScene:init()
	self:initView("leagueView.LeagueView")
end

function LeagueScene:notifyChatNews(data)
	local chatDialogbox = App:getRunningScene():getChildByName("ChatDialogbox");
	if chatDialogbox:getFriendUID() == data.info.sender then
		chatDialogbox:notifyChatNews(data);
	end
end

return LeagueScene