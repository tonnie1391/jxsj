-- 文件名  : treasuremap2_merchant.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-19 17:07:35
-- 描述    : 

Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua");

local tbNpc = Npc:GetClass("treasuremap2_merchant");

function tbNpc:OnDialog()
	local szMsg = "Ta có thể giúp gì cho ngươi?";
	local tbOpt = {
	--	{"我要买药。",self.Shop, self},
		{"Ta muốn rời khỏi đây",self.Leave,self},
		{"Kết thúc phó bản", self.EndMission, self},
		{"Để ta suy nghĩ lại"},
		};
		
	Dialog:Say(szMsg, tbOpt);	
end

function tbNpc:Leave()	
	FightAfter:Fly2City(me);
end

function tbNpc:Shop()	
	me.OpenShop(14,7);
end

function tbNpc:EndMission(bSure)	
	local nCaptainId = me.GetTempTable("TreasureMap2").nCaptainId;
	if not nCaptainId or nCaptainId ~= me.nId then
		Dialog:Say("Bạn không mở phó bản này, không thể kết thúc.");
		return;
	end	

	local tbInstance = TreasureMap2:GetInstancingByPlayerId(nCaptainId);
	if not tbInstance then
		Dialog:Say("Phó bản đã đóng, không thể kết thúc.");
		return;
	end
	local nDisTime = GetTime() - tbInstance.nStartTime;
	if nDisTime < TreasureMap2.CANCLOSE_TIME * 60 then
		Dialog:Say(string.format("Chỉ có thể đóng phó bản sau khi mở %d phút.",TreasureMap2.CANCLOSE_TIME));
		return;	
	end
		
	if bSure and bSure == 1 then
		tbInstance:EndGame();
		return;
	end	
		
	local tbOpt = {
		{"Kết thúc phó bản", self.EndMission, self, 1},
		{"Để ta suy nghĩ lại"},
		};	
		
	Dialog:Say("Bạn có chắc muốn kết thúc?", tbOpt);
end
