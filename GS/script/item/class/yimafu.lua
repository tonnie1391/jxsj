--易马符-90级马
--sunduoliang
--2008.10.31

local tbItem = Item:GetClass("yimafu");
tbItem.tbWantHorse = 
{
	{1, 12, 17, 3},	--奇珍阁（乌云踏雪）
	{1, 12, 19, 3}, --奇珍阁（绝影）
	{1, 12, 20, 3}, --奇珍阁（照夜玉狮子）
	{1, 12, 21, 3}, --奇珍阁（汗血宝马）
}

function tbItem:OnUse()
	local szMsg = ("请选择您想要用你的90级马换取的马匹。");
	local tbOpt = {};
	for nId, tbHorse in ipairs(self.tbWantHorse) do
		local szName = KItem.GetNameById(unpack(tbHorse));
		table.insert(tbOpt, {szName, self.GetHorse, self, it.dwId, nId});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:GetHorse(nItemId, nId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local szContent = string.format("您选择了<color=yellow>%s<color><color=red>（获取绑定)<color>，请放入<color=yellow>易马符<color>和你不想要的<color=yellow>90级马<color>。", KItem.GetNameById(unpack(self.tbWantHorse[nId])));
	local tbParam = {
		tbAward = {
			{
				nGenre=self.tbWantHorse[nId][1], 
				nDetail=self.tbWantHorse[nId][2],
				nParticular=self.tbWantHorse[nId][3],
				nLevel=self.tbWantHorse[nId][4],
				nCount=1,
				nBind=1,
				nTimeLimit=365*24*60, 
				nTimeType=0
			}
				 },
		tbMareial = {{nGenre=18, nDetail=1,nParticular=238,nLevel=1,nCount=1},},
		tbMareialOne = {
			{nGenre=1, nDetail=12,nParticular=5,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=6,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=7,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=8,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=9,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=17,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=18,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=19,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=20,nLevel=3,nCount=1},
			{nGenre=1, nDetail=12,nParticular=21,nLevel=3,nCount=1},			
		},
	}
	Dialog:OpenGift(szContent, tbParam);
	return 0;
end
