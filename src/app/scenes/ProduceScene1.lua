local Tips = require("app.views.common.Tips");
----------------------
-- 生产场景
----------------------
local ProduceScene1 = class("ProduceScene1", require("app.scenes.GameSceneBase"))

function ProduceScene1:init()
	self:initView("produceView.ProduceView1");
end

-- 更新生产队列
function ProduceScene1:notifyProduceQueue(data)
	print("生产队列变更")
	--dump(data);
	ProduceDataMgr:setProduceQueue(data.items);
	self:getViewBase().m_ccbProduceView1:updateQueue();
end

return ProduceScene1