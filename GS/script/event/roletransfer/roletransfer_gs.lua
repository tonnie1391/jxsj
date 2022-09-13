-- 文件名　：roletransfer.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-07-20 09:29:26
-- 功能    ：角色转移

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\roletransfer\\roletransfer_def.lua");
SpecialEvent.tbRoleTransfer = SpecialEvent.tbRoleTransfer or {};
local tbRoleTransfer = SpecialEvent.tbRoleTransfer;

--对话
function tbRoleTransfer:OnDialog()
	if SpecialEvent.tbRoleTransfer.bOpen ~= 1 then
		Dialog:Say("系统未开放！");
		return;
	end
	local szMsg = "两人组队，可以在我这里进行角色转移操作，请确认您要进行转移角色操作吗？";
	local tbOpt = {
		{"<color=yellow>打开网站主题说明<color>", self.OpenURL, self},
		{"申请转移角色", self.ApplyRoleTransfer, self},
		{"查询角色转移情况", self.QueryRoleTransfer, self},
		{"关于转移角色说明", self.Information, self},
		{"我在想想"},
		}
	if self:CheckCanCancleApply() == 1 then
		table.insert(tbOpt, 2, {"撤销申请转移角色", self.CancleApply, self});
	end

	Dialog:Say(szMsg, tbOpt)
	return;
end

--打开外部网页
function tbRoleTransfer:OpenURL()
	me.CallClientScript({"OpenWebSite", "http://zt.xoyo.com/jxsj/jsfl/"});
	return;
end

--申请
function tbRoleTransfer:ApplyRoleTransfer(nFlag)
	if SpecialEvent.tbRoleTransfer.bOpen ~= 1 then
		return;
	end
	
	local nRet, szErrorMsg = self:CheckCanTransfer();
	if nRet == 0 and szErrorMsg then
		me.Msg(szErrorMsg);
		Dialog:SendBlackBoardMsg(me, szErrorMsg);
		return;
	end
	
	if not nFlag then
		Dialog:Say("您确认要进行转移吗？\n\n<color=red>  注：转移时将取出钱庄存入的金币以及撤销金币交易所贩卖和收购的金币，转移期间请勿进行金币所交易和钱庄金币存入操作。<color>", {{"确认",self.ApplyRoleTransfer, self, 1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	local pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[2]);
	if not pPlayer  then
		return;
	end
	
	--道具记录
	local tbFind = me.FindItemInBags(unpack(self.tbApplyItem));
	tbFind[1].pItem.Delete(me);
	local pItem = me.AddItem(unpack(self.tbApplyItem));
	if not pItem then
		return;
	end
	pItem.SetCustom(2, me.szAccount);	
	pItem.SetGenInfo(1, GetTime());
	pItem.Sync();
	
	me.SetTaskStr(self.TASK_GROUP_ID, self.TASK_OBJ_ACCOUNT, pPlayer.szAccount);
	me.AddExtPoint(0, GetTime());
	pPlayer.AddExtPoint(0, GetTime());
	--记录buff数据
	local tbInfo = {me.szAccount, me.szName, pPlayer.szAccount, pPlayer.szName, GetTime(), 1};
	GCExcute{"SpecialEvent.tbRoleTransfer:SetBuffer", tbInfo};
	--取出钱庄的金币
	me.TakeOutCoin(me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_SUM));
	--撤销金币交易所单
	local tbBill = KJbExchangeGs.GetPlayerBill(me.nId);
	if tbBill and tbBill.dwIndex ~= 0 then
		JbExchange:DelOneBill(tbBill.dwIndex, tbBill.btType);
	end
	--三级以上好友邮件
	self:SendMail(1);
	KPlayer.SendMail(me.szName, "角色转移通知", "您已经成功申请了角色转移，请周知。剑侠世界特此提醒。");
	KPlayer.SendMail(pPlayer.szName, "角色转移通知",  string.format("玩家<color=yellow>%s<color>已经成功申请转入您的账号底下，请周知。剑侠世界特此提醒。",me.szName));
	me.Msg("您的角色已经申请转移成功，3天后将开通网页申请请您填写申请资料。");
	Dialog:SendBlackBoardMsg(me, "您的角色已经申请转移成功，3天后将开通网页申请请您填写申请资料。");
	pPlayer.Msg("<color=yellow>"..me.szName.."<color>申请转入您帐号，确保您的帐号不超10名角色。");
	Player:SendMsgToKinOrTong(me, "成功申请角色转移。", 1);
	Player:SendMsgToKinOrTong(me, "成功申请角色转移。", 0);
	me.SendMsgToFriend("Hảo hữu ["..me.szName.."]成功申请角色转移。");
	Dialog:SendBlackBoardMsg(pPlayer, ""..me.szName.."申请转入您帐号，确保您的帐号不超10名角色。");
	--log
	StatLog:WriteStatLog("stat_info", "role_change", "apply", me.nId, pPlayer.szAccount);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s,%s组队申请角色转移。", me.szName, pPlayer.szName));
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s,%s组队申请角色转移。", me.szName, pPlayer.szName));
	--Dbg:WriteLog(me.szAccount, me.szName, pPlayer.szAccount, pPlayer.szName, "申请转移角色");
end

--撤销申请
function tbRoleTransfer:CancleApply()
	if SpecialEvent.tbRoleTransfer.bOpen ~= 1 then
		return;
	end	
	--账号锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法进行该操作。");
		return 0;	
	end
	if IsLoginUseVicePassword(me.nPlayerIndex) == 1 then
		Dialog:Say("您使用副密码登陆游戏，无法进行该操作。");
		return 0;
	end
	Dialog:OpenGift("请放入<color=yellow>角色转移资格证<color>", nil ,{self.OnOpenGiftOk, self});	
end

function tbRoleTransfer:OnOpenGiftOk(tbItemObj)
	--账号锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法进行该操作。");
		return 0;
	end
	if IsLoginUseVicePassword(me.nPlayerIndex) == 1 then
		Dialog:Say("您使用副密码登陆游戏，无法进行该操作。");
		return 0;
	end
	if self:CheckCanCancleApply() ~= 1 then
		Dialog:Say("您的账号有问题。");
		return;
	end
	if Lib:CountTB(tbItemObj) <= 0 then
		me.Msg("请放入角色转移资格证。");
		return 0;
	end
	if Lib:CountTB(tbItemObj) > 1 then
		me.Msg("您放入的物品不对。");
		return 0;
	end	
	local dwItemId = 0;
	for _, pItem in pairs(tbItemObj) do
		local szFollowItem = string.format("%s,%s,%s,%s", unpack(self.tbApplyItem));
		if szFollowItem ~= pItem[1].SzGDPL() then
			me.Msg("您放入的物品不对。");
			return 0;
		end		
		if pItem[1].szCustomString ~= me.szAccount then
			me.Msg("您放入的物品不对。");
			return 0;
		end
	end
	for _, pItem in pairs(tbItemObj) do
		dwItemId = pItem[1].dwId;
	end	
	me.AddWaitGetItemNum(1);
	GCExcute{"SpecialEvent.tbRoleTransfer:CancleApply", me.szAccount, me.szName, dwItemId, me.GetExtPoint(0)};
end

--查询自己转移情况
function tbRoleTransfer:QueryRoleTransfer()	
	if me.GetExtPoint(0) <= 0 then
		Dialog:Say("您的账号中没有角色进行转移。");
		return;
	end	
	local szMsg = "";
	for szName, tbEx in pairs(self.tbTransferDate) do
		for _,tb in pairs(tbEx) do
			if tb[1] == me.szAccount and tb[5] == 1 then			
				if GetTime() - me.GetExtPoint(0) < self.nDayApplyInGame then
					szMsg = string.format("您的角色<color=yellow>%s<color>正处于游戏申请期，%s之后可以进行网页申请。", szName , Lib:TimeDesc(self.nDayApplyInGame + tb[4] - GetTime()));
				elseif GetTime() - me.GetExtPoint(0) < self.nDayApplyInGame + self.nDayApplyInNet then
					szMsg = string.format("您的角色<color=yellow>%s<color>正处于网页申请期，%s之后过期。", szName , Lib:TimeDesc(self.nDayApplyInGame + self.nDayApplyInNet + tb[4] - GetTime()));
				elseif GetTime() - me.GetExtPoint(0) >= self.nDayApplyInGame + self.nDayApplyInNet and GetTime() - me.GetExtPoint(0) < self.nMaxTransferDay then
					szMsg = string.format("您的角色<color=yellow>%s<color>转移失败，需要等待%s之后可以重新申请。", szName , Lib:TimeDesc(self.nMaxTransferDay + tb[4] - GetTime()));
				elseif GetTime() - me.GetExtPoint(0) >= self.nMaxTransferDay then
					szMsg = string.format("您的角色<color=yellow>%s<color>转移失败，重新登录即可再次申请转移角色。", szName);
				end			
			end			
			if tb[2] == me.szAccount and tb[4] == me.GetExtPoint(0) then
				szMsg = string.format("角色<color=yellow>%s<color>正在转入您的账号", szName);				
				if tb[5] == 1 then
					if GetTime() - me.GetExtPoint(0) < self.nDayApplyInGame then
						szMsg = szMsg..string.format("，正处于游戏申请期，%s之后可以进行网页申请。", Lib:TimeDesc(self.nDayApplyInGame + tb[4] - GetTime()));
					elseif GetTime() - me.GetExtPoint(0) < self.nDayApplyInGame + self.nDayApplyInNet then
						szMsg = szMsg..string.format("，正处于网页申请期，%s之后可以进行接收资料填写。", Lib:TimeDesc(self.nDayApplyInGame + self.nDayApplyInNet + tb[4] - GetTime()));
					elseif GetTime() - me.GetExtPoint(0) >= self.nDayApplyInGame + self.nDayApplyInNet and GetTime() - me.GetExtPoint(0) < self.nDayOthenAccept then
						szMsg = szMsg..string.format("，正处于网页接收期，请快去填写资料，如果网站审核未通过表示已经失败，需要等待%s之后可以重新申请。", Lib:TimeDesc(self.nMaxTransferDay + tb[4] - GetTime()));
					elseif GetTime() - me.GetExtPoint(0) >= self.nDayOthenAccept and GetTime() - me.GetExtPoint(0) < self.nMaxTransferDay then
						szMsg = szMsg..string.format("，转移失败，需要等待%s之后可以重新申请。", Lib:TimeDesc(self.nMaxTransferDay + tb[4] - GetTime()));
					elseif GetTime() - me.GetExtPoint(0) >= self.nMaxTransferDay then
						szMsg = szMsg.."，转移失败，重新登录即可再次申请转移角色。";
					end
				elseif tb[5] == 0 then
					szMsg = "对方撤销了转移角色,重新登录可再次申请转移。";
				end
			end
		end
	end
	if szMsg == "" and GetTime() - me.GetExtPoint(0) >= self.nMaxTransferDay then
		szMsg = "角色转移失败，重新登录即可再次申请转移角色。";
	end
	if szMsg == "" then
		szMsg = "没有信息";
	end
	Dialog:Say(szMsg);
	return;
end

function tbRoleTransfer:Information(nType)
	local tbOpt = {
		{"角色转移条件", self.Information, self, 2},
		{"角色转移流程", self.Information, self, 3},
		{"注意事项", self.Information, self, 4},
		{"我知道啦"},
	}
	if not nType then
		Dialog:Say(self.tbInfo[1], tbOpt);
		return;
	else
		Dialog:Say(self.tbInfo[nType], {{"返回", self.Information, self}});
		return;
	end
end

--撤销成功把玩家解锁
function tbRoleTransfer:CancleApplySuccess(szAccount, szName, dwItemId, nTime)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	local szTransfered = nil; 
	local szObjAccount = "";	
	for _, tb in pairs(self.tbTransferDate[szName] or {}) do
		if tb[1] == szAccount and tb[4] == nTime and tb[5] == 1 then
			tb[5] = 0;
			szTransfered = tb[3];
			break;
		end
	end
	
	if pPlayer then
		pPlayer.AddWaitGetItemNum(-1);
		local pItem = KItem.GetObjById(dwItemId);
		if pItem then			
			pItem.Delete(pPlayer);
			pPlayer.AddBindCoin(self.nCancelApplyCoin);
		end
		pPlayer.PayExtPoint(0, pPlayer.GetExtPoint(0));
		pPlayer.Msg("您撤销了转移申请。");
		KPlayer.SendMail(pPlayer.szName, "角色转移通知", "您已经成功撤销了角色转移，请周知。剑侠世界特此提醒。");
		KPlayer.SendMail(szTransfered, "角色转移通知", string.format("玩家<color=yellow>%s<color>已经成功撤销了角色转移，请周知。剑侠世界特此提醒。", pPlayer.szName));
		--log
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "成功撤销了角色转移申请。");
		StatLog:WriteStatLog("stat_info", "role_change", "fail", pPlayer.nId, string.format("%s,%s,%s", pPlayer.GetTaskStr(self.TASK_GROUP_ID, self.TASK_OBJ_ACCOUNT), os.date("%Y%m%d%H%M%S", nTime), 0));
	end
end

--检查能不能转移
function tbRoleTransfer:CheckCanTransfer()
	--账号锁
	if me.IsAccountLock() ~= 0 then
		return 0, "你的账号处于锁定状态，无法进行该操作。";	
	end
	--组队，必须队长申请
	if me.nTeamId <= 0 then
		return 0, "只有两人组队才可以申请转移角色。";
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId)
	if #tbPlayerList ~= 2 then
		return 0, "只有两人组队才可以申请转移角色。";
	end
	if me.IsCaptain() == 0 then
		return 0, "只有队长才能申请转移角色。";
	end	
	--等级要求
	if me.nLevel < self.nMinLevel then
		return 0, string.format("等级不足%s级，不能申请转移角色。", self.nMinLevel);
	end
	--财富荣誉
	if PlayerHonor:GetPlayerHonor(me.nId, PlayerHonor.HONOR_CLASS_MONEY, 0) < self.nMinHonor then
		return 0, string.format("财富荣誉不足%s，不能申请转移角色。", self.nMinHonor);
	end
	--同一时间一对账号之间只能转一个角色
	if me.GetExtPoint(0) > 0 then
		return 0, "您账号有角色正在转移中或是转移失败，需要等候有效期24天。";
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[2]);
	--在跟前
	if not pPlayer then
		return 0, "你的队友不在跟前。";
	end
	if pPlayer and pPlayer.GetExtPoint(0) > 0 then
		return 0, "对方的账号底下有角色在进行转移。";
	end
	if #KGCPlayer.GetRolesOfAccount(pPlayer.szAccount) >= 10 then
		return 0, "对方的账号角色过多，不能转入。";
	end	
	local nMapId1, nX1,nY1 = me.GetWorldPos();
	local nMapId2, nX2,nY2 = pPlayer.GetWorldPos();
	if nMapId1 ~= nMapId2 or (nX1 - nX2) * (nX1 - nX2) + (nY1 - nY2) * (nY1 - nY2) > 400  then
		return 0, "你的队友不在跟前。";
	end
	--内部账号不可以转移或者转入
	if jbreturn:GetMonLimit(me) > 0 then
		return 0, "您的账号异常，不能转移角色";
	end	
	if jbreturn:GetMonLimit(pPlayer) > 0 then
		return 0, "对方的账号异常，不能转入角色";
	end	
	--副密码不能转移
	if IsLoginUseVicePassword(me.nPlayerIndex) == 1 then
		return 0, "您使用副密码登陆游戏，不能执行转移操作。";
	end
	if IsLoginUseVicePassword(pPlayer.nPlayerIndex) == 1 then
		return 0, "对方使用副密码登陆游戏，不能执行转移操作。";
	end
	--转移资格证
	local tbFind = me.FindItemInBags(unpack(self.tbApplyItem));
	if #tbFind <= 0 then
		--购买资格证
		self:BuyItem();
		return 0, "需要角色转移资格证才能转移角色";
	end
	return 1;
end

--购买角色转移资格证
function tbRoleTransfer:BuyItem(nFlag)
	if not nFlag then
		Dialog:Say("您没有角色转移资格证<color=yellow>（15000金币）<color>，请确认购买吗？\n\n<color=yellow>点击确认则直接扣除15000金币进行购买，请再三确认。<color>", {{"购买角色转移资格证", self.BuyItem, self, 1},{"取消"}});
		return;
	end
	if me.nCoin < self.nCancelApplyCoin then
		Dialog:Say("您的金币不足！", {{"我知道啦"}});
		return;
	end
	if me.CountFreeBagCell() <= 0 then
		Dialog:Say("需要一格背包空间。", {{"我知道啦"}});
		return;
	end
	me.ApplyAutoBuyAndUse(self.nWairListId, 1, 0);
	return;
end

--检查是否可以撤销
function tbRoleTransfer:CheckCanCancleApply()	
	if me.GetExtPoint(0) <= 0 then
		return 0;
	end
	if not self.tbTransferDate[me.szName] then
		return 0;
	end
	for _, tb in ipairs(self.tbTransferDate[me.szName] or {}) do
		--是自己的账号在转移，并且状态为正在转移，且游戏申请时间不足5天
		if tb[1] == me.szAccount and  GetTime() - tb[4]  < self.nDayApplyInGame and tb[4] == me.GetExtPoint(0) and tb[5] == 1 then
			return 1;
		end
	end
	return 0;
end

--send mail
function tbRoleTransfer:SendMail(nType)
	local szBroadcastMsg = self.tbMailMsg[nType];
	if not szBroadcastMsg then
		return;
	end
	local tbFriendList = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_BIDFRIEND);
	for _, szName in pairs(tbFriendList or {}) do
		if me.GetFriendFavorLevel(szName) >= self.nFrendLevel then
			KPlayer.SendMail(szName, "角色转移通知", string.format(szBroadcastMsg, me.szName));
		end
	end
end

--登录事件
function tbRoleTransfer:OnPlayerLogIn()
	if SpecialEvent.tbRoleTransfer.bOpen ~= 1 then
		return;
	end
	--找道具，看看是不是转移前的道具
	local tbFind = me.FindItemInAllPosition(unpack(self.tbApplyItem));
	for _, tb in pairs(tbFind) do
		local szTransferAccount = tb.pItem.szCustomString;
		--道具跟自己账号不匹配转移成功啦
		if szTransferAccount ~= "" and szTransferAccount ~= me.szAccount  then
			tb.pItem.Delete(me);
			me.NewWorld(unpack(self.tbMapInfo));
			local nTime = me.GetExtPoint(0);
			me.PayExtPoint(0, nTime);
			self:SendMail(2);
			me.Msg("恭喜您角色转移成功！");
			Dialog:SendBlackBoardMsg(me, "恭喜您角色转移成功！");
			Player:SendMsgToKinOrTong(me, "角色转移成功。", 1);
			Player:SendMsgToKinOrTong(me, "角色转移成功。", 0);
			me.SendMsgToFriend("Hảo hữu ["..me.szName.."]角色转移成功。");
			GCExcute{"SpecialEvent.tbRoleTransfer:TransferSuccess", me.szAccount, me.szName, nTime};
			--log 转移成功
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "成功转移角色原账号信息为："..szTransferAccount);
			StatLog:WriteStatLog("stat_info", "role_change", "succ",me.nId, string.format("%s,%s,%s", szTransferAccount, os.date("%Y%m%d%H%M%S", nTime), 1));
			return 0;
		end
	end
	
	for _, tb in ipairs(self.tbTransferDate[me.szName] or {}) do
		--转移中的角色
		if me.GetExtPoint(0) > 0 and me.GetExtPoint(0) == tb[4] and GetTime() - me.GetExtPoint(0) < self.nMaxTransferDay and tb[1] == me.szAccount and  tb[5] == 1 then
			local szMsg = "";
			if GetTime() - tb[4]  < self.nDayApplyInGame then
				szMsg = string.format("您的角色正处于角色转移中<color=yellow>%s<color>之后可以进行网页申请。", Lib:TimeDesc(self.nDayApplyInGame + tb[4] - GetTime()));
			elseif GetTime() - tb[4]  < self.nDayApplyInGame + self.nDayApplyInNet then
				szMsg = "您的角色正处于角色转移中，请尽快去网页申请转移。";
			end
			--掉客户端窗口提醒申请中
			if szMsg ~= "" then
				me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
				me.Msg(szMsg);
			end
			return 0;
		end		
	end
	--撤销转移及失败转移的转入账号解除扩展变量
	if me.GetExtPoint(0) > 0 then
		for _, tbEx in pairs(self.tbTransferDate) do
			for _, tb in ipairs(tbEx) do
				if tb[2] == me.szAccount and tb[3] == me.szName and tb[5] == 0 and me.GetExtPoint(0) == tb[4] then
					me.PayExtPoint(0, me.GetExtPoint(0));
					return 0;
				end
			end
		end
	end
	--转移时间过20天失败的转出账号解除扩展变量同时申请的道具还原，可以接着申请
	if me.GetExtPoint(0) > 0 and GetTime() - me.GetExtPoint(0) >= self.nMaxTransferDay then
		local nTime = me.GetExtPoint(0);
		me.PayExtPoint(0, me.GetExtPoint(0));
		--找道具，看看是不是转移的道具
		local tbFind = me.FindItemInAllPosition(unpack(self.tbApplyItem));
		for _, tb in pairs(tbFind) do
			local szTransferAccount = tb.pItem.szCustomString;
			if szTransferAccount == me.szAccount then
				tb.pItem.SetCustom(2, "");
				tb.pItem.SetGenInfo(1, 0);
				tb.pItem.Sync();
				--找到道具说明是失败转移的角色
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "转移角色失败。");
				StatLog:WriteStatLog("stat_info", "role_change", "fail", me.nId, string.format("%s,%s,%s", me.GetTaskStr(self.TASK_GROUP_ID, self.TASK_OBJ_ACCOUNT), os.date("%Y%m%d%H%M%S", nTime), 1));
				break;
			end
		end
		return 0;		
	end
end

--转移成功角色
function tbRoleTransfer:TransferSuccess(szAccount, szName, nTime)
	for _, tb in pairs(self.tbTransferDate[szName] or {}) do
		if tb[2] == szAccount and tb[4] == nTime and tb[5] == 1 then
			tb[5] = 2;
			break;
		end
	end
end

--设内存数据
function tbRoleTransfer:SetBuffer(tbInfo)
	self.tbTransferDate[tbInfo[2]] = self.tbTransferDate[tbInfo[2]] or {};
	local nFlag = 0;
	for _, tb in pairs(self.tbTransferDate[tbInfo[2]]) do
		if tb[1] == tbInfo[1] and tb[2] == tbInfo[3] or tb[3] == tbInfo[4] then
			tb[4] = tbInfo[5];
			tb[5] = tbInfo[6];
			nFlag = 1;
		end
	end
	if nFlag == 0 then
		table.insert(self.tbTransferDate[tbInfo[2]], {tbInfo[1], tbInfo[3], tbInfo[4],tbInfo[5], tbInfo[6]});
	end
end

--loadbuff
function tbRoleTransfer:LoadBuffer_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0);	
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbTransferDate = tbBuffer;
	end
end

------------------------------------- 角色转移失败相关处理 --------------------------------------------

-- 角色转账号失败回调
-- buff格式 {[rolename] = {nFlag, szOldAccount, szNewAccount}}
function tbRoleTransfer:OnTransferFail(nFlag, szRole, szOldAccount, szNewAccount)
	if nFlag == 0 then
		return;
	end
	
	if (not self.tbTransferFailData) then
		self.tbTransferFailData = GetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0);
	end
	self.tbTransferFailData = self.tbTransferFailData or {};
	
	--assert(not self.tbTransferFailData[szRole]);	-- 操作流程上应该要控制，不要出现多次记录
	
	self.tbTransferFailData[szRole] = {};
	self.tbTransferFailData[szRole] = {nFlag, szOldAccount, szNewAccount};
	
	--SetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0, 1, self.tbTransferFailData);
	GCExcute{"SpecialEvent.tbRoleTransfer:BroadcastTransferFailData", szRole, self.tbTransferFailData[szRole]};
end

function tbRoleTransfer:OnLogin_CheckTransferFail()
	if (not self.tbTransferFailData) then
		self.tbTransferFailData = GetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0);
	end
	
	local nRet = 1;
	if self.tbTransferFailData and self.tbTransferFailData[me.szName] then
		nRet = self:ReApplyChangeData(self.tbTransferFailData[me.szName]);
	end	
	
	return nRet;
end

-- 重新修改数据
function tbRoleTransfer:ReApplyChangeData(tbInfo)
	local nFlag = tbInfo[1];
	local nRet = 0;
	
	for _, tbCall in pairs(self.tbTransferFailCallback) do
		if (Lib:LoadBits(nFlag, tbCall[1], tbCall[1]) == 1) then
			if (_G[tbCall[2]](me.szName, tbInfo[2], tbInfo[3], tbCall[3] or 0) == 1) then
				nFlag = Lib:SetBits(nFlag, 0, tbCall[1], tbCall[1]);
			end
		end			
	end
	
	if tbInfo[1] ~= nFlag then
		if nFlag == 0 then
			self.tbTransferFailData[me.szName] = nil;
			nRet = 1;
		else
			self.tbTransferFailData[me.szName][1] = nFlag;
		end
		--SetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0, 1, self.tbTransferFailData);
		GCExcute{"SpecialEvent.tbRoleTransfer:BroadcastTransferFailData", me.szName, self.tbTransferFailData[me.szName]};
	end
	
	return nRet;	
end

function tbRoleTransfer:OnSyncTransferFailData(szName, tbData)
	if (not self.tbTransferFailData) then
		self.tbTransferFailData = GetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0) or {};
	end
	self.tbTransferFailData[szName] = tbData;
end

tbRoleTransfer.tbTransferFailCallback =
{
	{ 0, "ChangeAccount_GameCenterData" },	-- gc
	{ 1, "ChangeAccount_GoddesData" }, 	-- goddes
	{ 2, "ChangeAccount_LogServerData" }, -- logserver
	{ 3, "ChangeAccount_GlobalNameServerData" }, -- global nameserver
	{ 4, "ChangeAccount_GameCenterData", 1 }, -- gc内存数据
}
PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.tbRoleTransfer.OnLogin_CheckTransferFail, SpecialEvent.tbRoleTransfer);
------------------------------------- 角色转移失败相关处理 --------------------------------------------

PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.tbRoleTransfer.OnPlayerLogIn, SpecialEvent.tbRoleTransfer);
ServerEvent:RegisterServerStartFunc(SpecialEvent.tbRoleTransfer.LoadBuffer_GS, SpecialEvent.tbRoleTransfer);



-----------------------test------------------------------
--显示所有角色转移情况
function tbRoleTransfer:_debug_show_transfer()
	local tbJindu = {"撤销", "申请期", "成功"};
	for szName, tb in pairs(self.tbTransferDate) do
		for _, tbEx in pairs(tb) do
			me.Msg("转移账号："..tbEx[1].."，转移角色："..szName.." ，转入账号："..tbEx[2].."，申请角色："..tbEx[3].." ，申请时间："..os.date("%Y-%m-%d %H:%M:%S", tbEx[4]).."，情况："..tbJindu[tbEx[5] + 1]);
		end
	end
end
