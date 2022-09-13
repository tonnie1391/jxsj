-- 文件名  : girl_vote_new_meigui.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-12 03:29:52
-- 描述    : 
local tbItem = Item:GetClass("girl_vote_new_meigui");
SpecialEvent.Girl_Vote_New = SpecialEvent.Girl_Vote_New or {};
local tbGirl = SpecialEvent.Girl_Vote_New;
function tbItem:OnUse()
	local tbNpc = Npc:GetClass("girl_dingding");
	local nState = tbGirl:GetState();
	if nState ~= tbGirl.emVOTE_STATE_SIGN then
		Dialog:Say("你好，巾帼英雄评选阶段已经结束。");
		return;
	end
	
	local nCheck, szGirlName = self:CheckIsVote(); 
	local szMsg = [[<color=yellow>“巾帼英雄”<color>评选拉开帷幕，谁能最终挺进决赛，荣登第一宝座？最精彩的赛事，最浪漫的评选方式，《剑侠世界》巾帼英雄海选10月12日正式开始报名，所有女玩家都有参加机会，拉风光环、面具、称号以及玄晶等超级大奖在向你招手，快来参加吧！]];
--	local tbOpt = {};
--	table.insert(tbOpt,{"<color=yellow>给我的美女队友投票<color>", tbNpc.VoteTickets, tbNpc});
--	table.insert(tbOpt,{"Ta chỉ xem qua Xóa bỏ"});	
--	Dialog:Say(szMsg, tbOpt);
	if nCheck == 0 then
		return;
	end
	tbGirl:VoteTickets2(szGirlName,1);
end


function tbItem:CheckIsVote()
	local tbAllPlayerId = KTeam.GetTeamMemberList(me.nTeamId);
	local tbPlayerId = me.GetTeamMemberList();
	if not tbPlayerId or not tbAllPlayerId or #tbAllPlayerId ~= 2 or #tbPlayerId ~= 2 then
		Dialog:Say("单独与美女组队，并且要在附近才能进行投票哦！");
		return 0;
	end
	local szGirlName = "";
	for _, pPlayer in pairs(tbPlayerId) do
		if pPlayer.nId ~= me.nId then
			szGirlName = pPlayer.szName;
			if pPlayer.nSex ~= 1 then
				Dialog:Say("玫瑰花只能送给女玩家！");
				return 0;
			end
			if tbGirl:IsHaveGirl(szGirlName) == 0 then
				Dialog:Say("该美女还未报名参赛，不能投票！叫她去临安丁丁处报名吧。");
				return 0;
			end
			break;
		end
	end
	return 1, szGirlName;
end