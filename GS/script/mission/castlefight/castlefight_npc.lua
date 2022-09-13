-- castlefight_npc.lua
-- zhouchenfei
-- 城堡战控制类
-- 2010/11/6 13:53:08

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

function CastleFight:OnDialog_SignUp(nSure)
	local tbConsole = self:GetConsole();
	
	if tbConsole:CheckState() ~= 1 then
		Dialog:Say("目前活动尚未开放。\n\n开放时间：\n<color=yellow>1月18日-2月17日\n上午10:00-晚上11:30<color>\n整点和半点开始报名，报名时间5分钟")
		return 0;
	end

	if tbConsole:IsOpen() ~= 1 then
		Dialog:Say("不在报名时间段。\n\n报名时间：\n上午10:00-晚上11:30\n<color=yellow>整点和半点开始报名，报名时间5分钟<color>");
		return 0;
	end
	
	local tbCfg = self:GetConsoleCfg();
	
	if me.nTeamId <= 0 then
		if nSure == 1 then
			self:OnDialogApplySignUp();
			return 0;
		end
		
		local tbPlayerList = {me.nId};

		if tbConsole:IsFull(#tbPlayerList) == 0 then
			Dialog:Say("活动报名人数已满。");
			return 0;
		end
		
		local nFlag, szMsg = self:CheckPlayer(me);
		
		if (nFlag == 0) then
			Dialog:Say(szMsg);
			return 0;
		end

		local tbOpt = {
			{"我要加入", self.OnDialog_SignUp, self, 1},
			{"Để ta suy nghĩ lại"},
			};
		Dialog:Say("你想加入决战夜岚关的行列吗？", tbOpt);
		return 0;
	end
	

	if me.IsCaptain() == 0 then
		Dialog:Say("你不是队长哦，去叫你们队长来报名吧。");
		return 0;
	end
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	
	if nSure == 1 then
		self:OnDialogApplySignUp(tbPlayerList);
		return 0;
	end
	
	local tbOpt = {
		{"我们要前往", self.OnDialog_SignUp, self, 1},
		{"我们再考虑考虑"},
		};
	Dialog:Say(string.format("你们队伍想加入决战夜岚关的行列吗？队伍有<color=yellow>%s人<color>，请确定队员在这里。", #tbPlayerList), tbOpt);
	return 0;
end

function CastleFight:IsSignUpByAward(pPlayer)
	return pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_AWARD);
end

function CastleFight:IsSignUpByTask(pPlayer)
	--self:TaskDayEvent();
	local nCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT);
	local nExCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_EXCOUNT)
	if nCount <= 0 and nExCount <= 0 then
		return 0, 0 ,0;
	end
	return nCount + nExCount, nCount, nExCount;
end

function CastleFight:OnDialogApplySignUp(tbPlayerList)	
	if not tbPlayerList then
		GCExcute{"CastleFight:ApplySignUp",{me.nId}};
		return 0;
	end
	local tbMTCfg = self:GetConsoleCfg();
	
	if (not tbMTCfg) then
		Dialog:Say("此活动不存在。");
		return 0;
	end
	
	if Lib:CountTB(tbPlayerList) > tbMTCfg.nMaxTeamMember then
		Dialog:Say("你们队伍人太多了，只能是四个人前去的。");
		return 0;
	end

	local tbConsole = self:GetConsole();
	if tbConsole:IsFull(#tbPlayerList) == 0 then
		Dialog:Say("活动报名人数已满。");
		return 0;
	end	

	local nMapId, nPosX, nPosY	= me.GetWorldPos();
	for _, nPlayerId in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			Dialog:Say("你们队伍有人没来啊，我们还不能出发，等等他吧。");
			return 0;
		end		
		
		local nFlag, szMsg = self:CheckPlayer(pPlayer);
		
		if (0 == nFlag) then
			Dialog:Say(string.format("%s%s", pPlayer.szName, szMsg));
			return 0;
		end
		
		local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
		local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
		if nMapId2 ~= nMapId or nDisSquare > 400 then
			Dialog:Say("您的所有队友必须在这附近。");
			return 0;
		end
		if not pPlayer or pPlayer.nMapId ~= nMapId then
			Dialog:Say("您的所有队友必须在这附近。");
			return 0;
		end
	end
	GCExcute{"CastleFight:ApplySignUp", tbPlayerList};
	return 0;
end

function CastleFight:CheckPlayer(pPlayer)
	local tbCfg = self:GetConsoleCfg();
	if pPlayer.nLevel < tbCfg.nMinLevel then
		return 0, string.format("等级未达到%s级，无法参加本次活动！", tbCfg.nMinLevel);
	end

	if (pPlayer.IsFreshPlayer() == 1) then
		return 0, "尚未加入门派，无法参加本次活动！";
	end

	if self:IsSignUpByAward(pPlayer) > 0 then
		return 0, "上次参加了决战夜岚关活动，先拿上礼物再打下一场吧！";
	end		
	if self:IsSignUpByTask(pPlayer) == 0 then
		return 0, "<color=red>没有挑战次数了。<color>\n\n在月影之石商店，用1个月影之石可换得1个<color=yellow>夜岚明灯<color>，使用后可获得3次挑战次数。";
	end
	
	local nTotal = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
	if (nTotal >= CastleFight.DEF_MAX_TOTAL_NUM) then
		return 0, string.format("<color=red>已经参加满%s次，无法再参与了。<color>\n\n您可打开<color>排行榜<color>查看当前“夜岚关荣誉”的排名，所有活动结束后，秦洼将据此发放丰厚的<color=yellow>最终奖励<color>。", CastleFight.DEF_MAX_TOTAL_NUM);
	end
	
	if pPlayer.GetEquip(Item.EQUIPPOS_MASK) then
		return 0, "不允许戴面具参加，请把面具摘下再来找我吧。";
	end
	
	if (tbCfg.nBagNeedFree and tbCfg.nBagNeedFree > 0) then
		if (pPlayer.CountFreeBagCell() < tbCfg.nBagNeedFree) then
			return 0, string.format("Hành trang không đủ chỗ trống%s，不能进去！", tbCfg.nBagNeedFree);
		end
	end

	local nFlag, szMsg = self:CheckItem(pPlayer);
	if (0 == nFlag) then
		return 0, szMsg;
	end
	return 1;
end

function CastleFight:CheckItem(pPlayer)
	local tbMTCfg = self:GetConsoleCfg();
	if (tbMTCfg) then
		if (tbMTCfg.tbJoinItem and #tbMTCfg.tbJoinItem > 0) then
			local nEnterFlag = self:CheckEnterCount(pPlayer, tbMTCfg.tbJoinItem);
			local szMsg = "";
			local nNameCount = 0;
			for _, tbItemInfo in pairs(tbMTCfg.tbJoinItem) do
				if (tbItemInfo.tbItem) then
					local szName = self:GetItemName(tbItemInfo.tbItem);
					if (szName and string.len(szName) > 0) then
						if (nNameCount > 0) then
							szMsg = string.format("%s<color=white>或<color>", szMsg);
						end
						
						szMsg = string.format("%s%s", szMsg, szName);
						nNameCount = nNameCount + 1;
					end
				end
			end
			if (string.len(szMsg) <= 0) then
				szMsg = "活动道具";
			end
			if (nEnterFlag <= 0) then
				return 0, string.format("身上没有<color=yellow>%s<color>，不能参加活动", szMsg);
				
			elseif (nEnterFlag > 1) then
				return 0, string.format("身上<color=yellow>%s<color>携带数量只能是一个，请取出背包中多余的道具，再来参加活动吧！", szMsg);
			end
			
			local nItemFlag, szItemMsg = CastleFight:ProcessItemCheckFun(pPlayer, tbMTCfg.tbJoinItem);
			if (0 == nItemFlag) then
				return 0, szItemMsg;
			end
		end
	end
	return 1;
end
