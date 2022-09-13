local tbValentineTitle = {};
SpecialEvent.ValentineTitle2009 = tbValentineTitle;

tbValentineTitle.tbLovers = {
	{"04","刹那魔法师"},
	{"04","【迟到千年】"},
	{"04","金枪横天下"},
	{"04","暖暖的小古"},
	{"04","枫雪枭雄"},
	{"04","漂逸菲儿"},
	{"06","赤脚啊扁"},
	{"06","赤脚小妹"},
	{"02","大寶點點壞"},
	{"02","小寶哆哆乖"},
	{"05","續寫傳說"},
	{"05","續寫神话"},
	{"03","藐视一切冷爷"},
	{"03","·迷你瀦·"},
	{"04","丨流氓座丨丶扫黄"},
	{"04","【白衣魔女】"},
};

function tbValentineTitle:CanGetTitle(pPlayer)
	if tonumber(GetLocalDate("%Y%m%d")) >= 20090323 then
		return 0;
	end
	
	local szGatewayName = string.sub(GetGatewayName(),5,6);
	for _, tb in ipairs(self.tbLovers) do
		if tb[1] == szGatewayName and tb[2] == pPlayer.szName then
			return 1;
		end
	end
	return 0;
end

function tbValentineTitle:GetTitle(pPlayer)
	local tbTitle = {[0] = {6,3,1,0},[1] = {6,3,2,0}};
	
	if pPlayer.FindTitle(unpack(tbTitle[pPlayer.nSex])) == 0 then
		pPlayer.AddTitle(unpack(tbTitle[pPlayer.nSex]));
		SpecialEvent:WriteLog(Dbg.LOG_INFO, "tbValentineTitle:GetTitle", pPlayer.szName);
	else
		Dialog:Say("您已经领过了。");
	end
end

-- ?pl DoScript("\\script\\event\\jieri\\200903_valentinetitle\\logic.lua")