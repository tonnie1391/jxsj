--Author：zhaoyu
--Date：2009/12/16 9:20:01
--Comments：月影之石商店

local tbNpc = Npc:GetClass("longwutaiye");

tbNpc.tbThings = nil;

function tbNpc:AnalyzeName()
	local szFile = "\\setting\\partner\\moonstone.txt";
	self.tbThings = { };
	self.tbThings = Lib:LoadTabFile(szFile);
	for _k, _v in ipairs(self.tbThings) do
		_v.szName = KItem.GetNameById(tonumber(_v.nGenre), tonumber(_v.nDetail), tonumber(_v.nParticular), tonumber(_v.nLevel));
	end
end

function tbNpc:MoonStoneShop()
	local szMsg, tbOpt;
	if not tbNpc.tbThings then
		tbNpc:AnalyzeName();
	end
	szMsg = "您可以使用<color=yellow>月影之石<color>在我这里兑换下列与同伴系统相关的物品。各种<color=yellow>名帖<color>可以用来<color=yellow>说服同伴<color>，各种<color=yellow>精魄<color>可以增加您与同伴的<color=yellow>亲密度<color>。";
	tbOpt = { };
	for _k, _v in ipairs(self.tbThings) do
		table.insert(tbOpt, { string.format("%s [%d]", _v.szName, _v.nCount), self.OnBuy, self, _k });
	end
	table.insert(tbOpt, { "Kết thúc đối thoại" });
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnBuy(nIndex)
	local tbData = self.tbThings[nIndex];
	local tbParams = 
	{
		nGenre		= tonumber(tbData.nGenre),
		nDetail		= tonumber(tbData.nDetail),
		nParticular	= tonumber(tbData.nParticular),
		nLevel		= tonumber(tbData.nLevel),
		nCount		= tonumber(tbData.nCount)
		--tbMareialOne = {{nGenre=, nDetail=,nParticular=,nLevel=,nCount=1}}, --材料必须其中一种
		--fnOnSucceed = self.OnSucceed,
		--tbSucceedParams = {self, tbData.nCount, tbData.szName}
	}
	tbParams.szName = KItem.GetNameById(tbParams.nGenre, tbParams.nDetail, tbParams.nParticular, tbParams.nLevel);
	tbParams.szTip = tbData.szTip;
	Dialog:OpenGift(tbData.szTip, {"Partner:MoonStoneCheckFun", tbParams}, { Partner.MoonStoneOkFun, Partner, tbParams } );
end

