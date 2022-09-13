-- 文件名  : chongji.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-17 13:10:12
-- 描述    :  冲级领奖活动

--VN--

SpecialEvent.tbVnChongji = SpecialEvent.tbVnChongji or {};
local tbVnChongji = SpecialEvent.tbVnChongji;
tbVnChongji.tbEquitLing = {18,1,992,1};
tbVnChongji.szFileName = "\\setting\\event\\specialevent\\item.txt";

function tbVnChongji:OnDialog()
	if me.GetRoleCreateDate() < 20100715 then
		Dialog:Say("你不满足条件吧！",{"知道了"});
		return;
	end
	if me.nLevel < 110 then
		Dialog:Say("等级达到110级就可以获得该奖励了！",{"知道了"});
		return;
	end
	if me.GetTask(2124,9) == 1 then
		Dialog:Say("你太贪心了吧，都领过了！",{"知道了"});
		return;
	end
	local nRate = MathRandom(10000);	
	local nRateSum = 0;
	for i, nRateEx in ipairs(self.tbRate) do
		nRateSum = nRateSum + nRateEx;
		if nRate <= nRateSum then
			if self.tbAwordItem[i] and #self.tbAwordItem[i] > 0 then
				local nIndex = MathRandom(#self.tbAwordItem[i]);
				local pItem = nil;
				if i <= 9 then
					pItem = me.AddItem(unpack(self.tbAwordItem[i][nIndex][1]));
				else
					pItem = me.AddItem(unpack(self.tbEquitLing));
					pItem.SetGenInfo(1, i);
					pItem.SetGenInfo(2, nIndex);
					pItem.Sync();
				end	
				me.AddBindCoin(20000);
				me.SetTask(2124,9,1);
				if pItem then
					Dbg:WriteLog("VnChongji", "冲级领奖活动", me.szAccount, me.szName, string.format("冲级领奖活动领取装备%s", pItem.szName));
				end
				
			end
			return;
		end		
	end
end

function tbVnChongji:LoadFile(szFileName)
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nIdEx = tonumber(tbParam.nId) or 0;
			local nIndex = tonumber(tbParam.Part) or 0;
			local nGenre = tonumber(tbParam.Genre) or 0;
			local nDetailType = tonumber(tbParam.DetailType) or 0;
			local nParticularType = tonumber(tbParam.ParticularType) or 0;
			local nLevel = tonumber(tbParam.Level) or 0;
			local nRate = tonumber(tbParam.Rate) or 0;
			local nSeries = tonumber(tbParam.Series) or 0;
			local nType = tonumber(tbParam.Type) or 0;
			local nSex = tonumber(tbParam.Sex) or 0;
			local szName = tbParam.Name or "";
			if not self.tbAwordItem then
				self.tbAwordItem = {};
			end
			if not self.tbRate then
				self.tbRate = {};
			end
			if nIndex > 0 then
				self.tbAwordItem[nIndex] = self.tbAwordItem[nIndex] or {};
				self.tbRate[nIndex] = self.tbRate[nIndex] or {};
				table.insert(self.tbAwordItem[nIndex], {{nGenre, nDetailType, nParticularType, nLevel}, szName, nSeries, nType, nSex});
				if nRate > 0 then
					self.tbRate[nIndex] = nRate;
				end
			end
		end
	end
end

SpecialEvent.tbVnChongji:LoadFile(SpecialEvent.tbVnChongji.szFileName);
