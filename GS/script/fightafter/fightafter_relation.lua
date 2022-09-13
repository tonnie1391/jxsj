-- 文件名  : fightafter_relation.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-30 09:47:54
-- 描述    : 
-- 描述    : 战后系统 玩家之间关系部分 其实可以放在kluaplayer下 先这样吧

if (MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\fightafter\\fightafter_def.lua");



--[[
FightAfter.emRELATION_NONE		   			= 0;   -- 无
FightAfter.emRELATION_TMPFRIEND   			= 1;   -- 临时好友
FightAfter.emRELATION_BIDFRIEND   			= 2;   -- 普通好友
FightAfter.emRELATION_TONGFRIEND			= 3;   -- 帮会好友
FightAfter.emRELATION_KINFRIEND				= 4;   -- 家族好友
FightAfter.emRELATION_COUPLE				= 5;   -- 夫妻
FightAfter.emRELATION_BLACK					= 6;   -- 黑名单
FightAfter.emRELATION_ENEMEY				= 7;   -- 仇人
--]]

function FightAfter:GetRelationTypeAndFavorlevel(pPlayer, szRelationPlayerName)
	local nRelationType = self:_GetRelationType(pPlayer,szRelationPlayerName);	
	local nFavorLevel   = 0;
	if nRelationType == self.emRELATION_BIDFRIEND or nRelationType == self.emRELATION_COUPLE then
		nFavorLevel = pPlayer.GetFriendFavorLevel(szRelationPlayerName);
	end
	
	
	if nRelationType == self.emRELATION_BIDFRIEND or nRelationType == self.emRELATION_TMPFRIEND then
		local tbInfo = GetPlayerInfoForLadderGC(szRelationPlayerName);
		if tbInfo then
			if pPlayer.dwKinId ~= 0 and pPlayer.dwKinId == tbInfo.nKinId then
				nRelationType = self.emRELATION_KINFRIEND;
			elseif pPlayer.dwTongId ~= 0 and pPlayer.dwTongId == tbInfo.nTongId then
				nRelationType = self.emRELATION_TONGFRIEND;
			end
		end		
	end
		
	return nRelationType, nFavorLevel;
end

function FightAfter:_GetRelationType(pPlayer, szRelationPlayerName)	
--	if pPlayer.IsCouple(szRelationPlayerName) == 1 then
--		return  self.emRELATION_COUPLE;
--	end
	
	if pPlayer.IsFriendRelation(szRelationPlayerName) == 1 then
		return self.emRELATION_BIDFRIEND;	
	end

	if pPlayer.IsHaveRelation(szRelationPlayerName,Player.emKPLAYERRELATION_TYPE_TMPFRIEND, 1) == 1 then
		return self.emRELATION_TMPFRIEND;
	end
	
	if pPlayer.IsHaveRelation(szRelationPlayerName,Player.emKPLAYERRELATION_TYPE_BLACKLIST, 1) == 1 then
		return self.emRELATION_BLACK;
	end	
	
	if pPlayer.IsHaveRelation(szRelationPlayerName,Player.emKPLAYERRELATION_TYPE_ENEMEY, 1) == 1 then
		return self.emRELATION_ENEMEY;
	end		
	return self.emRELATION_NONE;
end

function FightAfter:InitRelationFile()
	local tbFile = Lib:LoadTabFile(self.RelationInfo);
	if not tbFile then
		print("[ERR] FightAfter InitRelationFile Error", self.RelationInfo);
		return;
	end
	
	self.RALATION_BUFFER = {};
	self.RALATION_BUFFER[self.emRELATION_NONE] 	     	= {};   
	self.RALATION_BUFFER[self.emRELATION_TMPFRIEND]		= {};  
	self.RALATION_BUFFER[self.emRELATION_BIDFRIEND] 	= {};  
	self.RALATION_BUFFER[self.emRELATION_TONGFRIEND] 	= {};   
	self.RALATION_BUFFER[self.emRELATION_KINFRIEND]		= {};   
	self.RALATION_BUFFER[self.emRELATION_COUPLE] 		= {};   
	self.RALATION_BUFFER[self.emRELATION_BLACK]		   	= {};  
	self.RALATION_BUFFER[self.emRELATION_ENEMEY] 		= {}; 



	for nId, tbParam in ipairs(tbFile) do
		local nRelationLevel  = tonumber(tbParam.RelationLevel) or 0;
		local nRelationNone  = tonumber(tbParam.None) or 0;
		local nRelationFriend  = tonumber(tbParam.BidFriend) or 0;
		local nRelationTong  = tonumber(tbParam.TongFriend) or 0;
		local nRelationKin   = tonumber(tbParam.KinFriend) or 0;
		
		self.RALATION_BUFFER[self.emRELATION_NONE][nRelationLevel] 	     	= nRelationNone;   
		self.RALATION_BUFFER[self.emRELATION_TMPFRIEND][nRelationLevel] 	= nRelationFriend;  
		self.RALATION_BUFFER[self.emRELATION_BIDFRIEND][nRelationLevel] 	= nRelationFriend;  
		self.RALATION_BUFFER[self.emRELATION_TONGFRIEND][nRelationLevel] 	= nRelationTong;   
		self.RALATION_BUFFER[self.emRELATION_KINFRIEND][nRelationLevel] 	= nRelationKin;   
		self.RALATION_BUFFER[self.emRELATION_COUPLE][nRelationLevel] 		= nRelationFriend;   
		self.RALATION_BUFFER[self.emRELATION_BLACK][nRelationLevel] 	   	= nRelationNone;  
		self.RALATION_BUFFER[self.emRELATION_ENEMEY][nRelationLevel] 		= nRelationNone; 
	end
end
	
FightAfter:InitRelationFile();