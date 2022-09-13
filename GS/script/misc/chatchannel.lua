-- 聊天频道（传声海螺）
-- wangbin 2008.06.03 13:39

ChatChannel.CHANNEL_NEARBY	= 1;
ChatChannel.CHANNEL_GLOBAL	= 2;
ChatChannel.CHANNEL_WORLD	= 3;
ChatChannel.CHANNEL_CITY	= 4;
ChatChannel.CHANNEL_FRIEND	= 5;
ChatChannel.CHANNEL_TEAM	= 6;
ChatChannel.CHANNEL_TONG	= 7;
ChatChannel.CHANNEL_FACTION	= 8;
ChatChannel.CHANNEL_KIN		= 9;
ChatChannel.CHANNEL_SERVER	= 10;
ChatChannel.CHANNEL_GM		= 11;


-- 1:上次公聊的日期，YYYYMMDD; 
-- 2:付费次数*1000+免费次数; 
-- 3:上次聊天的级别；
-- 4:跨服聊天次数
ChatChannel.TASK_CHAT		  	= 2030;


-- 获取免费公聊的次数
function ChatChannel:GetFreeCount(nLevel)
	if (nLevel < 30) then		-- [1, 30)
		return 0
	elseif (nLevel < 40) then	-- [30, 40)
		return 3
	elseif (nLevel < 50) then	-- [40, 50)
		return 4
	elseif (nLevel < 60) then	-- [50, 60)
		return 5
	elseif (nLevel < 70) then	-- [60, 70)
		return 6
	elseif (nLevel < 80) then	-- [70, 80)
		return 7
	elseif (nLevel < 90) then	-- [80, 90)
		return 8
	elseif (nLevel < 100) then	-- [90, 100)
		return 9
	else
		return 10
	end
end

function ChatChannel:GetChatCount(pPlayer)
	local nTaskCount = pPlayer.GetTask(ChatChannel.TASK_CHAT, 2)
	local nPayCount = math.floor(nTaskCount / 1000)	-- 付费次数
	local nFreeCount = nTaskCount % 1000			-- 免费次数
	return nFreeCount, nPayCount
end

function ChatChannel:SetChatCount(pPlayer, nFreeCount, nPayCount)
	pPlayer.SetTask(ChatChannel.TASK_CHAT, 2, nPayCount * 1000 + nFreeCount)
end

function ChatChannel:CheckPermission(pPlayer, nChannelType)
	if (not pPlayer or not nChannelType) then
		return 0;
	end
	
	local nLevel = pPlayer.nLevel	
	if (pPlayer.IsForbidChat() ~= 0) then
		pPlayer.Msg("您被禁言了，暂时不能聊天。");
		return 0;
	end
	--  check是否可以使用该频道
	if (0==pPlayer.CanUseChatChannel(nChannelType))then
		pPlayer.Msg("你目前所在地可能属于特殊区域，不能使用此聊天频道。");
		return 0;
	end
	
	if nChannelType == self.CHANNEL_WORLD then
		if (nLevel < 30) then
			pPlayer.Msg("当您到30级以后才能使用公聊。")
			return 0
		else
			-- 公聊扣钱
			return self:PayForChat(pPlayer, nChannelType);
		end
	elseif nChannelType == self.CHANNEL_CITY then
		if (nLevel < 55) then
			pPlayer.Msg("当您到55级以后才能使用城聊。")
			return 0
		else
			return 1
		end
	elseif nChannelType == self.CHANNEL_GLOBAL then
		if (nLevel < 30) then
			pPlayer.Msg("当您到30级以后才能使用跨服聊天。")
			return 0
		else
			-- 跨服聊天扣钱
			return self:PayForGlobalChat(pPlayer, nChannelType);
		end	
	end
	return 1;
end

function ChatChannel:PayForGlobalChat(pPlayer, nChannelType)
	local nTaskCount = pPlayer.GetTask(ChatChannel.TASK_CHAT, 4);
	if (nTaskCount <= 0) then
	pPlayer.Msg("您没有大区公聊次数了，在奇珍阁购买千里传音可以增加大区公聊的次数。")
		return 0;
	end
	nTaskCount = nTaskCount - 1;
	pPlayer.SetTask(ChatChannel.TASK_CHAT, 4, nTaskCount);
	pPlayer.Msg("您还有" .. nTaskCount .. "次大区公聊次数。")
	return 1;
end

function ChatChannel:PayForChat(pPlayer, nChannelType)
	
	if (nChannelType ~= self.CHANNEL_WORLD) then
		return 0;
	end
	
	local nLevel = pPlayer.nLevel
	local nTaskDate = pPlayer.GetTask(ChatChannel.TASK_CHAT, 1)
	local nLastYear = math.floor(nTaskDate / 10000)
	local nTmp 		= nTaskDate - 10000 * nLastYear
	local nLastMon  = math.floor(nTmp / 100)
	local nLastDay  = nTmp % 100
	
	local nFreeCount, nPayCount = ChatChannel:GetChatCount(pPlayer)
	local nCurrYear, nCurrMon, nCurrDay = LocalTime(3)
	local nLastLevel = pPlayer.GetTask(ChatChannel.TASK_CHAT, 3)
	if (nLastLevel ~= nLevel or
		nLastYear ~= nCurrYear or
		nLastMon ~= nCurrMon or
		nLastDay ~= nCurrDay) then
		-- 重新初始化免费次数
		nFreeCount = ChatChannel:GetFreeCount(nLevel)
		ChatChannel:SetChatCount(pPlayer, nFreeCount, nPayCount)
	end

	if (nFreeCount == 0 and nPayCount == 0) then
		pPlayer.Msg("您今天的免费公聊次数已经用完，您可以在奇珍阁购买传声海螺增加公聊次数。")
		return 0
	end

	if (nFreeCount > 0) then
		nFreeCount = nFreeCount - 1
		if (nPayCount > 0) then
			pPlayer.Msg("您今天的免费公聊次数还有" .. nFreeCount .. "条，您的附加公聊次数还有" .. nPayCount .. "条。")
		else
			pPlayer.Msg("您今天的免费公聊次数还有" .. nFreeCount .. "条，您可以在奇珍阁购买传声海螺增加公聊次数。")
		end
	else
		nPayCount = nPayCount - 1
		pPlayer.Msg("您还有" .. nPayCount .. "次附加公聊次数。")
	end
	
	if (nLastYear ~= nCurrYear or nLastMon ~= nCurrMon or nLastDay ~= nCurrDay) then
		nTaskDate = nCurrYear * 10000 + nCurrMon * 100 + nCurrDay
		pPlayer.SetTask(ChatChannel.TASK_CHAT, 1, nTaskDate)
	end
	if (nLastLevel ~= nLevel) then
		pPlayer.SetTask(ChatChannel.TASK_CHAT, 3, nLevel)
	end
	ChatChannel:SetChatCount(pPlayer, nFreeCount, nPayCount)

	return 1
end
