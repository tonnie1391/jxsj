-- 文件名　：kingame_exit.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-04 15:19:18
-- 描述：离开点

local tbNpc = Npc:GetClass("kingame_exit");

function tbNpc:OnDialog()
	local szMsg = "确定要离开么？"
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"我要离开",self.BackToCity,self};
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:BackToCity()
	local pGame = KinGame2:GetGameObjByMapId(me.nMapId);
	if not pGame then
		return 0;
	end
	pGame:KickPlayer(me);
	SpecialEvent.ActiveGift:AddCounts(me, 21);		--完成家族关卡活跃度
	return 0;
end
