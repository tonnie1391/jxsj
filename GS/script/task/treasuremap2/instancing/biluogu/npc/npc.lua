------------------------------------------------------
-- 文件名　：npc.lua
-- 创建者　：dengyong
-- 创建时间：2012-08-02 18:31:42
-- 描  述  ：碧落谷NPC
------------------------------------------------------

Require("\\script\\task\\treasuremap2\\instancing\\biluogu\\main.lua");

local function GetMission(pNpc)
	local nMapId, nMapX, nMapY	= pNpc.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	assert(tbInstancing);
	
	return tbInstancing;	
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_xiaobing");
function tbNpc:OnDeath(pNpcKiller)
	local tbInstancing = GetMission(him);
	tbInstancing:AddKillBossNum(him);
	if tbInstancing.MONSTER1_COUNT <= 0 then
		return;
	end
	
	tbInstancing.MONSTER1_COUNT = tbInstancing.MONSTER1_COUNT - 1;
	if tbInstancing.MONSTER1_COUNT <= 0 then
		tbInstancing:GoNextStep();	-- 进入第二步
	end
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_boss1");
function tbNpc:OnDeath(pNpcKiller)
	local tbInstancing = GetMission(him);
	tbInstancing:GoNextStep();		-- 进入第三步
	tbInstancing:AddKillBossNum(him);
end

function tbNpc:OnDialog()	
	local tbInstancing = GetMission(him);
	if tbInstancing.nBoss1Dialog == 1 then
		Dialog:Say("你们是什么人，是如何偷入谷中的？来人，把这些闯入者拿下！");
		tbInstancing:GoNextStep();		-- 进入第一步
	end
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_boss2_1");
function tbNpc:OnDialog()
	Dialog:Say("演员也是有尊严的！");
	--local tbInstancing = GetMission(him);
	--tbInstancing:GoNextStep();
end

function tbNpc:OnDeath()
	local tbInstancing = GetMission(him);
	tbInstancing:GoNextStep();		-- 进入第4步
	tbInstancing:AddKillBossNum(him);
end


local tbNpc = Npc:GetClass("biluogu_boss2_2");
function tbNpc:OnDeath()
	local tbInstancing = GetMission(him);
	tbInstancing:GoNextStep();		-- 进入第5步
	tbInstancing:AddKillBossNum(him);
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_boss3");
function tbNpc:OnDialog()
	local szMsg = [[虽然我早就料到义军会派人来，不过却没想到你们能做的这么利落。还真是羡慕你们义军啊，哈哈哈哈。也不必多读，你们的命和游龙珏的秘密，我就不客气的收下了]];
--	Dialog:Say(szMsg);
	local tbInstancing = GetMission(him);
	if tbInstancing.nBoss3Dialog == 1 then
		tbInstancing:GoNextStep();		-- 进入第6步
	end
end

function tbNpc:OnDeath(pNpcKiller)
	local tbInstancing = GetMission(him);
	tbInstancing:GoNextStep();		-- 进入第7步
	tbInstancing:AddKillBossNum(him);
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_lin");
function tbNpc:OnDialog()
	--Dialog:Say("演员也是有尊严的");
	--local tbInstancing = GetMission(him);
	--tbInstancing:GoNextStep();
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_jiguan");
function tbNpc:OnDialog()
	local tbInstancing = GetMission(him);
	tbInstancing:ApplyJiGuan(him.szName);
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_lulutong")
function tbNpc:OnDialog()
	local szMsg = "想去哪儿，就去哪儿！";
	local tbOpt = {};
	local tbInstancing = GetMission(him);
	
	local tbTransOpt = 
	{
		{"<color=yellow>前往岚夕池<color>", me.NewWorld, tbInstancing.nMapId, 54368/32, 111776/32},
		{"<color=yellow>前往屋前广场<color>", me.NewWorld, tbInstancing.nMapId, 55552/32, 109728/32},
		{"<color=yellow>前往离殇岛<color>", me.NewWorld, tbInstancing.nMapId, unpack(tbInstancing.tbBoatLeavePos[2])},
	}
	
	for i, tb in pairs(tbTransOpt) do
		if i > tbInstancing.nBossStep then
			break;
		end
		
		table.insert(tbOpt, tb);
	end
		
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_chuanfu")
function tbNpc:OnDialog()
	local tbInstancing = GetMission(him);
	tbInstancing:ChuanfuDialog();
end

------------------------------------------------------------------------------------

local tbNpc = Npc:GetClass("biluogu_waterfight")
function tbNpc:OnDeath(pNpcKiller)
	local tbInstancing = GetMission(him);
	tbInstancing:AddKillBossNum(him);
	if tbInstancing.WATER_FIGHT_COUNT <= 0 then
		return;
	end
	
	tbInstancing.WATER_FIGHT_COUNT = tbInstancing.WATER_FIGHT_COUNT - 1;
	tbInstancing:UpdateMsgUI();
	if tbInstancing.WATER_FIGHT_COUNT <= 0 then
		tbInstancing:GoNextStep();
	end
end