
if (not LifeSkill.tbLifeSkillDatas) then
	LifeSkill.tbLifeSkillDatas	= {};
end;

if (not LifeSkill.tbRecipeDatas) then
	LifeSkill.tbRecipeDatas = {};
end

if (not LifeSkill.tbKindMap) then
end

if (not LifeSkill.tbKindMap) then
end

if (not LifeSkill.tbStorageDatas) then
	LifeSkill.tbStorageDatas = {};
end
-------------------------------------------------------------------------
-- 从配置文件读取所有技能
function LifeSkill:LoadAllSkill()
	local tbNumColSet = {["ID"]=1, ["Gene"]=1, ["Belong"]=1, ["MaxLevel"]=1};
	local tbSkillSet = Lib:LoadTabFile(self.szSkillFilePath, tbNumColSet);
	local nSkillCount = 0;
	for _, tbSkill in pairs(tbSkillSet) do
		tbSkill.tbRecipeDatas = {};
		tbSkill.nRecipeCount = 0;
		assert(not self.tbLifeSkillDatas[tbSkill.ID])
		self.tbLifeSkillDatas[tbSkill.ID] = tbSkill;
		self:_AddSkillExpMap(tbSkill.ID);
		nSkillCount = nSkillCount + 1;
	end

	return nSkillCount;
end

-------------------------------------------------------------------------
-- 从配置文件读取所有配方
-- 新填绑定类型(0-默认属性,绑定和不绑定都可, 1-绑定, 2-不绑定)
function LifeSkill:LoadAllRecipe()
	local tbNumColSet = 
	{["ID"]=1, ["Kind"]=1, ["Storage"]=1, ["Consume"]=1,["Category"]=1,["Belong"]=1,["SkillLevel"]=1,["Cost"]=1,["ExpGain"]=1,["MakeTime"]=1,["AutoAppend"]=1,
		["Produce1Genre"]=1,["Produce1Detail"]=1,["Produce1Parti"]=1,["Produce1Level"]=1,["Produce1Luck"]=1,["Produce1Series"]=1,["Produce1Bind"]=1,["Produce1Rate"]=1,
		["Produce2Genre"]=1,["Produce2Detail"]=1,["Produce2Parti"]=1,["Produce2Level"]=1,["Produce2Luck"]=1,["Produce2Series"]=1,["Produce2Bind"]=1,["Produce2Rate"]=1,
		["Produce3Genre"]=1,["Produce3Detail"]=1,["Produce3Parti"]=1,["Produce3Level"]=1,["Produce3Luck"]=1,["Produce3Series"]=1,["Produce3Bind"]=1,["Produce3Rate"]=1,
		["Stuff1Genre"]=1,["Stuff1Detail"]=1,["Stuff1Parti"]=1,["Stuff1Level"]=1,["Stuff1Series"]=1,["Stuff1Bind"]=1,["Stuff1Num"]=1,
		["Stuff2Genre"]=1,["Stuff2Detail"]=1,["Stuff2Parti"]=1,["Stuff2Level"]=1,["Stuff2Series"]=1,["Stuff2Bind"]=1,["Stuff2Num"]=1,
		["Stuff3Genre"]=1,["Stuff3Detail"]=1,["Stuff3Parti"]=1,["Stuff3Level"]=1,["Stuff3Series"]=1,["Stuff3Bind"]=1,["Stuff3Num"]=1,
		["Stuff4Genre"]=1,["Stuff4Detail"]=1,["Stuff4Parti"]=1,["Stuff4Level"]=1,["Stuff4Series"]=1,["Stuff4Bind"]=1,["Stuff4Num"]=1,
		["Stuff5Genre"]=1,["Stuff5Detail"]=1,["Stuff5Parti"]=1,["Stuff5Level"]=1,["Stuff5Series"]=1,["Stuff5Bind"]=1,["Stuff5Num"]=1};
	local tbRecipeSet 	= Lib:LoadTabFile(self.szRecipeFilePath, tbNumColSet);
	
	local tbKindLib		= Lib:LoadTabFile(self.szKindFilePath, {["KindId"]=1});
	local tbKindMap		= {};
	for _, kind in ipairs(tbKindLib) do
		tbKindMap[kind.KindId] = kind.Name;
	end
	
	local tbCategoryLib = Lib:LoadTabFile(self.szCategoryFilePath, {["CategoryId"]=1});
	local tbCategoryMap = {};
	for _, category in ipairs(tbCategoryLib) do
		tbCategoryMap[category.CategoryId] = category.Name;
	end
	
	self.tbCost = {};
	local nRecipeCount = 0;
	for _, tbRecipe in ipairs(tbRecipeSet) do
		self.tbCost[tbRecipe.Produce1Genre..","..tbRecipe.Produce1Detail..","..tbRecipe.Produce1Parti..","..tbRecipe.Produce1Level] = tbRecipe.Cost
		tbRecipe.KindName = tbKindMap[tbRecipe.Kind] or tbRecipe.Kind;
		tbRecipe.CategoryName = tbCategoryMap[tbRecipe.Category] or tbRecipe.Category;
		tbRecipe.tbStuffSet = 
		{
			{
				tbItem = {tbRecipe.Stuff1Genre, tbRecipe.Stuff1Detail,  tbRecipe.Stuff1Parti, tbRecipe.Stuff1Level, tbRecipe.Stuff1Series},
				nBind  = tbRecipe.Stuff1Bind,
				nCount = tbRecipe.Stuff1Num,
			},
			{
				tbItem = {tbRecipe.Stuff2Genre, tbRecipe.Stuff2Detail,  tbRecipe.Stuff2Parti, tbRecipe.Stuff2Level, tbRecipe.Stuff2Series},
				nBind  = tbRecipe.Stuff2Bind,
				nCount = tbRecipe.Stuff2Num,
			},
			{
				tbItem = {tbRecipe.Stuff3Genre, tbRecipe.Stuff3Detail,  tbRecipe.Stuff3Parti, tbRecipe.Stuff3Level, tbRecipe.Stuff3Series},
				nBind  = tbRecipe.Stuff3Bind,
				nCount = tbRecipe.Stuff3Num,
			},
			{
				tbItem = {tbRecipe.Stuff4Genre, tbRecipe.Stuff4Detail,  tbRecipe.Stuff4Parti, tbRecipe.Stuff4Level, tbRecipe.Stuff4Series},
				nBind  = tbRecipe.Stuff4Bind,
				nCount = tbRecipe.Stuff4Num,
			},
			{
				tbItem = {tbRecipe.Stuff5Genre, tbRecipe.Stuff5Detail,  tbRecipe.Stuff5Parti, tbRecipe.Stuff5Level, tbRecipe.Stuff5Series},
				nBind  = tbRecipe.Stuff5Bind,
				nCount = tbRecipe.Stuff5Num,
			},
		}
		tbRecipe.tbProductSet = 
		{
			{ 
				tbItem = {tbRecipe.Produce1Genre, tbRecipe.Produce1Detail, tbRecipe.Produce1Parti, tbRecipe.Produce1Level, tbRecipe.Produce1Luck, tbRecipe.Produce1Series}, 
				nBind  = tbRecipe.Produce1Bind,
				nRate = tbRecipe.Produce1Rate 
			},
			{ 
				tbItem = {tbRecipe.Produce2Genre, tbRecipe.Produce2Detail, tbRecipe.Produce2Parti, tbRecipe.Produce2Level, tbRecipe.Produce2Luck, tbRecipe.Produce2Series}, 
				nBind  = tbRecipe.Produce2Bind,
				nRate = tbRecipe.Produce2Rate 
			},
			{ 
				tbItem = {tbRecipe.Produce3Genre, tbRecipe.Produce3Detail, tbRecipe.Produce3Parti, tbRecipe.Produce3Level, tbRecipe.Produce3Luck, tbRecipe.Produce3Series}, 
				nBind  = tbRecipe.Produce3Bind,
				nRate = tbRecipe.Produce3Rate 
			},
			
		}
		if tbRecipe.Storage == 1 then
			self.tbStorageDatas[tbRecipe.ID] = {nStartDate=0, nEndDate=0, nBelong=tbRecipe.Belong, nAutoAppend=tbRecipe.AutoAppend};
		end
		assert(not self.tbRecipeDatas[tbRecipe.ID]);
		self.tbRecipeDatas[tbRecipe.ID] = tbRecipe;
		self:_AddRecipeToSkill(tbRecipe);
		nRecipeCount = nRecipeCount + 1;
		
	end
	
	local tbEventRecipeLib = Lib:LoadTabFile(self.szEventRecipeFilePath, {["Id"]=1, ["StartDate"]=1, ["EndDate"]=1});
	for _, tbEvnetRecipe in ipairs(tbEventRecipeLib) do

		if not self.tbStorageDatas[tbEvnetRecipe.Id] then
			self.tbStorageDatas[tbEvnetRecipe.Id] = {};
		end
		self.tbStorageDatas[tbEvnetRecipe.Id].nStartDate = tbEvnetRecipe.StartDate;
		self.tbStorageDatas[tbEvnetRecipe.Id].nEndDate = tbEvnetRecipe.EndDate;
		
		if tbEvnetRecipe.EndDate < 0 or tbEvnetRecipe.StartDate < 0 then
			self.tbStorageDatas[tbEvnetRecipe.Id] = nil;
		end
	end
	
	return nRecipeCount;
end


-------------------------------------------------------------------------
-- 为指导技能添加所属配方表
function LifeSkill:_AddRecipeToSkill(tbRecipe)
	if (not tbRecipe) then
		assert(false);
	end
	local tbBelongSkill = self.tbLifeSkillDatas[tbRecipe.Belong];
	tbBelongSkill.tbRecipeDatas[tbBelongSkill.nRecipeCount + 1] = tbRecipe;
	tbBelongSkill.nRecipeCount = tbBelongSkill.nRecipeCount + 1;
end


-------------------------------------------------------------------------
-- 为指定技能添加所属经验表
function LifeSkill:_AddSkillExpMap(nSkillId)
	local tbSkillData = self.tbLifeSkillDatas[nSkillId];
	if (not tbSkillData) then
		assert(false);
		return;
	end
	local tbNumColSet = {["level"]=1, ["exp"]=1};
	local tbSkillExpMap = Lib:LoadTabFile(tbSkillData.LevelExp, tbNumColSet);
	tbSkillData.tbSkillExpMap = {};
	local nMaxLevel = 0;
	for _, row in pairs(tbSkillExpMap) do
		tbSkillData.tbSkillExpMap[row.level] = row.exp;
		if (nMaxLevel < row.level) then
			nMaxLevel = row.level;
		end
	end
	tbSkillData.nMaxLevel = nMaxLevel;
end

