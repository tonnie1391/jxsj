-- 文件名　：201112_xmas_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-29 15:33:34
-- 描述：2011圣诞npc

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



local tbSanta = Npc:GetClass("santaclaus_2011xmas");

function tbSanta:OnDialog()
	local nLastGetTime = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSockTimeTaskId);
	local nNowTime = GetTime();
	if tonumber(os.date("%Y%m%d",nLastGetTime)) ~= tonumber(os.date("%Y%m%d",nNowTime)) then	--隔天会把领取次数和时间清零
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSockCountTaskId,0);
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSockTimeTaskId,0);
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSockLevelTaskId,0);
	end
	local nCanGet,szError = self:CheckCanGetSock();
	if nCanGet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError,"系统");
		return 0;
	end
	self:GiveSock();
end


function tbSanta:CheckCanGetSock()
	if Xmas2011:IsEventOpen() ~= 1 then
		return 0,"活动已经截止。"
	end
	local nTime = tonumber(os.date("%H%M",GetTime()));
	if (nTime < Xmas2011.nNpcBeginWalkTimeDay or 
		nTime > Xmas2011.nNpcEndWalkTimeDay) and
		(nTime < Xmas2011.nNpcBeginWalkTimeNight or 
		nTime > Xmas2011.nNpcEndWalkTimeNight) then
		return 0,"现在还不是领取圣诞袜子的时间段！";		
	end
	if me.nLevel < Xmas2011.nSockEventBaseLevel then
		return 0,string.format("等级未达到%s级的玩家无法领取圣诞袜子！",Xmas2011.nSockEventBaseLevel);
	end
	local nGetCount = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSockCountTaskId);
	if nGetCount >= Xmas2011.nGetSockMaxCount then
		return 0,string.format("你今天已经领取过%s只袜子了，每人每天最多可以领取%s只袜子！",Xmas2011.nGetSockMaxCount,Xmas2011.nGetSockMaxCount);
	end
	local nLastGetTime = tonumber(os.date("%H%M",me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSockTimeTaskId)));
	if nTime >= Xmas2011.nNpcBeginWalkTimeDay and 
		nTime <= Xmas2011.nNpcEndWalkTimeDay and
		nLastGetTime >= Xmas2011.nNpcBeginWalkTimeDay and 
		nLastGetTime <= Xmas2011.nNpcEndWalkTimeDay then
		return 0,"每阶段每人只能领取一次袜子，请下阶段再来领取！";		
	end
	if nTime >= Xmas2011.nNpcBeginWalkTimeNight and 
		nTime <= Xmas2011.nNpcEndWalkTimeNight and
		nLastGetTime >= Xmas2011.nNpcBeginWalkTimeNight and 
		nLastGetTime <= Xmas2011.nNpcEndWalkTimeNight then
		return 0,"每阶段每人只能领取一次袜子，请下阶段再来领取！";		
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法领取袜子！";
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!";
	end
	return 1;
end


function tbSanta:GiveSock()
	local tbSock = Xmas2011.tbSockGdpl;
	local tbGdpl = tbSock[MathRandom(#tbSock)];
	local pItem = me.AddItem(unpack(tbGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add Sock Failed!",me.nId,me.szName);	
	else
		StatLog:WriteStatLog("stat_info","shengdanjie_2011","get_socks",me.nId,1);
		--记录领取的次数和时间
		local nGetCount = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSockCountTaskId);
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSockCountTaskId,nGetCount + 1);
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSockTimeTaskId,GetTime());
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSockLevelTaskId,pItem.nLevel);
		local szMsg = string.format("你获得了一只<color=yellow>%s<color>，快去寻找和你相同花色袜子的有缘人吧！",pItem.szName);
		Dialog:Say(szMsg);
		Dialog:SendBlackBoardMsg(me,szMsg);
		me.Msg(szMsg);
	end
end


---------------------雪人冰座
local tbSnowBase = Npc:GetClass("snowbase_2011xmas");

function tbSnowBase:OnDialog()
	local nRet,szError = self:CheckCanMakeSnowBoy(him.dwId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	GeneralProcess:StartProcess("堆雪人中...", 7 * Env.GAME_FPS,{self.GiveSnowBall,self,him.dwId},nil,tbEvent);
end

function tbSnowBase:GiveSnowBall(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRet,szError = self:CheckCanMakeSnowBoy(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	if me.ConsumeItemInBags(1, unpack(Xmas2011.tbSnowBallGdpl)) ~= 0 then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Delete Snow Ball Failed!",me.nId,me.szName);	
	else
		--me.AddSkillState(Xmas2011.nForbidMakeSkillId,1,1,Xmas2011.nForbidMakeTime,1,0,1);	
		local szMsg = "你成功给雪人上交了一个雪团";
		Dialog:SendBlackBoardMsg(me,szMsg);
		StatLog:WriteStatLog("stat_info","shengdanjie_2011","snow_man_join",me.nId,1);
		self:AddUnFinishSnowBoy(nNpcId);
	end
end

function tbSnowBase:AddUnFinishSnowBoy(nNpcId,nMapId,nX,nY)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nMapId,nX,nY = pNpc.GetWorldPos();
	local szCaptainName = pNpc.GetTempTable("SpecialEvent").szCaptainName or "";	--记录队长的名字
	local szName = pNpc.szName;
	local tbPlayerList = pNpc.GetTempTable("SpecialEvent").tbBelongPlayerList or {};
	local nTemplateId = Xmas2011.nUnFinishSnowBoyTemplateId;
	local pUnFinishSnowBoy = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
	if not pUnFinishSnowBoy then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add Unfinish Snowboy Failed!",me.nId,me.szName);
		return 0;	
	else
		pUnFinishSnowBoy.szName = szName;
		pUnFinishSnowBoy.GetTempTable("SpecialEvent").szCaptainName = szCaptainName;
		pUnFinishSnowBoy.GetTempTable("SpecialEvent").tbBelongPlayerList = {};
		pUnFinishSnowBoy.GetTempTable("SpecialEvent").nGetSnowBallCount = 1;	--已经交过一次雪团了
		for _,szName in pairs(tbPlayerList) do
			table.insert(pUnFinishSnowBoy.GetTempTable("SpecialEvent").tbBelongPlayerList,szName);
		end
		pUnFinishSnowBoy.GetTempTable("SpecialEvent").tbPlayerGiveCount = {};
		pUnFinishSnowBoy.GetTempTable("SpecialEvent").tbPlayerGiveCount[me.nId] = 1;
		pUnFinishSnowBoy.SetLiveTime(Xmas2011.nUnFinSnowBoyLiveTime);
		pUnFinishSnowBoy.Sync();
		pNpc.Delete();
	end
end


function tbSnowBase:CheckCanMakeSnowBoy(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"只有组队才能进行堆雪人活动！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount ~= Xmas2011.nMakeSnowBoyRequirePlayerCount then
		return 0,string.format("只有%s人队伍才能进行堆雪人活动！",Xmas2011.nMakeSnowBoyRequirePlayerCount);
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法进行堆雪人活动！";
	end
	local tbPlayerList = pNpc.GetTempTable("SpecialEvent").tbBelongPlayerList or {};
	local nIsBelong = 0;
	for _,szName in pairs(tbPlayerList) do
		if szName == me.szName then
			nIsBelong = 1;
			break;
		end
	end
	if nIsBelong ~= 1 then
		return 0,"这个冰座不是你们队伍的，请确认你们队伍的冰座后再进行堆雪人！";
	end
--	local nHasState = me.GetSkillState(Xmas2011.nForbidMakeSkillId);
--	if nHasState > 0 then
--		return 0,"你的手还冻得通红，请稍后再来堆雪人！";
--	end
	local tbFind = me.FindItemInBags(unpack(Xmas2011.tbSnowBallGdpl));
	if #tbFind < 1 then
		return 0,string.format("你背包中没有%s,无法堆雪人！",KItem.GetNameById(unpack(Xmas2011.tbSnowBallGdpl)));
	end
	return 1;
end


----------------未完成的雪人
local tbUnFinSnowBoy = Npc:GetClass("snowboy_unfinish_2011xmas");

function tbUnFinSnowBoy:OnDialog()
	local nHasCount = him.GetTempTable("SpecialEvent").nGetSnowBallCount or 1;
	local szBall = KItem.GetNameById(unpack(Xmas2011.tbSnowBallGdpl));
	local nMaxCount = Xmas2011.nNeedSnowBallCount;
	if not him.GetTempTable("SpecialEvent").tbPlayerGiveCount then
		him.GetTempTable("SpecialEvent").tbPlayerGiveCount = {};
	end
	local nMineGiveCount = him.GetTempTable("SpecialEvent").tbPlayerGiveCount[me.nId] or 0;
	local szMsg = string.format("    如果你的背包中有<color=yellow>%s<color>，则可以对你队伍所堆建的雪人加上一个雪球，当上交至<color=yellow>%s<color>个雪球时，队员可以领取一份雪人奖励！\n    当前雪人已经上交的雪团数量为<color=yellow>%s<color>。\n    你上交过的雪团数量为<color=yellow>%s<color>。",szBall,nMaxCount,nHasCount,nMineGiveCount);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"堆雪人",self.OnGiveSnowBall,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbUnFinSnowBoy:OnGiveSnowBall(nNpcId)
	local nRet,szError = self:CheckCanMakeSnowBoy(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	GeneralProcess:StartProcess("堆雪人中...", 7 * Env.GAME_FPS,{self.GiveSnowBall,self,nNpcId},nil,tbEvent);
end

function tbUnFinSnowBoy:GiveSnowBall(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRet,szError = self:CheckCanMakeSnowBoy(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	if me.ConsumeItemInBags(1, unpack(Xmas2011.tbSnowBallGdpl)) ~= 0 then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Delete Snow Ball Failed!",me.nId,me.szName);	
	else
		--me.AddSkillState(Xmas2011.nForbidMakeSkillId,1,1,Xmas2011.nForbidMakeTime,1,0,1);	
		local szMsg = "你成功给雪人上交了一个雪团";
		Dialog:SendBlackBoardMsg(me,szMsg);
		StatLog:WriteStatLog("stat_info","shengdanjie_2011","snow_man_join",me.nId,1);
		pNpc.GetTempTable("SpecialEvent").nGetSnowBallCount = (pNpc.GetTempTable("SpecialEvent").nGetSnowBallCount or 1) + 1;
		if not pNpc.GetTempTable("SpecialEvent").tbPlayerGiveCount[me.nId] then
			pNpc.GetTempTable("SpecialEvent").tbPlayerGiveCount[me.nId] = 0;
		end
		pNpc.GetTempTable("SpecialEvent").tbPlayerGiveCount[me.nId] = pNpc.GetTempTable("SpecialEvent").tbPlayerGiveCount[me.nId] + 1;
		if pNpc.GetTempTable("SpecialEvent").nGetSnowBallCount >= Xmas2011.nNeedSnowBallCount then
			self:AddFinalSnowBoy(nNpcId);
		end
	end
end

function tbUnFinSnowBoy:AddFinalSnowBoy(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nMapId,nX,nY = pNpc.GetWorldPos();
	local szCaptainName = pNpc.GetTempTable("SpecialEvent").szCaptainName or "";	--记录队长的名字
	local szName = pNpc.szName;
	local tbPlayerList = pNpc.GetTempTable("SpecialEvent").tbBelongPlayerList or {};
	local nTemplateId = Xmas2011.nSnowBoyTemplateId;
	local pFinSnowBoy = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
	if not pFinSnowBoy then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add Finish Snowboy Failed!",me.nId,me.szName);
		return 0;	
	else
		pFinSnowBoy.szName = szName;
		pFinSnowBoy.GetTempTable("SpecialEvent").szCaptainName = szCaptainName;
		pFinSnowBoy.GetTempTable("SpecialEvent").tbBelongPlayerList = {};
		local szMsg = "小雪人堆好了！贴好印象就能领取奖励咯";
		for _,szName in pairs(tbPlayerList) do
			table.insert(pFinSnowBoy.GetTempTable("SpecialEvent").tbBelongPlayerList,szName);
			local pPlayer = KPlayer.GetPlayerByName(szName);
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer,szMsg);
				Player:SendMsgToKinOrTong(pPlayer,"和他的队友堆成了圣诞雪人！获得了宝箱【冰雪之心】！大家掌声鼓励！",0);
				pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]和他的队友堆成了圣诞雪人！获得了宝箱【冰雪之心】！大家掌声鼓励！");		
			end
		end
		pFinSnowBoy.SetLiveTime(Xmas2011.nSnowBoyLiveTime);
		pFinSnowBoy.Sync();
		pNpc.Delete();
	end
end


function tbUnFinSnowBoy:CheckCanMakeSnowBoy(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"只有组队才能进行堆雪人活动！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount ~= Xmas2011.nMakeSnowBoyRequirePlayerCount then
		return 0,string.format("只有%s人队伍才能进行堆雪人活动！",Xmas2011.nMakeSnowBoyRequirePlayerCount);
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法进行堆雪人活动！";
	end
	local tbPlayerList = pNpc.GetTempTable("SpecialEvent").tbBelongPlayerList or {};
	local nIsBelong = 0;
	for _,szName in pairs(tbPlayerList) do
		if szName == me.szName then
			nIsBelong = 1;
			break;
		end
	end
	if nIsBelong ~= 1 then
		return 0,"这个雪人不是你们队伍的，请确认你们队伍的雪人后再进行堆雪人！";
	end
--	local nHasState = me.GetSkillState(Xmas2011.nForbidMakeSkillId);
--	if nHasState > 0 then
--		return 0,"你的手还冻得通红，请稍后再来堆雪人！";
--	end
	local tbFind = me.FindItemInBags(unpack(Xmas2011.tbSnowBallGdpl));
	if #tbFind < 1 then
		return 0,string.format("你背包中没有%s,无法堆雪人！",KItem.GetNameById(unpack(Xmas2011.tbSnowBallGdpl)));
	end
	return 1;
end


------------------完成的雪人
local tbFinSnowBoy = Npc:GetClass("snowboy_2011xmas");

function tbFinSnowBoy:OnDialog()
	local nLastGetPrizeTime = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSnowPrizeTimeTaskId);
	if os.date("%Y%m%d",GetTime()) ~= os.date("%Y%m%d",nLastGetPrizeTime) then
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSnowPrizeCountTaskId,0);
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastGetSnowPrizeTimeTaskId,GetTime());
	end
	if me.szName == him.GetTempTable("SpecialEvent").szCaptainName then
		self:GiveCaptainSnowBoyPrize(him.dwId);
	else
		self:GiveMemberSnowBoyPrize(him.dwId);
	end
end

function tbFinSnowBoy:GiveCaptainSnowBoyPrize(nNpcId)
	local szMsg = "    你们的雪人已经堆好了，现在可以领取一份雪人的奖励！<color=green>活动期间，每个人每天只能领取一次奖励！<color>";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"领取奖励",self.GivePrize,self,nNpcId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbFinSnowBoy:GiveMemberSnowBoyPrize(nNpcId)
	local nRet,szError = self:CheckCanGetPrize(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if not pNpc.GetTempTable("SpecialEvent").tbHasSignList then
		pNpc.GetTempTable("SpecialEvent").tbHasSignList = {};
	end
	if pNpc.GetTempTable("SpecialEvent").tbHasSignList[me.nId] ~= 1 then
		local szMsg = "    你们的雪人已经堆好了，想要领取雪人奖励，需要输入<color=yellow>3<color>个字以内的雪人印象哦！";
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"输入印象",self.AskWriteImpress,self,nNpcId};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
	else
		self:OnGiveMemberPrize(nNpcId);
	end
end

function tbFinSnowBoy:OnGiveMemberPrize(nNpcId)
	local szMsg = "    你已经对雪人评价了印象，可以领取一份雪人奖励！<color=green>活动期间，每个人每天只能领取一次奖励！<color>";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"领取奖励",self.GivePrize,self,nNpcId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbFinSnowBoy:AskWriteImpress(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	Dialog:AskString("请输入雪人印象：",Xmas2011.nInputStringMaxLength,self.ProcessImpress,self,nNpcId);
	return 1;
end

function tbFinSnowBoy:ProcessImpress(nNpcId,szImpress)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	--名字合法性检查
	local nLen = GetNameShowLen(szImpress);
	if nLen > Xmas2011.nInputStringMaxLength or nLen <= 0 then
		Dialog:Say("您输入的印象字数达不到要求,必须在1到3个汉字之间。");
		return 0;
	end
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szImpress) ~= 1 then
		Dialog:Say("您输入的印象含有非法字符。");
		return 0;
	end
	--是否包含敏感字串
	if IsNamePass(szImpress) ~= 1 then
		Dialog:Say("您输入的印象含有非法的敏感字符。");
		return 0;
	end
	if not pNpc.GetTempTable("SpecialEvent").tbImpress then
		pNpc.GetTempTable("SpecialEvent").tbImpress = {};
	end
	table.insert(pNpc.GetTempTable("SpecialEvent").tbImpress,szImpress);
	pNpc.GetTempTable("SpecialEvent").tbHasSignList[me.nId] = 1;
	local szTitle = "";
	for _,szImpress in pairs(pNpc.GetTempTable("SpecialEvent").tbImpress) do
		szTitle = szTitle .. "<color=yellow>" .. szImpress .. "<color>·"; 
	end
	szTitle = string.sub(szTitle,1,-3);
	pNpc.SetTitle(szTitle);
	pNpc.Sync();
	self:OnGiveMemberPrize(nNpcId);
	return 1;
end

function tbFinSnowBoy:GivePrize(nNpcId)
	local nRet,szError = self:CheckCanGetPrize(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	local nLevel = Xmas2011:GetPrizeLevel();
	local tbGdpl = Xmas2011.tbSnowPrizeGdpl[nLevel];
	local nCurCount = me.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,Xmas2011.nGiveSnowboyPrizeCount);
	if nCurCount == Xmas2011.nGiveSnowboyPrizeCount then
		local nGetCount = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSnowPrizeCountTaskId);
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSnowPrizeCountTaskId,nGetCount + 1);
		StatLog:WriteStatLog("stat_info","shengdanjie_2011","snow_man_box",me.nId,1);
	else
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add Snowboy Prize Failed!",me.nId,me.szName);
	end
end


function tbFinSnowBoy:CheckCanGetPrize(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbPlayerList = pNpc.GetTempTable("SpecialEvent").tbBelongPlayerList or {};
	local nIsBelong = 0;
	for _,szName in pairs(tbPlayerList) do
		if szName == me.szName then
			nIsBelong = 1;
			break;
		end
	end
	if nIsBelong ~= 1 then
		return 0,"这个雪人不是你们队伍的，请确认你们队伍的雪人后再来领取奖励！";
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法领取奖励！";
	end
	local nHasGetPrizeCount = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSnowPrizeCountTaskId);
	if nHasGetPrizeCount >= Xmas2011.nGetSnowPrizeMaxCount then
		return 0,"你今天已经领取过一次雪人的奖励了，无法再次领取！";
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!";
	end
	return 1;
end

-------------------雪堆
local tbSnowHeap = Npc:GetClass("snowheap_2011xmas");

function tbSnowHeap:OnDialog()
	local nRet,szError = self:CheckCanGetSnowBall(him.dwId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	GeneralProcess:StartProcess("采集雪团中...", 3 * Env.GAME_FPS,{self.GetSnowBall,self},nil,tbEvent);
end

function tbSnowHeap:CheckCanGetSnowBall()
	if Xmas2011:IsEventOpen() ~= 1 then
		return 0,"Sự kiện đã kết thúc!";
	end
	if me.nLevel < Xmas2011.nMakeSnowBoyBaseLevel then
		return 0, "你的等级未达到参加活动需要的最低等级！";		
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法采集雪球！";
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!";
	end
	return 1;
end

function tbSnowHeap:GetSnowBall()
	local pItem = me.AddItem(unpack(Xmas2011.tbNormalSnowBallGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add Normal Snowball Failed!",me.nId,me.szName);	
	end
end


--------------雪城建设
----------大雪人
local tbSnowMan = Npc:GetClass("snowman_2011xmas");

function tbSnowMan:OnDialog()
	if Xmas2011:IsEventOpen() ~= 1 then
		Dialog:Say(string.format("你好，%s，新的一年，要有新气象哦！",me.szName));
		return 0;
	end
	local nLastProduceTime = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastProduceSnowManTimeTaskId);
	if os.date("%Y%m%d",GetTime()) ~= os.date("%Y%m%d",nLastProduceTime) then
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGiveSnowBallCountTaskId,0);
		me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nLastProduceSnowManTimeTaskId,GetTime());
	end
	local nCurrentProcess = him.GetTempTable("SpecialEvent").nCurrentProcess or 0;
	if nCurrentProcess < Xmas2011.nFinishProduceNeedMaxCount then
		local szMsg = string.format("    在圣诞活动期间，全服玩家可将<color=yellow>%s<color>赠予雪人滚滚，完成雪城建设的任务，任务完成后全服玩家都可获得雪城建设奖励。\n    滚滚还会根据雪团的捐赠个数给予每位参与者圣诞奖励的返还。每人每天只能捐赠<color=yellow>%s<color>个哦！\n    雪人当前的进度为：%s/%s",KItem.GetNameById(unpack(Xmas2011.tbSnowBallGdpl)),Xmas2011.nCanGiveSnowBallMaxCount,nCurrentProcess,Xmas2011.nFinishProduceNeedMaxCount);
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"捐赠雪团",self.GiveSnowBall,self,him.dwId};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
	else
		local szMsg = "本服的雪城建设已经完成，本服玩家可以领取一份雪人的最终奖励！";
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"捐赠雪团",self.GiveSnowBall,self,him.dwId};
		tbOpt[#tbOpt + 1] = {"领取最终奖励",self.GetFinalPrize,self,him.dwId};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);		
	end
end

function tbSnowMan:GiveSnowBall(nNpcId)
	local nRet,szError = self:CheckCanGiveSnowBall(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	local nCurrentProcess = pNpc.GetTempTable("SpecialEvent").nCurrentProcess or 0;
	local nLevel = Xmas2011:GetPrizeLevel();
	local szMsg = string.format("    你可以通过上交<color=yellow>%s<color>来进行雪城建设，每上交一次会得到和上交个数对应的<color=yellow>%s<color>奖励哦！\n    当前雪城建设进度为%s/%s",KItem.GetNameById(unpack(Xmas2011.tbSnowBallGdpl)),KItem.GetNameById(unpack(Xmas2011.tbReturnPrizePreOneTime[nLevel])),nCurrentProcess,Xmas2011.nFinishProduceNeedMaxCount);
	Dialog:OpenGift(szMsg, nil, {self.OnInputSnowBall,self,nNpcId});
end

function tbSnowMan:OnInputSnowBall(nNpcId,tbItemObj,bSure)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRet,szError = self:CheckCanGiveSnowBall(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	local nCount = 0;
	for _,pItem in pairs(tbItemObj) do
		if pItem[1] and self:CheckCanDel(pItem[1].SzGDPL()) == 1 then	--防止放入其它东西
			nCount = nCount + 1;
		end
	end
	local nHasGiveCount = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGiveSnowBallCountTaskId);
	local nRemainCount = Xmas2011.nCanGiveSnowBallMaxCount - nHasGiveCount;
	local nFinalGiveCount = (nCount - nRemainCount > 0 and nRemainCount or nCount);
	local nLevel = Xmas2011:GetPrizeLevel();
	if not bSure and nFinalGiveCount > 0 then
		local szMsg = string.format("    您确定要上交<color=yellow>%s<color>个雪团进行雪城建设么？你可以得到<color=yellow>%s<color>个%s哦！\n    你今天已经上交了<color=yellow>%s<color>个雪团了，每人每天最多可以上交<color=yellow>%s<color>个雪团，多余的雪团将不会上进行上交！",nFinalGiveCount,nFinalGiveCount,KItem.GetNameById(unpack(Xmas2011.tbReturnPrizePreOneTime[nLevel])),nHasGiveCount,Xmas2011.nCanGiveSnowBallMaxCount);
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"确定上交",self.OnInputSnowBall,self,nNpcId,tbItemObj,1};
		tbOpt[#tbOpt + 1] = {"我在想想",self.OnInputSnowBall,self,nNpcId,tbItemObj,0};
		Dialog:Say(szMsg,tbOpt);
	end
	if bSure and bSure == 1 then
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("Hành trang không đủ <color=yellow>1 ô<color> trống!");
			return 0;
		end
		local nDelCount = 0;
		for _,pItem in pairs(tbItemObj) do
			if pItem[1] and self:CheckCanDel(pItem[1].SzGDPL()) == 1 then
				local nHasGiveCount = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGiveSnowBallCountTaskId);
				local nRemainCount = Xmas2011.nCanGiveSnowBallMaxCount - nHasGiveCount;
					if nRemainCount > 0 then
					if me.DelItem(pItem[1],Player.emKLOSEITEM_USE) == 1 then
						nDelCount = nDelCount + 1;
						me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGiveSnowBallCountTaskId,nHasGiveCount + 1);
					end
				end
			end
		end
		self:AddSnowmanProcess(nNpcId,nDelCount);
		self:GiveReturnBack(nDelCount);
	elseif bSure and bSure == 0 then
		return 0;
	end
end

--增加上交的雪团的数量
function tbSnowMan:AddSnowmanProcess(nNpcId,nCount)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nNowCount = pNpc.GetTempTable("SpecialEvent").nCurrentProcess or 0;
	pNpc.GetTempTable("SpecialEvent").nCurrentProcess = nNowCount + nCount;
	if nNowCount + nCount >= Xmas2011.nFinishProduceNeedMaxCount then	--如果交满了，就同步一次
		pNpc.GetTempTable("SpecialEvent").nCurrentProcess = Xmas2011.nFinishProduceNeedMaxCount;
		local nOrgProcess = KGblTask.SCGetDbTaskInt(DBTASK_XMAS_SNOWMAN_PROCESS) or 0;
		if nOrgProcess < Xmas2011.nFinishProduceNeedMaxCount then	--防止多次同步相同数据
			local nCurrentProcess = nNowCount + nCount;
			local nDeta = nCurrentProcess - nOrgProcess;
			GCExcute({"SpecialEvent.Xmas2011:OnSyncProduceProcess",nDeta});
			Xmas2011:StopSyncTimer();
		end
	end
end

function tbSnowMan:GiveReturnBack(nCount)
	local nLevel = Xmas2011:GetPrizeLevel();
	local tbGdpl = Xmas2011.tbReturnPrizePreOneTime[nLevel];
	local nReturn = nCount or 1;
	local nCurCount = me.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,nCount);
	local szFMsg = "Hảo hữu [<color=yellow>"..me.szName.."<color>]给雪人滚滚捐赠了" .. nReturn .. "颗莹白的雪花团子，获得了宝箱【雪人的报恩】，雪人滚滚脸红了！";
	local szKMsg = "给雪人滚滚捐赠了" .. nReturn .. "颗莹白的雪花团子，获得了宝箱【雪人的报恩】，雪人滚滚脸红了！";
	me.SendMsgToFriend(szFMsg);
	Player:SendMsgToKinOrTong(me,szKMsg,0);
	StatLog:WriteStatLog("stat_info","shengdanjie_2011","build_join",me.nId,nCount);
	if nCurCount ~= nCount then
		Dbg:WriteLog("SpecialEvent", "Xmas2011,Add Player Return Item Failed!",me.nId,me.szName,nCurCount,nCount);			
	end
end

--是否是要删除的东西
function tbSnowMan:CheckCanDel(szGDPL)
	if not szGDPL or #szGDPL == 0 then
		return 0;
	end
	local bCanDel = 0;
	local tbNeed = Xmas2011.tbSnowBallGdpl;
	if szGDPL == string.format("%s,%s,%s,%s",tbNeed[1],tbNeed[2],tbNeed[3],tbNeed[4]) then
		bCanDel = 1;
	end
	return bCanDel;
end

function tbSnowMan:CheckCanGiveSnowBall(nNpcId)
	if Xmas2011:IsEventOpen() ~= 1 then
		return 0,"Sự kiện đã kết thúc!";
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if me.nLevel < Xmas2011.nProduceSnowManBaseLevel then
		return 0, "你的等级未达到参加活动需要的最低等级！";		
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法上交雪团！";
	end
	local nHasGiveSnowBallCount = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGiveSnowBallCountTaskId);
	if nHasGiveSnowBallCount >= Xmas2011.nCanGiveSnowBallMaxCount then
		return 0,string.format("你今天已经上交过%s个雪团了，每人每天最可以上交%s个雪团，请明天再来！",Xmas2011.nCanGiveSnowBallMaxCount,Xmas2011.nCanGiveSnowBallMaxCount);
	end
	return 1;
end

function tbSnowMan:GetFinalPrize(nNpcId)
	local nRet,szError = self:CheckCanGetFinalPrize(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	local nLevel = Xmas2011:GetPrizeLevel();
	local tbGdpl = Xmas2011.tbReturnPrizeFinal[nLevel];
	local nCount = Xmas2011.nFinalPrizeCount;
	local nGiveCount = me.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,nCount);
	me.SetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSnowManFinalPrizeTaskId,1);	--标记已经领取过最终奖励
	if nGiveCount ~= nCount then
		Dbg:WriteLog("SpecialEvent","Xmas2011,Add Player SnowMan Finial Prize Count Not Match!",me.nId,me.szName,nGiveCount,nCount);
	end
end


function tbSnowMan:CheckCanGetFinalPrize(nNpcId)
	if Xmas2011:IsEventOpen() ~= 1 then
		return 0,"Sự kiện đã kết thúc!";
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if me.nLevel < Xmas2011.nProduceSnowManBaseLevel then
		return 0,"你的等级未达到参加活动需要的最低等级！";		
	end
	local pMask = me.GetEquip(Item.EQUIPPOS_MASK);
	if not pMask or Xmas2011:IsMaskXmasNeed(pMask.szName) ~= 1 then
		return 0,"你没有装备圣诞欢喜面具，无法领取雪人奖励！";
	end
	local nHasGetPrize = me.GetTask(Xmas2011.nTaskGroupId,Xmas2011.nHasGetSnowManFinalPrizeTaskId);
	if nHasGetPrize == 1 then
		return 0,"你已经领取过雪城建设的最终奖励，无法再次领取！";
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"Hành trang không đủ <color=yellow>1 ô<color> trống, không thể thao tác!";
	end
	return 1;
end

