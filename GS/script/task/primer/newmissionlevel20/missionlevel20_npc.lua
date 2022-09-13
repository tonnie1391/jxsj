-- 文件名　：missionlevel20_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-16 09:30:17
-- 功能    ：

Task.NewPrimerLv20 = Task.NewPrimerLv20 or {};
local NewPrimerLv20 = Task.NewPrimerLv20;

local tbShiBing = Npc:GetClass("NewPrimerLv20_shibing");

tbShiBing.tbCunming = {
	[10251] = 10316,
	--[10252] = 1,
	--[10253] = 1,
	}

tbShiBing.tbPosInfo = {
	{1898,3551},
	{1885,3565},
	{1922,3548},
	{1936,3516},
}

function tbShiBing:OnDeath(pNpcKiller)
	local tbTasks = Task:GetPlayerTask(pNpcKiller.GetPlayer()).tbTasks[NewPrimerLv20.TASK_MAIN_ID];
	if tbTasks and  tbTasks.nReferId == NewPrimerLv20.TASK_SUB_ID_NEXT and
		tbTasks.nCurStep == 1 and him.nTemplateId == 10258 then
		local nMapId, nX, nY = him.GetWorldPos();
		local pTaskNpc = KNpc.Add2(10263, 35, -1, nMapId, nX, nY);
		if pTaskNpc then
			pTaskNpc.SetLiveTime(35*18);
		end
	end
	local tbNpc = KNpc.GetAroundNpcListByNpc(him.dwId, 10);
	for _, pNpc in ipairs(tbNpc) do
		if self.tbCunming[pNpc.nTemplateId] then
			local nMapId, nX, nY = pNpc.GetWorldPos();
			local pTaskNpc = KNpc.Add2(self.tbCunming[pNpc.nTemplateId], 1, -1, nMapId, nX, nY);
			if pTaskNpc then
				Timer:Register(Env.GAME_FPS, self.Speak, self, pTaskNpc.dwId);
				pTaskNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
				local tbPos = self.tbPosInfo[MathRandom(#self.tbPosInfo)]
				pTaskNpc.AI_AddMovePos(tbPos[1] * 32, tbPos[2] * 32);
				pTaskNpc.GetTempTable("Npc").tbOnArrive = {self.tbOnLightArrive, self, pTaskNpc.dwId};
				pNpc.Delete();
			end
		end
	end
end

function tbShiBing:Speak(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.SendChat("谢谢书青小姐和少侠救命之恩.......");
	end
	return 0;
end

function tbShiBing:tbOnLightArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
end

local tbShenmi = Npc:GetClass("NewPrimerLv20_shenmiren");

function tbShenmi:OnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	if pPlayer then
		ChangeWorldWeather(pPlayer.nMapId, 1);
		Setting:SetGlobalObj(pPlayer);
		Npc.SceneAction:DoParam(13);
		Npc.SceneAction:DoParam(14);
		me.LockClientInput();
		for i =70, 83 do
			Npc.SceneAction:DoParam(i);
		end
		me.CallClientScript({"GM:DoCommand",string.format("me.StartAutoPath(%s, %s, 1)", 1829, 3490)});
		Timer:Register(30*18, self.OnDeathEx, self, me.nId);
		self:OnFinalBossPercent(me.nId);
		Setting:RestoreGlobalObj();
	end
end
--神秘人20%血时触发子书青，挡子弹场景
function tbShenmi:OnFinalBossPercent(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 20);
	local nX = 1831;
	local nY = 3486;
	for i, pNpcEx in pairs(tbNpcList) do
		if pNpcEx.nTemplateId == 10301 then
			pNpcEx.AI_AddMovePos(nX * 32, nY * 32);
			pNpcEx.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			pNpcEx.SendChat("小心，快躲开...");
			Timer:Register(18, self.AddOtherZiqing, self, pNpcEx.dwId, pPlayer.nMapId, nX, nY, nPlayerId);
			return;
		end
	end
end
--子书青到达子弹点
function tbShenmi:AddOtherZiqing(nNpcId, nMapId, nX, nY, nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pNpc.Delete();
	Dialog:PlayIlluastration(pPlayer, {szImage = "chahua_xueguang.spr",bPenetrate = 1, nOpenTime = 0, nCloseTime = 0,nLoops = 1, nFadeinTime = 200, nFadeinTime = 100, nLastTime = 1000});
	Dialog:SendBlackBoardMsg(pPlayer,  '<color=yellow>Tử Thư Thanh<color>: Không......');
	local pNpcEx = KNpc.Add2(11079, 15, -1, nMapId, nX, nY);
	if pNpcEx then
		Timer:Register(9, self.AddOtherZiqingEx, self, pNpcEx.dwId);
	end
	return 0;
end
function tbShenmi:AddOtherZiqingEx(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.CastSkill(2935,1,-1,pNpc.nIndex);
		pNpc.SendChat("书青，终是不辱使命...");
		Timer:Register(5*18, self.AddOtherZiqingEx2, self, pNpc.dwId);
	end
	return 0;
end

function tbShenmi:AddOtherZiqingEx2(nNpcId)
local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	return 0;
end

function tbShenmi:OnDeathEx(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.UnLockClientInput();
		pPlayer.GetNpc().SendChat("前辈...");
	end
	return 0;
end

local tbXuShiwei = Npc:GetClass("NewPrimerLv20_XuShiwei");

function tbXuShiwei:OnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	if pPlayer then
		Setting:SetGlobalObj(pPlayer);
		Npc.SceneAction:DoParam(15);
		Npc.SceneAction:DoParam(16);
		Timer:Register(90, self.OnDeathEx, self, me.nId);
		Setting:RestoreGlobalObj();
	end
end

function tbXuShiwei:OnDeathEx(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.GetNpc().SendChat("许大哥……");
		NewPrimerLv20:SayZishuqing(pPlayer, "沈大哥，带他走吧……快带他走！");
	end
	return 0;
end
