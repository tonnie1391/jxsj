-- 文件名　：201201_springfestival_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-12-28 17:45:41
-- 描述：npc

Require("\\script\\event\\jieri\\201201_springfestival\\201201_springfestival_def.lua");

SpecialEvent.SpringFestival2012 = SpecialEvent.SpringFestival2012 or {};
local SpringFestival = SpecialEvent.SpringFestival2012;

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

--聚宝盆
local tbJubaopen = Npc:GetClass("jubaopen_sf2012");

function tbJubaopen:OnDialog()
	local nLastGetTime = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastGetIngotTimeTaskId);
	local nNowTime = GetTime();
	if tonumber(os.date("%Y%m%d",nLastGetTime)) ~= tonumber(os.date("%Y%m%d",nNowTime)) then	--隔天会把领取次数和时间清零
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastGetIngotTimeTaskId,0);
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nGetIngotCountTaskId,0);
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastGetIngotLevelTaskId,0);
	end
	local nCanGet,szError = self:CheckCanGetIngot();
	if nCanGet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	GeneralProcess:StartProcess("摸啊摸啊摸...", 5 * Env.GAME_FPS,{self.GetIngot,self,him.dwId},nil,tbEvent);
end

function tbJubaopen:CheckCanGetIngot()
	if SpringFestival:IsEventStep1Open() ~= 1 then
		return 0,string.format("%s：对不起，该活动已经结束！",me.szName);
	end
	local nTime = tonumber(os.date("%H%M",GetTime()));
	if (nTime < SpringFestival.nBeginGetIngotTimeDay or 
		nTime >= SpringFestival.nEndGetIngotTimeDay) and
		(nTime < SpringFestival.nBeginGetIngotTimeNight or 
		nTime >= SpringFestival.nEndGetIngotTimeNight) then
		return 0,"    聚宝盆里的宝物已经被抢光啦，请耐心等待宝物刷新吧！\n    2012年1月15日到1月30日每天<color=green>12:00-14:00、20:00-22:00<color>期间，聚宝盆内将会刷新各式宝物。";		
	end
	if me.nLevel < SpringFestival.nGetIngotBaseLevel then
		return 0,string.format("等级未达到<color=green>%s级<color>的玩家无法在聚宝盆中摸宝！",SpringFestival.nGetIngotBaseLevel);
	end
	local nGetCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nGetIngotCountTaskId);
	if nGetCount >= SpringFestival.nGetIngotMaxCountPerDay then
		return 0,string.format("你今天已经摸过%s次宝了，每人每天最多可以进行<color=green>%s次<color>摸宝！",SpringFestival.nGetIngotMaxCountPerDay,SpringFestival.nGetIngotMaxCountPerDay);
	end
	local nLastGetTime = tonumber(os.date("%H%M",me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastGetIngotTimeTaskId)));
	if nTime >= SpringFestival.nBeginGetIngotTimeDay and 
		nTime <= SpringFestival.nEndGetIngotTimeDay and
		nLastGetTime >= SpringFestival.nBeginGetIngotTimeDay and 
		nLastGetTime <= SpringFestival.nEndGetIngotTimeDay then
		return 0,"每个时间段一人只能摸一次宝物，请等待下一个阶段再来吧！\n    活动期间每天12:00-14:00、20:00-22:00<color>，聚宝盆内将会刷新各式宝物。";		
	end
	if nTime >= SpringFestival.nBeginGetIngotTimeNight and 
		nTime <= SpringFestival.nEndGetIngotTimeNight and
		nLastGetTime >= SpringFestival.nBeginGetIngotTimeNight and 
		nLastGetTime <= SpringFestival.nEndGetIngotTimeNight then
		return 0,"每个时间段一人只能摸一次宝物，请等待下一个阶段再来吧！\n    活动期间每天12:00-14:00、20:00-22:00<color>，聚宝盆内将会刷新各式宝物。";		
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end

function tbJubaopen:GetIngot(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nCanGet,szError = self:CheckCanGetIngot();
	if nCanGet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local tbIngot = SpringFestival.tbIngotGdpl;
	local tbGdpl = tbIngot[MathRandom(#tbIngot)];
	local pItem = me.AddItem(unpack(tbGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add Ingot Failed!",me.nId,me.szName);	
	else
		--记录领取的次数和时间
		local nGetCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nGetIngotCountTaskId);
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nGetIngotCountTaskId,nGetCount + 1);
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastGetIngotTimeTaskId,GetTime());
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastGetIngotLevelTaskId,pItem.nLevel);
		local szMsg = string.format("Bạn nhận được một <color=green>%s<color>，快去寻找拥有匹配宝物的有缘人吧！",pItem.szName);
		Dialog:SendBlackBoardMsg(me,szMsg);
		me.Msg(szMsg);
	end
end


-----------------礼炮
local tbLipao = Npc:GetClass("lipaonpc_sf2012");

function tbLipao:OnDialog()
	local nRet , szError = self:CheckCanFire(him.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local szMsg = "    感谢你们为我寻得宝物，如果能再帮我点燃这支新春炮竹，我会很高兴的。\n    两人要<color=green>同时点燃<color>炮竹才会燃着哦！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"点燃炮竹",self.FireLipao,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbLipao:FireLipao(nNpcId)
	GeneralProcess:StartProcess("点燃炮竹中...", 5 * Env.GAME_FPS,{self.DoFireLipao,self,nNpcId},nil,tbEvent);
end


function tbLipao:DoFireLipao(nNpcId)
	local nRet , szError = self:CheckCanFire(nNpcId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	local tbList = pNpc.GetTempTable("SpecialEvent").tbFireList;
	table.insert(tbList,GetTime());	--记录时间，进行差值计算
	if #tbList >= 2 then
		if self:CheckFireOk(nNpcId) == 1 then
			self:GiveLipaoPrize();
			pNpc.GetTempTable("SpecialEvent").nIsFired = 1;	--标记已经点燃过了
			self:OnCastSkill(pNpc.dwId);
			pNpc.GetTempTable("SpecialEvent").nCastSkillTimer = Timer:Register(SpringFestival.nLipaoCastSkillDelay,self.OnCastSkill,self,pNpc.dwId);
		else
			local tbMember = me.GetTeamMemberList();
			for _,pPlayer in pairs(tbMember) do
				if pPlayer then
					Dialog:SendBlackBoardMsg(pPlayer,"点燃炮竹失败，请与你的队友<color=green>同时点燃<color>！");
				end
			end
			pNpc.GetTempTable("SpecialEvent").tbFireList = {};
		end
	end
end

function tbLipao:GiveLipaoPrize()
	local tbGdpl = SpringFestival.tbLipaoPrizeGdpl;
	local tbMember = me.GetTeamMemberList();
	local szName1 = tbMember[1] and tbMember[1].szName or "";
	local szName2 = tbMember[2] and tbMember[2].szName or "";
	local szFMsg = string.format("噼啪噼啪噼！只听一阵阵响声和欢呼从远方传来。原来是[%s]和[%s]点燃了新年炮竹，也一同燃放了新春的激情！",szName1,szName2);
	local szKMsg = "和他的队友点燃了新年炮竹，也一同燃放了新春的激情！";
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			pPlayer.SendMsgToFriend(szFMsg);
			Player:SendMsgToKinOrTong(pPlayer,szKMsg,0);
			Dialog:SendBlackBoardMsg(pPlayer,"你的队伍成功点燃了新年炮竹，获得了神秘奖励！");
			local pItem = pPlayer.AddItem(unpack(tbGdpl));
			if not pItem then
				Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add Lipao Prize Failed!",pPlayer.nId,pPlayer.szName);	
			end
		end
	end
end

function tbLipao:CheckFireOk(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbList = pNpc.GetTempTable("SpecialEvent").tbFireList;
	if not tbList[1] or not tbList[2] then
		return 0;
	end
	local nDeta = math.abs(tbList[1] - tbList[2]);
	if nDeta <= SpringFestival.nFireLipaoTimeDeta then
		return 1;
	else
		return 0;
	end
end

function tbLipao:CheckCanFire(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0,"点炮竹错误！";
	end
	if SpringFestival:IsEventStep1Open() ~= 1 then
		return 0,"该活动已经结束！";
	end
	if self:CheckIsBelong(nNpcId,me.szName) ~= 1 then
		return 0,"这个炮竹不属于你，请找到你们队伍放置的炮竹再进行点燃！";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"只有<color=green>组队<color>才能进行点燃炮竹！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount ~= SpringFestival.nMatchIngotNeedMemberCount then
		return 0,string.format("只有<color=green>%s人队伍<color>才能点燃炮竹！",SpringFestival.nMatchIngotNeedMemberCount);
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,SpringFestival.nMatchIngotNeedRange) or {};
	for _, tbRound in pairs(tbPlayerList) do
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
	local nIsBelong = 1;	--是否属于这个队伍
	local nAllHasFree = 1;	--是否都有空间 
	local tbMember = me.GetTeamMemberList();
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			if self:CheckIsBelong(nNpcId,pPlayer.szName) ~= 1 then
				nIsBelong = 0;
			end
			if pPlayer.CountFreeBagCell() < 1 then
				nAllHasFree = 0;
			end
		end
	end
	if nIsBelong ~= 1 then
		return 0,"这个炮竹不属于你们队伍，请确定队伍成员为领取炮竹时候的成员！";
	end
	local nIsFired = pNpc.GetTempTable("SpecialEvent").nIsFired or 0;
	if nIsFired == 1 then
		return 0,"你们队伍已经点燃过炮竹了，不要再点啦！";
	end
	if nAllHasFree ~= 1 then
		return 0,"请保证队伍中所有成员预留出<color=green>1<color>格背包空间！";	
	end
	return 1;
end


function tbLipao:CheckIsBelong(nNpcId,szName)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbBelong = pNpc.GetTempTable("SpecialEvent").tbBelong or {};
	local nIsBelong = 0;
	for _,szRec in pairs(tbBelong) do
		if szRec == szName then
			nIsBelong = 1;
			break;
		end
	end
	return nIsBelong;
end

function tbLipao:OnCastSkill(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nSkillId = SpringFestival.nLipaoSkillId[MathRandom(#SpringFestival.nLipaoSkillId)];
	local nMapId,nX,nY = pNpc.GetWorldPos();
	pNpc.CastSkill(nSkillId,1,nMapId,nX * 32,nY * 32,1);
end


--------------------未点燃的花灯
local tbLantern = Npc:GetClass("lantern_unfire_sf2012")

function tbLantern:OnDialog()
	if SpringFestival:IsEventStep1Open() ~= 1 then
		Dialog:Say(string.format("%s：你好，新年要有新气象哦！",me.szName));
		return 0;
	end
	local szMsg = "    传说每一个灯笼中都居住着一个灯笼小精灵，你相信吗？\n \n     2012年<color=green>1月15日到1月30日<color>期间，逍遥谷、军营、白虎堂、宋金战场、藏宝图等日常活动可产出道具<color=green>[火折子]<color>，可用<color=green>精活加工<color>成[燃着的火折子]。\n    拥有[燃着的火折子]的玩家可点燃各大城镇中的灯笼并获得丰厚奖励。";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"点亮花灯",self.FireLatern,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"等会再来吧"};
	Dialog:Say(szMsg,tbOpt);
end

function tbLantern:FireLatern(nNpcId)
	local nLastFireTime = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastFireLanternTimeTaskId);
	if os.date("%Y%m%d",nLastFireTime) ~= os.date("%Y%m%d",GetTime()) then
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastFireLanternTimeTaskId,GetTime());	--隔天清零
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nFireLanternCountTaskId,0);
	end
	local nRet ,szError = self:CheckCanFire(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	GeneralProcess:StartProcess("点亮花灯中...", 10 * Env.GAME_FPS,{self.DoFireLantern,self,nNpcId},nil,tbEvent);
end

function tbLantern:DoFireLantern(nNpcId)
	local nRet ,szError = self:CheckCanFire(nNpcId);
	if nRet ~= 1 then
		if szError and #szError > 0 then
			Dialog:Say(szError);
			me.Msg(szError);
		end
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	local tbGdpl = SpringFestival.tbFireMatchGdpl;
	local tbFind = me.FindItemInBags(unpack(tbGdpl));
	if #tbFind > 0 then
		if me.DelItem(tbFind[1].pItem,Player.emKLOSEITEM_USE) ~= 1 then
			Dbg:WriteLog("SpecialEvent","SpringFestival2011,Delete Ingot Failed!",pPlayer.nId,pPlayer.szName);	
		else
			StatLog:WriteStatLog("stat_info","spring_2012","use_stick",me.nId,1);
			local nFireCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nFireLanternCountTaskId);
			me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nFireLanternCountTaskId,nFireCount + 1);
			me.AddSkillState(SpringFestival.nFireLanternBuffId,1,1,SpringFestival.nFireLanternBuffTime,1,0,1);	--加个状态
			local tbPrize = SpringFestival.tbLanternPrizeGdpl;	--给奖励
			local pItem = me.AddItem(unpack(tbPrize));
			if not pItem then
				Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add Lantern Prize Failed!",me.nId,me.szName);	
			end
			--好友，家族公告
			local szFMsg = string.format("Hảo hữu [<color=yellow>%s<color>]点燃了新春彩灯，还幸运的召唤出了一个会施仙术的灯笼精灵，真是太神奇了！",me.szName);
			local szKMsg = string.format("点燃了新春彩灯，还幸运的召唤出了一个会施仙术的灯笼精灵，真是太神奇了！",me.szName);
			Dialog:SendBlackBoardMsg(me,"你成功点燃了灯笼，并且幸运的召唤出了一个灯笼精灵！");
			Player:SendMsgToKinOrTong(me,szKMsg,0);
			me.SendMsgToFriend(szFMsg);
			local nMapId,nX,nY = pNpc.GetWorldPos();
			local nTemplateId = SpringFestival.nLanternTemplateId;
			pNpc.Delete();	--先删掉未点燃的
			local pLantern = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
			if pLantern then
				pLantern.GetTempTable("SpecialEvent").nDeleteTimer = Timer:Register(SpringFestival.nFireLanternLiveTime,self.OnLanternReborn,self,pLantern.dwId);
				pLantern.szName = "";
				pLantern.SetTitle(string.format("<color=yellow>%s<color>点亮的花灯",me.szName));
				pLantern.Sync();
			else
				Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add Fire Lantern Failed!",me.nId,me.szName);	
			end
		end
	end
end

function tbLantern:CheckCanFire(nNpcId)
	if SpringFestival:IsEventStep1Open() ~= 1 then
		return 0,"对不起，活动已经结束！";
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if me.nLevel < SpringFestival.nDropLanternBaseLevel then
		return 0,string.format("等级未达到<color=green>%s级<color>的玩家无法点亮花灯！",SpringFestival.nDropLanternBaseLevel);
	end
	local nFireCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nFireLanternCountTaskId);
	if nFireCount >= SpringFestival.nFireLanternMaxCountPerDay then
		return 0,string.format("你今天已经点亮过<color=green>%s<color>次花灯了，无法再点亮了，请明天再来！",nFireCount);
	end
	local tbGdpl = SpringFestival.tbFireMatchGdpl;
	local tbFind = me.FindItemInBags(unpack(tbGdpl));
	if #tbFind < 1 then
		return 0,string.format("你身上并没有<color=green>%s<color>啊，怎么点亮花灯呢？",KItem.GetNameById(unpack(tbGdpl)));
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end


function tbLantern:OnLanternReborn(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nMapId,nX,nY = pNpc.GetWorldPos();
	local nTemplateId = SpringFestival.nLanternUnFireTemplateId;
	pNpc.Delete();
	local pLantern = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
	if not pLantern then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add UnFire Lantern Failed!",nMapId,nX,nY);	
	else
		pLantern.szName = "";	--去掉名字
		pLantern.Sync();
	end
end


----------祈愿树
local tbHopeTree = Npc:GetClass("hopetree_sf2012");

function tbHopeTree:OnDialog()
	if SpringFestival:IsHopeOpen() == 1 then
		local szMsg = "    你想梦想成真吗？把祈愿卡交给我，我将送予你幸运奖券作为答谢。\n    幸运奖券可以参加对应日期的抽奖活动，<color=green>游龙阁声望令，大量古币、绑金<color>等你拿。奖励丰厚且中奖率100%哦。";
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"祈愿卡兑换幸运奖券",self.ChangeLotteryCard,self};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
	else
		Dialog:Say(string.format("你好，%s，新年要有新气象哦！",me.szName));
	end
end

function tbHopeTree:ChangeLotteryCard()
	local szMsg = "1张祈愿卡可兑换1张幸运奖券，奖券只有在对应日期才可使用。你想兑换哪一天的奖券？";
	local tbOpt = {};
	local tbCard  = SpringFestival.tbLotterCardGdpl;
	local nValue = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nChangeLotteryCardTaskId);
	for _,tbInfo in pairs(tbCard) do
		local nDateTime = Lib:GetDate2Time(tbInfo[1]);
		local tbGdpl = tbInfo[2];
		local szFarmerDate = tbInfo[3] or "";
		local nBegin,nEnd = tbGdpl[4] * 3 - 2,tbGdpl[4] * 3;
		local nIsLevelHasChange = Lib:LoadBits(nValue,nBegin,nEnd);
		local szColor = nIsLevelHasChange > 0 and "gray" or "white";
		local szDate = string.format("%s年%s月%s日（%s）",os.date("%Y",nDateTime),os.date("%m",nDateTime),os.date("%d",nDateTime),szFarmerDate);
		local szDes = string.format("<color=%s>兑换%s幸运奖券<color>",szColor,szDate);
		local tbDes = {szDes,self.Change,self,tbGdpl,nDateTime};
		table.insert(tbOpt,tbDes);
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbHopeTree:Change(tbGdpl,nDateTime)
	local nRet ,szError = self:CheckCanChange(tbGdpl);
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	local nConsumeCount = me.ConsumeItemInBags(1,unpack(SpringFestival.tbHopeCardGdpl));
	if nConsumeCount == 0 then
		local pItem = me.AddItem(unpack(tbGdpl));
		if not pItem then
			Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add LotterCard Failed!",me.nId,me.szName);
			return 0;
		else
			me.AddBindCoin(SpringFestival.nHopeGiveBindCoin);
			SpringFestival:GiveExtFudai(2);	--给福袋
			local nLevel = tbGdpl[4];
			local nValue = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nChangeLotteryCardTaskId);
			local nBegin,nEnd = nLevel * 3 - 2,nLevel * 3;
			nValue = Lib:SetBits(nValue,nLevel,nLevel*3 - 2 ,nLevel * 3);
			me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nChangeLotteryCardTaskId,nValue);
			--祈愿好友公告
			local szDate = string.format("%s月%s日",os.date("%m",nDateTime),os.date("%d",nDateTime));
			local szFMsg = string.format("Hảo hữu [<color=yellow>%s<color>]打开了祈愿树送予的幸运奖券，获得了%s的抽奖资 ô.",me.szName,szDate);
			local szKMsg = string.format("打开了祈愿树送予的幸运奖券，获得了%s的抽奖资格",szDate);
			Player:SendMsgToKinOrTong(me,szKMsg,0);
			me.SendMsgToFriend(szFMsg);		
			local tbCard  = SpringFestival.tbLotterCardGdpl;
			local nTotal = #tbCard;
			local nChanged = 0;
			for _,tbInfo in pairs(tbCard) do
				local tb = tbInfo[2];
				local nL = tb[4];
				local nB,nE = nL * 3 - 2,nL * 3;
				local nIsLevelHasChange = Lib:LoadBits(nValue,nB,nE);
				if nIsLevelHasChange > 0 then
					nChanged = nChanged + 1;
				end
			end
			local szMsg = string.format("你已成功兑换了%s张幸运券，还可兑换%s张！",nChanged,nTotal - nChanged);
			local tbOpt = {};
			if nTotal - nChanged > 0 then
				tbOpt[#tbOpt + 1] = {"继续兑换",self.ChangeLotteryCard,self};
			end
			tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
			Dialog:Say(szMsg,tbOpt);
			return 1;
		end
	else
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Delete HopeCard Failed!",me.nId,me.szName);
		return 0;
	end
end


function tbHopeTree:CheckCanChange(tbGdpl)
	if SpringFestival:IsHopeOpen() ~= 1 then
		return 0,"现在不是兑换幸运券的时间！";
	end
	if me.nLevel < SpringFestival.nHopeBaseLevel then
		return 0,string.format("等级未达到%s级的玩家无法兑换幸运券！",SpringFestival.nHopeBaseLevel);
	end
	if not tbGdpl then
		return 0,"兑换错误，请稍后再试！";
	end
	local nLevel = tbGdpl[4];
	local nValue = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nChangeLotteryCardTaskId);
	local nBegin,nEnd = nLevel * 3 - 2,nLevel * 3;
	local nIsLevelHasChange = Lib:LoadBits(nValue,nBegin,nEnd);
	if nIsLevelHasChange > 0 then
		return 0,"你已经兑换过这一天的幸运券了，无法进行兑换！";
	end
	local tbCardFind = me.FindItemInBags(unpack(SpringFestival.tbHopeCardGdpl));
	if #tbCardFind <= 0 then
		return 0,string.format("你的背包中没有<color=green>%s<color>，无法兑换幸运券！",KItem.GetNameById(unpack(SpringFestival.tbHopeCardGdpl)));
	end
	if me.CountFreeBagCell() < 2 then
		return 0,"需要<color=green>2格<color>背包空间，整理下再来！";
	end
	return 1;
end


