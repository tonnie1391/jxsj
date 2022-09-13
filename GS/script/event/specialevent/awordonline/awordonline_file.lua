-- 文件名　：awordonline_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-27 11:21:24
-- 描  述  ：
	SpecialEvent.tbAwordOnline = SpecialEvent.tbAwordOnline or {};
	local tbAwordOnline = SpecialEvent.tbAwordOnline;

function tbAwordOnline:Load()	
	local szFileName = "\\setting\\event\\specialevent\\awordonline.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nIdEx = tonumber(tbParam.nId) or 1;
			local nGenre  = tonumber(tbParam.Genre) or 0;
			local nDetailType = tonumber(tbParam.DetailType) or 0;
			local nParticularType = tonumber(tbParam.ParticularType) or 0;
			local nLevel = tonumber(tbParam.Level) or 0;
			local nNum = tonumber(tbParam.nNum) or 0;
			local nMoney = tonumber(tbParam.nMoney) or 0;
			local nBindMoney = tonumber(tbParam.BindMoney) or 0;
			local nBindCoin = tonumber(tbParam.BindCoin) or 0;
			local szInfomation = tbParam.Infomation or "";
			local nTimer1  = tonumber(tbParam.Ready1Time) or 0;
			local nTimer2 = tonumber(tbParam.Ready2Time) or 0;
			if not self.tbAword then
				self.tbAword = {};
			end
			if not self.tbAword_timer then
				self.tbAword_timer = {};
			end
			if not self.tbAword[nIdEx] then
				self.tbAword[nIdEx] = {};
			end
			if nTimer1 ~= 0 and nTimer2 ~= 0 then
				self.tbAword_timer[nIdEx] = {nTimer1, nTimer2, 0};
			end
			table.insert(self.tbAword[nIdEx],{{nGenre,nDetailType,nParticularType,nLevel}, nNum, nMoney, nBindMoney, nBindCoin, szInfomation});
		end
	end	
end

if  not MODULE_GC_SERVER then
	SpecialEvent.tbAwordOnline:Load();
end
