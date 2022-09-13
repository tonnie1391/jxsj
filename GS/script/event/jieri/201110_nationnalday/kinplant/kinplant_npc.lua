-- 文件名　：kinplant_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-12 19:50:27
-- 功能    ：

SpecialEvent.tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011 or {};
local tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011;
local tbNpc1 = Npc:GetClass("Kintree1_2011");

function tbNpc1:OnDialog()	
	local szMsg = "种子正在生长中...\n此快乐之种已被浇水<color=green>%s/3<color>\n";
	local tbTemp = him.GetTempTable("Npc").tbKinPlant;
	local szWaterMsg = ""
	for szName, _ in pairs(tbTemp.tbWarterInfo) do
		if szWaterMsg == "" then
			szWaterMsg = "今日为种子浇水的侠客有：\n";
		end	
		szWaterMsg = szWaterMsg.."<color=yellow>"..szName.."<color>\n";
	end
	szMsg = szMsg..szWaterMsg
	szMsg =string.format(szMsg, Lib:CountTB(tbTemp.tbWarterInfo));
	local tbOpt = {
		{"浇水", self.GradeTree, self, him.dwId, me.nId},
		{"Ta hiểu rồi"}};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc1:GradeTree(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end	
	local nRet, szErrorMsg = tbKinPlant_2011:CanGrade(pPlayer, pNpc);
	if  nRet == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, szErrorMsg);
		return 0;
	end
	local tbEvent = 
		{
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_SITE,
			Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_DEATH,
		};
		
		GeneralProcess:StartProcess("浇水中...", 3 * Env.GAME_FPS, {tbKinPlant_2011.GradeTree, tbKinPlant_2011, dwNpcId, nPlayerId}, nil, tbEvent);
 end

local tbNpc2 = Npc:GetClass("Kintree2_2011");

function tbNpc2:OnDialog()	
	local szMsg = "果实已经成熟...\n此快乐之种已被浇水<color=green>3/3次<color>\n当日果实数量<color=green>%s/30<color>\n";
	local tbTemp = him.GetTempTable("Npc").tbKinPlant;
	if not tbTemp then
		Dialog:Say("树有问题！");
		return 0;
	end
	local szWaterMsg = ""
	for szName, _ in pairs(tbTemp.tbWarterInfo) do
		if szWaterMsg == "" then
			szWaterMsg = "今日为种子浇水的侠客有：\n";
		end	
		szWaterMsg = szWaterMsg.."<color=yellow>"..szName.."<color>\n";
	end
	szMsg = szMsg..szWaterMsg
	local nNum = tbTemp.nNum;
	local nCount = tbKinPlant_2011.tbPlantInfo[me.dwKinId][nNum][4]
	szMsg =string.format(szMsg, nCount);
	local tbOpt = {		
		{"果树成长经历", self.Infor, self, tbTemp},
		{"Ta hiểu rồi"}};
	if him.nTemplateId == tbKinPlant_2011.tbTempNpc[3] and tbKinPlant_2011:GetState() == 1 then
		table.insert(tbOpt, 1, {"摘取丰硕之果", tbKinPlant_2011.GatherSeed, tbKinPlant_2011, him.dwId, me.nId});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc2:Infor(tbTemp)
	local szMsg = "今日光顾该果实的侠客有：\n";
	for szName, _ in pairs(tbTemp.tbGatherSeed) do
		szMsg = szMsg.."<color=yellow>"..szName.."<color>\n";		
	end
	Dialog:Say(szMsg);
end
