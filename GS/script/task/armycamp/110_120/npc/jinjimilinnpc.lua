-------------------------------------------------------
-- 文件名　：jinjimilinnpc.lua
-- 文件描述：荆棘密林NPC
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-16 10:35:31
-------------------------------------------------------

local tbNpc_1 = Npc:GetClass("hl_jiheshi");

tbNpc_1.szDesc	= "集合石"
tbNpc_1.SEND_POS	= {1702, 3328};

function tbNpc_1:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (tbInstancing.nJiHeShiTime ~= 0) then
		local szMsg = "集合石暂不能使用，请过" .. tbInstancing.nJiHeShiTime .. "秒再使用！";
		local tbOpt = {"Kết thúc đối thoại"};
		Dialog:Say(szMsg, tbOpt);
		return;
	end;
	if (tbInstancing.nJiHeShiCanUse ~= 1) then
		return ;
	end;
	
	local tbOpt = {};
	local szMsg = "请选择您要召唤的队友";
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		if (tbInstancing.tbPassJingJiMiLin[teammate.nId] ~= 1 and teammate.nId ~= me.nId) then
			tbOpt[#tbOpt + 1] = { teammate.szName, self.CallUp, self, tbInstancing, teammate.nId};
		end;
	end;
	if (#tbOpt == 0) then
		szMsg = "队友都已经通过荆棘密林或不在副本中，不再需要传送！";
	end;
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg, tbOpt);
end;

function tbNpc_1:CallUp(tbInstancing, nId)
	if (tbInstancing.tbPassJingJiMiLin[nId] and tbInstancing.tbPassJingJiMiLin[nId] == 1) then
		return;
	end;
	
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (not pPlayer or pPlayer.nMapId ~= tbInstancing.nMapId) then
		return;
	end;
	
	Setting:SetGlobalObj(pPlayer);
	
	local tbPlayerDarkData	= BlackSky:GetDarkData();
	if (tbPlayerDarkData.nInDark == 1) then
		Setting:RestoreGlobalObj();
		return;
	end;
	
	local szMsg = "您的队友召唤您，是否立刻传送？";
	local tbOpt = {
			{"是",  self.SendNewPos, self, tbInstancing},
			{"否"},
		};
	Dialog:Say(szMsg, tbOpt);		
	Setting:RestoreGlobalObj();
end;	

function tbNpc_1:SendNewPos(tbInstancing)
	if (tbInstancing.nJiHeShiTime ~= 0) then
		return;
	end;
	
	me.NewWorld(tbInstancing.nMapId, self.SEND_POS[1], self.SEND_POS[2]);
	tbInstancing.nJiHeShiTime	= 30;
	me.SetFightState(1);
	Task.tbArmyCampInstancingManager:Tip2MapPlayer(me.nMapId, "<color=yellow>" .. me.szName .. "<color>已经被传送通过荆棘密林");
end;


local tbNpc_2 = Npc:GetClass("hl_round1");

tbNpc_2.szDesc 	= "开启BOSS1"
tbNpc_2.szText 	= "<npc=4181>：义军？你们来做什么，是白秋琳派你们来的？还是龙五。";
tbNpc_2.tbBoss1Pos	= {1719, 3290};
tbNpc_2.EFFECT_NPC	= 2976


function tbNpc_2:OnDialog()
	local nMapId, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing or tbInstancing.nBoss1Out ~= 0) then
		return;
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(self.szText, self.TalkEnd, self, him.dwId, tbInstancing);
		Setting:RestoreGlobalObj();
	end;	
end;

function tbNpc_2:TalkEnd(dwId, tbInstancing)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc or tbInstancing.nBoss1Out ~= 0) then
		return;
	end;
	
	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	
	local pNpc = KNpc.Add2(self.EFFECT_NPC, 10, -1, tbInstancing.nMapId, self.tbBoss1Pos[1], self.tbBoss1Pos[2]);
	Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, nMapId, pNpc.dwId);
end;

function tbNpc_2:CallBoss(nMapId, dwId)
	local pNpc = KNpc.GetById(dwId);
	if (not pNpc) then
		return 0;	
	end;
	pNpc.Delete();
		
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if (not tbInstancing or tbInstancing.nBoss1Out ==1) then
		return 0 ;
	end;
		
	local pNpc = KNpc.Add2(4181, tbInstancing.nNpcLevel, -1, nMapId, self.tbBoss1Pos[1], self.tbBoss1Pos[2]);
	pNpc.CastSkill(1163, 10, -1, pNpc.nIndex);
	
	for i = 1, 9 do
		pNpc.AddLifePObserver(i * 10);
	end;
	tbInstancing.nBoss1Out = 1;	
	
	return 0;
end;

local tbNpc_1 = Npc:GetClass("hl_boss1");

tbNpc_1.szDesc 	= "BOSS1"
tbNpc_1.tbText  = {
			[90] = "也许你还会记得我，也许你已经忘记。",
			[80] = "回去吧，这里不属于你。",
			[70] = "我的妻儿还好吗？",
			[60] = "不许你们惊扰我的主人！",
			[50] = "虽然我只是个守门的，但不要低估了我的能力。",
			[40] = "我不愿意再见到你们了，真的。",
			[30] = "感受到了吗？我的能力提升了许多。",
			[20] = "生不逢时，英雄无用武之地。",
			[10] = "再见了，我的朋友，我不会忘记你的。",
			[0]  = "<npc=4181>：唉，希望你们能够活着回来。如果你能见到我的妻儿请帮我转告，我爱他们。",
	}

function tbNpc_1:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	
	if (self.tbText[nLifePercent]) then
		--him.SendChat(self.tbText[nLifePercent]);
		
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
				teammate.Msg(self.tbText[nLifePercent], him.szName);
		end;
	end;
end;

function tbNpc_1:OnDeath(pNpc)
	local nMapId, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	
	tbInstancing.nTrap2Pass = 1;
	tbInstancing.nJiHeShiCanUse = 0;
	
	local pNpc = KNpc.Add2(4151, 120, -1, tbInstancing.nMapId, 55200 / 32, 105056 / 32);
	pNpc.szName = "";
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(self.tbText[0]);
		Setting:RestoreGlobalObj();
	end;	
end;