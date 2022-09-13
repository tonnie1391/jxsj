-- 文件名　：newversionevent.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-26 15:44:23
-- 功能    ：2011-11资料片任务处理

SpecialEvent.tbNewVersion_2011 = SpecialEvent.tbNewVersion_2011 or {};
local tbNewVersion_2011 = SpecialEvent.tbNewVersion_2011;
tbNewVersion_2011.bOpen			= 1;			--开关

tbNewVersion_2011.nGroupId 			= 2179		--修复20级任务时候的id
tbNewVersion_2011.nRepairTaskId 		= 8;			--修复20级任务时候的id

tbNewVersion_2011.nCreatRole 		= 20111122;	--修复角色建号时间限制
tbNewVersion_2011.nLevel 			= 20;			--20级修复
tbNewVersion_2011.nTaskId 			= 157;		--老新手任务id
tbNewVersion_2011.nReferIds 			= 323;		-- 老新手任务最后一个子任务id
tbNewVersion_2011.nAdvLevel 			= 50;			--50级修复
tbNewVersion_2011.tbTaskInfo			= {8, 24, 25, 38, 51, 56, 63, 69, 74, 78, 84,95};		--20-50主线任务(1-12)最后一个子任务id
tbNewVersion_2011.szGateWayLimit = "gate0724";		--雪芳草不处理

tbNewVersion_2011.tbBaiQiuLin	= {
	{1, 1386, 3101},
	{2, 1779, 3579},
	{7, 1525, 3275},
	{4, 1623, 3243},
	{5, 1596, 3122},
	{6, 1594, 3106},
	{8, 1693, 3378},
	};

function tbNewVersion_2011:OnLogin()
	if self.bOpen == 0 or GetGatewayName() == self.szGateWayLimit then
		return;
	end
	if me.GetTask(self.nGroupId, self.nRepairTaskId)  >= 1 or me.GetRoleCreateDate() >= self.nCreatRole then
		return;
	end	
	--20级修复
	local szMsg = "";
	if Task:HaveTask(me, self.nTaskId) == 1  then		
		Task : Failed(self.nTaskId);
		me.SetTask(1000, self.nTaskId, self.nReferIds);
		me.SetTask(1000, 480, 691);	--新加教育任务
		me.SetTask(1025, 32, 2);	--烟雨江南任务置为可接
		--传到本服的白秋林跟前
		self:NewWorld();
		if me.nLevel < self.nLevel then
			me.AddLevel(self.nLevel - me.nLevel);
		end
		--提示资料片任务修复
		szMsg = "由于您有本次资料片调整的任务，秋姨帮您快速提升等级到<color=yellow>20<color>级，请您在<color=green>白秋琳<color>处<color=yellow>接取剧情任务<color>。";
		if me.nFaction <= 0 or me.nRouteId <= 0 then
			szMsg = "由于您有本次资料片调整的任务，秋姨帮您快速提升等级到<color=yellow>20<color>级，请您加入门派、选定门派路线后在<color=green>白秋琳<color>处<color=yellow>接取剧情任务<color>。";
		end
		self:OnDialogInfo(szMsg);
	end
	--50级修复
	local nFlag = 0;
	for nTaskId, nReferIds in pairs(self.tbTaskInfo) do
		if Task:HaveTask(me, nTaskId) == 1 then
			Task : Failed(nTaskId);
			nFlag = 1;
		end
	end
	--放弃过50主线任务的才操作（防止多次操作）
	if nFlag == 1 then
		for nTaskId, nReferId in pairs(self.tbTaskInfo) do
			me.SetTask(1000, nTaskId, nReferId);	--设到最后的下一个，这样就接不了相应的任务
		end
		me.SetTask(1000, 480, 691);	--新加教育任务
		if me.nLevel < self.nAdvLevel then
			me.AddLevel(self.nAdvLevel - me.nLevel);
		end
		--置50级主线任务完成id
		me.SetTask(1022, 107, 1);-- 设置50级主线任务变量
		--传到本服的白秋林跟前
		self:NewWorld();
		--提示资料片任务修复
		szMsg = "由于您有本次资料片调整的任务，秋姨帮您快速提升等级到<color=yellow>50<color>级，请在<color=green>白秋琳<color>处接取剧情任务。";
		self:OnDialogInfo(szMsg);
	end
	if me.nLevel > self.nLevel then
		me.SetTask(1000, 480, 691);	--新加教育任务
	end
	--设置已经操作过
	me.SetTask(self.nGroupId, self.nRepairTaskId, 1); 
end

--传送到本服白秋林处
function tbNewVersion_2011:NewWorld()
	local tbPos = self.tbBaiQiuLin[GetServerId()];
	if tbPos then
		me.NewWorld(tbPos[1], tbPos[2], tbPos[3]);
	end
end

function tbNewVersion_2011:OnDialogInfo(szMsg)
	Dialog:Say(szMsg);
	me.Msg(szMsg);
end

PlayerEvent:RegisterGlobal("OnLogin", tbNewVersion_2011.OnLogin, tbNewVersion_2011);
