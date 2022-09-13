-- 文件名　：coinexception.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-08-29 10:26:49
-- 描述：金币异常的统一log处理

Log.szCoinExceptionDir = "..\\gamecenter\\log\\coinexception\\";

--金币相关的几种类型
Log.tbCoinExceptionType = 
{
	[1] = "Auction";	--拍卖行	
	[2] = "Trade";		--玩家交易
	[3] = "IbShop";		--奇珍阁
	[4] = "JbExchange";	--金币交易所
}

function Log:RecordCoinException(nType,szPayoutPlayerName,szIncomePlayerName,nCoin,szInfo)
	self:WriteCoinException(nType,szPayoutPlayerName,szIncomePlayerName,nCoin,szInfo);	
	return 1;
end

function Log:WriteCoinException(nType,szPayoutPlayerName,szIncomePlayerName,nCoin,szInfo)
	if not nType or not self.tbCoinExceptionType[nType] or not szInfo or szInfo == "" then
		return 0;
	end
	local szDate = tostring(os.date("%Y_%m_%d",GetTime()));
	local szGate = GetGatewayName();
	local szFileName = string.format("%s%s_%s.txt",self.szCoinExceptionDir,szGate,szDate);
	local szLineInfo = self:FormatInfo(nType,szPayoutPlayerName,szIncomePlayerName,nCoin,szInfo);
	if not KFile.ReadTxtFile(szFileName) then
		local szTitle = string.format("Date\tType\tPayoutPlayer\tIncomePlayer\tCoin\tDetails\n")
		KFile.WriteFile(szFileName,szTitle);
		KFile.AppendFile(szFileName,szLineInfo);
	else
		KFile.AppendFile(szFileName,szLineInfo);
	end
	return 1;
end

function Log:FormatInfo(nType,szPayoutPlayerName,szIncomePlayerName,nCoin,szInfo)
	local szType = self.tbCoinExceptionType[nType];
	local szDate = tostring(os.date("%Y%m%d%H%M%S",GetTime()));
	local szLineInfo = string.format("%s\t%s\t%s\t%s\t%d\t%s\n",szDate,szType,szPayoutPlayerName,szIncomePlayerName,nCoin,szInfo);
	return szLineInfo;
end


