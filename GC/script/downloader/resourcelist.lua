if not MODULE_GAMECLIENT or not MINI_CLIENT then return end
Require("\\script\\misc\\clientevent.lua")

local szReplaceFile = "\\setting\\downloader\\file_replace.txt";
MiniResource.tbMapExtRes = 
{
	["lingxiucun"] = "map_level_1",
	["xiangmiyuan"] = "map_level_5",
}

MiniResource.nShowInfo = 0;
local szBaseResKey = "base";

MiniResource.tbResource = 
{
	{szBaseResKey, "\\setting\\downloader\\reslist\\base.txt"},	-- 玩家基础资源，跑，站，基本UI
	{"map_level_1", "\\setting\\downloader\\reslist\\map_level_1.txt"},
	{"newtask_step_1_1", "\\setting\\downloader\\reslist\\newtask_step_1_1.txt"}, 	-- 新手任务
	{"newtask_step_1_2", "\\setting\\downloader\\reslist\\newtask_step_1_2.txt"}, 	-- 新手任务
	{"map_level_5", "\\setting\\downloader\\reslist\\map_level_5.txt"},				-- 玩家基础资源，跑，站
	{"icon", "\\setting\\downloader\\reslist\\icon.txt"},							-- 一些小图标
	{"first_weapon", "\\setting\\downloader\\reslist\\first_weapon.txt"},			-- 第一把武器
	{"newtask_step_2", "\\setting\\downloader\\reslist\\newtask_step_2.txt"}, 		-- 新手任务2
	{"player_base_2", "\\setting\\downloader\\reslist\\player_base_2.txt"},			-- 玩家资源(攻击，被击，死亡)
	{"fightskill_icon", "\\setting\\downloader\\reslist\\fightskill_icon.txt"},		-- 技能图标
  	{"map2130", "\\setting\\downloader\\reslist\\map\\shilianshanzhuang2\\element_res.txt"}, 	-- 10级副本
	{"newtask_step_3", "\\setting\\downloader\\reslist\\newtask_step_3.txt"}, 		-- 10级副本
	{"skill_effect_1", "\\setting\\downloader\\reslist\\skill_effect_1.txt"},		-- 10级副本特效
	{"map42", "\\setting\\downloader\\reslist\\map\\shunanzhuhai\\element_res.txt"},	-- 15级地图
	{"newtask_step_4", "\\setting\\downloader\\reslist\\newtask_step_4.txt"}, 		-- 15级地图
	{"ui", "\\setting\\downloader\\reslist\\ui.txt"},								-- 基本ui
	{"map2129", "\\setting\\downloader\\reslist\\map\\biluogu\\element_res.txt"},	-- 20级副本
	{"newtask_step_5", "\\setting\\downloader\\reslist\\newtask_step_5.txt"}, 		-- 20级地图
	{"skill_effect_2", "\\setting\\downloader\\reslist\\skill_effect_2.txt"},		-- 20级副本特效
	{"player_base_3", "\\setting\\downloader\\reslist\\player_base_3.txt"},			-- 马相关的
	{"task_item", "\\setting\\downloader\\reslist\\task_item.txt"},
	{"item_icon_1", "\\setting\\downloader\\reslist\\item_icon_1.txt"},	-- 装备小图标
	{"item_icon_2", "\\setting\\downloader\\reslist\\item_icon_2.txt"},	-- 其他道具小图标
	{"map22", "\\setting\\downloader\\reslist\\map\\tianwangbang\\element_res.txt"},
	{"map47", "\\setting\\downloader\\reslist\\map\\tianrenjiaojindi\\element_res.txt"},
	{"map48", "\\setting\\downloader\\reslist\\map\\jianxingfeng\\element_res.txt"},
	{"map52", "\\setting\\downloader\\reslist\\map\\baihuagu\\element_res.txt"},
	{"map55", "\\setting\\downloader\\reslist\\map\\qingluodao\\element_res.txt"},
	{"map36", "\\setting\\downloader\\reslist\\map\\yandanglongqiu\\element_res.txt"},
	{"map31", "\\setting\\downloader\\reslist\\map\\longmenkezhan\\element_res.txt"},
	{"map15", "\\setting\\downloader\\reslist\\map\\gaibang\\element_res.txt"},
	{"map60", "\\setting\\downloader\\reslist\\map\\yanziwu\\element_res.txt"},
	{"map64", "\\setting\\downloader\\reslist\\map\\yuanshisenlin\\element_res.txt"},
	{"task_npc_01", "\\setting\\downloader\\reslist\\task_npc_01.txt"},
	{"task_npc_02", "\\setting\\downloader\\reslist\\task_npc_02.txt"},
	{"task_npc_03", "\\setting\\downloader\\reslist\\task_npc_03.txt"},
	{"task_npc_04", "\\setting\\downloader\\reslist\\task_npc_04.txt"},
	{"task_npc_05", "\\setting\\downloader\\reslist\\task_npc_05.txt"},
	{"task_npc_06", "\\setting\\downloader\\reslist\\task_npc_06.txt"},
	{"task_npc_07", "\\setting\\downloader\\reslist\\task_npc_07.txt"},
	{"map4", "\\setting\\downloader\\reslist\\map\\daoxiangcun\\element_res.txt"},
	{"map7", "\\setting\\downloader\\reslist\\map\\longquancun\\element_res.txt"},
	{"map8", "\\setting\\downloader\\reslist\\map\\balingxian\\element_res.txt"},
	{"map5", "\\setting\\downloader\\reslist\\map\\jiangjincun\\element_res.txt"},
	{"map6", "\\setting\\downloader\\reslist\\map\\shiguzhen\\element_res.txt"},
	{"map3", "\\setting\\downloader\\reslist\\map\\yonglezhen\\element_res.txt"},
	{"map1", "\\setting\\downloader\\reslist\\map\\yunzhongzhen\\element_res.txt"},
	{"map2", "\\setting\\downloader\\reslist\\map\\longmenzhen\\element_res.txt"},
	{"map23", "\\setting\\downloader\\reslist\\map\\bianjingfu\\element_res.txt"},
	{"map24", "\\setting\\downloader\\reslist\\map\\fengxiangfu\\element_res.txt"},
	{"map25", "\\setting\\downloader\\reslist\\map\\xiangyangfu\\element_res.txt"},
	{"map26", "\\setting\\downloader\\reslist\\map\\yangzhoufu\\element_res.txt"},
	{"map27", "\\setting\\downloader\\reslist\\map\\chengdufu\\element_res.txt"},
	{"map28", "\\setting\\downloader\\reslist\\map\\dalifu\\element_res.txt"},
	{"map29", "\\setting\\downloader\\reslist\\map\\linanfu\\element_res.txt"},
	{"map16", "\\setting\\downloader\\reslist\\map\\emeipai\\element_res.txt"},
	{"map51", "\\setting\\downloader\\reslist\\map\\jiulaofeng\\element_res.txt"},
	{"map63", "\\setting\\downloader\\reslist\\map\\hupanzhulin\\element_res.txt"},
	{"map72", "\\setting\\downloader\\reslist\\map\\baihuazhen\\element_res.txt"},
	{"map57", "\\setting\\downloader\\reslist\\map\\jinguohuangling\\element_res.txt"},
	{"map58", "\\setting\\downloader\\reslist\\map\\bingxuemigong\\element_res.txt"},
	{"map62", "\\setting\\downloader\\reslist\\map\\baihuazhen\\element_res.txt"},
	{"map65", "\\setting\\downloader\\reslist\\map\\luweidang\\element_res.txt"},
	{"map59", "\\setting\\downloader\\reslist\\map\\longhuhuanjing\\element_res.txt"},
	{"map66", "\\setting\\downloader\\reslist\\map\\talin\\element_res.txt"},
	{"map67", "\\setting\\downloader\\reslist\\map\\jinguohuangling\\element_res.txt"},
	{"map68", "\\setting\\downloader\\reslist\\map\\bingxuemigong\\element_res.txt"},
	{"map75", "\\setting\\downloader\\reslist\\map\\luweidang\\element_res.txt"},
};

function MiniResource:Init()
	self.tbReplaceFile = {};
	local tbFileData = Lib:LoadTabFile(szReplaceFile);
	for _, tbItem in ipairs(tbFileData) do
		self.tbReplaceFile[tbItem["Source"]] = tbItem["Dest"];
	end
end

function MiniResource:GetGroupName(nStep)
	if (not MiniResource.tbResource[nStep]) then
		return nil
	end
	return MiniResource.tbResource[nStep][1];
end

function MiniResource:GetGroupStep(szGroupName)
	for i = 1, #MiniResource.tbResource do
		if (MiniResource.tbResource[i][1] == szGroupName) then
			return i;
		end
	end
end

function MiniResource:IsGroupExist(szGroupName)
	for _, tbItem in ipairs(self.tbResource) do
		if (tbItem[1] == szGroupName) then
			return 1;
		end
	end
	
	return 0;
end

-- 获得一个组的资源列表，去掉已经下载的，替换资源的
function MiniResource:GetGroupResourceList(nStep)
	assert(nStep <= #self.tbResource);
	local tbResList = {};
	local cFileSource = self.tbResource[nStep][2];
	if (type(cFileSource) == "string") then
		local tbFileData = Lib:LoadTabFile(cFileSource);
		if (not tbFileData) then
			print(cFileSource, "can not open.")
		end
		assert(tbFileData);
		for _, v in ipairs(tbFileData) do
			tbResList[#tbResList + 1] = v["ResPath"];
		end
	elseif (type(cFileSource) == "table") then
		tbResList = cFileSource;
	else
		print(type(cFileSource));
		assert(false);
	end	
	
	-- 去掉替换资源
	local tbRet = {};
	for _, szFile in ipairs(tbResList) do
		local szSubstitute = self.tbReplaceFile[szFile];
		if (not szSubstitute) then
			tbRet[#tbRet+1] = szFile;
		elseif (szSubstitute ~= "") then
			tbRet[#tbRet+1] = szSubstitute;
		end
	end
	
	return tbRet;
end

-- 测试看当前步骤是否完成
function MiniResource:FirstStep()
	self.nCurrStep = 0;
	self:GoNextStep();
end

function MiniResource:CheckStepState()
	local tbFileList = self:GetGroupResourceList(self.nCurrStep);
	local nPercent = GetResourceCompletePercent(tbFileList);
	self:ShowInfo("【资源】"..self:GetGroupName(self.nCurrStep).."完成"..nPercent.."%");
	if (nPercent >= 100) then
		if (self.tbResource[self.nCurrStep][3]) then
			Lib:CallBack({self.tbResource[self.nCurrStep][3], self.tbResource[self.nCurrStep][1]});
		end
		self:GoNextStep();
	end
end

function MiniResource:GoNextStep()
	if (self.nCurrStep + 1 > #self.tbResource) then
		return;
	end
	
	self.nCurrStep = self.nCurrStep + 1;
	
	local tbFileList = self:GetGroupResourceList(self.nCurrStep);
	assert(tbFileList);
	
	RequestMultiResource(1, tbFileList);
	self:ShowInfo("【资源】"..self:GetGroupName(self.nCurrStep).."开始下载");
end

function MiniResource:InsertNpcResource(strKey)
	if (self:IsGroupExist(strKey) == 1) then
		return 1;
	end
	
	local tbData = GetNpcResourceList(strKey);
	assert(tbData);
	table.insert(self.tbResource, {strKey, tbData, NpcResourceComplete});
	self:ShowInfo("插入资源"..strKey);
end

function MiniResource:OnClientStart()
	Timer:Register(Env.GAME_FPS * 2, self.CheckStepState, self);
end

function MiniResource:ShowInfo(szMsg)
	if (MiniResource.nShowInfo == 1) then
		me.Msg(szMsg);
	end
end

ClientEvent:RegisterClientStartFunc(MiniResource.OnClientStart, MiniResource)

MiniResource:Init();
MiniResource:FirstStep();

------------------------------------------------------------------------------
function MiniResource:GetMapRes(strMapName)
	MiniResource.tbMapRes = MiniResource.tbMapRes or {};
	if (MiniResource.tbMapRes[strMapName]) then
		return MiniResource.tbMapRes[strMapName];
	end
	
	local tbResList = {};
	-- 路径文件
	table.insert(tbResList, "\\map_publish\\" .. strMapName .. "\\path.txt")
	
	-- 地图逻辑
	local strWorFileName =  "\\map_publish\\" .. strMapName .. ".wor"
	local tbWorFileData = Lib:LoadIniFile(strWorFileName);
	assert(tbWorFileData);
	local szRect = tbWorFileData["MAIN"]["rect"]
	local _, _, left, top, right, bottom = string.find(szRect, "(%d+),(%d+),(%d+),(%d+)")
	local strFormat = "\\map_publish\\" .. strMapName .. "\\v_%03d\\%03d_region_c.dat"
	for v = top, bottom do 
		for h = left, right do
			table.insert(tbResList, string.format(strFormat, v, h))
		end
	end
	
	-- 地图资源
	local strResFileName =  "\\setting\\downloader\\reslist\\map\\" .. strMapName .. "\\element_res.txt"
	local tbResFileData = Lib:LoadTabFile(strResFileName)
	if (tbResFileData) then
		for _, v in ipairs(tbResFileData) do
			table.insert(tbResList, v["ResPath"])
		end
	end
	
	-- 基础资源，第一次进入地图下载
	local nStep = self:GetGroupStep(szBaseResKey);
	assert(nStep);
	if (self.nCurrStep <= nStep) then
		local tbResEx = self:GetGroupResourceList(nStep);
		for _, szResFile in ipairs(tbResEx) do
			table.insert(tbResList, szResFile);
		end
	end
	
	-- 特殊处理
	local strExtResKey = MiniResource.tbMapExtRes[strMapName];
	if (strExtResKey) then
		local nStep = self:GetGroupStep(strExtResKey);
		if (nStep) then
			local tbResEx = self:GetGroupResourceList(nStep);
			for _, szResFile in ipairs(tbResEx) do
				table.insert(tbResList, szResFile);
			end
		else
			print(strMapName,strExtResKey, "is not exist.");
		end
	else
		print(strMapName, "have not ext file");
	end

	-- 去掉替换资源
	local tbRet = {};
	for _, szFile in ipairs(tbResList) do
		local szSubstitute = self.tbReplaceFile[szFile];
		if (not szSubstitute) then
			tbRet[#tbRet+1] = szFile;
		elseif (szSubstitute ~= "") then
			tbRet[#tbRet+1] = szSubstitute;
		end
	end
	
	MiniResource.tbMapRes[strMapName] = tbRet;
	
	return tbRet;
end

function MiniResource:EnterMap(strMapName)
	MiniResource.tbCompleteMap = MiniResource.tbCompleteMap or {};
	if (MiniResource.tbCompleteMap[strMapName] == 1) then
		return 1;
	end
	
	local tbResList = self:GetMapRes(strMapName);
	RequestMultiResource(130, tbResList);
	if (MiniResource.nMapCheckTimerId) then
		Timer:Close(MiniResource.nMapCheckTimerId);
		MiniResource.nMapCheckTimerId = nil;
	end
	LoadingProgress(0);
	MiniResource.nMapCheckTimerId = Timer:Register(Env.GAME_FPS * 2, self.CheckMapState, self, strMapName);
	
	me.CallServerScript({"MiniDownloadInfoCmd", "ClientSyncMapState", 0});
	if (MiniResource.nDownloadInfoTimer) then
		Timer:Close(MiniResource.nDownloadInfoTimer);
		MiniResource.nMapCheckTimerId = nil;
	end
	MiniResource.nDownloadInfoTimer = Timer:Register(Env.GAME_FPS * 10, self.SyncDownloadInfo, self);
end

function MiniResource:CheckMapState(strMapName)
	local tbResList = self:GetMapRes(strMapName);
	local nPercent = GetResourceCompletePercent(tbResList);
	LoadingProgress(nPercent);
	if (nPercent >= 100) then
		MiniResource:OnMapLoadFinish(strMapName);
	end
end

function MiniResource:SyncDownloadInfo()
	local tbInfo = GetMiniDownloadInfo();
	if not tbInfo then
		Timer:Close(MiniResource.nDownloadInfoTimer);
		MiniResource.nMapCheckTimerId = nil;
		return 0;
	end
	local szStep = self:GetGroupName(self.nCurrStep);
	local nSpeed = math.floor(tbInfo.nActualSpeed * 100/1024)/100;
	local nPercent = tbInfo.nPercent;
	
	me.CallServerScript({"MiniDownloadInfoCmd", "ClientSendMiniDowloadInfo2", szStep, nSpeed, nPercent});
end

function MiniResource:OnMapLoadFinish(strMapName)
	self:ShowInfo("地图"..strMapName.."完成");
	if (MiniResource.nMapCheckTimerId) then
		Timer:Close(MiniResource.nMapCheckTimerId);
		MiniResource.nMapCheckTimerId = nil;
	end
	
	MiniResource.tbMapRes[strMapName] = nil;
	MiniResource.tbCompleteMap[strMapName] = 1;
	
	-- 通知自动寻路地图资源加载完成事件
	UiNotify:OnNotify(UiNotify.emCOREEVENT_AUTOPATH_DELAYLOAD_SUCC);
	
	me.CallServerScript({"MiniDownloadInfoCmd", "ClientSyncMapState", 1});
	if (MiniResource.nDownloadInfoTimer) then
		Timer:Close(MiniResource.nDownloadInfoTimer);
		MiniResource.nMapCheckTimerId = nil;
	end
end
