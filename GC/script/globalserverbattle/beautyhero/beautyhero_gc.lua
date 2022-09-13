-- 文件名  : beautyhero_gc.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-19 17:14:25
-- 描述    : 

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\globalserverbattle\\beautyhero\\beautyhero_def.lua");


-- 开启活动
function BeautyHero:StartMatch_GC()
	local nIndex = self:GetMatchIndex();  --时间到了才开启
	if nIndex > 0 then	
--		GlobalExcute{"BeautyHero:StartMatch_GS",nIndex}; -- 直接传index 给GS？ TODO
		self:StartMatch_GC_EX(nIndex);
	end
	
end

--可以用指令开启
function BeautyHero:StartMatch_GC_EX(nIndex)
	GlobalExcute{"BeautyHero:StartMatch_GS",nIndex}; -- 直接传index 给GS？ TODO
end

-- 一般由副本自行关闭 但提供强行关闭的指令
function BeautyHero:EndMatch_ALL_GC()
	GlobalExcute{"BeautyHero:EndMatch_GS"};
end


function BeautyHero:EndMatchFlag_GC(nSeries)
	GlobalExcute{"BeautyHero:EndMatchFlag_GS",nSeries};
end

function BeautyHero:UpdateBeautyHeroLadder()
	PlayerHonor:OnSchemeUpdateBeautyHeroHonorLadder();
end

--增加跨服活动奖励 -- 本服领取 GS
function BeautyHero:AddGlobalRestAward(nPlayerId,nAddBindCoin)
	local nCurCoin = GetPlayerSportTask(nPlayerId, BeautyHero.TSK_GB_PLAYER_GROUP, BeautyHero.TSK_GB_PLAYER_REST_AWARD) or 0;
	nCurCoin = nCurCoin + nAddBindCoin;
	SetPlayerSportTask(nPlayerId, BeautyHero.TSK_GB_PLAYER_GROUP, BeautyHero.TSK_GB_PLAYER_REST_AWARD,nCurCoin);
end

-- 玩家活动奖励 GS
function BeautyHero:SetGlobalMatchAward(nPlayerId,nRank)
	SetPlayerSportTask(nPlayerId, BeautyHero.TSK_GB_PLAYER_GROUP, BeautyHero.TSK_GB_PLAYER_MATCH_AWARD,nRank);
end


-- TODO
function BeautyHero:FinalWinner_GC(tb16thPlayer)
	if GLOBAL_AGENT then
		GC_AllExcute({"BeautyHero:UpdateHelpTable",  tb16thPlayer});
	end
end


-- 帮助锦囊
function BeautyHero:UpdateHelpTable(tb16thPlayer)
	
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	local tbPlayerRank = BeautyHero:GetMatchPlayerRank_Final(tb16thPlayer);
	local szMsg = string.format([[
跨服巾帼英雄PK赛顺利结束!

<color=green>冠军：  <color> <color=yellow>%s<color>

<color=green>亚军：  <color> <color=yellow>%s<color>

<color=green>四强：  <color> <color=yellow>%s<color>

<color=green>八强：  <color> <color=yellow>%s<color>

<color=green>十六强：<color> <color=yellow>%s<color>
]], tbPlayerRank[5] or "无",tbPlayerRank[4] or "无",
	tbPlayerRank[3] or "无",tbPlayerRank[2] or "无"
	,tbPlayerRank[1] or "无");
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_BEAUTYHERO, "巾帼英雄赛战报", szMsg, nEndTime, nAddTime);
end

function BeautyHero:GetMatchPlayerRank_Final(tb16player)
	local tbPlayerRank = {}; 
	local tbRankNum    = {};
	for _, tbInfo in pairs(tb16player) do 
		tbRankNum[tbInfo.nWinCount + 1] = tbRankNum[tbInfo.nWinCount + 1] or 0;
		tbRankNum[tbInfo.nWinCount + 1] = tbRankNum[tbInfo.nWinCount + 1] + 1;
	  	if not tbPlayerRank[tbInfo.nWinCount + 1] then
	  		tbPlayerRank[tbInfo.nWinCount + 1] = Lib:StrFillL(tbInfo.szName, 16);
	  	else
	  		tbPlayerRank[tbInfo.nWinCount + 1] = tbPlayerRank[tbInfo.nWinCount + 1].."   "..(Lib:StrFillL(tbInfo.szName, 16));
	 	end
	 	
	 	if tbRankNum[tbInfo.nWinCount + 1] % 2 == 0 then
	 		tbPlayerRank[tbInfo.nWinCount + 1] = tbPlayerRank[tbInfo.nWinCount + 1] .. "\n      ";
	 	end
	end
	return tbPlayerRank;	
end

-- 跨服 全局服 消息
function BeautyHero:GlobalMsg_Center(szMsg)
	if GLOBAL_AGENT then
		Dialog:GlobalNewsMsg_Center(szMsg);
		Dialog:GlobalMsg2SubWorld_Center(szMsg);
	end
end
