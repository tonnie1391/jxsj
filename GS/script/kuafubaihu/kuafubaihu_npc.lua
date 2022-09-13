 -- 文件名　：kuafubaihu_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-22 21:40:47
-- 描述：跨服白虎的npc一些定义


Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

---------------------------白虎堂亲卫----------------------
local tbBaiHuQinWei = Npc:GetClass("kuafubaihu_qinwei");

function tbBaiHuQinWei:OnDialog(szParam)
	local tbOpt = {};	
	local szMsg = "奉堂主之命，在此恭候，大侠准备好了吗？";
	tbOpt[1]	= {"是的，请带我进去!", self.JoinAction, self};
	tbOpt[2]	= {"我再准备一下!"};
	Dialog:Say(szMsg, tbOpt);
end

function tbBaiHuQinWei:JoinAction()	--加入pk，进行判断,战斗地图的OnEnter不用再进行判断
	local szMsg = "";
	local nPlayerServerId,nPlayerMapIndex,nPlayerCampId = KuaFuBaiHu:GetPlayerGroupIndex(me);
	local nPlayerMapId; 
	if nPlayerServerId then
		nPlayerMapId = KuaFuBaiHu.tbFightMapIdList[nPlayerServerId][nPlayerMapIndex];
	end
	local bOutForDeath = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_OUT_FOR_DEATH);
	if bOutForDeath == 1 then	--在传入时间内死亡出来的无法进入
		szMsg = "你已身受重伤，请下次再来。";
		Dialog:Say(szMsg);
		return;
	end
	if KuaFuBaiHu.nActionState == KuaFuBaiHu.APPLYSTATE  then	--pk未开启
		szMsg = "密室封闭已久，腐雾弥漫，我们且在这里再守片刻。";
		Dialog:Say(szMsg);
		return;
	end
	if KuaFuBaiHu.nActionState == KuaFuBaiHu.FORBIDENTER or KuaFuBaiHu.nActionState == KuaFuBaiHu.RESTSTATE then	--过了35分钟无法进入
		szMsg = "大侠还是堵在门口，防止贼人逃窜吧!";
		Dialog:Say(szMsg);
		return ;
	end
	if nPlayerMapId and Map:CheckTagServerPlayerCount(nPlayerMapId) == 0  then
		szMsg = "地图内人满为患，请稍后再进!";
		Dialog:Say(szMsg);
		return;
	end
	KuaFuBaiHu:JoinGame(me);
end



---------------------------------白虎堂传送门----------------------------------
local tbBaiHuChuanSong = Npc:GetClass("kuafubaihu_chuansong");


function tbBaiHuChuanSong:OnDialog(szParam)
	if not GLOBAL_AGENT then
		local nMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
		if nMoney < 0 then
			nMoney = 0;
		end
		local szMoney = Item:FormatMoney(nMoney);
		local szMsg = string.format([[<color=green>    即将进行跨服活动，30分时该入口关闭！在此之前您需要准备用来购买药品和菜的跨服绑银。<color>
			
			当前跨服绑银：<color=yellow>%s两<color>
			
			若不够，可打开奇珍阁，购买跨服活动专用绑银，将其使用后再进入密道。]],szMoney);
		local tbOpt = {};
		tbOpt[1] = {"准备好了，我要进入",self.Join,self};
		tbOpt[2] = {"我先准备一下"}
		Dialog:Say(szMsg,tbOpt);
	else
		KuaFuBaiHu:NewWorld2GlobalMap(me);
	end
end

function tbBaiHuChuanSong:Join()
	local nUnionId = me.dwUnionId;
	local nTongId  = me.dwTongId;
	local nHonorLevel = me.GetHonorLevel();	--财富等级
	if nHonorLevel < BaiHuTang.BASIC_TRANS_LEVEL then	--小于混天无法进入
		me.Msg("你未达到进入密室的等级！","系统提示");
		return 0;
	end
	if nUnionId == 0 and nTongId == 0 then
		me.Msg("你没有帮会，无法进入密室!","系统提示");
		return 0;
	end
	if BaiHuTang.nKillBossCamp ~= (nUnionId ~=0 and nUnionId or nTongId) then	
		me.Msg("只有杀死BOSS的帮会或联盟成员，才可以进入密室","系统提示");
		return 0;
	end
	if BaiHuTang.nKillBossCamp == (nUnionId ~=0 and nUnionId or nTongId) and BaiHuTang:IsPlayerInBossDeathMap(me.nId) == 0 then
		me.Msg("BOSS死亡时你未在第三层,不得进入！","系统提示");
		return 0;
	end
	KuaFuBaiHu:NewWorld2GlobalMap(me);
end


------------------------------白虎堂堂主----------------------------------------
local tbBaiHuTangZhu = Npc:GetClass("kuafubaihu_tangzhu");

function tbBaiHuTangZhu:OnDialog(szParam)
	local pNpc = him;
	local szMsg = [[    澜叔当年困死晁错于密室之中，便隐匿江湖，难寻踪迹，后来江湖疯传名录之事，父亲怕招惹是非，竟将密室机关损坏，从此无人可以进得此室。
					    今日密室重现人间，也算天意。我等热血男儿，应挺身而出，集齐秘录，上报朝廷，铲除贪官！
					    大家可以在这里稍事休息，刚才已有贼人闯入，武功妖异无比，等下入室，大家万须小心。密室错综复杂，我会命贴身护卫为大家带路。]]
	Dialog:Say(szMsg);
	return;
end

-----------------白虎堂最终boss----------------
local tbBaiHuBoss_Final = Npc:GetClass("kuafubaihu_boss")

function tbBaiHuBoss_Final:OnDeath(pNpcKiller)
	local pNpc = him;
	local pPlayerKiller = pNpcKiller.GetPlayer();
	local nDropCount = MathRandom(KuaFuBaiHu.tbFinalBossDropCount.nMin,KuaFuBaiHu.tbFinalBossDropCount.nMax);	--掉落个数
	local tbPlayer, nCount = KPlayer.GetMapPlayer(pNpc.nMapId);
	if not pPlayerKiller then
		pNpc.DropRateItem(KuaFuBaiHu.szFinalBossDropFile,nDropCount,-1,-1);
		--记录谁杀死boss，和掉落个数
		Dbg:WriteLogEx(2, "KuafuBaiHu", "Killer is not in this server",pNpc.szName,KuaFuBaiHu.szFinalBossDropFile,nDropCount);
	else
		pNpc.DropRateItem(KuaFuBaiHu.szFinalBossDropFile,nDropCount,-1,-1,pPlayerKiller.nId);
		--记录谁杀死boss，和掉落个数
		Dbg:WriteLogEx(2, "KuafuBaiHu", pNpcKiller.szName,pNpc.szName,KuaFuBaiHu.szFinalBossDropFile,nDropCount);
	end

	if not pPlayerKiller then
		return 0;
	end
	local szMsg = "<color=yellow>["..pNpcKiller.szName .. "]<color>杀死了<color=green>" ..pNpc.szName .."<color>。 " ;
	if nCount > 0 then
		KDialog.Msg2PlayerList(tbPlayer, szMsg, "系统提示");
	end
end

-- 血量触发
function tbBaiHuBoss_Final:OnLifePercentReduceHere(nLifePercent)
	local szMsg = "";
	local pNpc = him;
	if nLifePercent == KuaFuBaiHu.tbFinalBossBloodPercent[1] then
		szMsg = "蚀月神教，武林至尊";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == KuaFuBaiHu.tbFinalBossBloodPercent[2] then
		szMsg = "集齐名录，必可亲见教主";
		pNpc.SendChat(szMsg);
	elseif nLifePercent == KuaFuBaiHu.tbFinalBossBloodPercent[3] then
		szMsg = "今我虽亡，教主必会为我报仇，名录既出，迟早为我教所得";
		pNpc.SendChat(szMsg);
	end
end

-----------------白虎堂小boss-----------------------

local tbBaiHuBoss_Normal = Npc:GetClass("kuafubaihu_boss2");


function tbBaiHuBoss_Normal:OnDeath(pNpcKiller)
	local pNpc = him;
	local pPlayerKiller = pNpcKiller.GetPlayer();
	local nDropCount = MathRandom(KuaFuBaiHu.tbNormalBossDropCount.nMin,KuaFuBaiHu.tbNormalBossDropCount.nMax);	--掉落个数
	if not pPlayerKiller then
		--记录谁杀死boss，和掉落个数
		pNpc.DropRateItem(KuaFuBaiHu.szNormaBossDropFile,nDropCount,-1,-1);
		Dbg:WriteLogEx(2, "KuafuBaiHu", "Killer is not in this server!",pNpc.szName, KuaFuBaiHu.szNormaBossDropFile, nDropCount);
	else
		--记录谁杀死boss，和掉落个数
		pNpc.DropRateItem(KuaFuBaiHu.szNormaBossDropFile,nDropCount,-1,-1,pPlayerKiller.nId);
		Dbg:WriteLogEx(2, "KuafuBaiHu", pNpcKiller.szName,pNpc.szName, KuaFuBaiHu.szNormaBossDropFile, nDropCount);
	end
end

----------------白虎药商-----------------------

local tbNpc = Npc:GetClass("kuafubaihu_npc_trader");

function tbNpc:OnDialog()
	me.OpenShop(164,7);
end
