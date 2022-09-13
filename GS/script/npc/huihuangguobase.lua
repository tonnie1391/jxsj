-- 文件名　：huihuangguobase.lua
-- 创建者　：zhongchaolong
-- 创建时间：2007-10-10 18:03:38
-- npc果子，
--对应等级的玩家可以采集对应等级的果子，采集时间nTime秒
--点击npc 符合条件就给与一个果子
--由此基类衍生出2个类，一个是辉煌果子npc，一个是黄金果子npc

local tbHuiHuangGuoBase = {};
tbHuiHuangGuoBase._tbBase	= Npc:GetClass("default");
tbHuiHuangGuoBase.nTimeout	= 3600*24*7; --设置得到的果子有效期为7天
tbHuiHuangGuoBase.TSK_LIMITWEIWANG	= 5;
tbHuiHuangGuoBase.TSKGID			= 2002;
tbHuiHuangGuoBase.LIMITWEIWANG		= 20;

function tbHuiHuangGuoBase:OnDialog()
	if (0 == me.GetCamp()) then
		me.Msg("你目前未入门派，不能拾取果实。")
		return 0;
	end
	local tbNpcInfo	= him.GetTempTable("Npc");
	if (tbNpcInfo.nIsCollected ~= nil and tbNpcInfo.nIsCollected == 1) then --已经被别人采集了
		me.Msg("已经被别人采集了");
		return 0;
	end
	
	if (me.CountFreeBagCell() < 1) then
		me.Msg("你背包已经没有空间了。");
		return 0;
	end
	local nGetPlayerRank = HuiHuangZhiGuo.GetPlayerRank();
	
	if (nGetPlayerRank ~= him.nLevel) then -- 如果级别不对,不能进行拾取
		--这里告诉玩家级别不对,不能拾取
		if (1 == him.nLevel) then
			me.Msg("这里的果子只有70级到99级之间玩家方能拾取!");
		end
		return 0;
	end
	
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	
	--这里需加入时间条
	GeneralProcess:StartProcess("正在采集...", self.nTime * Env.GAME_FPS, {self.GetFruit, self,him.dwId,me.nId}, nil, tbEvent);
	
end

function tbHuiHuangGuoBase:GetFruit(dwNpcId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(dwNpcId);
	if (pPlayer.nCurLife <= 0) then
		pPlayer.Msg("采集失败");
		return 0;
	end
	if (pNpc == nil) then
		pPlayer.Msg("采集失败");
		return 0;
	end
	local tbNpcInfo	= pNpc.GetTempTable("Npc");
	if (tbNpcInfo.nIsCollected == 1) then
		pPlayer.Msg("采集失败");
		return 0;
	end
	tbNpcInfo.nIsCollected = 1;
	local pGuoZi = me.AddItemEx(Item.SCRIPTITEM, self.tbItemGuoZi.nDetail,self.tbItemGuoZi.nParticular,self.tbItemGuoZi.nLevel,{bTimeOut = 1});
	if(pGuoZi ~= nil ) then --果子得到了
		pPlayer.SetItemTimeout(pGuoZi,os.date("%Y/%m/%d/%H/%M/%S",GetTime()+self.nTimeout));
		pGuoZi.Sync();
		self:AwardWeiWang(pPlayer, self.tbItemGuoZi.szName);		
	end
	pNpc.Delete();
	
end

function tbHuiHuangGuoBase:AwardWeiWang(pPlayer, szGuoName)
	assert(szGuoName);
	local nWeiWang = 0;
	local nGongXian = 0;
	if ("辉煌之果" == szGuoName) then
		nWeiWang = 1;
		nGongXian = 5;
	elseif ("黄金之果" == szGuoName) then
		nWeiWang = 5;
		nGongXian = 30;
	end
	pPlayer.AddKinReputeEntry(nWeiWang, "huihuangzhiguo");
end

--辉煌之果定义
local tbHuiHuangZhiGuo			= Npc:GetClass("huihuangzhiguo");
tbHuiHuangZhiGuo._tbBase		= tbHuiHuangGuoBase;
tbHuiHuangZhiGuo.tbItemGuoZi	= {szName = "辉煌之果",nGenre = 18,nDetail = 1,nParticular = 25,nLevel = 1,};
tbHuiHuangZhiGuo.nTime			= 10;
--黄金之果定义
local tbHuangJinZhiGuo			= Npc:GetClass("huangjinzhiguo");
tbHuangJinZhiGuo._tbBase		= tbHuiHuangGuoBase;
tbHuangJinZhiGuo.tbItemGuoZi	= {szName = "黄金之果",nGenre = 18,nDetail = 1,nParticular = 26,nLevel = 1,};
tbHuangJinZhiGuo.nTime			= 60;
