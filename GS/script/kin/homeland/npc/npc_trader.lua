local tbNpc = Npc:GetClass("homeland_npc_trader");

function tbNpc:OnDialog()
	local szMsg = "  Ngươi muốn mua vật dụng gì?";
	local tbOpt = 
	{
		{"<color=yellow>[Bạc khóa] Dược phẩm<color>", self.OnBuyYaoBind, self},
		{"Dược phẩm", self.OnBuyYao, self},
		{"Ta không mua nữa"},
	};
	Dialog:Say(szMsg, tbOpt);		
end

-- 买药
function tbNpc:OnBuyYaoBind()
	me.OpenShop(14,7);
end

function tbNpc:OnBuyYao()
	me.OpenShop(14,1);
end