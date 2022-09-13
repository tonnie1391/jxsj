-- 军营传送官
local tbNpc1 = Npc:GetClass("junyingchuansong");
function tbNpc1:OnDialog()
	local szMainMsg = "Xin chào! Ngươi khỏe không?";
	local tbOpt = {
		{"伏牛山军营【青龙】", self.ChoseCamp, self, me.nId, 556,1631,3142},
		{"伏牛山军营【朱雀】", self.ChoseCamp, self, me.nId, 558,1631,3142},
		{"伏牛山军营【玄武】", self.ChoseCamp, self, me.nId, 559,1631,3142},
	}
	Lib:SmashTable(tbOpt);
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	
	Dialog:Say(szMainMsg);
end


function tbNpc1:ChoseCamp(nPlayerId, nMapId, nPosX, nPosY)
	local pPlayer  = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	if (pPlayer.nLevel < 60) then
		Task.tbArmyCampInstancingManager:Warring(pPlayer, "等级未达到60级，不能进入军营。");
		return;
	end
	
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
	pPlayer.SetFightState(0);
end


local tbNpc2 = Npc:GetClass("instcingoutsender");
tbNpc2.tbSendPos = {
	[24] = {1934,3414},
	[25] = {1444,3091},
	[29] = {1577,4114},
	}

function tbNpc2:OnDialog()
	local pPlayer = me;
	local nMapId = pPlayer.GetTask(2043, 2);
	if (nMapId ~= 25 and nMapId ~= 24 and nMapId ~= 29) then
		nMapId = 29
	end
	
	local szMainMsg = "Đại hiệp muốn rời khỏi đây sao?";
	local tbOpt = {
		{"Đúng, đưa ta đi", self.EnterRegisterCamp, self, me.nId, nMapId, self.tbSendPos[nMapId][1], self.tbSendPos[nMapId][2]},		
		{"Kết thúc đối thoại"}
	}
	
	Dialog:Say(szMainMsg, tbOpt);
end


function tbNpc2:EnterRegisterCamp(nPlayerId, nMapId, nPosX, nPosY)
	local pPlayer  = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
	pPlayer.SetFightState(0);
end

-- 副本接引人
local tbRegister = Npc:GetClass("fbchuansong");

--打开客户端自动组队界面
function tbRegister:OpenAutoTeamUi()
	me.CallClientScript({ "AutoTeam:OpenUi" });
end

function tbRegister:OnDialog()
	if me.nMapId > 30 then
		Dialog:Say("您好，参加军营活动请前往襄阳、临安、凤翔府军营报名处！");
		return;
	end
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	local szMainMsg = "Hãy chọn phó bản mà nhóm ngươi đang muốn nhận thử thách!";
	local tbOpt = {};
		
	local tbInstancingMgr = Task.tbArmyCampInstancingManager;
	for i = 1, #tbInstancingMgr.tbSettings do
		local tbInstacing = tbInstancingMgr:GetInstancingSetting(i);
		tbOpt[#tbOpt + 1] = {tbInstacing.szName, self.ChoseInstcing, self, i, me.nId};
	end
	tbOpt[#tbOpt + 1] = {"Tự động tổ đội", tbRegister.OpenAutoTeamUi, tbRegister};
	
	if (me.GetTask(2060, 1) == 1) then
		tbOpt[#tbOpt+1] = {"Bồi thường nhiệm vụ QD", self.AmendeForCampTask, self, me.nId};
	end
	
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say(szMainMsg, tbOpt);
end

function tbRegister:AmendeForCampTask(nPlayerId)
	Dialog:Say("补偿奖励为8000000经验、40000银两、1800活力精力", 
		{"是否现在领取", Task.AmendeForCampTask, Task, nPlayerId}, 
		{"以后再领"})
end

function tbRegister:ChoseInstcing(nInstancingTemplateId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	local tbInstancingMgr = Task.tbArmyCampInstancingManager;
--	local nRet, szError = tbInstancingMgr:CheckEnterCondition(nInstancingTemplateId, nPlayerId);
--	if (nRet ~= 1) then
--		tbInstancingMgr:Warring(pPlayer, szError);
--		return;
--	end
	
	local tbInstancingSetting = tbInstancingMgr:GetInstancingSetting(nInstancingTemplateId);
	
	local tbOpt = 
	{
		{"Báo danh", tbInstancingMgr.AskRegisterInstancing, tbInstancingMgr, nInstancingTemplateId, pPlayer.nId},
		{"Vào phó bản", tbInstancingMgr.AskEnterInstancing, tbInstancingMgr, nInstancingTemplateId, pPlayer.nId},
		{"Kết thúc đối thoại"}
	}
	
	Dialog:Say(tbInstancingSetting.szEnterMsg, tbOpt);
end
