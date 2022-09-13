-- 文件名  : xoyogame_achieve.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-14 14:22:11
-- 描述    : 逍遥谷成就
XoyoGame.Achievement = XoyoGame.Achievement or {};
local tbAchieve = XoyoGame.Achievement;

--参加逍遥谷次数
function tbAchieve:JoinGames(pPlayer)	
	Achievement:FinishAchievement(pPlayer, 180);
	Achievement:FinishAchievement(pPlayer, 181);
	Achievement:FinishAchievement(pPlayer, 182);
	Achievement:FinishAchievement(pPlayer, 183);
	Achievement:FinishAchievement(pPlayer, 184);	
end


--参加逍遥谷次数
function tbAchieve:PassGames(pPlayer,nLevel)
	if nLevel >= XoyoGame.ROOM_EASY_BEG_LEVEL then -- 简单逍遥谷
		return;
	end
	if nLevel >= 2 and nLevel <= XoyoGame.ROOM_MAX_LEVEL - 3 then
		Achievement:FinishAchievement(pPlayer, 183 + nLevel);
	elseif nLevel > XoyoGame.ROOM_MAX_LEVEL - 3 then	--逍遥6关后的通关成就
		Achievement:FinishAchievement(pPlayer, 365 + nLevel);
	end
end

function tbAchieve:XoyoCardNum(pPlayer,nCardNum)
	local nType = 0;
	if nCardNum < 24 then
		nType = 0;
	elseif nCardNum < 36 then
		nType = 1;
	elseif nCardNum <  XoyoGame.XoyoChallenge:GetTotalCardNum() then
		nType = 2;
	else
		nType = 3;
	end
	
	for i = 1, nType do
		Achievement:FinishAchievement(pPlayer, 190 + i);
	end
end
		 
function tbAchieve:XoyoRank(pPlayer,nRank)
	local nType = 0;
	if nRank > 3000 then
		nType = 0;
	elseif nRank > 500 then
		nType = 1;
	elseif nRank > 100 then
		nType = 2;
	elseif nRank > 10 then
		nType = 3;
	elseif nRank > 1 then
		nType = 4;
	else
		nType = 5;
	end
	
	for i = 1, nType do
		Achievement:FinishAchievement(pPlayer, 193 + i);
	end
	if nType > 3 then
		Achievement:FinishAchievement(pPlayer, 199);
	end
end