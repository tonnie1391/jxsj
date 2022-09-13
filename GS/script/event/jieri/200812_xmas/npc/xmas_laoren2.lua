-------------------------------------------------------------------
--File: xmas_laoren2.lua
--Author: fenghewen
--Date: 2008-12-16 10:23
--Describe: 圣诞老人npc脚本
-------------------------------------------------------------------
if  MODULE_GC_SERVER then
	return;
end
local tbSantaClaus = Npc:GetClass("xmas_laoren2");
tbSantaClaus.tbSocks = {18,1,269,1};	--圣诞袜子
tbSantaClaus.nLevelLimit = 60

function tbSantaClaus:OnDialog()
	local nCheck = SpecialEvent.Xmas2008:Check();
	if nCheck == -1 then
		Dialog:Say("圣诞老人：活动还没开始，我还要准备一段时间才有礼物呢。")
		return 0;		
	end
	if nCheck == 0 then
		Dialog:Say("圣诞老人：礼物都送完了，休息一会就离开。")
		return 0;
	end	
	Dialog:Say("各位圣诞快乐！我们在此处相遇，很有缘啊，来来来，老头子送你个~~~袜子，嘿嘿！",
		{
			{"接受礼物", self.RecevePresent, self, him.dwId},
			{"Ta chỉ xem qua Xóa bỏ"}
		})
end

-- 接受礼物
function tbSantaClaus:RecevePresent(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end
	
	local tbNpcTemp = pNpc.GetTempTable("Npc");
	if not tbNpcTemp.tbPlayerList then
		tbNpcTemp.tbPlayerList = {};
	end
	
	local tbPlayerList = tbNpcTemp.tbPlayerList;
	if tbPlayerList[me.nId] == 1  then
		Dialog:Say("你不是已经得到礼物了吗？礼物不多，给他人留点吧。");
		return 0;
	end
	
	if me.nLevel < self.nLevelLimit  then
		Dialog:Say("恩~~ 你阅历不够，恐怕无法识别此中玄机 ，60级以后再来吧。");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不足!")
		return 0;
	end
	
	-- 给袜子
	local pItem = me.AddItem(unpack(self.tbSocks));
	if pItem then
		pItem.Bind(1);
		tbPlayerList[me.nId] = 1;
	end
end
	

