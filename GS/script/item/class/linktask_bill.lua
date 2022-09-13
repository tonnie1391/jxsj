
-- ====================== 文件信息 ======================

-- 剑侠世界任务链 - 钱庄银票
-- Edited by peres
-- 2008/12/10 PM 00:26

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

Require("\\script\\task\\linktask\\linktask_head.lua");

local tbTreasureMap = Item:GetClass("linktask_bill");

function tbTreasureMap:OnUse()

end;

function tbTreasureMap:GetTip()
	
	local szMain = [[一张可兑换银两的银票，可在以下几处兑换成不绑定的银两：<enter><enter>
					<color=orange>1. 白虎堂二层的商会接头人<enter>
					2. 伏牛山军营副本击败大工匠后出现的商会接头人<enter>
					3. 逍遥谷的加工/制造大师柳阔<enter>
					4. 义军军需官<color><enter><enter>
	]];
	
	local nMoney	= math.floor( (10000 * LinkTask:_CountLevelProductivity()) / 2 );
	
	szMain = szMain.."<color>根据你的等级，当前每张银票可以兑换为："..nMoney.." 不绑定的银两。<color>";
	
	return szMain;
end;
