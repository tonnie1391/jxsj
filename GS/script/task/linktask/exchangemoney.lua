-- 用于兑换银票
-- 普通兑换银票
Require("\\script\\task\\linktask\\linktask_head.lua");

local tbExchangeNormal = Npc:GetClass("exchangenormal");

function tbExchangeNormal:OnDialog()
	if (Task.IVER_nCloseExchangeNoemal == 1) then
		Dialog:Say("您好：有什么事吗？");
		return;
	end
	
	local nNpcId = 0;
	if him.nTemplateId == 2961 then
		nNpcId = him.dwId;
		local nLimit = 0;
		
		if not BaiHuTang.tbGetAwardCount[nNpcId] then 
			BaiHuTang.tbGetAwardCount[nNpcId] = 0;
		end
		
		nLimit = BaiHuTang.tbGetAwardCount[nNpcId];
		
		if nLimit >= 30 then
			Dialog:Say("对不起，每场白虎堂我只能兑换 <color=yellow>30 次<color>银票，您还是下次再来吧！");
			return
		end;
	end;
	
	Dialog:Say("我这里可以兑换义军包万同所开出的银票，你现在要马上兑换吗？", 
--		{"现在就兑换", LinkTask.ShowBillGiftDialog, LinkTask, nNpcId},
		{"不了"})
end


local tbYiJunJunXuGuan = Npc:GetClass("yijunjunxuguan");

-- 申请兑换银票
function tbYiJunJunXuGuan:ApplyEchangeYinPia(nPlayerId)
	if (Task.IVER_nCloseExchangeNoemal == 1) then
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	
	--print("Step1：\n", pPlayer.szName.."申请兑换银票");
	local nCurrTime = GetTime();
	local nToday = tonumber(os.date("%Y%m%d", nCurrTime));
	local nAvailablyData = pPlayer.GetTask(2057, 1);
	
	--print("Step2：", "今天日期是===>", nToday);
--	print("之前记录的激活截至日期===>", nAvailablyData)
	
	if (nAvailablyData >= nToday) then
		LinkTask:ShowBillGiftDialog();
		return;
	end
	
	local szToday = os.date("%Y年%m月%d日", nCurrTime);
	local szAvailablyData = os.date("%Y年%m月%d日", nCurrTime + 3600 * 24 * 31);
	local szMsg = "每次充值 15 元就可以使一个游戏帐号下的一个角色拥有 31 天的银票兑换期，您现在可以开启 31 天的银票兑换期，兑换期从 <color=yellow>"..szToday.."<color> 到 <color=yellow>"..szAvailablyData.."<color>，您确认要开启吗？";
	Dialog:Say(szMsg,
			{"是", self.ActiveForLinkTask, self, nPlayerId},
			{"否"}
		);
end



-- 是否可以激活当前
function tbYiJunJunXuGuan:ActiveForLinkTask(nPlayerId)
	if (Task.IVER_nCloseExchangeNoemal == 1) then
		return;
	end	
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
--	print("step3：\n"..pPlayer.szName.."申请激活当前帐号")
	local nToday = tonumber(os.date("%Y%m%d", GetTime()));
	local nAvailablyData = pPlayer.GetTask(2057, 1);
	if (nAvailablyData > nToday) then
		pPlayer.Msg("此帐号本月不需要激活了");
		return;
	end
	
	local nMoneyPerOne = 15;	-- 15块激活一个
	--local nCurActiveNum = pPlayer.GetLinkTaskActiveAccountNum();
--	print("step4：\n"..pPlayer.szName.."当前已经激活的数目", nCurActiveNum, "\n本月冲值金额："..pPlayer.GetExtMonthPay());
	--assert(nCurActiveNum < 12);	-- liuchang 最多建立12个角色，之后有删角色功能可能会有Bug
	
	if (nMoneyPerOne <= pPlayer.GetExtMonthPay()) then
		--pPlayer.AddLinTaskActiveAccount();
		local nAvailablyData =  tonumber(os.date("%Y%m%d", GetTime() + 3600 * 24 * 31)); -- 增加31天
		pPlayer.SetTask(2057, 1, nAvailablyData);
		self:ApplyEchangeYinPia(nPlayerId);
	else
		pPlayer.Msg("你当月冲值不够，每次充值 15 元可以使一个角色拥有 31 天的银票兑换期。");
	end
end
