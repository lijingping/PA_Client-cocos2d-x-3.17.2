local LeagueScene = class("LeagueScene", require("app.scenes.GameSceneBase"))

function LeagueScene:init()
	self:initView("leagueFight.LeagueFight")
end

return LeagueScene