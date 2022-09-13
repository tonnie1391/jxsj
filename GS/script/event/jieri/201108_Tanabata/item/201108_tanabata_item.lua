-- 文件名　：201108_tanabata_item.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-25 10:44:41
-- 描述：七夕活动道具


SpecialEvent.Tanabata201108 =  SpecialEvent.Tanabata201108 or {};
local Tanabata201108 = SpecialEvent.Tanabata201108;

local tbEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
}


---七夕红烛
local tbMaleItem = Item:GetClass("QX_malefire");

function tbMaleItem:InitGenInfo()
	local nSec = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 3600 * 24;
	it.SetTimeOut(0, nSec);
	return	{};
end

function tbMaleItem:CheckCanUse()
	local nMapId,nX,nY = me.GetWorldPos();
	local szMapType = GetMapType(nMapId);
	if szMapType ~= "village" and szMapType ~= "city" and szMapType ~= "fight" then
		Dialog:Say("该道具只能在新手村、各大城市和野外地图使用！");
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		Dialog:Say("只有组队才能使用该道具！");
		return 0;
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		Dialog:Say("只有两人队伍才能使用该道具。");
		return 0;
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	for _, tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		Dialog:Say("对不起，你的队友离你太远了。");
		return 0;
	end
	local tbMember = me.GetTeamMemberList();
	local tbSex = {};
	local nDiffSex = 0;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
		end
	end
	if tbSex[1] and tbSex[2] then
		if tbSex[1] ~= tbSex[2] then
			nDiffSex = 1;
		end
	end
	if nDiffSex ~= 1 then
		Dialog:Say("必须和异性组队才能使用该道具!");
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or 
		pNpc.nTemplateId == Tanabata201108.nTongxinzhuTemplateId or 
		pNpc.nTemplateId == Tanabata201108.nHongzhuTemplateId then
			Dialog:Say(string.format("在这点蜡烛会把<color=green>%s<color>给挡住了，还是挪个地方吧。", pNpc.szName ~= "" and pNpc.szName or "别人的蜡烛"));
			return 0;
		end
	end
	return 1;	
end


function tbMaleItem:OnUse()
	if self:CheckCanUse() == 1 then
		local tbMember = me.GetTeamMemberList();
		GeneralProcess:StartProcess("点燃中...", 1 * Env.GAME_FPS, {self.DoFire, self,it.dwId,tbMember}, nil, tbEvent);
	end
end


function tbMaleItem:DoFire(nItemId,tbMember)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if not tbMember then
		return 0;
	end
	if self:CheckCanUse() ~= 1 then
		return 0;
	end
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		return 0;
	end
	local nMapId,nX,nY = me.GetWorldPos();
	local pNpc = nil;
	for i = 1, #tbMember do
		local cTeamMate = tbMember[i]
		if (cTeamMate.szName ~= me.szName) then
			if (KPlayer.CheckRelation(me.szName, cTeamMate.szName, Player.emKPLAYERRELATION_TYPE_COUPLE) == 0) then
				pNpc = KNpc.Add2(Tanabata201108.nHongzhuTemplateId,10,-1,nMapId,nX,nY);
			else
				pNpc = KNpc.Add2(Tanabata201108.nTongxinzhuTemplateId,10,-1,nMapId,nX,nY);
			end
			Dialog:SendBlackBoardMsg(cTeamMate,string.format("<color=yellow>%s<color>放下了七夕红烛，请<color=yellow>%s<color>尽快许下七夕之愿",me.szName,cTeamMate.szName));
		end
	end
	if not pNpc then
		return 0;
	else
		pNpc.SetTitle(string.format("<color=yellow>%s<color>和<color=yellow>%s<color>的红烛",tbMember[1].szName,tbMember[2].szName));
		pNpc.szName = "";
		pNpc.GetTempTable("SpecialEvent").szMaleName = tbMember[1].nSex == 0 and tbMember[1].szName or tbMember[2].szName;
		pNpc.GetTempTable("SpecialEvent").szFemaleName = tbMember[1].nSex == 1 and tbMember[1].szName or tbMember[2].szName;
		pNpc.GetTempTable("SpecialEvent").nWaitHopeTimer = Timer:Register(Tanabata201108.nWaitHopeTime * Env.GAME_FPS, Npc:GetClass("QX_fire").WaitHope,Npc:GetClass("QX_fire"),pNpc.dwId);
		pNpc.GetTempTable("SpecialEvent").bDoHope = 0;	--女方是否使用过火
		pNpc.Sync();
	end
end



-------七夕之愿------------
local tbFemaleItem = Item:GetClass("QX_femalehope");

function tbFemaleItem:CheckCanUse()
	local nMapId,nX,nY = me.GetWorldPos();
	local szMapType = GetMapType(nMapId);
	if szMapType ~= "village" and szMapType ~= "city" and szMapType ~= "fight" then
		Dialog:Say("该道具只能在新手村、各大城市和野外地图使用！");
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		Dialog:Say("只有组队才能使用该道具！");
		return 0;
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		Dialog:Say("只有两人队伍才能使用该道具。");
		return 0;
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	for _, tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		Dialog:Say("对不起，你的队友离你太远了。");
		return 0;
	end
	local tbMember = me.GetTeamMemberList();
	local tbSex = {};
	local nDiffSex = 0;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
		end
	end
	if tbSex[1] and tbSex[2] then
		if tbSex[1] ~= tbSex[2] then
			nDiffSex = 1;
		end
	end
	if nDiffSex ~= 1 then
		Dialog:Say("必须和异性组队才能使用该道具!");
		return 0;
	end
	local bCouple = 0;
	local bHasEmptyBag = 1;
	for i = 1, #tbMember do
		local cTeamMate = tbMember[i];
		if cTeamMate.CountFreeBagCell() < 1 then
			bHasEmptyBag = 0;
		end
		if (cTeamMate.szName ~= me.szName) then
			if (KPlayer.CheckRelation(me.szName, cTeamMate.szName, Player.emKPLAYERRELATION_TYPE_COUPLE) == 1) then
				bCouple = 1;			
			end
		end
	end
	local tbNpcList = KNpc.GetAroundNpcList(me, 20);
	local pFire = nil;
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == Tanabata201108.nHongzhuTemplateId or pNpc.nTemplateId == Tanabata201108.nTongxinzhuTemplateId then
			local szFemaleName = pNpc.GetTempTable("SpecialEvent").szFemaleName;
			local szMaleName = pNpc.GetTempTable("SpecialEvent").szMaleName;
			if szFemaleName == me.szName and tbMember[1] and tbMember[2] and 	--如果蜡烛点完换队伍，则不让使用
				szMaleName == (tbMember[1].szName ~= me.szName and tbMember[1].szName or tbMember[2].szName) then
				pFire = pNpc;
				break;
			end
		end
	end
	if not pFire then
		Dialog:Say("这里好像没有你们队伍点燃的蜡烛!");
		return 0;
	end
	if bHasEmptyBag ~= 1 then
		Dialog:Say("请保证队伍两人留出至少一格背包空间！");
		return 0;
	end
	return 1,pFire,bCouple;
end


function tbFemaleItem:OnUse()
	local bCanUse,pFire,bCouple = self:CheckCanUse();
	if bCanUse == 1 then
		GeneralProcess:StartProcess("许愿中...", 1 * Env.GAME_FPS, {self.DoHope, self,it.dwId,pFire,bCouple}, nil, tbEvent);
	end
end

function tbFemaleItem:DoHope(nItemId,pFire,bCouple)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if not pFire then
		return 0;
	end
	if self:CheckCanUse() ~= 1 then
		return 0;
	end
	
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		return 0;
	end
	local nAddExpTime = Tanabata201108.nAddExpTime;
	local nWaitHopeTimer = pFire.GetTempTable("SpecialEvent").nWaitHopeTimer;
	pFire.GetTempTable("SpecialEvent").nAddExpTimer = Timer:Register(nAddExpTime * Env.GAME_FPS, Npc:GetClass("QX_fire").AddExp,Npc:GetClass("QX_fire"),pFire.dwId);
	pFire.GetTempTable("SpecialEvent").bCouple = bCouple or 0;
	pFire.GetTempTable("SpecialEvent").bDoHope = 1;	--已经许愿了
	if nWaitHopeTimer and nWaitHopeTimer > 0 then
		Timer:Close(nWaitHopeTimer);
		pFire.GetTempTable("SpecialEvent").nWaitHopeTimer = 0;
	end
	--todo,给箱子
	local tbMember = me.GetTeamMemberList();
	for _,pMember in pairs(tbMember) do
		if pMember then
			if bCouple == 1 then
				pMember.AddItem(18,1,1360,2);	--侠侣宝箱
				StatLog:WriteStatLog("stat_info", "qixi_2011","txqy", pMember.nId,2,1);
			else
				pMember.AddItem(18,1,1360,1);	--同心宝箱
				StatLog:WriteStatLog("stat_info", "qixi_2011","txqy", pMember.nId,1,1);
			end
		end
	end
end


function tbFemaleItem:InitGenInfo()
	local nSec = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 3600 * 24;
	it.SetTimeOut(0, nSec);
	return	{};
end