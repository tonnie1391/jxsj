-- 文件名　：horsexiang.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-08 12:23:58
--vn箱子，用于加时间限制的

local tbHorseXiang = Item:GetClass("horsexiang_vn");
function tbHorseXiang:OnUse()	
	local nGenre = tonumber(it.GetExtParam(1));
	local nDetail = tonumber(it.GetExtParam(2));
	local nParticular = tonumber(it.GetExtParam(3));
	local nLevel = tonumber(it.GetExtParam(4));
	local nNum = tonumber(it.GetExtParam(5)) or 1;
	local bBind = tonumber(it.GetExtParam(6)) or 1;
	local nTimes = tonumber(it.GetExtParam(7)) or 0;
	local nAchievement = tonumber(it.GetExtParam(8)) or 0;
	local nSpreed = tonumber(it.GetExtParam(9)) or 0;
	
	if nAchievement > 0 then
		if Achievement:CheckFinished(nAchievement) == 0 then
			me.Msg("不能使用，需要完成成就：<color=yellow>"..Achievement:GetAchievementInfoById(nAchievement).szAchivementName.."<color>");
			return 0;
		end
	end
	if nSpreed > 0 then
		if Spreader:GetAllConsume() < nSpreed * 100 then
			me.Msg("奇珍阁消耗不足：<color=yellow>"..nSpreed.."元<color>");
			 return 0;
		end
	end
	
	if not nGenre or not nDetail or not nParticular or not nLevel then
		return 0;
	end
	local bTimes = 0;
	if nTimes > 0 then
		bTimes = 1;
	end
	
	local nNeedCount = KItem.GetNeedFreeBag(nGenre, nDetail, nParticular, nLevel, {bTimeOut= bTimes}, nNum);	
	
	if nGenre <= 5 then
		nNeedCount = nNum;
	end
	
	if me.CountFreeBagCell() < nNeedCount then
		me.Msg(string.format("Hành trang không đủ ，需要%s格背包空间。", nNeedCount));
		return 0;
	end	
	local szName = "";
	for i =1, nNum do
		local nTimeout = 0;
		local tbInfo = {};
		tbInfo.bMsg = 0;
		if bTimes == 1 then
			tbInfo.bTimeOut = 1;
			nTimeout = GetTime() + nTimes * 60;
		end
		if bBind == 1 then	
			tbInfo.bForceBind = 1;
		end
		local pItem = me.AddItemEx(nGenre, nDetail, nParticular, nLevel,tbInfo,nil,nTimeout);
		if pItem and szName == "" then
			szName = pItem.szName;
		end
	end
	if szName ~= "" then
		me.Msg("您获得了" .. tostring(nNum) .. "个" .. szName .. "!","");
	end
	return 1;
end

function tbHorseXiang:GetTip()
	local nAchievement = tonumber(it.GetExtParam(8)) or 0;
	local nSpreed = tonumber(it.GetExtParam(9)) or 0;
	local szMsg = "";
	if nAchievement > 0 then
		local szAchivementName = Achievement:GetAchievementInfoById(nAchievement).szAchivementName;
		if Achievement:CheckFinished(nAchievement) == 0 then
			szMsg = "<color=red>需要完成成就："..szAchivementName.."<color>\n";
		else
			szMsg =  "<color=green>完成成就："..szAchivementName.."<color>\n";
		end
	end
	if nSpreed > 0 then
		szMsg = szMsg .. "<color=yellow>奇珍阁消耗："..nSpreed.."元<color>";
	end
	return szMsg;
end
