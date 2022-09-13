-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-1-25 10:10:10
-- 描  述  ：


if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\santaclaus2010\\santa2010_def.lua");
SpecialEvent.Santa2010 = SpecialEvent.Santa2010 or {};
local tbSanta = SpecialEvent.Santa2010 or {};

-- 襄阳,扬州,汴京三个主城增加圣诞老人
function tbSanta:AddSantaClaus_GS()
	if SubWorldID2Idx(tbSanta.SANTA_CLAUS_BORN_POS[1][1]) >= 0 then
		Npc:GetClass("santaclaus_2010"):StartSendGift(1);
	end
	if SubWorldID2Idx(tbSanta.SANTA_CLAUS_BORN_POS[2][1]) >= 0 then
		Npc:GetClass("santaclaus_2010"):StartSendGift(2);
	end
	Dialog:GlobalNewsMsg_GS("圣诞老人已在临安，大理现身，请等级大于60级的侠士前往一同庆祝节日!");
	Dialog:GlobalMsg2SubWorld_GS("圣诞老人已在临安，大理现身，请等级大于60级的侠士前往一同庆祝节日!");
	return 0;
end


-- 开始公告
function tbSanta:StartSantaClaus_GS()
	self.TimerId = Timer:Register(tbSanta.PREPARE_TIME, self.AddSantaClaus_GS, self);
	Dialog:GlobalNewsMsg_GS("圣诞老人5分钟后将会在临安，大理现身，请等级大于60级的侠士前往一同庆祝节日！");
	Dialog:GlobalMsg2SubWorld_GS("圣诞老人5分钟后将会在临安，大理现身，请等级大于60级的侠士前往一同庆祝节日！");
end
