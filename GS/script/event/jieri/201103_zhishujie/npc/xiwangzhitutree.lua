-- 文件名  : xiwangzhitutree.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2011-02-28 17:26:42
-- 描述    : 希望之土希望之种

local tbNpcTu = Npc:GetClass("xiwangzhitu_2011");
tbNpcTu.tbMsg = {"赐予希望之风", "浇灌希望之水"};

function tbNpcTu:OnDialog()
	local szMsg = "这是希望的风，吹来温暖，吹来关怀，吹来希望。\n";
	local tbTemp = him.GetTempTable("Npc").tbZhiShu2011;
	local nStep = tbTemp.nStep;
	local tbOpt = {{"Để ta suy nghĩ thêm"}};
	table.insert(tbOpt, 1, {self.tbMsg[nStep], SpecialEvent.tbZhiShu2011.MakeStepAction, SpecialEvent.tbZhiShu2011, me.nId, him.dwId});
	Dialog:Say(szMsg, tbOpt);
end


local tbNpc = Npc:GetClass("xiwangzhizhong_2011");

function tbNpc:OnDialog()
	local szMsg = string.format("金灿灿的，充满了希望的种子，每天可以在木良处<color=yellow>免费领取一次<color>种植道具。也可以在<color=yellow>月影之石商店购买<color>，<color=green>3月10日-3月16日<color>每天最多可以种植%s棵树哦。\n", SpecialEvent.tbZhiShu2011.nMaxPlant);	
	local tbOpt = {
		{"摘取种子", SpecialEvent.tbZhiShu2011.GetXiWangZhong, SpecialEvent.tbZhiShu2011, him.dwId},
		{"Để ta suy nghĩ thêm"}
	};
	Dialog:Say(szMsg, tbOpt);
end
