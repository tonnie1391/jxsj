-------------------------------------------------------------------
--File: xmas_tree.lua
--Author: fenghewen
--Date: 2008-12-16 10:23
--Describe: 圣诞树npc脚本
-------------------------------------------------------------------
if  MODULE_GC_SERVER then
	return;
end
local tbChristmasTree = Npc:GetClass("xmas_tree");
tbChristmasTree.tbSocks = {18,1,269,1};	--圣诞袜子
--tbChristmasTree.tbSnowGroups = {18,1,537,1};	--小雪团 
tbChristmasTree.tbSnowGroups = {22,1,45,1};	--小雪团 
tbChristmasTree.nSnowGroupRate = 20
tbChristmasTree.nLevelLimit = 60

function tbChristmasTree:OnDialog()
	if SpecialEvent.Xmas2008:Check() ~= 1 then
		Dialog:Say(string.format("哇，好美的圣诞树呢。不过上面没有挂礼物哦"));
		return 0;
	end	
	Dialog:Say("哇，好美的圣诞树呢，上面还挂了这么多礼物，我拿一个没关系吧",
		{
			{"摘取礼物", self.RecevePresent, self, him.dwId},
			{"我看看而已（离开）"}
		})
end

-- 摘取礼物
function tbChristmasTree:RecevePresent(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcTemp = pNpc.GetTempTable("Npc");
	
	if not tbNpcTemp.tbPlayerList then
		tbNpcTemp.tbPlayerList = {};
	end
	
	local tbPlayerList = tbNpcTemp.tbPlayerList;
	
	if tbPlayerList[me.nId] == 1 then
		Dialog:Say("我好像已经拿过礼物了，还是给他人留点吧。");
		return 0;
	end
	
	if me.nLevel < self.nLevelLimit then
		Dialog:Say("我功力不够啊，拿不到礼物，还是60级再来拿吧。");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不足!")
		return 0;
	end
	
	local nRusult = MathRandom(1, 100);
	
	if nRusult > self.nSnowGroupRate then
		-- 给小雪团
		local nNum = MathRandom(1, 9);
		local nG, nD, nP, nL = unpack(tbChristmasTree.tbSnowGroups);
		me.AddStackItem(nG, nD, nP, nL, {bTimeOut=1}, nNum);
	else
		-- 给袜子
		local pItem = me.AddItem(unpack(self.tbSocks));
		if pItem then
			pItem.Bind(1);
		end
	end
	
	tbPlayerList[me.nId] = 1;
end


