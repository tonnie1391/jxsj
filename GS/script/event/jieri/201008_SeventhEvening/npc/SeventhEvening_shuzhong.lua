-------------------------------------------------------
-- 文件名　：SeventhEvening_shuzhong.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-07-23 11:49:39
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("QX_shuzhong");
SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local tbSeventhEvening = SpecialEvent.SeventhEvening;

function tbNpc:OnDialog()
	
	local szMaleName = him.GetTempTable("SpecialEvent").szMaleName;
	local szFemaleName = him.GetTempTable("SpecialEvent").szFemaleName;
	if not szMaleName or not szFemaleName then
		return 0;
	end
	
	if me.szName ~= szFemaleName then
		Dialog:Say("对不起，你不能给这颗树浇水。");
		return 0;
	end
	
	local tbFind = me.FindItemInBags(unpack(tbSeventhEvening.tbTongxinshuiId));
	if not tbFind or #tbFind <= 0 then
		Dialog:Say("对不起，你身上没有同心水。");
		return 0;
	end
	
	for _, tbItem in pairs(tbFind) do
		me.DelItem(tbItem.pItem);
		break;
	end
	
	local nMapId, nMapX, nMapY = him.GetWorldPos();
	local pNpc = KNpc.Add2(tbSeventhEvening.SHUMIAO_ID, 1, -1, nMapId, nMapX, nMapY);
	if not pNpc then
		return 0;
	end
	
	pNpc.GetTempTable("SpecialEvent").szMaleName = szMaleName;
	pNpc.GetTempTable("SpecialEvent").szFemaleName = szFemaleName;
	
	him.Delete();
	
	local szMsg = "男女双方同时点击小树，小树便可变成茂盛的同心树。";
	Dialog:SendBlackBoardMsg(me, szMsg);
	local pPlayer = KPlayer.GetPlayerByName(szMaleName);
	if pPlayer then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	
	Timer:Register(60 * 10 * Env.GAME_FPS, tbSeventhEvening.OnTimerDelNpc, tbSeventhEvening, pNpc.dwId);
end
