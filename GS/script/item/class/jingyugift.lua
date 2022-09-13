-- 文件名　：jingyugift.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-11-07 11:06:48
-- 功能    ：

SpecialEvent.NewPlayerGiftEx = SpecialEvent.NewPlayerGiftEx or {};
local NewPlayerGiftEx = SpecialEvent.NewPlayerGiftEx;
NewPlayerGiftEx.nMaxCount = 15;
NewPlayerGiftEx.nMaxRate = 1000;
NewPlayerGiftEx.nRate = 5;
NewPlayerGiftEx.tbHonor = {
	{{18,1,1251,1}, "Tiểu Du Long Lệnh [Hộ Thân Phù]"},
	{{18,1,1251,2}, "Tiểu Du Long Lệnh [Nón] "},
	{{18,1,1251,3}, "Tiểu Du Long Lệnh [Y Phục]"},
	{{18,1,1251,4}, "Tiểu Du Long Lệnh [Yêu Đái]"},
	{{18,1,1251,5}, "Tiểu Du Long Lệnh [Giày]"}, 
	{{18,1,1251,6}, "Tiểu Du Long Lệnh [Liên]"},
	{{18,1,1251,7}, "Tiểu Du Long Lệnh [Nhẫn]"},
	{{18,1,1251,8}, "Tiểu Du Long Lệnh [Hộ Uyển]"},
	{{18,1,1251,9}, "Tiểu Du Long Lệnh [Ngọc Bội]"},
	}

if (MODULE_GAMESERVER) then
local tbItem	= Item:GetClass("jingyugift");

function tbItem:OnUse()
	 if me.CountFreeBagCell() < 1 then
	  	me.Msg("Hành trang không đủ chỗ trống!");
	  	return 0;
	end
	local nRet = 0;
	local nDay = KGblTask.SCGetDbTaskInt(DBTASK_NEWPLAYERGIFT_HONOR_DAY);
	local nAllCount = KGblTask.SCGetDbTaskInt(DBTASK_NEWPLAYERGIFT_HONOR_COUNT);
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	if nDay ~= nNowDay then
		nAllCount = 0;
	end
	local nRate = MathRandom(NewPlayerGiftEx.nMaxRate);
	if not IpStatistics:IsStudioRole(me) and nAllCount < NewPlayerGiftEx.nMaxCount and nRate <= NewPlayerGiftEx.nRate and me.nLevel >= 90 then
		me.AddWaitGetItemNum(1);
		GCExcute({"SpecialEvent.NewPlayerGiftEx:CanGetHonor", me.nId, it.dwId});
		return 0;
	else
		return Item:GetClass("randomitem"):SureOnUse(253, 0, 0, 0, 0, 0, 0, 0, 0, it);
	end	
end

--加声望牌子
function NewPlayerGiftEx:AddAward(nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	pPlayer.AddWaitGetItemNum(-1);
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end	
	local nIndex = MathRandom(#self.tbHonor);
	local pItemEx = pPlayer.AddItem(unpack(self.tbHonor[nIndex][1]));
	if pItemEx then
		pItemEx.Bind(1);
		local szMsg = string.format("%s mở %s nhận được %s!", pPlayer.szName, pItem.szName, self.tbHonor[nIndex][2]);
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		pItem.Delete(pPlayer);
	end
	return;
end

--random
function NewPlayerGiftEx:AddRandomItem(nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	pPlayer.AddWaitGetItemNum(-1);
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end	
	local nRet = Item:GetClass("randomitem"):SureOnUse(253, 0, 0, 0, 0, 0, 0, 0, 0, pItem);
	if nRet == 1 then
		pItem.Delete(pPlayer);
	end
	return;
end
end
----------------------------------------------------------------------------
--gc

if (MODULE_GC_SERVER) then
function NewPlayerGiftEx:CanGetHonor(nPlayerId, nItemId)
	local nDay = KGblTask.SCGetDbTaskInt(DBTASK_NEWPLAYERGIFT_HONOR_DAY);
	local nAllCount = KGblTask.SCGetDbTaskInt(DBTASK_NEWPLAYERGIFT_HONOR_COUNT);
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	if nDay ~= nNowDay then
		KGblTask.SCSetDbTaskInt(DBTASK_NEWPLAYERGIFT_HONOR_DAY, nNowDay);
		nAllCount = 0;
	end
	if nAllCount >= self.nMaxCount then
		GlobalExcute({"SpecialEvent.NewPlayerGiftEx:AddRandomItem", nPlayerId, nItemId});
		return;
	end
	GlobalExcute({"SpecialEvent.NewPlayerGiftEx:AddAward", nPlayerId, nItemId});
	KGblTask.SCSetDbTaskInt(DBTASK_NEWPLAYERGIFT_HONOR_COUNT, nAllCount + 1);
end
end
