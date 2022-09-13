-- 文件名　：awordonline_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-27 11:21:24
-- 描  述  ：

if  not MODULE_GAMESERVER then
	return;
end
Require("\\script\\event\\minievent\\newplayergift.lua");

SpecialEvent.tbAword = SpecialEvent.tbAword or {};
local tbAword = SpecialEvent.tbAword;

function tbAword:Load()	
	local szFileName = "\\setting\\event\\specialevent\\aword.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nGroup = tonumber(tbParam.nGroup) or 1;
			local nGroupEx = tonumber(tbParam.nGroupEx) or 1;
			local nType = tonumber(tbParam.nType) or 0;
			local nGenre  = tonumber(tbParam.Genre) or 0;
			local nDetailType = tonumber(tbParam.DetailType) or 0;
			local nParticularType = tonumber(tbParam.ParticularType) or 0;
			local nLevel = tonumber(tbParam.Level) or 0;
			local nNum = tonumber(tbParam.nNum) or 0;
			local nTime = tonumber(tbParam.nTime) or 0;
			local nMoney = tonumber(tbParam.nMoney) or 0;
			local nBindMoney = tonumber(tbParam.BindMoney) or 0;
			local nBindCoin = tonumber(tbParam.BindCoin) or 0;					
			local nReadyTime  = tonumber(tbParam.Ready1Time) or 0;
			local nPlayerLevel = tonumber(tbParam.nPlayerLevel) or 0;
			local nDay = tonumber(tbParam.nDay) or 0;
			if not self.tbAword then
				self.tbAword = {};
			end
			if not self.tbAword[nGroup] then
				self.tbAword[nGroup] = {};
			end
			if not self.tbAword_timer then
				self.tbAword_timer = {};
			end
			if not self.tbAword_Day then
				self.tbAword_Day = {};
			end
			if not self.tbAword[nGroup][nGroupEx] then
				self.tbAword[nGroup][nGroupEx] = {};
			end
			if nReadyTime ~= 0 then
				self.tbAword_timer[nGroupEx] = nReadyTime;
			end
			if nDay ~= 0 then
				self.tbAword_Day[nGroupEx] = nDay;
			end
			table.insert(self.tbAword[nGroup][nGroupEx],{nType, {nGenre,nDetailType,nParticularType,nLevel}, nNum, nMoney, nBindMoney, nBindCoin, nTime, nPlayerLevel});
			
			if EventManager.IVER_bOpenZaiXian == 1 and EventManager.IVER_bOpenZaiXian4 == 1 then
				self:ChangeData();
			end
		end
	end	
end

function tbAword:ChangeData()	
	if not self.tbAword[4] then
		return;
	end	
	SpecialEvent.NewPlayerGift.tbData = {};	
	for i, tbAwordEx in ipairs(self.tbAword[4]) do
		SpecialEvent.NewPlayerGift.tbData[i] = {};
		for _,tbAwordLevel in ipairs(tbAwordEx) do
			if #SpecialEvent.NewPlayerGift.tbData[i] <= 0 then
				table.insert(SpecialEvent.NewPlayerGift.tbData[i], 1, tbAwordLevel[8]);
			end
			if tbAwordLevel[5] > 0 then
				table.insert(SpecialEvent.NewPlayerGift.tbData[i],{"BindMoney",tbAwordLevel[5]});
			end
			if tbAwordLevel[6] > 0 then
				table.insert(SpecialEvent.NewPlayerGift.tbData[i],{"BindCoin",tbAwordLevel[6]});
			end
			if tbAwordLevel[3] > 0 then
				if tbAwordLevel[7] > 0 then
					table.insert(SpecialEvent.NewPlayerGift.tbData[i],{tbAwordLevel[2],tbAwordLevel[3],nil,tbAwordLevel[7]});
				else
					table.insert(SpecialEvent.NewPlayerGift.tbData[i],{tbAwordLevel[2],tbAwordLevel[3]});
				end
			end
		end
	end
	SpecialEvent.NewPlayerGift:Init();
end

SpecialEvent.tbAword:Load();
