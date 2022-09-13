-----------------------------------------------------------
-- 文件名　：taohuashi.lua
-- 文件描述：对话桃花使及战斗桃花使
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-26 17:26:10
-----------------------------------------------------------

-- 战斗桃花使
local tbTaoHuaShi_Fight = Npc:GetClass("taohuashifight");

tbTaoHuaShi_Fight.tbText = {
	[70] = {"看样子你们是有备而来的！", "不过爷爷我可不是吃素的！", "让你们瞧瞧我的厉害吧！"},
	[50] = {"我觉得有些紧张！", "我们坐下来谈谈怎么样？", "别那么固执好不好？"},
	[20] = {"都是出来混的，给点面子吧！", "大家都不容易啊！", "我们停手好不好？"},
	[10] = {"好小子！软硬不吃是吧？", "算你狠咱们走着瞧！"},
	[0]  = {"我真的没想到……"},
}
-- 死亡时执行
function tbTaoHuaShi_Fight:OnDeath(pNpc)
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	him.SendChat(self.tbText[0][1]);
	
	tbInstancing.nTaoHuaShiPass = 1;
	if (not tbInstancing.nJinZhiTaoHuaLin) then
		return;
	end;
	
	local pNpc = KNpc.GetById(tbInstancing.nJinZhiTaoHuaShi);
	if (pNpc) then
		pNpc.Delete();
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Task.tbArmyCampInstancingManager:ShowTip(teammate, "Đã có thể đến Bích Ngô Phong rồi!");
	end;
end;

-- 血量在一定的时候执行
function tbTaoHuaShi_Fight:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		return;
	end;
	tbInstancing:NpcSay(him.dwId, self.tbText[nLifePercent], 1);
end;

-- 对话桃花使
local tbTaoHuaShi_Dialog = Npc:GetClass("taohuashidialog");

tbTaoHuaShi_Dialog.tbText = {
	"来吧！来吧！我都等的不耐烦了！",
	"你们真以为你们可以闯过我这个山头吗？",
	"在你们之前已经有无数人尝试过了！",
}
-- 对话
function tbTaoHuaShi_Dialog:OnDialog()
	local nSubWorld, _, _ = him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if (tbInstancing.nTaoHuaShiOut ~= 0) then
		return;
	end;
	
	local szMsg = string.format("%s：来吧！来吧！我都等的不耐烦了！", him.szName);
	local tbOpt = {
		{"Khiêu chiến", self.Fight, self, me.nId, him.dwId},
		{"Kết thúc đối thoại"},
	}
	Dialog:Say(szMsg, tbOpt);
end;

-- 对话转战斗
function tbTaoHuaShi_Dialog:Fight(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	if (not pPlayer or not pNpc) then
		return;
	end;
	
	local nSubWorld, nNpcPosX, nNpcPosY = pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if (tbInstancing.nTaoHuaShiOut ~= 0) then
		return;
	end
	-- 战斗桃花使
	local pTaoHuaShi = KNpc.Add2(4171, tbInstancing.nNpcLevel, -1 , nSubWorld, nNpcPosX, nNpcPosY);
	assert(pTaoHuaShi);
	tbInstancing:NpcSay(pTaoHuaShi.dwId, self.tbText, 1);
	
	pTaoHuaShi.AddLifePObserver(70);
	pTaoHuaShi.AddLifePObserver(50);
	pTaoHuaShi.AddLifePObserver(20);
	pTaoHuaShi.AddLifePObserver(10);
	
	tbInstancing.nTaoHuaShiOut = 1;
	pNpc.Delete();
end;

