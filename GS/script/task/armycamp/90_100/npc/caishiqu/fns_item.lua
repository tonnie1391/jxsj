----------------------------------------
-- 可消除百斩吉金钟罩的道具
-- ZhangDeheng
-- 2008/10/28  10:41
----------------------------------------

local tbFnsItem = Item:GetClass("chickenblood");

tbFnsItem.SKILL_ID  	= 1123;
tbFnsItem.ADVICE_RANGE	= 41; 	-- 用于判断局部范围内是否有百斩吉

-- 判断一个玩家是否在指定的范围内
function tbFnsItem:IsPlayerInRange(pPlayer, nRange)
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, nRange);
	if not tbPlayerList then
		return false;
	end;
	
	for _, player in ipairs(tbPlayerList) do
		if pPlayer.nId == player.nId then
			return true;
		end;
	end;
	return false;
end;

-- 一个范围内的队伍中成员显示消息
function tbFnsItem:Msg2Team(szMsg)
	if (MODULE_GAMESERVER) then
		local tbTeamMemberList = me.GetTeamMemberList();
		if tbTeamMemberList then
			for _, pPlayer in ipairs(tbTeamMemberList) do
				-- 仅向在100范围内的队伍中玩家显示消息
				if self:IsPlayerInRange(pPlayer, 100) then
					Dialog:SendBlackBoardMsg(pPlayer, szMsg);	
				end;
			end;
		end;
		Dialog:SendBlackBoardMsg(me, szMsg);		
	end;
end

function tbFnsItem:OnUse()
	local bExist = false;
	-- 判断玩家周围是否有百斩吉存在
	local tbNpcList = KNpc.GetAroundNpcList(me, self.ADVICE_RANGE);
	if tbNpcList then
		for _, pNpc in ipairs(tbNpcList) do
			if 4111 == pNpc.nTemplateId then
				bExist = true;
			end;
		end;
	end
	
	if bExist then -- 存在
		if me.nFightState == 1 then -- 是否处于战斗状态
			me.CastSkill(tbFnsItem.SKILL_ID, 1, -1, me.GetNpc().nIndex);
			local szMsg = "金钟罩已破！"
			self:Msg2Team(szMsg);
			return 1;
		else  -- 非战斗状态
			local szMsg = "非战斗状态，不能使用该物品！"
			Dialog:SendInfoBoardMsg(me, szMsg);
			return 0;
		end;
	else -- 不存在
		local szMsg = "此物只有对百斩吉使用才有效！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return 0;
	end;	
end
