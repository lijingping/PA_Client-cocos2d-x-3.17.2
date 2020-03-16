local MailDataMgr = class("MailDataMgr")

function MailDataMgr:Init()
	
end

function MailDataMgr:setCurTouchMailData(data)
	self.m_curTouchMailData = data;
end

function MailDataMgr:getCurTouchMailData()
	return self.m_curTouchMailData;
end



return MailDataMgr;