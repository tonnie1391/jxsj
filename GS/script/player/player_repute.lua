Require("\\script\\player\\player.lua");

-- 声望对应的称号
Player.tbTitleForRepute		= {};
Player.CHECKREPUTETITLETIME	= 1231257600;  -- 01/07/09 00:00:00

function Player:LoadReputeTitle()
	local tbTitleForRepute = {};
	local tbData = Lib:LoadTabFile("\\setting\\player\\playertitle_repute.txt");
	for _, tbRow in ipairs(tbData) do
		local nCampId	= tonumber(tbRow["CAMPID"]);
		local nClassId	= tonumber(tbRow["CLASSID"]);
		local nLevel	= tonumber(tbRow["LEVEL"]);
		local tbValue	= Lib:SplitStr(tbRow["TITLEPARAM"], ",");
		if (tbValue and #tbValue > 0) then
			local tbParam = {};
			for i=1, #tbValue do
				tbParam[i] = tonumber(tbValue[i]);
			end
			if (not tbTitleForRepute[nCampId]) then
				tbTitleForRepute[nCampId] = {};
			end
			
			if (not tbTitleForRepute[nCampId][nClassId]) then
				tbTitleForRepute[nCampId][nClassId] = {};
			end
			tbTitleForRepute[nCampId][nClassId][nLevel] = tbParam;
		end
	end
	self.tbTitleForRepute = tbTitleForRepute;
end

function Player:AddReputeTitle(nCampId, nClassId, nLevel)
	if (not self.tbTitleForRepute or 
		not self.tbTitleForRepute[nCampId] or
		not self.tbTitleForRepute[nCampId][nClassId] or
		not self.tbTitleForRepute[nCampId][nClassId][nLevel]) then
			return;
	end
	local tbParam = self.tbTitleForRepute[nCampId][nClassId][nLevel];
	if (1 == me.FindTitle(unpack(tbParam))) then
		return;
	end
	me.AddTitle(unpack(tbParam));
end

-- 上线时检查是否有称号没加上
function Player:ProcessAllReputeTitle(pPlayer)
	local nLastOutTime = me.GetLastLogoutTime();
	if (not nLastOutTime) then
		self:WriteReputeLog("ProcessAllReputeTitle", pPlayer.szName .. " have no last logout time!!!");
		return;
	end
	
	-- 在此之后离线的都不检查
	if (nLastOutTime >= self.CHECKREPUTETITLETIME) then
		return;
	end
	
	if (not self.tbTitleForRepute) then
		self:WriteReputeLog("ProcessAllReputeTitle", pPlayer.szName .. " is not loading tbTitleForRepute table !!!");
		return;
	end

	for nCampId, tbCamp in pairs(self.tbTitleForRepute) do
		if (tbCamp) then
			for nClassId, tbClass in pairs(tbCamp) do
				if (tbClass) then
					for nLevel, tbParam in pairs(tbClass) do
						if (tbParam) then
							local nNowLevel = pPlayer.GetReputeLevel(nCampId, nClassId);
							if (nNowLevel) then
								if (nLevel == nNowLevel) then
									if (0 == pPlayer.FindTitle(unpack(tbParam))) then
										pPlayer.AddTitle(unpack(tbParam));
									end
								else -- 如果不是可以检查看看是否有称号需要去掉
									-- pPlayer.RemoveTitle(unpack(tbParam));
								end
							end
						end
					end
				end
			end
		end
	end
	
end

function Player:WriteReputeLog(...)
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Player", "ReputeTitle", unpack(arg));
end

-- 增加声望的回调，成就用
-- 注意：并不一定增加成功，比如说某项成就已经达到上限不能增加了，但是也会回调到这里
function Player:AfterAddRepute(nCampId, nClassId, nPoint)
	if (not nCampId or not nClassId or not nPoint) then
		return;
	end
	
	Achievement:OnAddRepute(me, nCampId, nClassId, nPoint);
	self:RepairAchievement_Repute();
end

function Player:RepairAchievement_Repute()
	local nLevel = 0;
	-- 家族关卡
	nLevel = me.GetReputeLevel(4, 1);
	if (nLevel >= 9 and Achievement:CheckFinished(54) == 0) then
		Achievement:__FinishAchievement(54);
	end
	
	-- 军营
	nLevel = me.GetReputeLevel(1, 2);
	if (nLevel >= 7 and Achievement:CheckFinished(242) == 0) then
		Achievement:__FinishAchievement(242);
	end
end

-- 增加指定声望数值之后返回声望的等级
function Player:GetReputeLevelByAddValue(nCampId, nClassId, nPoint)
	if not nCampId or not nClassId or not nPoint then
		return -1;
	end
	local tbReputeSetting = KPlayer.GetReputeInfo();		-- 获得声望配置信息
	if not tbReputeSetting then
		return -1;
	end
	local nLevel = me.GetReputeLevel(nCampId, nClassId);
	if nPoint == 0 then
		return nLevel;
	end
	local nMaxLevel = #tbReputeSetting[nCampId][nClassId];
	if nLevel >= nMaxLevel then
		return nMaxLevel;
	end
	local nValue = me.GetReputeValue(nCampId, nClassId);
	local nAssumeValue = nValue + nPoint;
	for nIndex = nLevel, nMaxLevel do
		nAssumeValue = nAssumeValue - tbReputeSetting[nCampId][nClassId][nIndex].nLevelUp;
		if nAssumeValue < 0 then
			return nIndex;
		elseif nAssumeValue == 0 then
			return nIndex + 1;
		end
	end
	return nMaxLevel;
end

if (MODULE_GAMESERVER) then
	Player:LoadReputeTitle();
	PlayerEvent:RegisterGlobal("OnAddReputeTitle", Player.AddReputeTitle, Player);
	PlayerEvent:RegisterGlobal("AfterAddRepute", Player.AfterAddRepute, Player);
end
