-- 文件名　：fire_newserverevent.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-10 17:03:21
-- 描述：新服活动，蜡烛


SpecialEvent.NewServerEvent =  SpecialEvent.NewServerEvent or {};
local NewServerEvent = SpecialEvent.NewServerEvent;

---烛火--------------------------
local tbFire = Npc:GetClass("fire_newserverevent");

function tbFire:AddExp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nAddExpTimer = pNpc.GetTempTable("SpecialEvent").nAddExpTimer;
	if not nAddExpTimer or nAddExpTimer == 0 then
		return 0;
	end
	local tbPlayer,nCount = KNpc.GetAroundPlayerList(nNpcId,NewServerEvent.nFireExpRange);
	local szMaleName = pNpc.GetTempTable("SpecialEvent").szMaleName;
	local szFemaleName = pNpc.GetTempTable("SpecialEvent").szFemaleName;
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				if pPlayer.szName == szMaleName or pPlayer.szName == szFemaleName then
					local nAddExp = pPlayer.GetBaseAwardExp() * NewServerEvent.nFireGiveExpRate;
					local nAddExpPerMin = nAddExp / NewServerEvent.nFireGiveExpCount ; 
					pPlayer.AddExp(nAddExpPerMin);
				end
			end
		end
	end
	if not pNpc.GetTempTable("SpecialEvent").nAddExpTimes then
		pNpc.GetTempTable("SpecialEvent").nAddExpTimes = 0;
	end
	pNpc.GetTempTable("SpecialEvent").nAddExpTimes = pNpc.GetTempTable("SpecialEvent").nAddExpTimes + 1;
	if pNpc.GetTempTable("SpecialEvent").nAddExpTimes >= NewServerEvent.nFireGiveExpCount then	--超过了给经验的次数
		pNpc.Delete();
		return 0;
	end
end

