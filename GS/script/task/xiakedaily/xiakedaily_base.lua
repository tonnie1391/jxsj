Require("\\script\\task\\xiakedaily\\xiakedaily_def.lua")

function XiakeDaily:GetTask(nTaskId)
	return me.GetTask(self.TASK_GROUP, nTaskId);
end

function XiakeDaily:SetTask(nTaskId, nValue)
	me.SetTask(self.TASK_GROUP, nTaskId, nValue);
end

function XiakeDaily:OnAccept()
	if MODULE_GAMESERVER then
		local nTaskDay, nTask1, nTask2 = self:GetTaskValue();
		local szBlackMsg = "<npc=7346>: \"Có thể ngươi sẽ lang bạt giang hồ, đánh bại khắp Võ Lâm Cao Thủ; cũng có thể ngươi sẽ là thiếu niên thành danh, võ công vô địch thiên hạ. Nhưng với sức lực của cá nhân ngươi khó có thể cứu được Đại Tống khỏi biển lửa. Tịnh khang sỉ, do vị tuyết; thần tử hận, hà thời diệt?\"<end>";
		szBlackMsg = szBlackMsg .. string.format("<npc=7346>: \"Lùi 1 bước để thấy được trời xanh, hiện tại ta rất cần sự tương trợ của các vị hiệp khách diệt gian trừ ác, để Đại Tống ta ngày càng vững mạnh, kể từ hôm nay, mỗi ngày nếu ngươi hoàn thành nhiệm vụ %s và %s, ta sẽ báo đền xứng đáng.\"<end>", self.TaskFile[nTask1].szDynamicDesc, self.TaskFile[nTask2].szDynamicDesc);
		szBlackMsg = szBlackMsg .."<playername>: \"Hành hiệp trượng nghĩa, trừ bạo an dân là trách nhiệm của ta, ta sẽ dốc hết sức mình.\"";
		TaskAct:Talk(szBlackMsg);
		self:LoadDate(self.TASK_MAIN_ID, nTask1, nTask2);
		self:SetTask(self.TASK_STATE, 1);
		self:SetTask(self.TASK_ACCEPT_DAY, nTaskDay);
		self:SetTask(self.TASK_ACCEPT_COUNT, self:GetTask(self.TASK_ACCEPT_COUNT)-1)
	end
end

function XiakeDaily:DoAccept(tbTask, nTaskId, nReferId)
	if nTaskId == self.TASK_MAIN_ID and nReferId == self.TASK_MAIN_ID then
		XiakeDaily:OnAccept();
	end
end

function XiakeDaily:FinishExecute()
	if MODULE_GAMESERVER then
		XiakeDaily:SetWeekTimes();
	end
end


