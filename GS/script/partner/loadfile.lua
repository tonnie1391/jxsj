------------------------------------------------------
-- 文件名　：loadfile.lua
-- 创建者　：dengyong
-- 创建时间：2009-12-02 09:30:53
-- 描  述  ：为同伴读取相关的配置表文件
------------------------------------------------------

Require("\\script\\partner\\define.lua");

Partner.tbLevelSetting = {};	-- 经验等级表
Partner.tbPartnerAttrib = {};	-- 同伴属性表
Partner.tbNpcExp = {};			-- 怪物经验掉落表
Partner.tbSkillRule = {};		-- 技能生成规则表
Partner.tbSkillSetting = {};	-- 技能配置表	
Partner.tbSkillSeries = {};		-- 技能五行
Partner.tbPotentialTemp = {};	-- 潜能分配模板
Partner.tbStarLevel = {};		-- 星级表
Partner.tbBaseValue = {};		-- 基础价值表
Partner.tbMaintenance = {};		-- 维护价值表
Partner.tbTalentLevel = {};		-- 领悟度升级表
Partner.tbItemTalentValue = {};	-- 可以用来兑换领悟度的道具及价值量
Partner.tbPartnerExpBook = {};	-- 同伴经验书的经验添加方式
Partner.tbPartnerSkillTip = {};	-- 同伴技能TIP信息
Partner.tbPersuadeInfo = {};	-- NPC模板ID与同伴ID的映射关系

-- 等级、经验配置表
-- tbLevelSetting =
-- {
-- 	  [nLevel] = {[nExp],[nEarnExpBase],[nEarnFriendshipBase]},
-- }
function Partner:LoadLevelSetting()
	local szPath = self.SUPERPATH..self.LEVELSETTINGFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nLevel = tonumber(tbData.Level);
		if not nLevel then
			print("Partner:LoadLevelSetting(), \\setting\\partner\\levelsetting.txt[Level]项配置有误！");
			return;
		end
				
		if not self.tbLevelSetting[nLevel] then
			self.tbLevelSetting[nLevel] = {};
		end
		self.tbLevelSetting[nLevel].nExp = tonumber(tbData.Exp) or 0;	-- 升级需要经验		
	end
end

-- NPC经验掉落表
-- tbNpcExp =
-- {
-- 		[nLevel] = {[nJYExp],[nSLExp],[nJYFriendship],[nSLFriendship]},
-- }	
function Partner:LoadNpcExp()
	local szPath = self.SUPERPATH..self.NPCEXPFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nLevel = tonumber(tbData.NpcLevel);
		if not nLevel then
			print("Partner:LoadNpcExp(), \\setting\\partner\\npcexp.txt[NpcLevel]项配置有误！");
			return;
		end
		
		if not self.tbNpcExp[nLevel] then
			self.tbNpcExp[nLevel] = {};	
 		end
 		
 		self.tbNpcExp[nLevel].nJYExp = tonumber(tbData.JYExp) or 0;		-- 杀死精英获得的经验
		self.tbNpcExp[nLevel].nSLExp = tonumber(tbData.SLExp) or 0;		-- 杀死首领获得的经验
	end	
end

function Partner:LoadStarLevel()
	local szPath = self.SUPERPATH..self.STARLEVELFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nStarLevel = tonumber(tbData.StarLevel);
		if not nStarLevel then
			print("Partner:LoadStarLevel(), \\setting\\partner\\starlevel.txt[StarLevel]项配置有误！");
			return;
		end
		
		if not self.tbStarLevel[nStarLevel] then
			self.tbStarLevel[nStarLevel] = {};
		end
		
		self.tbStarLevel[nStarLevel].nStarValue = tonumber(tbData.StarValue) or 0;
		self.tbStarLevel[nStarLevel].szNameColor = tbData.NameColor;
		self.tbStarLevel[nStarLevel].nEmptyStar = tonumber(tbData.EmptyStar) or 0;
		self.tbStarLevel[nStarLevel].nFillStar = tonumber(tbData.FillStar) or 0;
	end
end

-- 领悟度等级表
function Partner:LoadTalentLevel()
	local szPath = self.SUPERPATH..self.TALENTLEVELFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nTalent = tonumber(tbData.Talent);
		if not nTalent then
			print("Partner:LoadTalentLevel(), \\setting\\partner\\talentlevel.txt[Talent]项配置有误！");
			return;
		end
		
		if not self.tbTalentLevel[nTalent] then
			self.tbTalentLevel[nTalent] = {};
		end
		
		self.tbTalentLevel[nTalent] = tonumber(tbData.Value) or 0;
	end	
end

-- tbItemTalentValue = 
-- {
-- 		[G_P_D_L] = {[nBindValue],[nUnBindValue]},
-- }
function Partner:LoadItemTalentValue()
	local szPath = self.SUPERPATH..self.ITEMTALENTVALUEFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local szIndex = string.format("%s_%s_%s_%s", tbData.G, tbData.D, tbData.P, tbData.L);
		
		if not self.tbItemTalentValue[szIndex] then
			self.tbItemTalentValue[szIndex] = {};
		end
		
		self.tbItemTalentValue[szIndex].nBindValue = tonumber(tbData.BindValue) or 0;
		self.tbItemTalentValue[szIndex].nUnBindValue = tonumber(tbData.UnBindValue) or 0;
	end
end


-- 同伴生成时相关属性表
-- tbPartnerAttrib = 
-- {
--    [nPartId] = {[nType],[nTypeLevel],[nLifeRatio], [nRate], ...},
-- }
function Partner:LoadPartnerAttrib()
	local szPath = self.SUPERPATH..self.PARTNERATTRIBFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end

	for _, tbData in pairs(tbFile) do
		local nPartId = tonumber(tbData.Id);
		if not nPartId then
			print("Partner:LoadPartnerAttrib(), \\setting\\partner\\partner.txt[Id]项配置有误！");
			return;
		end
		
		if not self.tbPartnerAttrib[nPartId] then
			self.tbPartnerAttrib[nPartId] = {};
		end
		self.tbPartnerAttrib[nPartId].nType = tonumber(tbData.Type) or 0;	  -- 同伴的类型
		self.tbPartnerAttrib[nPartId].nTypeLevel = tonumber(tbData.TypeLevel) or 0;	-- 同伴的类型等级
		self.tbPartnerAttrib[nPartId].nEffectNpcId = tonumber(tbData.EffectNpcId) or 0; -- 效果NPCID。
		self.tbPartnerAttrib[nPartId].nLifeRatio = tonumber(tbData.LifeRatio) or 0;	-- 可以被说服时的生命比例上限
		self.tbPartnerAttrib[nPartId].nRate = tonumber(tbData.Rate) or 0;		-- 被说服的概率
		self.tbPartnerAttrib[nPartId].IsDrop = tonumber(tbData.IsDrop) or 0; 	-- 是否掉落，0不掉落
		--self.tbPartnerAttrib[nPartId].szName = tbData.name;						-- 名字
	end
end

function Partner:LoadPersuadeInfo()
	local szPath = self.SUPERPATH..self.PERSUADEINFOFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		print("Partner:LoadPersuadeInfo()加载失败！")
		return;
	end
	
	self.tbPersuadeInfo = {};
	local tbColName = nil;
	for _, tbData in pairs(tbFile) do
		
		--加载列
		if not tbColName then
			for szKey in pairs(tbData) do
				if string.find(szKey, "NPCId") then
					tbColName = tbColName or {};
					table.insert(tbColName, szKey);
				end
			end
		end
		
		local nPartnerId = tonumber(tbData.PartnerId);
		for _, szKey in ipairs(tbColName) do
			local nNpcTempId = tonumber(tbData[szKey]);
			if nNpcTempId then
				if self.tbPersuadeInfo[nNpcTempId] then
					print("Partner:LoadPersuadeInfo(), PartnerId["..nPartnerId.."], "..szKey.." load again！");
					return;
				end
				self.tbPersuadeInfo[nNpcTempId] = nPartnerId;
			end
		end
	end		
end


-- 加载基础价值量表
function Partner:LoadBaseValue()
	local szPath = self.SUPERPATH..self.BASEVALUEFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		print("Partner:LoadBaseValue()加载失败");
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nType = tonumber(tbData.Type);
		if not nType then
			print("Partner:LoadBaseValue(), \\setting\\partner\\basevalue.txt[Type]项配置有误！");
			return;
		end
		
		if not self.tbBaseValue[nType] then
			self.tbBaseValue[nType] = {};
		end
		
		self.tbBaseValue[nType].nValueOf2Skills = tonumber(tbData.ValueOf2Skills) or 0;	-- 有两个技能时的默认价值量
		self.tbBaseValue[nType].nValueOf3Skills = tonumber(tbData.ValueOf3Skills) or 0; --   三
		self.tbBaseValue[nType].nValueOf4Skills = tonumber(tbData.ValueOf4Skills) or 0; --   四
		self.tbBaseValue[nType].nValueOf5Skills = tonumber(tbData.ValueOf5Skills) or 0; --   五
		self.tbBaseValue[nType].nValueOf6Skills = tonumber(tbData.ValueOf6Skills) or 0; --   六
		self.tbBaseValue[nType].nValueOf7Skills = tonumber(tbData.ValueOf7Skills) or 0; --   七
		self.tbBaseValue[nType].nValueOf8Skills = tonumber(tbData.ValueOf8Skills) or 0; --   八
		self.tbBaseValue[nType].nValueOf9Skills = tonumber(tbData.ValueOf9Skills) or 0; --   九
		self.tbBaseValue[nType].nValueOf10Skills = tonumber(tbData.ValueOf10Skills) or 0; -- 十
	end
end

function Partner:LoadMaintenance()
	local szPath = self.SUPERPATH..self.MAINTENANCEFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		print("Partner:LoadMaintenance()加载失败");
		return;
	end

	for _, tbData in pairs(tbFile) do
		local nSkillUpRate = tonumber(tbData.SkillUpRate);
		if not nSkillUpRate then
			print("Partner:LoadMaintenance(), \\setting\\partner\\maintenance.txt[SkillUpRate]项配置有误！");
			return;
		end
		
		if not self.tbMaintenance[nSkillUpRate] then
			self.tbMaintenance[nSkillUpRate] = {};
		end
		
		self.tbMaintenance[nSkillUpRate].nMaintenance = tonumber(tbData.Maintenance) or 0;
		self.tbMaintenance[nSkillUpRate].nTitleValue = tonumber(tbData.TitleValue) or 0;
	end
end

-- 技能生成规则表
--Partner.tbSkillRule =
--{
--	[nType]	= {....},
--}
function Partner:LoadSkillRule()
	local szPath = self.SUPERPATH..self.SKILLRULEFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nType = tonumber(tbData.Type);
		if not nType then
			print("Partner:LoadSkillRule(), \\setting\\partner\\skillrule.txt[Type]项配置有误！");
			return;
		end
		
		if not self.tbSkillRule[nType] then
			self.tbSkillRule[nType] = {};
		end
		self.tbSkillRule[nType].nLevelRequire = tonumber(tbData.LevelRequire) or 100;	-- 说服该档次NPC的等级限制，默认为100
		self.tbSkillRule[nType].nCalRate = tonumber(tbData.CalRate) or 1;	 -- 计算领悟度，亲密度的价值量权重
		self.tbSkillRule[nType].nRateOf2Skills = tonumber(tbData.RateOf2Skills) or 0;	-- 有两个技能的概率
		self.tbSkillRule[nType].nRateOf3Skills = tonumber(tbData.RateOf3Skills) or 0;	-- 有三个技能的概率
		self.tbSkillRule[nType].nRateOf4Skills = tonumber(tbData.RateOf4Skills)or 0;	-- 有四个技能的概率
		self.tbSkillRule[nType].nRateOf5Skills = tonumber(tbData.RateOf5Skills)or 0;	-- 有五个技能的概率
		self.tbSkillRule[nType].nRateOf6Skills = tonumber(tbData.RateOf6Skills)or 0;	-- 有六个技能的概率
		self.tbSkillRule[nType].nRateOf7Skills = tonumber(tbData.RateOf7Skills) or 0;	-- 有七个技能的概率
		self.tbSkillRule[nType].nRateOf8Skills = tonumber(tbData.RateOf8Skills) or 0;	-- 有八个技能的概率
		self.tbSkillRule[nType].nRateOf9Skills = tonumber(tbData.RateOf9Skills) or 0;	-- 有九个技能的概率
		self.tbSkillRule[nType].nRateOf10Skills = tonumber(tbData.RateOf10Skills) or 0;	-- 有十个技能的概率
		-- 如果必出技能格式为{id1,id2,id3,id4,id5}，读取的时候要去掉首尾的字符
		self.tbSkillRule[nType].nBichuSkill1Id = tbData.bichuSkill1Id;   -- 必出技能1ID
		self.tbSkillRule[nType].nBichuSkill2Id = tbData.bichuSkill2Id;   -- 必出技能2ID
		self.tbSkillRule[nType].nBichuSkill3Id = tbData.bichuSkill3Id;   -- 必出技能3ID
		if (string.find(tbData.bichuSkill1Id, "{*}")) then
			self.tbSkillRule[nType].nBichuSkill1Id = string.sub(tbData.bichuSkill1Id, 2, #tbData.bichuSkill1Id - 1);   -- 必出技能1ID
		end
		if (string.find(tbData.bichuSkill2Id, "{*}")) then
			self.tbSkillRule[nType].nBichuSkill2Id = string.sub(tbData.bichuSkill2Id, 2, #tbData.bichuSkill2Id - 1);   -- 必出技能2ID
		end
		if (string.find(tbData.bichuSkill3Id, "{*}")) then
			self.tbSkillRule[nType].nBichuSkill3Id = string.sub(tbData.bichuSkill3Id, 2, #tbData.bichuSkill3Id - 1);   -- 必出技能3ID
		end

		-- 随机技能模板ID
		self.tbSkillRule[nType].nRandomSkillTemplateId = tonumber(tbData.RandomSkillTemplateId) or 0;
	end
end
	
-- 同伴经验书
function Partner:LoadPartnerExpBook()
	local szPath = self.SUPERPATH..self.EXPBOOKFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nLevel = tonumber(tbData.nLevel);
		if not nLevel then
			print("Partner:LoadPartnerExpBook(), \\setting\\partner\\partnerexpbook.txt[nLevel]项有误！");
			return;
		end
		
		self.tbPartnerExpBook[nLevel] = tonumber(tbData.nBaseExp) or 0;
	end
end

-- 技能模板表
--Partner.tbSkillSetting =
--{
--	[nRandomSkillTemplateId] = 
--		{
--			{[nSkillid], [nSeries], [nRate]},
--		}
--}
function Partner:LoadSkillSetting()
	local szPath = self.SUPERPATH..self.SKIllSETTINGFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do	
		local nRandomSkillTemplateId = tonumber(tbData.RandomSkillTemplateId);
		if not nRandomSkillTemplateId then
			print("Partner:LoadSkillSetting(), \\setting\\partner\\skillsetting.txt[RandomSkillTemplateId]项配置有误！");
			return;
		end
		
		if not self.tbSkillSetting[nRandomSkillTemplateId] then
			self.tbSkillSetting[nRandomSkillTemplateId] = {};
		end
		
		local tbSkillGroup = {};
		tbSkillGroup.nSkillId = tonumber(tbData.SkillId) or 0;	-- 技能ID
		tbSkillGroup.nSeries = tonumber(tbData.Series) or -1;		-- 五行默认为-1
		tbSkillGroup.nRate = tonumber(tbData.Rate) or 0;			-- 权重
		
		table.insert(self.tbSkillSetting[nRandomSkillTemplateId], tbSkillGroup);
		
		self.tbSkillSeries[tbSkillGroup.nSkillId] = tonumber(tbData.Series) or -1;
	end
end

-- 加载潜能分配模板表
function Partner:LoadPotentialTemp()
	local szPath = self.SUPERPATH..self.POTENTIALTEMPFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nPotenTemplateId = tonumber(tbData.PotenTemplId);
		if not nPotenTemplateId then
			print("Partner:LoadPotentialTemp(), \\setting\\partner\\potential.txt[PotenTemplId]项配置有误！");
			return;
		end
		
		if not self.tbPotentialTemp[nPotenTemplateId] then
			self.tbPotentialTemp[nPotenTemplateId] = {};
		end
		
		self.tbPotentialTemp[nPotenTemplateId].nStrength = tonumber(tbData.Strength) or 0;
		self.tbPotentialTemp[nPotenTemplateId].nDexterity = tonumber(tbData.Dexterity) or 0;
		self.tbPotentialTemp[nPotenTemplateId].nVitality = tonumber(tbData.Vitality) or 0;
		self.tbPotentialTemp[nPotenTemplateId].nEnergy = tonumber(tbData.Energy) or 0;
		self.tbPotentialTemp[nPotenTemplateId].nRate = tonumber(tbData.Rate) or 0;
	end
end

-- 同伴技能TIP信息
function Partner:LoadPartnerSkillTipInfo()
	local szPath = self.SUPERPATH..self.PARTNERSKILLTIPFILENAME;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return;
	end
	
	for _, tbData in pairs(tbFile) do
		local nSkillId = tonumber(tbData.SkillId);
		if not nSkillId then
			print("Partner:LoadPartnerSkillTipInfo(), [SkillId]配置有误！");
			return;
		end
		
		if not self.tbPartnerSkillTip[nSkillId] then
			self.tbPartnerSkillTip[nSkillId] = {};
		end
		
		self.tbPartnerSkillTip[nSkillId].szDesc = tbData.SkillDesc;
		self.tbPartnerSkillTip[nSkillId].szName = tbData.SkillName;
	end
end

-- 读取所有相关的配置文件
Partner:LoadLevelSetting();		-- 等级、经验配置表
Partner:LoadStarLevel();		-- 星级表
Partner:LoadNpcExp();			-- NPC经验掉落表
Partner:LoadTalentLevel();
Partner:LoadItemTalentValue();
Partner:LoadPartnerAttrib();	-- 同伴生成时相关属性表
Partner:LoadBaseValue();		-- 默认价值量表
Partner:LoadMaintenance();		-- 维护表
Partner:LoadSkillRule();		-- 技能生成规则表
Partner:LoadPotentialTemp();	-- 潜能随机模板表
Partner:LoadPartnerSkillTipInfo() -- 同伴技能TIP
Partner:LoadPersuadeInfo();

if MODULE_GAMESERVER then
	Partner:LoadSkillSetting();		-- 技能模板表
	Partner:LoadPartnerExpBook();	-- 同伴经验书
end