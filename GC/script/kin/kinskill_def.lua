-- 文件名　：kinskill_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-06-16 15:20:23
--

if not Kin then --调试需要
	Kin = {};
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
end

--记录家族脚本临时数据
if not Kin.tbKinSkill then
	Kin.tbKinSkill = {};
end

Kin.tbKinSkill.Open = 1;

Kin.TASK_GROUP = 2168;
Kin.TASK_SKILLOFFER = 1;			--家族技能贡献度
--Kin.TASK_SKILLOFFER_DAY = 2;		--家族技能周贡献度(每周)
--Kin.TASK_SKILLOFFER_WEEK = 3;	--家族技能周贡献度时间

--Kin.nMaxPoint = 1000;			--每周能获得的最大贡献值
--Kin.nPersonMax = 350;			--家族周目标个人达到最大值

Kin.nLostMaxPoint = 700;		--每次加入家族损失技能贡献值最大值

--load技能相关表
function Kin:LoadKinSkill()
	--升级经验
	local szFileSkillExp = "\\setting\\kin\\skilllevel.txt";	
	local tbFile = Lib:LoadTabFile(szFileSkillExp);
	if not tbFile then
		print("【家族技能】读取文件错误，文件不存在",szFileSkillExp);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nLevel = tonumber(tbParam.Level) or 0;
			local nExp = tonumber(tbParam.Exp) or 0;		
			
			if nLevel > 0 then
				self.tbKinSkill.tbLevelExp[nLevel] = nExp;
			end
		end
	end
	local szFileSkillInfo = "\\setting\\kin\\kinskill.txt";
	--技能详细情况
	local tbFileEx = Lib:LoadTabFile(szFileSkillInfo);
	if not tbFileEx then
		print("【家族技能】读取文件错误，文件不存在",szFileSkillInfo);
		return;
	end
	for nId, tbParam in ipairs(tbFileEx) do
		if nId >= 1 then
			local nGenreId = tonumber(tbParam.GenreId) or 0;
			local nDetailId = tonumber(tbParam.DetailId) or 0;
			local nSkillId = tonumber(tbParam.SkillId) or 0;
			local nPassive = tonumber(tbParam.Passive) or 0;
			local szLevelTable = tbParam.LevelTable or "";
			local szSkillName = tbParam.SkillName or "";
			local szSkillSpr = tbParam.SkillSpr or "";
			local szSkillInfo = tbParam.SkillInfo or "";
			local nTaskId = tonumber(tbParam.TaskId) or 0;
			local szGenreInfo = tbParam.GenreInfo or "";
			local szDetailInfo = tbParam.DetailInfo or "";			
			local szSkillEffectSpr = tbParam.SkillEffectSpr or "";
			if nGenreId <= 0 or nDetailId <= 0 or nSkillId <= 0 then
				print("【家族技能】家族技能id错误", szFileSkillInfo, nId);
			end
			self.tbKinSkill.tbSkillInfo[nGenreId] = self.tbKinSkill.tbSkillInfo[nGenreId] or {};
			self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId] = self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId] or {};
			self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId] = self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId] or {};
			self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId] = {szSkillName = szSkillName, szSkillSpr = szSkillSpr,szSkillEffectSpr = szSkillEffectSpr, szSkillInfo = szSkillInfo, nTaskId = nTaskId, nPassive = nPassive, szLevelTable=szLevelTable, tbCondition = {}};
			for i =1, 10 do
				local sz = "Condition"..i;
				local nCondition = tonumber(tbParam[sz]) or -1;
				self.tbKinSkill.tbSkillInfo[nGenreId][nDetailId][nSkillId].tbCondition[i]= nCondition;
			end
			--描述
			self.tbKinSkill.tbInfo[nGenreId] = self.tbKinSkill.tbInfo[nGenreId] or {};
			self.tbKinSkill.tbInfo[nGenreId][nDetailId] = self.tbKinSkill.tbInfo[nGenreId][nDetailId] or {};
			if szGenreInfo ~= "" then
				self.tbKinSkill.tbInfo[nGenreId].szGenreInfo = szGenreInfo;
			end			
			if szDetailInfo ~= "" then
				self.tbKinSkill.tbInfo[nGenreId][nDetailId] = szDetailInfo;
			end			
		end
	end
end

--初始化家族技能
function Kin:InitKinSkill()
	self.tbKinSkill.tbLevelExp = {};
	self.tbKinSkill.tbSkillInfo = {};
	self.tbKinSkill.tbInfo = {};
	self:LoadKinSkill();
end

--初始化家族技能
Kin:InitKinSkill();
