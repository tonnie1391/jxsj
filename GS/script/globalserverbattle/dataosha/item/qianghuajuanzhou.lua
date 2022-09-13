-- 文件名　：qianghuajuanzhou.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-27  9:19:31
-- 描  述  ：强化卷轴公共

DaTaoSha.tbqianghuajuanzhou = DaTaoSha.tbqianghuajuanzhou or {};
local tbqianghuajuanzhou = DaTaoSha.tbqianghuajuanzhou;
tbqianghuajuanzhou.szInfo = "Tặng cho đồng đội!"

function tbqianghuajuanzhou:OnQiangHua(nType, nId)
	local pEquip = me.GetItem(Item.ROOM_EQUIP, nType, 0);
	if not pEquip then
		return;
	end
	if DaTaoSha:GetPlayerMission(me).nLevel == 1 then
		if pEquip.nEnhTimes < 14 then
		 	pEquip.Regenerate(
				pEquip.nGenre,
				pEquip.nDetail,
				pEquip.nParticular,
				pEquip.nLevel,
				pEquip.nSeries,
				pEquip.nEnhTimes + 1,			-- 强化次数加一
				pEquip.nLucky,
				pEquip.GetGenInfo(),
				0,
				pEquip.dwRandSeed,
				0
			);
			local pItem = KItem.GetObjById(nId);
			if pItem then
				pItem.Delete(me);
			end
			local szMsg = string.format("%s được nâng lên +%s", pEquip.szName, pEquip.nEnhTimes);
			me.Msg(szMsg);
		else
			local szMsg = string.format("%s không thể nâng thêm được nữa!", pEquip.szName);
			me.Msg(szMsg);
		end		
	else
		if pEquip.nEnhTimes < 14 then
		 	pEquip.Regenerate(
				pEquip.nGenre,
				pEquip.nDetail,
				pEquip.nParticular,
				pEquip.nLevel,
				pEquip.nSeries,
				pEquip.nEnhTimes + 1,			-- 强化次数加一
				pEquip.nLucky,
				pEquip.GetGenInfo(),
				0,
				pEquip.dwRandSeed
			);
			local pItem = KItem.GetObjById(nId);
			if pItem then
				pItem.Delete(me);
			end
			local szMsg = string.format("%s được nâng lên +%s", pEquip.szName, pEquip.nEnhTimes);
			me.Msg(szMsg);
		else
			local szMsg = string.format("%s không thể nâng thêm được nữa!", pEquip.szName);
			me.Msg(szMsg);	
		end
	end	
end

function tbqianghuajuanzhou:Trade(nId, nType)
	local tbOpt = {};
	local tbDialog = {};
	if 0 == me.nTeamId then
		me.Msg("您没有队友！");
		return 0;
	end
	local tbPlayerIdList = KTeam.GetTeamMemberList(me.nTeamId);
	for _, nPlayerId in pairs(tbPlayerIdList) do			
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if  pPlayer and pPlayer.szName ~= me.szName then
			table.insert(tbDialog,{pPlayer.szName,self.TradeEx,self,pPlayer.nId, nId, nType});
		end
	end
	table.insert(tbDialog,{"Đóng lại"});
	tbOpt = Lib:MergeTable( tbOpt,tbDialog);			
	Dialog:Say(self.szInfo,tbOpt);	
	return 0;	
end

function tbqianghuajuanzhou:TradeEx(nPlayerId, nItemId, nType)		
	local pItem = KItem.GetObjById(nItemId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
	if pItem and pPlayer then
		if pPlayer.CountFreeBagCell() > 0 then	--交易玩家包裹有空间			
			local tbItem = DaTaoSha.QIANGHUAJUANZHOU[nType];	
			pPlayer.AddItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
			local szMsg = string.format("队友 <color=yellow>%s<color> 交易给队友 <color=yellow>%s<color>  %s ！", me.szName, pPlayer.szName, pItem.szName);
			KTeam.Msg2Team(me.nTeamId, szMsg);
			pItem.Delete(me);	
		else
			me.Msg("对方空间不足！");
		end
	end
end
	