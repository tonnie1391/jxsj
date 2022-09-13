------------------------------------------------------
-- 文件名　：zhenyuansetting.lua
-- 创建者　：dengyong
-- 创建时间：2010-07-05 14:58:24
-- 功能    ：真元的配置表管理
------------------------------------------------------
Item.tbZhenYuanSetting  = {};

local tbZhenYuanSetting = Item.tbZhenYuanSetting;

tbZhenYuanSetting.PATH_SETTING		= "\\setting\\item\\001\\zhenyuansetting\\";

tbZhenYuanSetting.TEMPLATE_SETTING 	= "gensetting.txt";		-- 真元模板配置表
tbZhenYuanSetting.ATTRIB_SETTING	= "attribsetting.txt";  -- 属性配置表
tbZhenYuanSetting.PARTNERTOZHENYUAN	= "partnerconvert.txt";	-- 同伴转成真元相关配置表
tbZhenYuanSetting.RANK_INFO			= "rankinfo.txt";		-- 真元排名战斗力提升配置表
tbZhenYuanSetting.LEVEL_SETTING		= "levelsetting.txt";   -- 经验等级配置表

-- 存放这些配置数据的内存表
tbZhenYuanSetting.tbTemplateSetting			= {};	-- 真元模板配置表
tbZhenYuanSetting.tbAttribSetting 			= {};	-- 属性价值量和成长表
tbZhenYuanSetting.tbAttribNameToId 			= {};	-- 魔法属性名到魔法属性ID映射表
tbZhenYuanSetting.tbPartnerToZhenYuan 		= {};	-- 同伴转真元时相关数据
tbZhenYuanSetting.tbZhenYuanTempToPartnerId = {};	-- 真元模板到同伴ID的映射表
tbZhenYuanSetting.tbRankInfo				= {};	-- 真元排名与战斗力提升表
tbZhenYuanSetting.tbLevelSetting 			= {};	-- 真元经验等级配置表

tbZhenYuanSetting.ATTRIB_COUNT			= 4;	-- 属性个数
tbZhenYuanSetting.ATTRIBPOTEN_COUNT	 	= 20;	-- 属性资质档次数

-- tbTemplateSetting =
-- {
--		[nZhenyuanTempl] = {nAttribValueMin, nAttribValueMax, {{潜能资质随机模板1},{潜能资质随机模板1}, ..}};
-- }
function tbZhenYuanSetting:LoadTemplateSetting()
	local tbFile = Lib:LoadTabFile(self.PATH_SETTING..self.TEMPLATE_SETTING);
	if not tbFile then
		print("Tải list thiết lập module chân nguyên thất bại!");
		return;
	end	
	
	self.tbTemplateSetting = {};
	
	for _, tbValue in pairs(tbFile) do
		local nZhenyuanTempl = assert(tonumber(tbValue.ZhenYuanTemp));
		
		self.tbTemplateSetting[nZhenyuanTempl] = self.tbTemplateSetting[nZhenyuanTempl] or {};
		
		self.tbTemplateSetting[nZhenyuanTempl].tbAttribPotenRate = {};
		local nTempCount = 1;
		while(tbValue["AttribPoten1Rate"..nTempCount]) do
			local tb = {};
			for i = 1, self.ATTRIB_COUNT do
				tb["nAttribPoten"..i.."Rate"] = assert(tonumber(tbValue["AttribPoten"..i.."Rate"..nTempCount]));
				self.tbTemplateSetting[nZhenyuanTempl]["nAttrib"..i.."ValueMin"] = assert(tonumber(tbValue["Attrib"..i.."ValueMin"]));
				self.tbTemplateSetting[nZhenyuanTempl]["nAttrib"..i.."ValueMax"] = assert(tonumber(tbValue["Attrib"..i.."ValueMax"]));
			end
			nTempCount = nTempCount + 1;
			table.insert(self.tbTemplateSetting[nZhenyuanTempl].tbAttribPotenRate, tb);
		end
		--self.tbTemplateSetting[nZhenyuanTempl].nAttribValueMin = assert(tonumber(tbValue.AttribValueMin));	-- 单条属性的价值量最小值
		--self.tbTemplateSetting[nZhenyuanTempl].nAttribValueMax = assert(tonumber(tbValue.AttribValueMax));	-- 单条属性的价值量最大值
	end
end

-- 属性配置表（价值量和资质成长）
-- tbAttribSetting = 
-- {
--		[AttribId] = {szDesc, nWeight, StarLevel1Value, ..., StarLevel20Value, StarLevel1Growth, ..., StarLevel20Growth}
-- }
-- tbAttribNameToId =
-- {
-- 		[Desc] = {AttribId},
-- }
function tbZhenYuanSetting:LoadAttribSetting()
	local tbFile = Lib:LoadTabFile(self.PATH_SETTING..self.ATTRIB_SETTING);
	if not tbFile then
		print("Tải list thiết lập thuộc tính thất bại!");
		return;
	end
	
	self.tbAttribSetting = {};
	self.tbAttribNameToId = {};
	
	for _, tbValue in pairs(tbFile) do
		local nAttribId = tonumber(tbValue.AttribId);
		if not nAttribId then
			assert(false);
		end
		
		self.tbAttribSetting[nAttribId] = self.tbAttribSetting[nAttribId] or {};
		for i = 1, self.ATTRIBPOTEN_COUNT do
			local szKey = "StarLevel"..i.."Value";
			self.tbAttribSetting[nAttribId][szKey] = assert(tonumber(tbValue[szKey]));
			szKey = "StarLevel"..i.."Growth";
			self.tbAttribSetting[nAttribId][szKey] = assert(tonumber(tbValue[szKey]));
		end	
		
		self.tbAttribSetting[nAttribId].nWeight = assert(tonumber(tbValue.Weight));	
		self.tbAttribSetting[nAttribId].szDesc = tbValue.Desc;
		self.tbAttribSetting[nAttribId].szTipText = tbValue.TipText;
		self.tbAttribSetting[nAttribId].nMaxValue = assert(tonumber(tbValue.MaxValue));
		self.tbAttribSetting[nAttribId].szTipDesc = tbValue.TipDesc;
			
		self.tbAttribNameToId[tbValue.Desc] = {};
		self.tbAttribNameToId[tbValue.Desc] = nAttribId;
	end
end

-- 同伴转成真元相关配置表
-- tbPartnerToZhenYuan =
-- {
-- 		[nPartnerId] = {nZhenYuanTemp, G, D, P, L, szName},	
-- }
function tbZhenYuanSetting:LoadPartnerToZhenYuanSetting()
	local tbFile = Lib:LoadTabFile(self.PATH_SETTING..self.PARTNERTOZHENYUAN);
	if not tbFile then
		print("Tải list thiết lập số liệu từ đồng hành sang chân nguyên thất bại!");
	end
	
	self.tbPartnerToZhenYuan = {};
	self.tbZhenYuanTempToPartnerId = {};
	
	for _, tbValue in pairs(tbFile) do
		local nParterId = tonumber(tbValue.PartnerId);
		if not nParterId then
			assert(false);
		end
		
		self.tbPartnerToZhenYuan[nParterId] = self.tbPartnerToZhenYuan[nParterId] or {};
		self.tbPartnerToZhenYuan[nParterId].nZhenYuanTemp = tonumber(tbValue.ZhenYuanTemp);
		self.tbPartnerToZhenYuan[nParterId].G = tonumber(tbValue.G);
		self.tbPartnerToZhenYuan[nParterId].P = tonumber(tbValue.P);
		self.tbPartnerToZhenYuan[nParterId].D = tonumber(tbValue.D);
		self.tbPartnerToZhenYuan[nParterId].L = tonumber(tbValue.L);
		self.tbPartnerToZhenYuan[nParterId].szName = tbValue.Name;
		self.tbPartnerToZhenYuan[nParterId].szPartnerName = tbValue.PartnerName;
		self.tbPartnerToZhenYuan[nParterId].nValueRate = assert(tonumber(tbValue.CalValueRate));
		
		self.tbZhenYuanTempToPartnerId[tonumber(tbValue.ZhenYuanTemp)] = nParterId;
	end
end

-- 真元排名与战斗力提升表
-- tbRankInfo = 
-- {
-- 		[nRank] = nFightPower,
-- }
function tbZhenYuanSetting:LoadRankInfo()
	local tbFile = Lib:LoadTabFile(self.PATH_SETTING..self.RANK_INFO);
	if not tbFile then
		print("Tải list xếp hạng chân nguyên thất bại!");
	end
	
	self.tbRankInfo = {};
	
	for _, tbValue in pairs(tbFile) do
		local szRank = tbValue.Rank;
		local tb = Lib:SplitStr(szRank, "~");
		if not tb or #tb == 0 then
			assert(false);
		end
		
		if #tb == 1 then
			local nRank = assert(tonumber(tb[1]));
			self.tbRankInfo[nRank] = assert(tonumber(tbValue.FightPower));
		elseif #tb == 2 then
			local nRank1 = assert(tonumber(tb[1]));
			local nRank2 = assert(tonumber(tb[2]));
			local tbFightPower = Lib:SplitStr(tbValue.FightPower, "~");
			if #tbFightPower == 1 then
				self.tbRankInfo[nRank1] = assert(tonumber(tbFightPower[1]));
				self.tbRankInfo[nRank2] = assert(tonumber(tbFightPower[1]));
			elseif #tbFightPower == 2 then
				-- 排名小的战斗力值高，反之
				self.tbRankInfo[math.min(nRank1, nRank2)] = math.max(tbFightPower[1], tbFightPower[2]);
				self.tbRankInfo[math.max(nRank1, nRank2)] = math.min(tbFightPower[1], tbFightPower[2]);
			else
				assert(false);
			end
		else
			assert(false);
		end		
	end
end

-- 真元经验等级配置表
function tbZhenYuanSetting:LoadLevelSetting()
	local tbFile = Lib:LoadTabFile(self.PATH_SETTING..self.LEVEL_SETTING);
	if not tbFile then
		print("Tải list thiết lập cấp kinh nghiệm chân nguyên thất bại!");
	end
	
	self.tbLevelSetting = {};
	
	for _, tbValue in pairs(tbFile) do
		local nLevel = assert(tonumber(tbValue.Level));
		
		self.tbLevelSetting[nLevel] = self.tbLevelSetting[nLevel] or {};
		self.tbLevelSetting[nLevel].nNeedExp = tonumber(tbValue.NeedExp);
		self.tbLevelSetting[nLevel].nBaseExpPerMin = tonumber(tbValue.BaseExpPerMin);
		self.tbLevelSetting[nLevel].nLevelValue = tonumber(tbValue.LevelValue);
	end	
end

tbZhenYuanSetting:LoadAttribSetting();
tbZhenYuanSetting:LoadPartnerToZhenYuanSetting();
tbZhenYuanSetting:LoadRankInfo();
tbZhenYuanSetting:LoadTemplateSetting();
tbZhenYuanSetting:LoadLevelSetting();