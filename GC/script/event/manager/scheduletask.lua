-------------------------------------------------------------------
--File: 	eventmanager.lua
--Author: sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统.
--
-------------------------------------------------------------------

function EventManager:scheduletask()
	--每天凌晨4点进行一次维护.
	self.EventManager:MaintainGC();
end
