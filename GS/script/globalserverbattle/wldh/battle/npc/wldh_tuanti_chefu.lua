-------------------------------------------------------
-- 文件名　：wldh_tuanti_chefu.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 16:22:19
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbNpc = Npc:GetClass("wldh_tuanti_chefu");

function tbNpc:OnDialog()
	
	local tbOpt	= 	
	{
		{"我想离开这里", self.OnLeaveSay, self},
		{"Để ta suy nghĩ lại"},
	};

	local szMsg	= "你好！我可以带你离开这里。";
	Dialog:Say(szMsg, tbOpt);
end

-- 离开
function tbNpc:OnLeaveSay()
	
	local tbOpt = 
	{
		{"Xác nhận", self.OnLeave, self},
		{"Để ta suy nghĩ lại"},
	};
	
	Dialog:Say("你确定要返回报名点吗？ ", tbOpt);
end

function tbNpc:OnLeave()
	
	local pPlayer = me;
	if 1 == pPlayer.nFightState then
		return;
	end
	
	local tbMission	= Wldh.Battle:GetMissionByMapId(him.nMapId);
	
	if tbMission then
		tbMission:KickPlayer(pPlayer);
	else
		self:ProcessError(pPlayer);
	end
end

function tbNpc:ProcessError(pPlayer)
	
	local nBattleIndex = pPlayer.GetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_INDEX);
	
	if 0 == nBattleIndex then
		nBattleIndex = 1;
	end
	
	local nMapId = Wldh.Battle.MAPID_SIGNUP[nBattleIndex];
	local nIndex = math.floor(MathRandom(#Wldh.Battle.POS_SIGNUP));

	pPlayer.NewWorld(nMapId, unpack(Wldh.Battle.POS_SIGNUP[nIndex]));
	pPlayer.SetFightState(0);
end
