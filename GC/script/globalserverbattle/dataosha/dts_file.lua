-- 文件名　：dts_file.lua
-- 创建者　：zounan/jiazhenwei
-- 创建时间：2009-10-14
-- 描  述  ：相关文件加载

--加载大会类型表
Require("\\script\\globalserverbattle\\dataosha\\dts_def.lua");
function DaTaoSha:LoadGameType()
	local tbFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\dataosha\\macth.txt");
	if not tbFile then
		print("【大逃杀】读取文件错误，文件不存在macth.txt");
		return;
	end
	self.MACTH_TYPE = {};	
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nLevel  = tonumber(tbParam.Level) or 1;
			local nReadyMap  = tonumber(tbParam.ReadyMap);
			local nMacthMap  = tonumber(tbParam.MacthMap);
			if not self.MACTH_TYPE[nLevel] then
				self.MACTH_TYPE[nLevel] = {};
				self.MACTH_TYPE[nLevel].tbReadyMap = {};
				self.MACTH_TYPE[nLevel].tbMacthMap = {};
			end		
			if nReadyMap then
				table.insert(self.MACTH_TYPE[nLevel].tbReadyMap, nReadyMap);
			end
			if nMacthMap then
				table.insert(self.MACTH_TYPE[nLevel].tbMacthMap, nMacthMap);
			end																						
		end
	end
	
	if MODULE_GC_SERVER then
		return 0;
	end	
		
	self.MACTH_BIRTH = {};	
	--加载pk场传入坐标
	local tbBirthFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\dataosha\\birth.txt");
	if not tbBirthFile then
		print("【大逃杀】读取文件错误，文件不存在trap.txt");
		return;
	end
	for nId, tbParam in ipairs(tbBirthFile) do
		local nRound = tonumber(tbParam.Round) or 1;
		if not self.MACTH_BIRTH[nRound] then
			self.MACTH_BIRTH[nRound] = {};
		end		
		local nPosX = math.floor((tonumber(tbParam.TRAPX) )/32);
		local nPosY = math.floor((tonumber(tbParam.TRAPY) )/32);
		table.insert(self.MACTH_BIRTH[nRound],{nPosX, nPosY});
	end
	--怪的刷新坐标
	self.MACTH_MONSTER_TRAP = {};	
	local tbMonsterFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\dataosha\\monstertrap.txt");
	if not tbMonsterFile then
		print("【大逃杀】读取文件错误，文件不存在monstertrap.txt");
		return;
	end
	for nId, tbParam in ipairs(tbMonsterFile) do
		local nRound = tonumber(tbParam.Round) or 1;
		if not self.MACTH_MONSTER_TRAP[nRound] then
			self.MACTH_MONSTER_TRAP[nRound] = {};
		end		
		local nPosX = math.floor((tonumber(tbParam.TRAPX))/32);
		local nPosY = math.floor((tonumber(tbParam.TRAPY))/32);
		table.insert(self.MACTH_MONSTER_TRAP[nRound],{nPosX, nPosY});
	end
	
	--商人坐标
	self.MACTH_MERCHANT_TRAP = {};	
	local tbMerchantFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\dataosha\\merchant.txt");
	if not tbMerchantFile then
		print("【大逃杀】读取文件错误，文件不存在merchant.txt");
		return;
	end
	for nId, tbParam in ipairs(tbMerchantFile) do
		local nRound = tonumber(tbParam.Round) or 1;
		if not self.MACTH_MERCHANT_TRAP[nRound] then
			self.MACTH_MERCHANT_TRAP[nRound] = {};
		end		
		local nPosX = math.floor((tonumber(tbParam.TRAPX) )/32);
		local nPosY = math.floor((tonumber(tbParam.TRAPY) )/32);
		table.insert(self.MACTH_MERCHANT_TRAP[nRound],{nPosX, nPosY});
	end	
	--瞬移符移动的点
	self.TRANS_POINT = {};	
	local tbTransPoint = Lib:LoadTabFile("\\setting\\globalserverbattle\\dataosha\\transpoint.txt");
	if not tbTransPoint then
		print("【大逃杀】读取文件错误，文件不存在transpoint.txt");
		return;
	end
	for nId, tbParam in ipairs(tbTransPoint) do
		local nRound = tonumber(tbParam.nRound);		
		local nPosX = math.floor((tonumber(tbParam.TRAPX) )/32);
		local nPosY = math.floor((tonumber(tbParam.TRAPY) )/32);
		if not self.TRANS_POINT[nRound] then
			self.TRANS_POINT[nRound] = {};
		end	
		table.insert(self.TRANS_POINT[nRound],{nPosX, nPosY});
	end	
end

if not MODULE_GAMECLIENT then
DaTaoSha:LoadGameType();
end
