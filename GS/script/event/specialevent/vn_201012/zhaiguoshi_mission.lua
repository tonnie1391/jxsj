-- 文件名  : zhaiguoshi.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-11-17 12:12:43
-- 描述    :  摘果实

--VN--
if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\vn_201012\\zhaiguoshi_def.lua");

SpecialEvent.tbZaiGuoShi.Mission = SpecialEvent.tbZaiGuoShi.Mission or Mission:New();
local tbMission = SpecialEvent.tbZaiGuoShi.Mission;

tbMission.nStartTime1 = 300;	--生长开始阶段
tbMission.nStartTime2 = 600;	--生长开始阶段
tbMission.nSecondtTime = 60;	--生长中间阶段
tbMission.nEndTime = 180;	--生长结束阶段

tbMission.tbPostion = {};					--位置信息{nMapId， nX， nY}
tbMission.tbTreeId = {7227,7228,7229};		--每个阶段树id
tbMission.nTreeIndex = 1;				--树阶段标志位
tbMission.nMaxTreeIndex = #tbMission.tbTreeId;	--树最大阶段数
tbMission.tbPlantedTree ={};				--已经种的树{[nNpcId] = 1} 表示种的树，还没有被删掉的
tbMission.szFile = "\\setting\\event\\specialevent\\zhaiguoshi.txt";
local tbPox = Lib:LoadTabFile(tbMission.szFile);
tbMission.tbMsg = {
	"摘果实活动已经开始，侠客们快去找树园老板参加债果树活动!";
	"种子已经萌芽，长成了小树苗了!";
	"桃树苗开花了，很快就要成熟了，快去准备采果子了！";
	"桃树开始结果子了，快去采集果子。";
	}

if tbPox then
	for _, pos in ipairs(tbPox) do
	    table.insert(tbMission.tbPostion, {tonumber(pos["MAPID"]), tonumber(pos["TRAPX"])/32, tonumber(pos["TRAPY"])/32});
	end
end

-- 开启活动
function tbMission:StartGame()	
	self.tbMisEventList	= 	--mission时间表
	{
		{"Msg2Server", Env.GAME_FPS, "Msg2Server" },
		{"Plant1Tree", Env.GAME_FPS * self.nStartTime1, "StartPlantOne"},
		{"Plant2Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"Plant3Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"DelTree", Env.GAME_FPS * self.nEndTime, "DelTree"},
		{"Plant1Tree", Env.GAME_FPS * self.nStartTime2, "StartPlantOne"},
		{"Plant2Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"Plant3Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"DelTree", Env.GAME_FPS * self.nEndTime, "DelTree"},
		{"Plant1Tree", Env.GAME_FPS * self.nStartTime1, "StartPlantOne"},
		{"Plant2Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"Plant3Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"DelTree", Env.GAME_FPS * self.nEndTime, "DelTree"},
		{"Plant1Tree", Env.GAME_FPS * self.nStartTime1, "StartPlantOne"},
		{"Plant2Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"Plant3Tree", Env.GAME_FPS * self.nSecondtTime, "StartPlantOne"},
		{"DelTree", Env.GAME_FPS * self.nEndTime, "DelTree"},
	};
	self.nStateJour 	= 0;
	self.tbGroups	= {};	
	self.tbPlayers	= {};	
	self.tbTimers	= {};
	self:GoNextState()	-- 开始报名
end

function tbMission:Msg2Server(nNum)
	if not nNum then
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL,self.tbMsg[1]);
	else
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL,self.tbMsg[nNum]);
	end
end

--开始一轮种树
function tbMission:StartPlantOne()
	self:DelTree();
	for _, tbPostionEx in ipairs(self.tbPostion) do
		if SubWorldID2Idx(tbPostionEx[1]) >= 0 then
			self:PlantTree(self.nTreeIndex, tbPostionEx[1], tbPostionEx[2], tbPostionEx[3]);
		end		
	end
	self:Msg2Server(self.nTreeIndex + 1);
	self.nTreeIndex = self.nTreeIndex + 1;
	if self.nTreeIndex > self.nMaxTreeIndex then
		self.nTreeIndex = 1;
	end	
end

--种树
function tbMission:PlantTree(nTreeIndex, nMapId, x, y)
	local nNpcId = self.tbTreeId[nTreeIndex];
	if nNpcId then
		local pNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y);
		if pNpc then
			pNpc.GetTempTable("Npc").tbMission = self;
			self.tbPlantedTree = self.tbPlantedTree or {};
			self.tbPlantedTree[pNpc.dwId] = 1;
		end
	end
end

--删树
function tbMission:DelTree()
	for nNpcId,_ in pairs(self.tbPlantedTree) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
end

--摘果子删树
function tbMission:DelTreeByGatherSeed(pNpc)
	if pNpc then
		self.tbPlantedTree[pNpc.dwId] = nil
		pNpc.Delete();
		return 1;
	end
	return 0;
end
