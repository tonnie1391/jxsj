-- FileName: qingminghuodong.lua
-- Author: lqy&lgy
-- Time: 2012/3/22 12:13
-- Comment:活动接引人
--


if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");

local tbQingMing2012 = SpecialEvent.tbQingMing2012;
local tbNpc= Npc:GetClass("puliuling_qingming2012");

function tbNpc:OnDialog()
	local szMsg =[[	
	  <color=yellow>清明时节雨纷纷，山河飘摇人断魂。
	  英魂杳杳往何处，万古长青浩然存。<color>	  
	  	在<color=green>4月1日到4月5日<color>期间，你可以通过<color=yellow>逍遥谷，军营副本，白虎堂，官府通缉以及击杀野外精英首领<color>等在线活动获得<color=yellow> “幽冥灯”<color>。在组队的状态下，可以在<color=yellow>各个新手村<color>放飞以祭祀英魂。每次成功祭祀均可获得奖励，同时组队人数越多，获得的奖励也会越丰厚。
	你可以使用一定精活将<color=yellow> “幽冥灯”<color>加工为<color=yellow> “赎魂灯”<color>，使用赎魂灯进行祭祀可以获得<color=yellow>更多的奖励<color>。
	<color=yellow>家族威望排名前50名的家族<color>，可由族长或者副族长到我这里，每天领取1枚<color=yellow>英灵挑战令<color>。使用后可以在野外地图召唤出已逝的英灵，成功击败英灵，家族成员均可获得奖励！]]
	local tbOpt =
	{
		{"查询清明节活动规则",self.GuiZe,self},
		{"领取英灵挑战令",self.TiaoZhanLin,self},
		{"Ta chỉ xem qua"},
	}
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:GuiZe()
	local szMsg =[[
	   
	   哦？你想要拜祭先辈英灵吗。按照传统的习俗，均是放飞孔明灯来寄托哀思。你可以通过参加逍遥谷，军营等在线活动获得祭祀需要的灯。得到灯后，你需要在各大<color=yellow>新手村<color>中放飞，成功的话可以获得奖励。放灯需要<color=red>组队<color>，组队的人数越多，可以获得的奖励就越多。当你在所有的新手村都放飞过灯后，你还可以获得额外的奖励！
	   另外，如果你所在的家族在江湖上略有名气，就可以在我这里领取一枚<color=yellow>英灵挑战令<color>，拿着这个你们就可以呼唤出已逝的英灵。如果你们能够获得他的认可，说不定会获得奖励！
	]];
	Dialog:Say(szMsg, {"Ta hiểu rồi"});
end

--领取挑战令
function tbNpc:TiaoZhanLin()
	local nOk,szMsg = tbQingMing2012:CanGetTiaoZhanLin(me.nId)
	if nOk == 0 then
		Dialog:Say(szMsg);
		return;
	end
	me.AddItem(unpack(tbQingMing2012.nQingMingTiaoZhanLingId));
	
	--记录log
	StatLog:WriteStatLog("stat_info", "qingmingjie2012", "get_token", me.nId, 1);
				
	local nKinId = me.GetKinMember();
	GCExcute({"SpecialEvent.tbQingMing2012:UpdateKinGet_GC", nKinId, 1});
	Dialog:SendBlackBoardMsg(me, "你获得了1枚英灵挑战令");
end

--鲜花
local tbXianHuaNpc= Npc:GetClass("xianhua_qingming2012");
function tbXianHuaNpc:OnDialog()
	--随机一条祝福
	local nRand= MathRandom(1,#tbQingMing2012.tbWishMsg);
	Dialog:Say(tbQingMing2012.tbWishMsg[nRand]);
end
