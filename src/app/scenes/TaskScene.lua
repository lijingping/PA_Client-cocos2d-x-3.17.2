local TaskScene = class("TaskScene", require("app.scenes.GameSceneBase"))

function TaskScene:init()
	print("TaskScene:init")
	self:initView("taskView.TaskView");
end

return TaskScene