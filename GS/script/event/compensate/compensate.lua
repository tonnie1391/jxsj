--回档补偿脚本
--孙多良
--2008.07.09
--现在是第四批奇珍阁补偿

-- 该文件已废弃
do return 0; end

local Compensate = {};
SpecialEvent.Compensate = Compensate;

Compensate.EXT_POINT  = 4;	--补偿扩展点，高24位记录批次，低8位记录次数，次数上限255
Compensate.EXT_BATCH  = 5;	--批次，每次补偿批次赠1
Compensate.EXT_COUNT  = 30;	--每批一次领取最多个数
Compensate.TIME_START = 0;
Compensate.TIME_END   = 200906142400;
Compensate.OPEN		  = 0; --开启开关
Compensate.FILE_PATH  = "\\setting\\event\\compensate\\compensate.txt";	--补偿名单路径
function Compensate:OnDialog()
	local tbOpt = {
		{"我要领取",self.GetAward, self},
		{"我没丢什么物品，没什么可领的"},
	}
	local szMsg = string.format("您好，在我这里可以领回您在奇珍阁%s区购买但丢失的物品。因物品丢失给大家带来的不便，我们深表歉意。\n每次最多领取%s件物品，如有多将会分批领取。\n<color=red>领取截止时间：%s年%s月%s日%s时<color>",IVER_g_szCoinName,self.EXT_COUNT, math.mod(math.floor(self.TIME_END/10^8), 10^4),math.mod(math.floor(self.TIME_END/10^6), 10^2),math.mod(math.floor(self.TIME_END/10^4), 10^2),math.mod(math.floor(self.TIME_END/10^2), 10^2));
	Dialog:Say(szMsg, tbOpt)
end

function Compensate:CheckState()
	if self.OPEN ~= 1 then
		return 0;
	end
	local szServer = string.sub(GetGatewayName(), 5, 6);
	local nDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nDate >= self.TIME_START and nDate < self.TIME_END and self.tbTxt[szServer] ~= nil then
		return 1;
	end
	return 0;
end

function Compensate:GetAward()
	if self:CheckState() == 0 then
		Dialog:Say("活动已经截至。");
		return 0;
	end
	local szServer = string.sub(GetGatewayName(), 5, 6);
	if self.tbTxt[szServer][string.upper(me.szAccount)] == nil then
		Dialog:Say(string.format("对不起，您在奇珍阁%s区购买的物品没有丢失的记录，没有可领取的物品。", IVER_g_szCoinName));
		return 0;
	end
	local tbItem = self.tbTxt[szServer][string.upper(me.szAccount)]
	if self:GetExtPointByte() * self.EXT_COUNT > #tbItem then
		Dialog:Say("对不起，您已经全部领取完所有的物品，不能再领取了。");
		return 0;
	end
	
	if self:GetExtPointByte() + math.ceil((#tbItem - self:GetExtPointByte() * self.EXT_COUNT) / self.EXT_COUNT) >  255 then
		Dialog:Say("您的帐号出现异常，暂时无法领取。");
		Compensate:WriteLog(me,"扩展点超过批次上限（上限255）");
		return 0;
	end
	
	if #tbItem - self:GetExtPointByte() * self.EXT_COUNT > self.EXT_COUNT then
		if me.CountFreeBagCell() < self.EXT_COUNT then
			Dialog:Say(string.format("对不起，您的背包空间不够，请整理一下背包再来领取。您需要%s格背包空间，分批领取。", self.EXT_COUNT));
			return 0;
		end
	else
		if me.CountFreeBagCell() < #tbItem - self:GetExtPointByte() * self.EXT_COUNT then
			Dialog:Say(string.format("对不起，您的背包空间不够，请整理一下背包再来领取。您需要%s格背包空间。", #tbItem - self:GetExtPointByte() * self.EXT_COUNT ));
			return 0;
		end
	end
	
	local nId = self:GetExtPointByte() * self.EXT_COUNT;
	nId = nId + 1;
	local nMaxId = #tbItem;
	if nMaxId > (self:GetExtPointByte() + 1) * self.EXT_COUNT  then
		nMaxId = (self:GetExtPointByte() + 1) * self.EXT_COUNT;
	end
	self:AddExtPointByte(1);
	for ni = nId, nMaxId do
		local pItem = me.AddItem(unpack(tbItem[ni].tbItem));
		if pItem then
			me.SetItemTimeout(pItem,os.date("%Y/%m/%d/00/00/00", GetTime() + 60 * tbItem[ni].nLimit));
			pItem.Sync();
			local szItem = string.format("%s,%s,%s,%s",tbItem[ni].tbItem[1],tbItem[ni].tbItem[2],tbItem[ni].tbItem[3],tbItem[ni].tbItem[4]);
			Compensate:WriteLog(me,"领取物品成功 物品ID："..szItem);
		else
			local szItem = string.format("%s,%s,%s,%s",tbItem[ni].tbItem[1],tbItem[ni].tbItem[2],tbItem[ni].tbItem[3],tbItem[ni].tbItem[4]);
			Compensate:WriteLog(me,"领取物品失败 物品ID："..szItem);
		end
	end
	local szMsg = ""
	if #tbItem - self:GetExtPointByte() * self.EXT_COUNT <= 0 then
		szMsg = "您成功领取所有了补偿物品，请查看您的背包。"
	else
		local nCount = math.ceil((#tbItem - self:GetExtPointByte() * self.EXT_COUNT) / self.EXT_COUNT);
		szMsg = string.format("您成功领取补偿物品，你还有<color=red>%s批<color>物品没领取，请查收好本批物品后继续领取余下物品。", nCount);
	end
	Dialog:Say(szMsg);
end

function Compensate:WriteLog(pPlayer, szMsg)
	Dbg:WriteLog("SpecialEvent.Compensate", "补偿", pPlayer.szAccount, pPlayer.szName, szMsg);
end

function Compensate:LoadFile()
	self.tbTxt = {};
	local tbFile = Lib:LoadTabFile(self.FILE_PATH);
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		local szGateWay = string.sub(tbParam.GATEWAY_NAME, 5, 6);
		if self.tbTxt[szGateWay] == nil then
			self.tbTxt[szGateWay] = {}
		end
		local szAccount = string.upper(tbParam.ACCOUNT);
		if self.tbTxt[szGateWay][szAccount] == nil then
			self.tbTxt[szGateWay][szAccount] = {};
		end
		local nItemType = tonumber(tbParam.ITEM_TYPE) or 0;
		local nGenre, nDetail, nParticular = self:GetItemType2Item(nItemType);
		local nLevel =  tonumber(tbParam.ITEM_LEVEL) or 1;
		local nTimeLimit = tonumber(tbParam.TIME_LIMIT) or 10080;
		if nItemType > 0 and  nGenre ~= 0 and nDetail ~=0 and nParticular ~= 0 then
			local tbTemp = {
				tbItem = {nGenre,nDetail,nParticular,nLevel},
				nLimit = nTimeLimit}
			table.insert(self.tbTxt[szGateWay][szAccount], tbTemp);
		end
	end
	return self.tbTxt;
end

function Compensate:GetItemType2Item(nNum)
	local nGenre, nDetail, nParticular = 0,0,0;
	nParticular = math.mod(nNum, 2^12);
	nDetail = math.floor((math.mod(nNum, 2^24) / 2^12));
	nGenre = math.floor(nNum / (2^24) );
	return nGenre, nDetail, nParticular;
end

function Compensate:GetExtPointByte()
	local nExtTemp = me.GetExtPoint(self.EXT_POINT);
	if nExtTemp > 0 and math.floor(nExtTemp / 2^8) ~= self.EXT_BATCH then
		me.PayExtPoint(self.EXT_POINT, nExtTemp);
		nExtTemp = 0
	end
	return math.mod(nExtTemp, 2^8 * self.EXT_BATCH);
end

function Compensate:AddExtPointByte(nPoint)
	local nExtTemp = me.GetExtPoint(self.EXT_POINT);
	if nExtTemp >= 0 and math.floor(nExtTemp / 2^8) ~= self.EXT_BATCH then
		if nExtTemp > 0 then
			me.PayExtPoint(self.EXT_POINT, nExtTemp);
		end
		me.AddExtPoint(self.EXT_POINT, 2^8 * self.EXT_BATCH);
	end
	me.AddExtPoint(self.EXT_POINT, nPoint);
end

Compensate:LoadFile()