-- 文件名　：event_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-08-31 11:04:16
-- 功能    ：新服活动201109

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\newgateevent\\event_def.lua");

SpecialEvent.tbNewGateEvent = SpecialEvent.tbNewGateEvent or {};
local tbNewGateEvent = SpecialEvent.tbNewGateEvent;

---------------------------老剑侠征战新疆土-----------------------------------------
function tbNewGateEvent:OnDialog()
	local szMsg = "老剑侠征战新疆土，您可以在我这里绑定老玩家账号，开始新服之旅，更有惊喜奖励等你来拿，快快行动吧。";
	local tbOpt = {
		{"绑定老玩家账号", self.BindOldAccount, self},
		{"领取奖励", self.GetAward, self},	
		{"Để ta suy nghĩ thêm"}
		}
	Dialog:Say(szMsg, tbOpt);
	return;
end

--领取奖励
function tbNewGateEvent:GetAward(nFlag)	
	local bCanAward = 1;
	local szMsg = "";	
	szMsg = szMsg.."领取奖励条件为：\n\n";
	if me.GetTask(self.TASK_GROUPID, self.TASK_BINDOLD) == 1 then
		szMsg = szMsg.."<color=green>    1.绑定武林前辈<color>\n";
	else
		szMsg = szMsg.."<color=gray>    1.绑定武林前辈<color>\n";
		bCanAward = 0;
	end
	if me.GetExtMonthPay() >= 100 then
		szMsg = szMsg.."<color=green>    2.充值达到100元<color>\n";
	else
		szMsg = szMsg.."<color=gray>    2.充值达到100元<color>\n";
		bCanAward = 0;
	end
	if me.nLevel >= self.nMinLevel then
		szMsg = szMsg.."<color=green>    3.等级达到60级<color>\n";	
	else
		szMsg = szMsg.."<color=gray>    3.等级达到60级<color>\n";
		bCanAward = 0;
	end
	if Achievement:CheckFinished(185) == 1 then
		szMsg = szMsg.."<color=green>    4.通过逍遥谷2关<color>\n";
	else
		szMsg = szMsg.."<color=gray>    4.通过逍遥谷2关<color>\n";
		bCanAward = 0;
	end	
	if me.GetTask(self.TASK_GROUPID, self.TASK_BINDAWARD) == 1 then
		szMsg = szMsg.."\n<color=green>您已经成功领取了奖励<color>";
		bCanAward = 2;
	else
		szMsg = szMsg.."\n<color=red>您未领取奖励<color>";
	end
	if not nFlag then
		if bCanAward == 1 then
			Dialog:Say(szMsg, {"领取奖励", self.GetAward, self, 1});
			return;
		else
			Dialog:Say(szMsg, {"Ta hiểu rồi"});
			return;
		end
	else
		if me.GetTask() == 1 then
			Dialog:Say("您已经领取过了", {"Ta hiểu rồi"});
			return;
		end
		if me.CountFreeBagCell() < 2  then
			Dialog:Say("Hành trang không đủ ，需要2格背包空间。", {"Ta hiểu rồi"});
			return 0;
		end
		if self.nMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
			Dialog:Say("您的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。", {"Ta hiểu rồi"});		
			return 0;		
		end
		local pItem = me.AddItem(unpack(self.tbItem));
		if pItem then
			me.SetItemTimeout(pItem, GetTime() + 3600* 24 *30, 0);
			pItem.Bind(1);
		end
		local pItemEx = me.AddItem(18, 1, 1352, 2);
		if pItem then
			me.SetItemTimeout(pItem, GetTime() + 3600* 24 *30, 0);
			pItem.Bind(1);
		end
		me.SetTask(self.TASK_GROUPID, self.TASK_BINDAWARD, 1);
		me.Msg("您已经成功获得实物抽奖资格，敬请期待。");
		Dialog:SendBlackBoardMsg(me, "您已经成功获得实物抽奖资格，敬请期待。");
		StatLog:WriteStatLog("stat_info", "tuiguang", "apply", me.nId, 3);
	end
end

--绑定老玩家
function tbNewGateEvent:BindOldAccount()
	Dialog:AskString("请输入需要绑定的老账号：", 15, self.CheckCanBind, self);
end

--输入确认
function tbNewGateEvent:CheckCanBind(szAccount)
	szAccount = string.lower(szAccount or "");
	szAccount = Lib:ClearBlank(szAccount);
	if me.GetTask(self.TASK_GROUPID, self.TASK_BINDOLD) == 1 then
		Dialog:Say("每个玩家只可以绑定一个老玩家账号。");
		return;
	end
	if not self.tbOldListBuff[szAccount] then
		Dialog:Say("您输入的老玩家账号不对，不能绑定！");
		return;
	end
	if self.tbOldList[szAccount] then
		Dialog:Say("您输入的老玩家账号已经绑定！");
		return;
	end	
	me.AddWaitGetItemNum(1);
	GCExcute({"SpecialEvent.tbNewGateEvent:BindAccount", me.nId, szAccount});
	return 1;
end

--绑定成功
function tbNewGateEvent:BindSucess(nPlayerId, szAccount)
	self.tbOldList[szAccount] = 1;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.SetTask(self.TASK_GROUPID, self.TASK_BINDOLD, 1);
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say("恭喜您绑定老玩家成功");
	Setting:RestoreGlobalObj();
	StatLog:WriteStatLog("stat_info", "tuiguang", "bind2", pPlayer.nId, szAccount);
	return;
end

--绑定失败
function tbNewGateEvent:BindFail(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.AddWaitGetItemNum(-1);
	local Oldme = me;
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say("您输入的老玩家账号已经绑定！");
	Setting:RestoreGlobalObj()
	return;
end

function tbNewGateEvent:LoadFile()
	local szFileName = "\\setting\\event\\specialevent\\oldpbackaccountlist.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local szOldAccount = string.lower(tbParam.OldAccount or "");
			szOldAccount = Lib:ClearBlank(szOldAccount);
			self.tbOldListBuff[szOldAccount] = 1;
		end
	end
end

--起服务器读文件
tbNewGateEvent:LoadFile();

--读buff
function tbNewGateEvent:LoadBuffer_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_NEWGATEEVENT, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbOldList = tbBuffer;
	end	
end

--ServerEvent:RegisterServerStartFunc(SpecialEvent.tbNewGateEvent.LoadBuffer_GS, SpecialEvent.tbNewGateEvent);


-------------------------------------开学有礼--------------------------------------
function tbNewGateEvent:OnDialogStude()
	local szMsg = "开学有礼大赠送，快来领取丰厚奖励吧。";
	local tbOpt = {
		{"领取绑金返还券", self.GetStudentBindMoney, self},
		{"绑金绑银大返还", self.GetStudentAward, self, 1},
		{"幸运小礼包", self.GetStudentAward, self, 2},
		{"幸运礼包", self.GetStudentAward, self, 3},	
		{"幸运大礼包", self.GetStudentAward, self, 4},	
		{"Để ta suy nghĩ thêm"}
		}
	Dialog:Say(szMsg, tbOpt);
	return;
end

--领奖
function tbNewGateEvent:GetStudentAward(nType, nFlag)
	local bCanAward = 1;
	local szMsg = "";
	szMsg = szMsg.."领取奖励条件为：\n\n";
	if me.GetExtMonthPay() >= 100 then
		szMsg = szMsg.."<color=green>    1.充值达到100元<color>\n";
	else
		szMsg = szMsg.."<color=gray>    1.充值达到100元<color>\n";
		bCanAward = 0;
	end
	if nType == 1 then
		szMsg ="每5级（最高80级）可以领取一定额度的绑银。\n".. szMsg;
		local nAwardLevel = me.GetTask(self.TASK_GROUPID, self.TASK_GRADE);
		if me.nLevel >= nAwardLevel + 5 and nAwardLevel <= 75 then
			szMsg = szMsg..string.format("\n<color=green>可以领取%s级奖励<color>\n", nAwardLevel + 5);
		elseif me.nLevel < nAwardLevel + 5 and nAwardLevel <= 75 then
			szMsg = szMsg..string.format("\n<color=red>下份奖励为：%s级的奖励<color>\n", nAwardLevel + 5);
			bCanAward = 0;
		elseif nAwardLevel > 75 then
			szMsg = szMsg.."\n<color=red>奖励已经领取完了<color>";
			bCanAward = 0;
		end		
	elseif nType ==2 then
		if me.nLevel >= 60 then
			szMsg = szMsg.."<color=green>    2.等级达到60级<color>\n";		
		else
			szMsg = szMsg.."<color=gray>    2.等级达到60级<color>\n";
			bCanAward = 0;
		end
		if Achievement:CheckFinished(185) == 1 then
			szMsg = szMsg.."<color=green>    3.通过逍遥谷2关<color>\n";		
		else
			szMsg = szMsg.."<color=gray>    3.通过逍遥谷2关<color>\n";
			bCanAward = 0;
		end
		if me.nKinFigure > 0  and me.nKinFigure <= 3 then
			szMsg = szMsg.."<color=green>    4.家族正式成员<color>\n";		
		else
			szMsg = szMsg.."<color=gray>    4.家族正式成员<color>\n";
			bCanAward = 0;
		end
	elseif nType == 3 then
		if me.nLevel >= 60 then
			szMsg = szMsg.."<color=green>    2.等级达到60级<color>\n";		
		else
			szMsg = szMsg.."<color=gray>    2.等级达到60级<color>\n";
			bCanAward = 0;
		end
		if Achievement:CheckFinished(185) == 1 then
			szMsg = szMsg.."<color=green>    3.通过逍遥谷2关<color>\n";		
		else
			szMsg = szMsg.."<color=gray>    3.通过逍遥谷2关<color>\n";
			bCanAward = 0;
		end
		if self:CheckTeamPlayer() == 1 then
			szMsg = szMsg.."<color=green>    4.组队（队长）邀请好友（两人组队且未被邀请过）且好友充值达100元<color>\n";
		else
			szMsg = szMsg.."<color=gray>    4.组队（队长）邀请好友（两人组队且未被邀请过）且好友充值达100元<color>\n";
			bCanAward = 0;		
		end
	elseif nType == 4 then
		if me.nLevel >= 80 then
			szMsg = szMsg.."<color=green>    2.等级达到80级<color>\n";		
		else
			szMsg = szMsg.."<color=gray>    2.等级达到80级<color>\n";
			bCanAward = 0;
		end
		if Achievement:CheckFinished(187) == 1 then
			szMsg = szMsg.."<color=green>    3.通过逍遥谷4关<color>\n";
		else
			szMsg = szMsg.."<color=gray>    3.通过逍遥谷4关<color>\n";
			bCanAward = 0;
		end
	end
	if nType >=2 then
		if  me.GetTask(self.TASK_GROUPID, self.TASK_GRADE + nType - 1) == 1 then
			szMsg = szMsg.."\n<color=green>您已经成功领取了奖励<color>";
			if nType == 3 then
				szMsg = szMsg.."<color=green>或是已经被邀请了<color>"
			end
			bCanAward = 2;
		else
			szMsg = szMsg.."\n<color=red>您未领取奖励<color>";
		end
	end
	if not nFlag then
		if bCanAward == 1 then
			Dialog:Say(szMsg, {"领取奖励", self.GetStudentAward, self, nType, 1});
			return;
		else
			Dialog:Say(szMsg, {"Ta hiểu rồi"});
			return;
		end
	else
		self:GetStudentAwardEx(nType)
	end
end

--绑银返还券
function tbNewGateEvent:GetStudentBindMoney()
	if me.GetTask(self.TASK_GROUPID, self.TASK_BINDCOIN) == 1 then
		Dialog:Say("您已经领取过了。", {"Ta hiểu rồi"});
		return 0;
	end
	if  me.GetExtMonthPay() < 100 then
		Dialog:Say("您充值不足100元，不能领取。", {"Ta hiểu rồi"});
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ ，需要2格背包空间。", {"Ta hiểu rồi"});
		return 0;
	end
	
	me.AddStackItem(18,1,1309,3,{bForceBind = 1}, 2);
	me.Msg("恭喜您获得10000额度的绑金返还券。");
	StatLog:WriteStatLog("stat_info", "tuiguang", "libao", me.nId, 1);
	me.SetTask(self.TASK_GROUPID, self.TASK_BINDCOIN, 1);
end

--领取奖励
function tbNewGateEvent:GetStudentAwardEx(nType)
	if nType == 1 then
		local nAwardLevel = me.GetTask(self.TASK_GROUPID, self.TASK_GRADE);
		if nAwardLevel + 5 > 80 then
			Dialog:Say("您已经没有奖励领取啦", {"Ta hiểu rồi"});
			return 0;
		end
		if me.nLevel < nAwardLevel + 5 then
			Dialog:Say(string.format("您等级不足%s级", nAwardLevel+ 5 ), {"Ta hiểu rồi"});
			return 0;
		end		
		if me.nLevel * 500 + me.GetBindMoney() > me.GetMaxCarryMoney() then
			Dialog:Say("您的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。", {"Ta hiểu rồi"});		
			return 0;
		end		
		me.AddBindMoney(me.nLevel * 500);
		me.SetTask(self.TASK_GROUPID, self.TASK_GRADE, nAwardLevel + 5);
		return;
	end
	if me.GetTask(self.TASK_GROUPID, self.TASK_GRADE + nType - 1)  == 1 then
		Dialog:Say("您已经没有奖励领取啦", {"Ta hiểu rồi"});
		return 0;
	end
	if me.CountFreeBagCell() < 1  then
		Dialog:Say("Hành trang không đủ 1 ô trống.", {"Ta hiểu rồi"});
		return 0;
	end
	if nType ~= 3 then
		local pItem = me.AddItem(unpack(self.tbXingyunLiBao[nType]));
		if pItem then
			me.SetItemTimeout(pItem, 3*24*60, 0);
			me.SetTask(self.TASK_GROUPID, self.TASK_GRADE + nType - 1, 1);
		end		
	else
		local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
		local pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[2]);
		if pPlayer then
			if pPlayer.CountFreeBagCell() < 1  then
				Dialog:Say("队友的背包空间不足，需要1格背包空间。", {"Ta hiểu rồi"});
				return 0;
			end
			local pItem = pPlayer.AddItem(unpack(self.tbXingyunLiBao[3]));
			if pItem then
				pPlayer.SetItemTimeout(pItem, 3*24*60, 0);
				pItem.SetCustom(2, me.szName);
				pItem.Sync();
				pPlayer.SetTask(self.TASK_GROUPID, self.TASK_GRADE + nType - 1, 1);
				me.SetTask(self.TASK_GROUPID, self.TASK_GRADE + nType - 1, 1);
				pPlayer.Msg("恭喜您获得幸运礼包，该礼包需要交易给Hảo hữu ["..me.szName.."]。");
			end
		else
			Dialog:Say("队友不在身边。", {"Ta hiểu rồi"});
			return 0;
		end
	end
	me.Msg("恭喜您获得奖励。");
	StatLog:WriteStatLog("stat_info", "tuiguang", "libao", me.nId, nType);
	return;
end

--绑定成功
function tbNewGateEvent:GetStudentSucess(nPlayerId, nType, nGen, nDetal)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	Setting:SetGlobalObj(pPlayer);
	local tbAward = self.tbStudentAward[nType][nGen][nDetal];
	pPlayer.AddWaitGetItemNum(-1);
	if tbAward[1] == 1 then
		local pItem = me.AddItem(unpack(tbAward[2]));
		if pItem then
			me.SetItemTimeout(pItem, 10, 0);
			pItem.Bind(1);
			me.Msg("恭喜您获得实物卡奖励（十分钟有效期），请尽快使用。");
			Dialog:SendBlackBoardMsg(me, "恭喜您获得实物卡奖励（十分钟有效期），请尽快使用。");
		end
	elseif tbAward[1] == 2 then
		me.AddBindMoney(tbAward[2])
		me.Msg("恭喜您获得绑银"..tbAward[2]);
	elseif tbAward[1] == 3 then
		me.AddBindCoin(tbAward[2]);
		me.Msg("恭喜您获得绑金"..tbAward[2]);
	elseif tbAward[1] == 4 then
		--离线时间
		Player.tbOffline:AddExOffLineTime(tbAward[2] * 60);
		me.Msg("恭喜您获得离线时间"..tbAward[2].."小时");
	end
	Setting:RestoreGlobalObj();
	return;
end

--检查队友是否符合资格
function tbNewGateEvent:CheckTeamPlayer()
	if me.nTeamId <= 0 then
		return 0;
	end
	if me.IsCaptain() == 0 then
		return 0;
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	if #tbPlayerList ~=  2 then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[2]);
	if not pPlayer  then
		return 0;
	end
	local nMapId1, nX1,nY1 = me.GetWorldPos();
	local nMapId2, nX2,nY2 = pPlayer.GetWorldPos();
	if nMapId1 ~= nMapId2 or (nX1 - nX2) * (nX1 - nX2) + (nY1 - nY2) * (nY1 - nY2) > 400  then
		return 0;
	end
	if pPlayer.GetTask(self.TASK_GROUPID, self.TASK_BAG) == 1 then
		return 0;
	end
	if pPlayer.GetExtMonthPay() < 100 then
		return 0;
	end
	return 1;
end

-------------------------------------百家争鸣--------------------------------------

--读buff
function tbNewGateEvent:LoadBufferKin_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_NEWGATEKINAWARD, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbKinAward = tbBuffer;
	end	
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.tbNewGateEvent.LoadBufferKin_GS, SpecialEvent.tbNewGateEvent);

-- 领取家族拉人赛奖励
function tbNewGateEvent:OnDialogKin()
	local szMsg = "百大威望家族赛活动排名奖励已经出炉，快来领取您的奖励吧。";
	local tbOpt = {
		{"领取家族奖励", self.GetAwardKin, self, 1},
		{"领取个人奖励", self.GetAwardKin, self, 2},
		{"Để ta suy nghĩ thêm"}
		}
	Dialog:Say(szMsg, tbOpt);
	return;
end

--获得奖励
function tbNewGateEvent:GetAwardKin(nType)
	local nRet, szErrorMsg = self:CheckGetAwardKin(nType);
	if nRet == 0 then
		Dialog:Say(szErrorMsg);
		return;
	end
	if nType == 1 then
		local nAwardMoney =self.tbKinMoneyAward[self.tbKinAward[me.dwKinId][1]];
		if not nAwardMoney then
			return;
		end
		Kin:AddFundGM_GS(me.dwKinId, nAwardMoney);
		GCExcute({"SpecialEvent.tbNewGateEvent:SetKinAward", me.dwKinId});
		self:SetKinAward(me.dwKinId);
	else
		local tbAward = self.tbKinAwardEx[self.tbKinAward[me.szName][1]];
		for _, tb in pairs(tbAward) do
			if tb[1] == 1 then
				me.AddBindCoin(tb[2]);
			elseif tb[1] == 2 then
				me.AddBindMoney(tb[2]);
			elseif tb[1] == 3 then
				me.AddKinReputeEntry(tb[2]);
			elseif tb[1] == 4 then
				me.AddStackItem(tb[2][1], tb[2][2], tb[2][3],tb[2][4],{bForceBind =1},tb[2][5]);
			else
				me.AddSpeTitle(tb[2], GetTime()+ 24*30*3600, "pink");
			end
		end
		me.SetTask(self.TASK_GROUPID, self.TASK_KINAWARD, 1);
		local pKin = KKin.GetKin(me.dwKinId);
		local szKinName = "";
		if pKin then
			szKinName = pKin.GetName();
		end
		
		--记录log
		local nType = self.tbKinAward[me.szName][1];
		nType = math.fmod(self.tbKinAward[me.szName][1], 2);
		StatLog:WriteStatLog("stat_info", "tuiguang", "weiwangsai", me.nId, string.format("%s, %s, %s",szKinName, self.tbKinAward[me.szName][2], nType));
	end
	return;
end

--检查奖励领取条件
function tbNewGateEvent:CheckGetAwardKin(nType)
	if nType == 1 then
		local cKin = KKin.GetKin(me.dwKinId);
		if not cKin then
			return 0, "您没有家族。"
		end
		if me.nKinFigure ~= 1 then
			return 0, "只有族长才能领取家族奖励。"
		end
		if not self.tbKinAward[me.dwKinId] then
			return 0, "您的家族并没有奖励领取。";
		end
		if self.tbKinAward[me.dwKinId][1] == 0 then
			return 0, "您家族的奖励已经领取过了。";
		end	
		local nAwardMoney =self.tbKinMoneyAward[self.tbKinAward[me.dwKinId][1]];
		if not nAwardMoney then
			return 0, "您的家族并没有奖励领取。";
		end
		local nKinMoney = cKin.GetMoneyFund();
		if nAwardMoney + nKinMoney > Kin.MAX_KIN_FUND then
			return 0, "家族资金过多。";
		end
	else
		if not self.tbKinAward[me.szName] then
			return 0, "您并没有家族威望赛奖励。";
		end
		if me.GetTask(self.TASK_GROUPID, self.TASK_KINAWARD) == 1 then
			return 0, "您已经领取过奖励啦。";
		end
		local tbAward = self.tbKinAwardEx[self.tbKinAward[me.szName][1]];
		if not tbAward then
			return 0, "您没有奖励领取。";
		end		
		local nNeedBag = 0;
		local nBindMone = 0;
		for _, tb in pairs(tbAward) do
			if tb[1] == 4 then
				nNeedBag = nNeedBag + tb[2][5];
			elseif tb[1] == 2 then
				nBindMone = nBindMone + tb[2];
			end
		end
		if me.CountFreeBagCell() < nNeedBag  then
			return 0, string.format("Hành trang không đủ ，需要%s格背包空间。", nNeedBag);
		end
		if nBindMone + me.GetBindMoney() > me.GetMaxCarryMoney() then
			return 0, "您的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。";
		end
	end
	return 1;
end

--同步buff
function tbNewGateEvent:SetKinAward(dwKinId)
	self.tbKinAward[dwKinId][1] = 0;
end

-----------------------------------------------------------------------------------------------------------
--师兄师姐带你闯江湖

function tbNewGateEvent:CheckCanAddExp(pPlayer)
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));	
	local nServerStarTime = tonumber(os.date("%Y%m%d", tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))));
	if nNowDate < self.nSeniorStartTime or nNowDate > self.nSeniorEndTime or nServerStarTime < self.nServerStarLimit then
		return 0;
	end
	Setting:SetGlobalObj(pPlayer);
	if self:CheckIsXiaoBai(me) == 1 and self:CheckHasNeworOld(2) == 1 then
		Setting:RestoreGlobalObj();
		return 10;
	elseif self:CheckIsXiaoBai(me) == 0 and self:CheckHasNeworOld(1) == 1 then
		Setting:RestoreGlobalObj();
		return 5;
	end
	Setting:RestoreGlobalObj();
	return 0;	
end

--检查队伍中是否有新秀或大师兄大师姐
function tbNewGateEvent:CheckHasNeworOld(nType)
	if me.nTeamId <= 0 then
		return 0;
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);	
	for i = 1, #tbPlayerList do
		if me.nId ~= tbPlayerList[i] then
			local pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[i]);
			if pPlayer then
				if nType == 1 and self:CheckIsXiaoBai(pPlayer) == 1 then
					return 1;
				elseif nType == 2 and self:CheckIsXiaoBai(pPlayer) == 0 then
					return 1;
				end
			end
		end
	end
	return 0;
end

--是否是新秀
function tbNewGateEvent:CheckIsXiaoBai(pPlayer)
	local nCreatTime = Lib:GetDate2Time(pPlayer.GetRoleCreateDate());
	local nNowTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")));
	if nNowTime - nCreatTime >= 7*24*3600 then
		return 0;
	end
	return 1, 7 * 24 * 3600 + nCreatTime - nNowTime ;
end

--礼官对话
function tbNewGateEvent:OnDialogSenior()
	local szMsg = "师兄师姐带你闯江湖，畅游武侠情怀。";
	local tbOpt = {
		{"查询我的资格", self.QuerySenior, self, 1},
		{"我可以做的事情", self.QuerySenior, self, 2},
		{"Để ta suy nghĩ thêm"}
		}
	Dialog:Say(szMsg, tbOpt);
	return;
end

--查询和帮助
function tbNewGateEvent:QuerySenior(nType)
	local szMsg = "";
	if nType == 1 then
		if self:CheckIsXiaoBai(me) == 1 then
			local nTimesBaiHu = me.GetTask(self.TASK_GROUPID, self.TASK_BAIHUATIMES);
			if nTimesBaiHu < 3 then
				szMsg = "你是<color=yellow>江湖新秀<color>"..string.format(",<color=green>已经参加白虎次数：%s / 3<color>", nTimesBaiHu);
			else
				szMsg = "你是<color=yellow>江湖新秀<color>,<color=red>已经参加白虎次数：3 / 3<color>";
			end
		else 
			if me.nSex == 0 then
				szMsg = "你是<color=yellow>大师兄<color>";
			else
				szMsg = "你是<color=yellow>大师姐<color>";
			end
		end
	else
		szMsg = [[
		    初入江湖，还在为征战路途一个人孤军奋战而感到茫然无措么？不用担心，在这里有大师兄大师姐带你一路闯关，<color=yellow>组队<color>升级更欢乐，兄弟情深聚江湖。
		<color=green>篝火经验奖励<color>:
		    江湖新秀通过篝火可获得<color=yellow>经验提升10%<color>。
		    大师兄大师姐通过篝火获得<color=yellow>经验提升5%<color>。
		<color=green>挑战逍遥谷奖励<color>:
		    江湖新秀通过<color=yellow>逍遥谷2层以上<color>可获得（通关层数*100）的额外<color=yellow>绑定金币<color>奖励。
		    大师兄大师姐通过<color=yellow>逍遥谷2层以上<color>可获得（通关层数*80）的额外<color=yellow>绑定金币<color>奖励。
		<color=green>勇闯白虎堂奖励<color>:
		    江湖新秀与大师兄大师姐组队，前三次一起参加白虎堂，进入<color=yellow>白虎堂二层<color>时，均可获得<color=yellow>100000绑银返还卷和50000绑定银两<color>。
		    江湖新秀与大师兄大师姐组队，前三次一起参加白虎堂，进入<color=yellow>白虎堂三层<color>时，均可获得<color=yellow>2000绑金返还卷和500绑定金币<color>。
		]]		
	end
	Dialog:Say(szMsg);
end

--上线加称号
function tbNewGateEvent:OnLogin()
	local nFlag, nRemendTime = self:CheckIsXiaoBai(me);
	if me.FindSpeTitle(self.szTitleName) == 0 and nFlag == 1 then
		-- me.AddSpeTitle(self.szTitleName, GetTime() + nRemendTime, "pink");
		Player:SendMsgToKinOrTong(me, "Bạn nhận được danh hiệu và phần thưởng tân thủ.", 1);
		me.Msg("Bạn nhận được danh hiệu và phần thưởng tân thủ.");
	end
end

PlayerEvent:RegisterGlobal("OnLogin", tbNewGateEvent.OnLogin, tbNewGateEvent);

-----------------------------------------------------------------------------------------------------------
--密友关系你侬我侬
function tbNewGateEvent:OnDialogNewBack()
	local szMsg = "携手江湖，亲密度代表着各位之间的友好程度，亲密度越高，彼此之间的情谊越深厚，密友反馈，更是给予两个感情的见证。你侬我侬，亲密关系，有你不孤单。<color=green>第一次奇珍阁消费后可给予亲密度大于10且最亲密的玩家返还礼物<color>。\n<color=red>注：需奇珍阁消费的玩家作为队长领取礼物。<color>";
	local tbOpt = {
		{"领取返还绑金", self.GetNewBackAward, self, 1},
		{"查询自己在奇珍阁消费返还情况", self.QueryNewBack, self, 1},
		{"Để ta suy nghĩ thêm"},
		}
	Dialog:Say(szMsg, tbOpt);
	return;
end

--查询返还好友
function tbNewGateEvent:QueryNewBack()
	local szName = me.GetTaskStr(self.TASK_GROUPID, self.TASK_BACKCOIN);
	local nFlag = math.fmod(me.GetTask(self.TASK_GROUPID, self.TASK_BACKCOINFLAG), 10);
	if  szName~= "" then
		local szMsg ="你的返还好友是：<color=yellow>"..szName.."<color>。";
		if nFlag == 1 then
			szMsg = szMsg.."<color=green>（已经领取奖励）<color>";
		else
			szMsg = szMsg.."<color=red>（未领取奖励）<color>";
		end		
		Dialog:Say(szMsg);
		return;
	end
	Dialog:Say("你还没有在奇珍阁消费并返还好友礼物。");
	return;
end

--检查
function tbNewGateEvent:CheckCanGetBackAward()
	if me.IsCaptain() == 0 then
		return 1, "请队长来领取吧。";
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId); 
	if #tbPlayerList ~=  2 then 
		return 1, "只能两个人组队前来。";
	end 
	local pPlayer = nil;
	for i = 1, #tbPlayerList do 
		if me.nId ~= tbPlayerList[i] then
			pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[i]);
			if not pPlayer then
				return 1, "你的队友没在跟前。";
			end 
		end
	end
	local nMapId1, nX1,nY1 = me.GetWorldPos();
	local nMapId2, nX2,nY2 = pPlayer.GetWorldPos();
	if nMapId1 ~= nMapId2 or (nX1 - nX2) * (nX1 - nX2) + (nY1 - nY2) * (nY1 - nY2) > 100  then
		return 1, "你的队友没在跟前。";
	end
	local szName = me.GetTaskStr(self.TASK_GROUPID, self.TASK_BACKCOIN);
	if  szName == "" then
		return 1, "你还没有在奇珍阁消费并返还好友礼物。";
	end	
	if  szName ~= pPlayer.szName then
		return 1, "你的队友恐怕不是你返还的好友吧。";
	end
	local nFlag = math.fmod(me.GetTask(self.TASK_GROUPID, self.TASK_BACKCOINFLAG), 10);
	if nFlag ==  1 then
		return 1, "你太贪心了，已经领取过奖励了。";
	end
	if me.CountFreeBagCell() < 2 then
		return 1, "你的背包空间不足2 ô.";
	end
	if pPlayer.CountFreeBagCell() < 2 then
		return 1, "你队友的背包空间不足2 ô.";
	end
	return 0, nil, pPlayer;
end

--领取返还奖励
function tbNewGateEvent:GetNewBackAward()
	local nRet, szErrorMsg, pPlayer = self:CheckCanGetBackAward(); 
	if nRet == 1 then
		Dialog:Say(szErrorMsg);
		return;
	end
	local nCoin = math.min(me.GetTask(self.TASK_GROUPID, self.TASK_BACKCOINFLAG), 1000);
	local nFlag =pPlayer.GetTask(2093, 63);
	me.AddItem(18, 1, 1309, 1);	--1000点绑金
	me.AddItem(18, 1, 1352, 1);	--100000点绑银
	if nFlag ~= 1 then
		pPlayer.AddItem(18, 1, 1309, 1);
		pPlayer.AddItem(18, 1, 1352, 1);
		pPlayer.AddBindCoin(nCoin);
		pPlayer.SetTask(2093, 63, 1);
	else
		pPlayer.Msg("每个角色只能领取一次好友返还奖励。");
	end
	if me.IsFriendRelation(pPlayer.szName) == 1 then
		me.AddFriendFavor(pPlayer.szName, 300);
	end
	me.SetTask(self.TASK_GROUPID, self.TASK_BACKCOINFLAG, me.GetTask(self.TASK_GROUPID, self.TASK_BACKCOINFLAG) + 1);	
end

--第一次买东西
function tbNewGateEvent:OnFirstBuy(pPlayer, nTotalCoin)	
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));	
	local nServerStarTime = tonumber(os.date("%Y%m%d", tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))));
	if nNowDate < self.nFriendBackStarTime or nNowDate > self.nFriendBackEndTime or nServerStarTime < self.nServerStarLimit then	
		return 0;
	end
	local szName = pPlayer.GetTaskStr(self.TASK_GROUPID, self.TASK_BACKCOIN);	
	if szName ~= "" then
		return;
	end
	local nMaxPoint = 0;
	local szPlayerName = "";
	local tbFriendList = pPlayer.GetRelationList(Player.emKPLAYERRELATION_TYPE_BIDFRIEND);	
	for _, szName in pairs(tbFriendList or {}) do
		if pPlayer.GetFriendFavor(szName) > nMaxPoint then
			nMaxPoint = pPlayer.GetFriendFavor(szName);
			szPlayerName = szName;
		end
	end
	if szPlayerName ~= "" and nMaxPoint > 10 then
		 pPlayer.SetTaskStr(self.TASK_GROUPID, self.TASK_BACKCOIN, szPlayerName);
		 pPlayer.SetTask(self.TASK_GROUPID, self.TASK_BACKCOINFLAG, nTotalCoin * 10);
		 KPlayer.SendMail(szPlayerName, "好友消费返还", string.format("您的好友<color=yellow>%s<color>在奇珍阁消费，你可以和他组队去<color=yellow>礼官<color>处领取返还奖励。", pPlayer.szName));
	end
end
