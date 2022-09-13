
-- ====================== 文件信息 ======================

-- 大漠古城护送者尉吕脚本
-- Edited by peres
-- 2008/05/15 PM 16:23

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbNpc			= Npc:GetClass("damogucheng_savenpc_talk");
local tbNpcFight	= Npc:GetClass("damogucheng_savenpc_fight");

tbNpc.tbTrack		= {
	{1659, 3273},
	{1669, 3280},
	{1678, 3288},
	{1688, 3300},
	{1698, 3310},
	{1707, 3300},	
	{1716, 3302},
}


tbNpc.tbTrack_2		= {
	{1719, 3306},
	{1725, 3311},
	{1731, 3317},
	{1738, 3322},
	{1748, 3315},
	{1752, 3311},
	{1756, 3306},
	{1765, 3300},
	{1775, 3309},
	{1781, 3314},
	{1789, 3301},
	{1799, 3291},
}

function tbNpc:OnDialog()
	local nKeys		= me.GetItemCountInBags(18,1,95,1);
	
	if nKeys > 0 then
		Dialog:Say("侠士，你找到了那把钥匙了？", {
				  {"来，我帮你打开这些铁鐐", tbNpc.Release, tbNpc, him.dwId},
				  {"再等等", tbNpc.OnExit, tbNpc},
				});
	else
		Dialog:Say("这些天杀的贼人……只要你能解开我身上的铁鐐，我就可以打开前面那扇通向内城的大门，杀光这群兔崽子……");
		return;
	end;
end;


function tbNpc:Release(nNpcId)
	local nKeys		= me.GetItemCountInBags(18,1,95,1);
	
	if nKeys <=0 then
		Dialog:Say("唉……你还是在城中找到那把钥匙再来吧！");
		return;
	end;
	
	local pNpc	= KNpc.GetById(nNpcId);
	
	if not pNpc then return; end;
	
	me.ConsumeItemInBags(1, 18, 1, 95, 1);
	
--	local pDialogNpc = KNpc.GetById(pNpc.dwId);
	
	local nCurMapId, nCurPosX, nCurPosY = pNpc.GetWorldPos();
	pNpc.Delete();
	
	local pFightNpc		= KNpc.Add2(2722, 120, -1, nCurMapId, nCurPosX, nCurPosY, 0, 0, 1);
	
	pFightNpc.szName	= "尉吕";
	pFightNpc.SetTitle("由<color=yellow>"..me.szName.."<color>的队伍保护");
	pFightNpc.SetCurCamp(0);
	
	pFightNpc.RestoreLife();
	
	pFightNpc.GetTempTable("Npc").tbOnArrive = {tbNpc.OnArrive, tbNpc, pFightNpc, me};

	
	pFightNpc.AI_ClearPath();
	
	for _,Pos in ipairs(self.tbTrack) do
		if (Pos[1] and Pos[2]) then
			pFightNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
		end
	end;
	
--	pFightNpc.AI_AddMovePos(1716*32, 3302*32); -- 终点为目标
	pFightNpc.SetNpcAI(9, 50, 1, -1, 25, 25, 25, 0, 0, 0, me.GetNpc().nIndex);
	
	pFightNpc.SendChat("很好……很好……");
	
end;

function tbNpc:OnArrive(pFightNpc, pPlayer)
	
	print ("tbNpc:OnArrive", pFightNpc.szName);
	local nCurMapId, nCurPosX, nCurPosY = pFightNpc.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nCurMapId);
	assert(tbInstancing);
	tbInstancing.nGateLock			= 1;
	
	if pFightNpc then
		pFightNpc.SendChat("你们……你们……很快就会知道临死前的味道");
		
		pFightNpc.AI_ClearPath();
		pFightNpc.GetTempTable("Npc").tbOnArrive = {tbNpc.OnArrive_2, tbNpc, pFightNpc}
		
		for _,Pos in ipairs(self.tbTrack_2) do
			if (Pos[1] and Pos[2]) then
				pFightNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
			end
		end;
		pFightNpc.SetNpcAI(9, 50, 1, -1, 25, 25, 25, 0, 0, 0, pPlayer.GetNpc().nIndex);
	end;
	
end;


function tbNpc:OnArrive_2(pFightNpc)
	if pFightNpc then
		pFightNpc.SendChat("这本来就不是属于你们的地方！");
	end;
end;

function tbNpc:OnExit()
	
end;