-- 文件名　：flower_newserverevent.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-10 16:21:25
-- 描述：送花道具相关

SpecialEvent.NewServerEvent =  SpecialEvent.NewServerEvent or {};
local NewServerEvent = SpecialEvent.NewServerEvent;

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

----花瓣
local tbFlowerLeaves = Item:GetClass("flowerleaves_newserverevent");

function tbFlowerLeaves:InitGenInfo()
	local nServerStartTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nEndTime	= NewServerEvent.nEndDate * 24 * 60 * 60;
	it.SetTimeOut(0, nServerStartTime + nEndTime);
	return	{};
end

function tbFlowerLeaves:OnUse()
	local szName = KItem.GetNameById(unpack(NewServerEvent.tbFlowerGDPL));
	local szMsg = string.format("Bạn có thể dùng <color=yellow>%s điểm<color> Tinh Hoạt Lực, để chế tạo thành <color=yellow>%s<color>。\n\nBạn có chắc chắn?",NewServerEvent.nMakeFlowerJinghuo,szName);
	local tbOpt = 
	{
		{"Chế tạo", self.MakeFlower,self,it.dwId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbFlowerLeaves:MakeFlower(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake();
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("Đang chế tạo...", 1 * Env.GAME_FPS, {self.DoMake,self,pItem.dwId},nil,tbEvent);
end

function tbFlowerLeaves:DoMake(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake();
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbFlowerInfo = NewServerEvent.tbFlowerGDPL;
	local nNeedGTPMKP = NewServerEvent.nMakeFlowerJinghuo;
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		return 0;
	end
	me.ChangeCurGatherPoint(-nNeedGTPMKP);
	me.ChangeCurMakePoint(-nNeedGTPMKP);
	local pItem = me.AddItem(tbFlowerInfo[1],tbFlowerInfo[2],tbFlowerInfo[3],tbFlowerInfo[4]);
	if not pItem then
		Dbg:WriteLog("New Server Event","Make Flower Failed",me.szName);
		return 0;
	end
	return 1;
end

function tbFlowerLeaves:CheckCanMake()
	if NewServerEvent:IsEventOpen() ~= 1 then
		return 0,"Sự kiện đã kết thúc.";
	end
	if me.IsAccountLock() ~= 0 then
		Account:OpenLockWindow(me);
		return 0,"Tài khoản đang bị khóa, không thể thao tác!";
	end
	if me.nLevel < NewServerEvent.nCanGiveFlowerLevel then
		return 0,string.format("等级未达到<color=yellow>%s<color>级的玩家无法进行鲜花制作！",NewServerEvent.nCanGiveFlowerLevel);
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		return 0, "Chỉ có thể chế tạo tại Thành Thị và Tân Thủ Thôn!";
	end
	local szErrMsg = "";
	if me.CountFreeBagCell() < 1 then
		szErrMsg = "Hành trang không đủ <color=yellow>1 ô<color> trống!";
		return 0, szErrMsg;
	end
	local nNeedGTPMKP = NewServerEvent.nMakeFlowerJinghuo;
	if me.dwCurGTP < nNeedGTPMKP or me.dwCurMKP < nNeedGTPMKP then
		szErrMsg = string.format("你的精活不足，制作玫瑰花需要消耗精力和活力各<color=yellow>%s点<color>。",nNeedGTPMKP);
		return 0, szErrMsg;
	end
	return 1;
end


----玫瑰花
local tbFlower = Item:GetClass("flower_newserverevent");

function tbFlower:InitGenInfo()
	local nServerStartTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nEndTime	= NewServerEvent.nEndDate * 24 * 60 * 60;
	it.SetTimeOut(0, nServerStartTime + nEndTime);
	return	{};
end

function tbFlower:CheckCanUse()
	if NewServerEvent:IsEventOpen() ~= 1 then
		Dialog:Say("Sự kiện đã kết thúc.");
		return 0;
	end
	if me.nSex == Player.FEMALE then	--女性玩家不能使用
		Dialog:Say("只有男性玩家才能进行鲜花馈赠！");
		return 0;
	end
	if me.nLevel < NewServerEvent.nCanGiveFlowerLevel then
		Dialog:Say(string.format("等级未达到<color=yellow>%s<color>级的玩家无法进行鲜花馈赠！",NewServerEvent.nCanGiveFlowerLevel));
		return 0;
	end
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
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,NewServerEvent.nFireExpRange);
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
	local tbLevel = {};
	local nDiffSex = 0;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
			table.insert(tbLevel,pPlayer.nLevel);
		end
	end
	if tbSex[1] and tbSex[2] then
		if tbSex[1] ~= tbSex[2] then
			nDiffSex = 1;
		end
	end
	if nDiffSex ~= 1 then
		Dialog:Say("必须和异性单独组队才能使用该道具!");
		return 0;
	end
	if tbLevel[1] < NewServerEvent.nCanGiveFlowerLevel or tbLevel[2] < NewServerEvent.nCanGiveFlowerLevel then
		Dialog:Say(string.format("队伍成员必须都达到<color=yellow>%s<color>级才能使用该道具!",NewServerEvent.nCanGiveFlowerLevel));
		return 0;
	end
	local nUseCount = 0;	--馈赠的次数
	local nGetCount = 0;	--接受的次数
	local bHasEmptyBag = 1;	--是否队员都有空闲的背包
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			local nTime = tonumber(os.date("%Y%m%d",pPlayer.GetTask(NewServerEvent.nTaskId,NewServerEvent.nUseFlowerTimeGroupId)));
			if tonumber(os.date("%Y%m%d",GetTime())) ~= nTime then
				pPlayer.SetTask(NewServerEvent.nTaskId,NewServerEvent.nUseFlowerCountGroupId,0);
				pPlayer.SetTask(NewServerEvent.nTaskId,NewServerEvent.nUseFlowerTimeGroupId,GetTime());
			end
			if pPlayer.nSex == Player.MALE then
				nUseCount = pPlayer.GetTask(NewServerEvent.nTaskId,NewServerEvent.nUseFlowerCountGroupId);
			else
				nGetCount = pPlayer.GetTask(NewServerEvent.nTaskId,NewServerEvent.nUseFlowerCountGroupId);
			end
			if pPlayer.CountFreeBagCell() < 1 then
				bHasEmptyBag = 0;
			end
		end
	end
	if nUseCount >= NewServerEvent.nCanGiveFlowerMaxCount then
		Dialog:Say(string.format("队伍中的男性玩家达到了当天的馈赠鲜花的上限。每个男性玩家每天只能进行%s次鲜花的馈赠!",NewServerEvent.nCanGiveFlowerMaxCount));
		return 0;
	end
	if nGetCount >= NewServerEvent.nCanGetFlowerMaxCount then
		Dialog:Say(string.format("队伍中的女性玩家达到了当天的接受鲜花馈赠的上限。每个女性玩家每天只能接受%s次鲜花的馈赠!",NewServerEvent.nCanGetFlowerMaxCount));
		return 0;
	end
	if bHasEmptyBag ~= 1 then
		Dialog:Say("请保证队伍中每个成员留出至少一格背包空间！");
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or 
			pNpc.nTemplateId == NewServerEvent.nFireTemplateId then
			Dialog:Say(string.format("在这点蜡烛会把<color=green>%s<color>给挡住了，还是挪个地方吧。", pNpc.szName ~= "" and pNpc.szName or "别人的蜡烛"));
			return 0;
		end
	end
	return 1;	
end


function tbFlower:OnUse()
	if self:CheckCanUse() == 1 then
		local tbMember = me.GetTeamMemberList();
		GeneralProcess:StartProcess("点燃中...", 1 * Env.GAME_FPS, {self.DoFire, self,it.dwId,tbMember}, nil, tbEvent);
	end
end

function tbFlower:DoFire(nItemId,tbMember)
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
	local pNpc = KNpc.Add2(NewServerEvent.nFireTemplateId,10,-1,nMapId,nX,nY);
	if not pNpc then
		Dbg:WriteLog("New Server Event","Add Fire Failed",me.szName);
		return 0;
	else
		local nAddExpTime = NewServerEvent.nFireGiveExpDelay;
		pNpc.SetTitle(string.format("<color=yellow>%s<color>和<color=yellow>%s<color>的红烛",tbMember[1].szName,tbMember[2].szName));
		pNpc.szName = "";
		pNpc.GetTempTable("SpecialEvent").szMaleName = tbMember[1].nSex == 0 and tbMember[1].szName or tbMember[2].szName;
		pNpc.GetTempTable("SpecialEvent").szFemaleName = tbMember[1].nSex == 1 and tbMember[1].szName or tbMember[2].szName;
		pNpc.GetTempTable("SpecialEvent").nAddExpTimer = Timer:Register(nAddExpTime,Npc:GetClass("fire_newserverevent").AddExp,Npc:GetClass("fire_newserverevent"),pNpc.dwId);
		pNpc.Sync();
		--todo,给箱子,记变量
		for i = 1, #tbMember do
			local pPlayer = tbMember[i];
			if pPlayer then
				local nGetCount = pPlayer.GetTask(NewServerEvent.nTaskId,NewServerEvent.nUseFlowerCountGroupId);
				pPlayer.SetTask(NewServerEvent.nTaskId,NewServerEvent.nUseFlowerCountGroupId,nGetCount + 1);
				local pItem = pPlayer.AddItem(unpack(NewServerEvent.tbFirePrizeGDPl));
				if not pItem then
					Dbg:WriteLog("New Server Event","Add Fire Prize Failed",pPlayer.szName);
				end
			end
		end
	end
end


