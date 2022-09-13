-- 文件名　：201112_xmas_item.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-28 17:12:35
-- 描述：道具

SpecialEvent.Xmas2011 =  SpecialEvent.Xmas2011 or {};
local Xmas2011 = SpecialEvent.Xmas2011;

Require("\\script\\event\\jieri\\201112_xmas\\201112_xmas_def.lua");

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

-----------------面具箱---------------------------
local tbMask = Item:GetClass("mask_card_2011xmas");

function tbMask:OnUse()
	local szInfo = "请选择你想要的圣诞面具：";
	local tbOpt = {};
	for nIndex,tbGdpl in ipairs(Xmas2011.tbMaskDetailGdpl) do
		table.insert(tbOpt,{KItem.GetNameById(unpack(tbGdpl)),self.AddMask,self,nIndex,it.dwId});
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szInfo,tbOpt);
	return 0;
end


function tbMask:AddMask(nType,nItemId)
	local pItem =  KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!");
		return 0;
	end
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Mask Item Delete Failed!",me.nId,me.szName);
		return 0;
	end
	local pMask = me.AddItem(unpack(Xmas2011.tbMaskDetailGdpl[nType]));
	if pMask then
		pMask.Bind(1);
		return 1;	
	else
		Dbg:WriteLog("SpecialEvent","Xmas2011,Give Mask Failed!",me.nId,me.szName);
		return 0;
	end
end


-------------------装满礼物的袜子
local tbPrizeSock = Item:GetClass("prize_sock_2011xmas");

function tbPrizeSock:InitGenInfo()
	local nRemainTime = Xmas2011:CalItemRemainTime();
	it.SetTimeOut(0,nRemainTime);
	return {};
end

function tbPrizeSock:OnUse()
	local nCanGetPrize = it.GetGenInfo(1,0) or 0;
	if nCanGetPrize ~= 1 then
		local nCanOpenStar,szError = self:CheckCanOpenStar();
		if nCanOpenStar ~= 1 then
			Dialog:Say(szError);
			return 0;
		end
		local _,x,y = me.GetWorldPos();
		me.CastSkill(Xmas2011.nUpStarSkillId,1,x*32,y*32,1);	--放星星特效
		GeneralProcess:StartProcess("点亮星星中...", 2 * Env.GAME_FPS, {self.OpenStar,self,it.dwId},nil,tbEvent);
	else
		self:GivePrize(it.dwId);
	end
end

function tbPrizeSock:OpenStar(nId)
	local pItem = KItem.GetObjById(nId);
	if not pItem then
		return 0;
	end
	local nCanOpenStar,szError = self:CheckCanOpenStar();
	if nCanOpenStar ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local nMapId,nX,nY = me.GetWorldPos();	
	local pStar = KNpc.Add2(Xmas2011.nStarNpcTemplateId,1,-1,nMapId,nX,nY);
	if pStar then
		pStar.SetLiveTime(Xmas2011.nStarLiveTime);	--设置生存时间
		pItem.SetGenInfo(1,1);
	else
		Dbg:WriteLog("SpecialEvent","Xmas2011,Open Star Failed!",me.nId,me.szName);
	end
end

function tbPrizeSock:CheckCanOpenStar()
	local nMapId,nX,nY = me.GetWorldPos();
	local szMapType = GetMapType(nMapId);
	if szMapType ~= "village" and szMapType ~= "city" then
		return 0,"该道具只能在新手村和各大城市使用！";
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,Xmas2011.nOpenStarRequireRange);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nTemplateId == Xmas2011.nStarNpcTemplateId then
			return 0,"这里貌似太过拥挤了，还是换一个地方试试吧！";
		end
	end
	return 1;
end

function tbPrizeSock:GivePrize(nId)
	local pItem = KItem.GetObjById(nId);
	if not pItem then
		return 0;
	end
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Give Sock Prize Failed!",me.nId,me.szName);
	else
		local tbRandomItem = Item:GetClass("randomitem");
		local nLevel = Xmas2011:GetPrizeLevel();
		tbRandomItem:SureOnUse(Xmas2011.tbPrizeRandomItemId[nLevel]);
	end
end


------------------普通花色袜子
local tbSock = Item:GetClass("sock_2011xmas");

function tbSock:InitGenInfo()
	local nRemainTime = GetTime() + Xmas2011.nSockLiveTime;
	it.SetTimeOut(0,nRemainTime);	--相对时间
	return {};
end


----------------脏兮兮小雪团
local tbNormalSnowBall = Item:GetClass("normalsnowball_2011xmas");

function tbNormalSnowBall:InitGenInfo()
--	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
--	it.SetTimeOut(0,nRemainTime);	--相对时间
	return {};
end

function tbNormalSnowBall:OnUse()
	local szName = KItem.GetNameById(unpack(Xmas2011.tbSnowBallGdpl));
	local szMsg = string.format("您可以通过消耗精力、活力，将它加工成<color=yellow>%s<color>。\n\n确定制作么？",szName);
	local tbOpt = 
	{
		{"确定制作", self.OnMakeSnowBall,self,it.nCount,it.dwId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbNormalSnowBall:OnMakeSnowBall(nMaxCount,nItemId)
	Dialog:AskNumber("请输入制作的数量：",nMaxCount,self.SureMakeSnowBall,self,nItemId);
end

function tbNormalSnowBall:SureMakeSnowBall(nItemId,nCount)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake(nCount,pItem.nCount);
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local szName = KItem.GetNameById(unpack(Xmas2011.tbSnowBallGdpl));
	local szMsg = string.format("您确定消耗精力、活力各<color=yellow>%s<color>点，将它加工成%s个<color=yellow>%s<color>。\n\n确定制作么？",Xmas2011.nMakeSnowBallNeedGTMK * nCount,nCount,szName);
	local tbOpt = 
	{
		{"确定制作", self.MakeSnowBall,self,nCount,nItemId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbNormalSnowBall:MakeSnowBall(nCount,nItemId)
	GeneralProcess:StartProcess("加工雪球中...", 1 * Env.GAME_FPS, {self.DoMake,self,nItemId,nCount},nil,tbEvent);
end

function tbNormalSnowBall:DoMake(nItemId,nMakeCount)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake(nMakeCount,pItem.nCount);
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbBallInfo = Xmas2011.tbSnowBallGdpl;
	local nNeedGTPMKP = Xmas2011.nMakeSnowBallNeedGTMK * nMakeCount;
	local nCount = pItem.nCount or 0;
	if nCount <= 0 then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Noraml SnowBall Not Found!",me.nId,me.szName);
		return 0;
	end
	if nCount - nMakeCount > 0 then
		if pItem.SetCount(nCount - nMakeCount) ~= 1 then
			Dbg:WriteLog("SpecialEvent","Xmas2011,Delete Noraml SnowBall Failed!",me.nId,me.szName);
			return 0;
		end	
	else 
		if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
			Dbg:WriteLog("SpecialEvent","Xmas2011,Delete Noraml SnowBall Failed!",me.nId,me.szName);
			return 0;
		end	
	end
	me.ChangeCurGatherPoint(-nNeedGTPMKP);
	me.ChangeCurMakePoint(-nNeedGTPMKP);
	local nCurCount = me.AddStackItem(tbBallInfo[1],tbBallInfo[2],tbBallInfo[3],tbBallInfo[4],nil,nMakeCount);
	StatLog:WriteStatLog("stat_info","shengdanjie_2011","snow_man_ball",me.nId,nMakeCount);
	if nCurCount ~= nMakeCount then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Add SnowBall Failed!",me.nId,me.szName);
	end
	return 1;
end

function tbNormalSnowBall:CheckCanMake(nCount,nItemCount)
	if Xmas2011:IsEventOpen() ~= 1 then
		return 0,"Sự kiện đã kết thúc!";
	end
	if me.nLevel < Xmas2011.nMakeSnowBoyBaseLevel then
		return 0, "你的等级未达到参加活动需要的最低等级！";		
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		return 0, "Chỉ có thể chế tạo tại Thành Thị và Tân Thủ Thôn!";
	end
	if not nCount or not nItemCount or nCount > nItemCount then
		return 0,"输入的数量有误，请重新输入！";
	end
	local nNeedGTPMKP = Xmas2011.nMakeSnowBallNeedGTMK * nCount;
	if me.dwCurGTP < nNeedGTPMKP or me.dwCurMKP < nNeedGTPMKP then
		return 0, string.format("你的精活不足，加工%s个雪球需要消耗精力和活力各<color=yellow>%s点<color>。",nCount,nNeedGTPMKP);
	end
	if me.CountFreeBagCell() < nCount then
		return 0,string.format("请保证留出<color=yellow>%s格<color>背包空间！",nCount);
	end
	return 1;
end


---------------莹白的雪花团子
local tbSnowBall = Item:GetClass("snowball_2011xmas");

function tbSnowBall:InitGenInfo()
	local nRemainTime = Xmas2011:CalItemRemainTime();
	it.SetTimeOut(0,nRemainTime);
	return {};
end

--------------------雪人冰座
local tbSnowBase = Item:GetClass("snowbase_2011xmas");

function tbSnowBase:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--相对时间
	return {};
end

function tbSnowBase:OnUse()
	if Xmas2011:IsEventOpen() ~= 1 then
		return 0;
	end
	local nCanDropSnowBase,szError = self:CheckCanDropSnowBase();
	if nCanDropSnowBase ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("放置雪人冰座中...", 1 * Env.GAME_FPS, {self.DropSnowBase,self,it.dwId},nil,tbEvent);
end

function tbSnowBase:CheckCanDropSnowBase()
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"只有组队才能放置雪人冰座！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount ~= Xmas2011.nMakeSnowBoyRequirePlayerCount then
		return 0,"只有三人队伍才能放置雪人冰座！";
	end
	if me.IsCaptain() ~= 1 then
		return 0,"只有队长才能放置雪人冰座！";
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,Xmas2011.nGetSockRequireRange);
	for _, tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		return 0,"对不起，你的队友离你太远了。";
	end
	local tbMember = me.GetTeamMemberList();
	local nIsAllLevelReach = 1;	--是否都达到了等级需求
	local nAllHasMask = 1;	--是否都有面具
	local tbPlayerName = {}; 
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			if pPlayer.nLevel < Xmas2011.nMakeSnowBoyBaseLevel then
				nIsAllLevelReach = 0;
			end
			local pMask = pPlayer.GetEquip(Item.EQUIPPOS_MASK);
			if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
				nAllHasMask = 0;
			end
			table.insert(tbPlayerName,pPlayer.szName);
		end
	end
	local tbNoFriendName = {};	--记录不是好友的名字
	for i = 1,#tbPlayerName do
		for j = i + 1,#tbPlayerName do
			local szName1 = tbPlayerName[i];
			local szName2 = tbPlayerName[j];
			if KPlayer.CheckRelation(szName1,szName2, Player.emKPLAYERRELATION_TYPE_BIDFRIEND) ~= 1 then
				local szError = string.format("<color=yellow>%s<color>和<color=yellow>%s<color>\n",szName1,szName2);
				table.insert(tbNoFriendName,szError);	
			end
		end
	end
	if nIsAllLevelReach ~= 1 then
		return 0,"队伍中有队友的等级未达到参加活动需要的最低等级！";
	end
	if nAllHasMask ~= 1 then
		return 0,"队伍中有成员没有装备圣诞欢喜面具！";
	end
	if #tbNoFriendName > 0 then
		local szMsg = "";
		for _,szError in pairs(tbNoFriendName) do
			szMsg = szMsg .. szError .. "没有好友关系，无法参加堆雪人活动！\n";
		end
		return 0,szMsg;	
	end
	local nMapId,nX,nY = me.GetWorldPos();
	local szMapType = GetMapType(nMapId);
	if szMapType ~= "village" and szMapType ~= "city" then
		return 0,"该道具只能在新手村和各大城市使用！";
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,Xmas2011.nDropSnowBaseRequireRange);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nTemplateId == Xmas2011.nSnowBaseTemplateId then
			return 0,"这里貌似太过拥挤了，还是换一个地方试试吧！";
		end
	end
	return 1;
end

function tbSnowBase:DropSnowBase(nItemId)
	local pItem =  KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nCanDropSnowBase,szError = self:CheckCanDropSnowBase();
	if nCanDropSnowBase ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Delete Snow Base Item Failed!",me.nId,me.szName);
		return 0;
	else
		local nTemplateId = Xmas2011.nSnowBaseTemplateId;
		local nMapId,nX,nY = me.GetWorldPos();
		local pSnowBase = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
		if pSnowBase then
			pSnowBase.SetLiveTime(Xmas2011.nSnowBaseLiveTime);
			local szName = me.szName .. "雪人";
			pSnowBase.szName = szName;
			pSnowBase.GetTempTable("SpecialEvent").szCaptainName = me.szName;	--记录队长的名字
			pSnowBase.GetTempTable("SpecialEvent").tbBelongPlayerList = {};	--记录是哪些队伍的
			local tbMember = me.GetTeamMemberList();
			for _,pMember in pairs(tbMember) do
				if pMember then
					table.insert(pSnowBase.GetTempTable("SpecialEvent").tbBelongPlayerList,pMember.szName);
				end
			end
			pSnowBase.Sync();
			return 1;
		else
			Dbg:WriteLog("SpecialEvent","Xmas2011,Add Snow Base Npc Failed!",me.nId,me.szName);
			return 0;
		end
	end
end



----------------圣诞令牌
local tbFubenXmas = Item:GetClass("fuben_2011xmas");

function tbFubenXmas:InitGenInfo()
	local nRemainTime = Xmas2011:CalItemRemainTime();
	it.SetTimeOut(0,nRemainTime);
	return {};
end


-------------宝石碎片
local tbStonePiece = Item:GetClass("stonepiece_2011xmas");

function tbStonePiece:OnUse()
	local szBoxName = KItem.GetNameById(unpack(Xmas2011.tbStoneBoxGdpl));
	local szPieceName = KItem.GetNameById(unpack(Xmas2011.tbStonePieceGdpl));
	local szMoonName = KItem.GetNameById(unpack(Xmas2011.tbMoonStoneGdpl));
	local nPieceCount = Xmas2011.nNeedStonePieceCount;
	local nMoonCount = Xmas2011.nNeedMoonStoneCount;
	local szMsg = string.format("    您可以通过消耗<color=yellow>%s<color>个<color=yellow>%s<color>和<color=yellow>%s<color>个<color=yellow>%s<color>，制作成为一个<color=yellow>%s<color>\n\n确定制作么？",nPieceCount,szPieceName,nMoonCount,szMoonName,szBoxName);
	local tbOpt = 
	{
		{"确定制作",self.OnMakeStoneBox,self,it.dwId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbStonePiece:OnMakeStoneBox(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local tbPieceFind = me.FindItemInBags(unpack(Xmas2011.tbStonePieceGdpl));
	local nPieceCount = 0;
	for _,tbItem in pairs(tbPieceFind) do
		if tbItem.pItem then
			nPieceCount = nPieceCount + tbItem.pItem.nCount;
		end
	end
	local nMaxCount = math.floor(nPieceCount / Xmas2011.nNeedStonePieceCount);
	if nMaxCount <= 0 then
		local szBoxName = KItem.GetNameById(unpack(Xmas2011.tbStoneBoxGdpl));
		local szPieceName = KItem.GetNameById(unpack(Xmas2011.tbStonePieceGdpl));
		local szMsg = string.format("您的<color=yellow>%s<color>不足，无法制作<color=yellow>%s<color>!",szPieceName,szBoxName);
		Dialog:Say(szMsg);
		me.Msg(szMsg);
		return 0;
	end
	Dialog:AskNumber("请输入制作的数量：",nMaxCount,self.SureMakeStoneBox,self,nItemId);
end

function tbStonePiece:SureMakeStoneBox(nItemId,nCount)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if nCount <= 0 then	--输入0，直接返回
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake(nCount,nItemId);
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local szBoxName = KItem.GetNameById(unpack(Xmas2011.tbStoneBoxGdpl));
	local szPieceName = KItem.GetNameById(unpack(Xmas2011.tbStonePieceGdpl));
	local szMoonName = KItem.GetNameById(unpack(Xmas2011.tbMoonStoneGdpl));
	local nPieceCount = Xmas2011.nNeedStonePieceCount * nCount;
	local nMoonCount = Xmas2011.nNeedMoonStoneCount * nCount;
	local szMsg = string.format("    您确定消耗<color=yellow>%s<color>个<color=yellow>%s<color>和<color=yellow>%s<color>个<color=yellow>%s<color>，制作<color=yellow>%s<color>个<color=yellow>%s<color>。\n\n确定制作么？",nPieceCount,szPieceName,nMoonCount,szMoonName,nCount,szBoxName);
	local tbOpt = 
	{
		{"确定制作", self.MakeStoneBox,self,nCount,nItemId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbStonePiece:MakeStoneBox(nCount,nItemId)
	GeneralProcess:StartProcess("制作宝箱中...", 1 * Env.GAME_FPS, {self.DoMakeBox,self,nItemId,nCount},nil,tbEvent);
end

function tbStonePiece:DoMakeBox(nItemId,nCount)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if nCount <= 0 then	--输入0，直接返回
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake(nCount,nItemId);
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local nNeedPieceCount = Xmas2011.nNeedStonePieceCount * nCount;
	local nNeedMoonCount = Xmas2011.nNeedMoonStoneCount * nCount;
	local nConsumePieceCount = me.ConsumeItemInBags(nNeedPieceCount,unpack(Xmas2011.tbStonePieceGdpl));
	local nConsumeMoonCount = me.ConsumeItemInBags(nNeedMoonCount,unpack(Xmas2011.tbMoonStoneGdpl));
	local tbBoxGdpl = Xmas2011.tbStoneBoxGdpl;
	if nConsumeMoonCount == 0 and nConsumePieceCount == 0 then
		local nCurCount = me.AddStackItem(tbBoxGdpl[1],tbBoxGdpl[2],tbBoxGdpl[3],tbBoxGdpl[4],nil,nCount);
		StatLog:WriteStatLog("stat_info","shengdanjie_2011","room_exchange",me.nId,nCount);
		if nCurCount ~= nCount then
			Dbg:WriteLog("SpecialEvent","Xmas2011,Add Stone Box Failed!",me.nId,me.szName,nCurCount,nCount);
		end
	else
		Dbg:WriteLog("SpecialEvent","Xmas2011,Delete Piece or MoonStone Failed!",me.nId,me.szName);
		return 0;
	end
	return 1;
end


function tbStonePiece:CheckCanMake(nCount,nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0 ,"道具使用错误！";
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		return 0, "Chỉ có thể chế tạo tại Thành Thị và Tân Thủ Thôn!";
	end
	if not nCount or nCount < 0 then
		return 0,"输入的数量有误，请重新输入！";
	end
	local tbMoonFind = me.FindItemInBags(unpack(Xmas2011.tbMoonStoneGdpl));	
	local tbPieceFind = me.FindItemInBags(unpack(Xmas2011.tbStonePieceGdpl));
	local nMoonCount = 0;
	local nPieceCount = 0;
	local szBoxName = KItem.GetNameById(unpack(Xmas2011.tbStoneBoxGdpl));
	local szPieceName = KItem.GetNameById(unpack(Xmas2011.tbStonePieceGdpl));
	local szMoonName = KItem.GetNameById(unpack(Xmas2011.tbMoonStoneGdpl));
	for _,tbItem in pairs(tbMoonFind) do
		if tbItem.pItem then
			nMoonCount = nMoonCount + tbItem.pItem.nCount;
		end
	end
	for _,tbItem in pairs(tbPieceFind) do
		if tbItem.pItem then
			nPieceCount = nPieceCount + tbItem.pItem.nCount;
		end
	end
	if math.floor(nMoonCount / Xmas2011.nNeedMoonStoneCount) < nCount then
		return 0,string.format("对不起，你背包中的<color=yellow>%s<color>不足以制作<color=yellow>%s<color>个<color=yellow>%s<color>！",szMoonName,nCount,szBoxName);
	end
	if math.floor(nPieceCount / Xmas2011.nNeedStonePieceCount) < nCount then
		return 0,string.format("对不起，你背包中的<color=yellow>%s<color>不足以制作<color=yellow>%s<color>个<color=yellow>%s<color>！",szPieceName,nCount,szBoxName);
	end
	local nNeedCell = math.ceil(nCount/Xmas2011.nBoxMaxStack);
	if me.CountFreeBagCell() < nNeedCell then
		return 0,string.format("请保证留出<color=yellow>%s<color>格背包空间！",nNeedCell);
	end
	return 1;
end
