-------------------------------------------------------
-- 文件名　: european_gs.lua
-- 创建者　: zhangjinpin@kingsoft
-- 创建时间: 2012-06-15 16:27:11
-- 文件描述: 
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\2012_european\\european_def.lua");

local tbEuropean = SpecialEvent.tbEuropean;

function tbEuropean:CheckJoin(pPlayer)

	-- 系统开关
	if self.IS_OPEN ~= 1 then
		Dialog:Say("对不起，活动尚未开启。");
		return 0;
	end
	
	-- 届数开启
	local nSession = KGblTask.SCGetDbTaskInt(DBTASK_EUROPEEN_SESSION);
	if nSession <= 0 then
		Dialog:Say("对不起，活动尚未开启。");
		return 0;
	end
	
	-- 有数据表
	if Lib:CountTB(self.tbGlobalBuffer) <= 0 then
		Dialog:Say("对不起，活动尚未开启。");
		return 0;
	end
	
	-- 可以领奖
	local nCount = pPlayer.GetTask(self.TASK_GID, self.TASK_COUNT);
	if nCount > 0 then
		return 1;
	end
	
	-- 等级限制
	if pPlayer.nLevel < self.MIN_LEVEL then
		Dialog:Say(string.format("对不起，你的等级不足<color=yellow>%s<color>级，无法参加活动。", self.MIN_LEVEL));
		return 0;
	end
	
	-- 披风限制
	if pPlayer.GetHonorLevel() < self.MIN_MANTLE then
		Dialog:Say(string.format("对不起，你的荣誉等级不足<color=yellow>%s<color>，无法参加活动。", self.MIN_MANTLE_NAME));
		return 0;
	end
	
	return 1;
end

function tbEuropean:Join()
	
	if self:CheckJoin(me) ~= 1 then
		return 0;
	end
	
	local nSession = KGblTask.SCGetDbTaskInt(DBTASK_EUROPEEN_SESSION);
	local nMySession = me.GetTask(self.TASK_GID, self.TASK_SESSION);
	if nMySession > 0 and self.tbGlobalBuffer[nMySession] then
		local nCount = me.GetTask(self.TASK_GID, self.TASK_COUNT);
		local nResult = me.GetTask(self.TASK_GID, self.TASK_RESULT);
		local tbMySession = self.tbGlobalBuffer[nMySession];
		if nCount > 0 then
			if tbMySession.nResult > 0 and tbMySession.nResult <= 3 then
				local szMsg = string.format([[<newdialog>    欢迎参加2012欧洲杯有奖竞猜，快来为您的主队加油，并赢取丰厚大奖吧！
              <color=green>%s<color>
        <color=yellow>%s<color>   vs   <color=yellow>%s<color>
      %s   %s
    该场的结果为：<color=yellow>%s<color>，赔率为：<color=yellow>%s<color>
    
    您已经投了<color=yellow>%s<color>注给<color=yellow>%s<color>。]],
tbMySession.szTime,
Lib:StrFillC(tbMySession.tbTeam[1], 8), Lib:StrFillC(tbMySession.tbTeam[3], 8),
self.IMAGE_PATH[tbMySession.tbTeam[1]] or "", self.IMAGE_PATH[tbMySession.tbTeam[3]] or "",
tbMySession.tbTeam[tbMySession.nResult], tbMySession.tbAward[tbMySession.nResult],
nCount, tbMySession.tbTeam[nResult]
);
				local nAward = 0;
				if nResult == tbMySession.nResult then
					local nMoney = nCount * self.BASE_MONEY * tbMySession.tbAward[nResult];
					szMsg = szMsg .. string.format("可获得的奖金为：<color=yellow>%s<color>", nMoney);
					local tbOpt = 
					{
						{"<color=yellow>领取奖金<color>", self.GetAward, self, me.nId};
						{"Ta hiểu rồi"},
					};
					Dialog:Say(szMsg, tbOpt);
					return 0;
				else
					szMsg = szMsg .. "很遗憾，您没有猜中结果。";
					me.SetTask(self.TASK_GID, self.TASK_COUNT, 0);
					me.SetTask(self.TASK_GID, self.TASK_RESULT, 0);
					local tbOpt = {{"Ta hiểu rồi"}};
					if nSession < 7 then
						table.insert(tbOpt, 1, {"<color=yellow>继续下一轮<color>", self.Join, self});
					end
					Dialog:Say(szMsg, tbOpt);
					return 0;
				end
			else
				local szMsg = string.format([[<newdialog>    欢迎参加2012欧洲杯有奖竞猜，快来为您的主队加油，并赢取丰厚大奖吧！
              <color=green>%s<color>
        <color=yellow>%s<color>   vs   <color=yellow>%s<color>
      %s   %s
              <color=green>该场的赔率为<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    
    <color=green>所有胜负平都按90分钟内计算，包含补时阶段，但不包括加时赛阶段和点球阶段。<color>
    
    您已经投了<color=yellow>%s<color>注给<color=yellow>%s<color>。<color=green>请等待比赛结束当天14点之前更新结果。<color>]],
tbMySession.szTime,
Lib:StrFillC(tbMySession.tbTeam[1], 8), Lib:StrFillC(tbMySession.tbTeam[3], 8),
self.IMAGE_PATH[tbMySession.tbTeam[1]] or "", self.IMAGE_PATH[tbMySession.tbTeam[3]] or "",
Lib:StrFillC(tbMySession.tbTeam[1], 8), tbMySession.tbAward[1],
Lib:StrFillC(tbMySession.tbTeam[2], 8), tbMySession.tbAward[2],
Lib:StrFillC(tbMySession.tbTeam[3], 8), tbMySession.tbAward[3],
nCount, tbMySession.tbTeam[nResult]
);
				Dialog:Say(szMsg);
				return 0;
			end
		end
	end
	
	if nMySession == 7 then
		Dialog:Say("2012欧洲杯竞猜活动已经全部结束了。");
		return 0;
	end
	
	local tbSession = self.tbGlobalBuffer[nSession];
	if not tbSession or nMySession == nSession then
		Dialog:Say("下一轮活动尚未开始，请稍后继续。");
		return 0;
	end
	
	local szMsg = string.format([[<newdialog>    欢迎参加2012欧洲杯有奖竞猜，快来为您的主队加油，并赢取丰厚大奖吧！
              <color=green>当前的比赛为<color>
        <color=yellow>%s<color>   vs   <color=yellow>%s<color>
      %s   %s
              <color=green>该场的赔率为<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    
    <color=green>所有胜负平都按90分钟内计算，包含补时阶段，但不包括加时赛阶段和点球阶段。<color>
    
]],
Lib:StrFillC(tbSession.tbTeam[1], 8), Lib:StrFillC(tbSession.tbTeam[3], 8),
self.IMAGE_PATH[tbSession.tbTeam[1]] or "", self.IMAGE_PATH[tbSession.tbTeam[3]] or "",
Lib:StrFillC(tbSession.tbTeam[1], 8), tbSession.tbAward[1],
Lib:StrFillC(tbSession.tbTeam[2], 8), tbSession.tbAward[2],
Lib:StrFillC(tbSession.tbTeam[3], 8), tbSession.tbAward[3]
);
	local tbOpt = {};
	local nTime = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local tbTime = tbSession.tbTime;
	if nTime >= tbTime[1] and nTime <= tbTime[2] then
		szMsg = szMsg .. string.format("    您打算投注哪支球队呢？");
		for i, szTeam in ipairs(tbSession.tbTeam) do
			table.insert(tbOpt, {string.format("<color=yellow>%s<color>", szTeam), self.OnJoin, self, i, szTeam});
		end
	else
		szMsg = szMsg .. string.format("<color=gray>    对不起，现在是非投注期。<color>");
	end
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};

	Dialog:Say(szMsg, tbOpt);
end

function tbEuropean:OnJoin(nIndex, szTeam)
	Dialog:AskNumber("请输入投注数：", self.MAX_COUNT, self.OnJoin_Sure, self, nIndex);
end

function tbEuropean:OnJoin_Sure(nIndex, nInput, nSure)
	
	local nSession = KGblTask.SCGetDbTaskInt(DBTASK_EUROPEEN_SESSION);
	local tbSession = self.tbGlobalBuffer[nSession];
	if not tbSession then
		return 0;
	end
	
	local nTime = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local tbTime = tbSession.tbTime;
	if nTime < tbTime[1] or nTime > tbTime[2] then
		Dialog:Say("对不起，现在是非投注期。");
		return 0;
	end
	
	if not tbSession.tbAward[nIndex] then
		Dialog:Say("投注失败，请重新下注");
		return 0;
	end
	
	if nInput <= 0 or nInput > self.MAX_COUNT then
		Dialog:Say("对不起，请输入正确的投注数量。");
		return 0;
	end
	
	local nCostMoney = nInput * self.BASE_MONEY;
	if me.nCashMoney < nCostMoney then
		Dialog:Say("对不起，您身上的银两不足。");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format([[<newdialog>    欢迎参加2012欧洲杯有奖竞猜，快来为您的主队加油，并赢取丰厚大奖吧！
              <color=green>当前的比赛为<color>
        <color=yellow>%s<color>   vs   <color=yellow>%s<color>
      %s   %s
              <color=green>该场的赔率为<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    <color=yellow>%s<color>：<color=cyan>%s（90分钟内）<color>
    
	<color=green>所有胜负平都按90分钟内计算，包含补时阶段，但不包括加时赛阶段和点球阶段。<color>
	
    您打算投<color=yellow>%s<color>注给<color=yellow>%s<color>，这样做将消耗<color=yellow>%s<color>银两，确定么？]],
Lib:StrFillC(tbSession.tbTeam[1], 8), Lib:StrFillC(tbSession.tbTeam[3], 8),
self.IMAGE_PATH[tbSession.tbTeam[1]] or "", self.IMAGE_PATH[tbSession.tbTeam[3]] or "",
Lib:StrFillC(tbSession.tbTeam[1], 8), tbSession.tbAward[1],
Lib:StrFillC(tbSession.tbTeam[2], 8), tbSession.tbAward[2],
Lib:StrFillC(tbSession.tbTeam[3], 8), tbSession.tbAward[3],
nInput, tbSession.tbTeam[nIndex], nCostMoney
);
		local tbOpt = 
		{
			{"<color=yellow>确定<color>", self.OnJoin_Sure, self, nIndex, nInput, 1},
			{"Để ta suy nghĩ thêm"}	
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nRet = me.CostMoney(nCostMoney, Player.emKPAY_EUROPEAN);
	if nRet ~= 1 then
		Dialog:Say("投注失败，请重新下注");
		return 0
	end
	
	me.SetTask(self.TASK_GID, self.TASK_COUNT, nInput);
	me.SetTask(self.TASK_GID, self.TASK_RESULT, nIndex);
	
	local nSession = KGblTask.SCGetDbTaskInt(DBTASK_EUROPEEN_SESSION);
	me.SetTask(self.TASK_GID, self.TASK_SESSION, nSession);
	me.Msg("投注成功！");
	
	local szMsg = "";
	
	local nKinId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		szMsg = string.format("家族成员<color=yellow>[%s]<color>在2012欧洲杯[%s]vs[%s]的比赛中投了<color=yellow>%s<color>注给<color=yellow>%s<color>。", me.szName, tbSession.tbTeam[1], tbSession.tbTeam[3], nInput, tbSession.tbTeam[nIndex]);
		KKin.Msg2Kin(nKinId, szMsg, 0);
	end
	
	szMsg = string.format("您的好友<color=green>[%s]<color>在2012欧洲杯[%s]vs[%s]的比赛中投了<color=green>%s<color>注给<color=green>%s<color>。", me.szName, tbSession.tbTeam[1], tbSession.tbTeam[3], nInput, tbSession.tbTeam[nIndex]);
	me.SendMsgToFriend(szMsg);
	
	Dbg:WriteLog("euro_2012", "put", me.szAccount, me.szName, nCostMoney, tbSession.tbTeam[nIndex], nSession, me.GetHonorLevel());
    StatLog:WriteStatLog("stat_info", "euro_2012", "put", me.nId, nCostMoney, tbSession.tbTeam[nIndex], nSession, me.GetHonorLevel());
end

function tbEuropean:GetAward(nPlayerId)
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local nMySession = pPlayer.GetTask(self.TASK_GID, self.TASK_SESSION);
	local nCount = pPlayer.GetTask(self.TASK_GID, self.TASK_COUNT);
	local nResult = pPlayer.GetTask(self.TASK_GID, self.TASK_RESULT);
	
	local tbMySession = self.tbGlobalBuffer[nMySession];
	if nCount <= 0 or not tbMySession then
		return 0;
	end
	
	if tbMySession.nResult <= 0 or tbMySession.nResult > 3 or tbMySession.nResult ~= nResult then
		return 0;
	end
	
	local nMoney = math.ceil(nCount * self.BASE_MONEY * (tbMySession.tbAward[nResult] - 1));
	if nMoney + nCount * self.BASE_MONEY + pPlayer.nCashMoney > pPlayer.GetMaxCarryMoney() then
		Dialog:Say("对不起，领取后您身上的银两将会超出上限，请整理后再来领取。");
		return 0;
	end
	
	local nTradeMoney = TradeTax:TradeMoney(pPlayer, nMoney);
	local nTotalMoney = nTradeMoney + nCount * self.BASE_MONEY;
	pPlayer.Earn(nTotalMoney, Player.emKEARN_EUROPEAN);
	
	pPlayer.SetTask(self.TASK_GID, self.TASK_COUNT, 0);
	pPlayer.SetTask(self.TASK_GID, self.TASK_RESULT, 0);
	
	local szMsg = "";
	
	local nKinId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		szMsg = string.format("家族成员<color=yellow>[%s]<color>在2012欧洲杯[%s]vs[%s]的比赛中获得了<color=yellow>%s<color>奖金。", pPlayer.szName, tbMySession.tbTeam[1], tbMySession.tbTeam[3], nTotalMoney);
		KKin.Msg2Kin(nKinId, szMsg, 0);
	end
	
	szMsg = string.format("您的好友<color=green>[%s]<color>在2012欧洲杯[%s]vs[%s]的比赛中获得了<color=green>%s<color>奖金。", pPlayer.szName, tbMySession.tbTeam[1], tbMySession.tbTeam[3], nTotalMoney);
	pPlayer.SendMsgToFriend(szMsg);
	
	Dbg:WriteLog("euro_2012", "get", pPlayer.szAccount, pPlayer.szName, nTotalMoney, tbMySession.tbTeam[nResult], nMySession, pPlayer.GetHonorLevel());
	StatLog:WriteStatLog("stat_info", "euro_2012", "get", pPlayer.nId, nTotalMoney, tbMySession.tbTeam[nResult], nMySession, pPlayer.GetHonorLevel());
end

function tbEuropean:LoadBuffer_GS()
	local tbLoadBuffer = GetGblIntBuf(self.BUFFER_INDEX, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

function tbEuropean:ClearBuffer_GS()
	self.tbGlobalBuffer = {};
end

ServerEvent:RegisterServerStartFunc(tbEuropean.LoadBuffer_GS, tbEuropean);
