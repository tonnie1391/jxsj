-- 文件名  : beautyhero_shop.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-18 14:51:09
-- 描述    : 
local tbNpc = Npc:GetClass("beautyhero_shop");


function tbNpc:OnDialog()
	local szMsg = "你好，我是药店老板。货真价实，老少不欺。";
	local tbOpt = {};
	
	table.insert(tbOpt,{"<color=gold>【绑定银两】<color>药品",self.BuyBindMedicine,self});
	if not GLOBAL_AGENT then
		table.insert(tbOpt,{"药品",self.BuyMedicine,self});
	end
	table.insert(tbOpt,{"<color=gold>【绑定银两】<color>食物",self.BuyBindFood,self});
	
	if not GLOBAL_AGENT then
		table.insert(tbOpt,{"食物",self.BuyFood,self});
	end
	
	
	table.insert(tbOpt,{"不买了"});
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:BuyMedicine()
	Dialog:OpenShop(183,1);
end

function tbNpc:BuyBindMedicine()
	Dialog:OpenShop(183,7);
end


function tbNpc:BuyBindFood()
	Dialog:OpenShop(21,7);	
end

function tbNpc:BuyFood()
	Dialog:OpenShop(21,1);	
end