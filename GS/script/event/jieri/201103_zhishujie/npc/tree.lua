-- 文件名  : tree.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2011-02-24 19:55:13
-- 描述    : 2011植树

local tbNpc = Npc:GetClass("tree_2011");
SpecialEvent.tbZhiShu2011 = SpecialEvent.tbZhiShu2011 or {};
local tbZhiShu2011 = SpecialEvent.tbZhiShu2011;

tbNpc.tbMsg = {
	[1] = "希望之种需要悉心呵护才能长成大树，每成功进入到下一阶段都可以选择<color=yellow>摘取果实<color>或者<color=yellow>继续培育<color>，选择摘取果实则获得本阶段奖励，树木将消失；选择培育下一阶段，树木有枯死的危险 。成功培育出的树木越高级，获得奖励越丰厚。",
	[2] = "你已经摘取了这棵树的果实，谢谢你为春天散播了爱和希望。",
	[3] = "这是别人种的树。",
	[4] = "果子已被摘光了。",
	}

function tbNpc:OnDialog()	
	local szMsg = "树正在生长中...\n";
	local tbOpt = {{"Ta hiểu rồi"}};
	local tbTemp = him.GetTempTable("Npc").tbZhiShu2011;	
	local tbAward = tbZhiShu2011.tbAward[tbTemp.nTreeIndex][1][tbTemp.nAwardIndex];
	if self:IsMySelf(him.dwId) == 0 then
		local nFlag = tbZhiShu2011:CanGatherSeedforOther(him.dwId, me.nId);
		if nFlag == 1 then
			szMsg = string.format("这里有自己家族帮会或是好友<color=yellow>%s<color>种的树，摘一个果子吧...", tbTemp.szName)
			table.insert(tbOpt, 1, {"领取绑定金币和绑定银两", tbZhiShu2011.GetAwardKinTong, tbZhiShu2011, him.dwId, me.nId, 3});
			table.insert(tbOpt, 1, {"领取绑定银两", tbZhiShu2011.GetAwardKinTong, tbZhiShu2011, him.dwId, me.nId, 2});
			table.insert(tbOpt, 1, {"领取绑定金币", tbZhiShu2011.GetAwardKinTong, tbZhiShu2011, him.dwId, me.nId, 1});
		elseif nFlag == 2 then
			szMsg = self.tbMsg[4];
		else
			szMsg = self.tbMsg[3];
		end		
	else
		--奖励提示	
		if tbTemp.nTreeIndex == 1 then
			local tbNextAward = tbZhiShu2011.tbAward[tbTemp.nTreeIndex + 1][1][tbTemp.nAwardIndex];
			if tbNextAward[1] ~= 3 then
				szMsg = string.format("\n\n<color=green>成功培育到下阶段可获得<color><color=gold>%s%s<color>\n", tbNextAward[2],tbNextAward[3]);
			else
				szMsg = string.format("\n\n<color=green>成功培育到下阶段可获得<color><color=gold>%s<color>\n",tbNextAward[3]);
			end
		elseif tbTemp.nTreeIndex < tbZhiShu2011.INDEX_BIG_TREE then
			local tbNextAward = tbZhiShu2011.tbAward[tbTemp.nTreeIndex + 1][1][tbTemp.nAwardIndex];
			if tbAward[1] ~= 3 then
				szMsg = string.format("\n\n<color=green>本阶段摘取果实可获得<color><color=gold>%s%s<color> \n<color=green>成功培育到下阶段可获得<color><color=gold>%s%s<color>\n", tbAward[2], tbAward[3],tbNextAward[2],tbNextAward[3]);
			else
				szMsg =  string.format("\n\n<color=green>本阶段摘取果实可获得<color=gold>%s<color> \n<color=green>成功培育到下阶段可获得<color><color=gold>%s<color>\n", tbAward[3],tbNextAward[3]);
			end
		else
			if tbAward[1] ~= 3 then
				szMsg =  string.format("\n\n<color=green>本阶段摘取果实可获得<color><color=gold>%s%s<color>\n", tbAward[2], tbAward[3]);
			else
				szMsg =  string.format("\n\n<color=green>本阶段摘取果实可获得<color><color=gold>%s<color>\n", tbAward[3]);
			end
		end
		--领奖选项
		if tbZhiShu2011:CanGatherSeed(him.dwId) == 1 then
			table.insert(tbOpt, 1, {"摘取果实", tbZhiShu2011.GatherSeed, tbZhiShu2011, him.dwId, me.nId});
		end
		--升级选项
		if tbZhiShu2011:IsNeedGrade(him.dwId) == 1 then
			szMsg = self.tbMsg[1]..szMsg;
			table.insert(tbOpt, 1,  {"继续培育", self.GradeTree, self, him.dwId, me.nId});			
		end
		--摘取过了的提示
		if tbZhiShu2011:CheckIsGatherSeed(him.dwId, me.nId) == 1 then
			szMsg = self.tbMsg[2];
		end
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GradeTree(dwNpcId, nPlayerId)
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
		
		GeneralProcess:StartProcess("培育中", 3 * Env.GAME_FPS, {tbZhiShu2011.GradeTree, tbZhiShu2011, dwNpcId, nPlayerId}, nil, tbEvent);
 end

--是不是自己的树
function tbNpc:IsMySelf(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbZhiShu2011 or tbTemp.tbZhiShu2011.nPlayerId ~= me.nId then
		return 0;
	end
	return 1;
end

