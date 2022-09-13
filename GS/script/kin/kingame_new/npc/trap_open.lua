-- 文件名　：trap_open.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-20 10:11:08
-- 描述：准备场开启游戏的图腾

local tbNpc = Npc:GetClass("trap_open")

function tbNpc:OnDialog()
	self:OnSwitch(him.dwId);
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
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
}

function tbNpc:OnSwitch(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end	
	local pGame = KinGame2:GetGameObjByMapId(me.nMapId);
	local tbTmp = pNpc.GetTempTable("KinGame2");
	if not pGame then
		return 0 ;
	end
	local cKin = KKin.GetKin(pGame.nKinId);
	if not cKin then
		return 0;
	end
	if tbTmp.nHasOpen ~= nil then
		Dialog:SendBlackBoardMsg(me, "这个柱子的机关已经被人开动过了。");
		return 0;
	end
	if tbTmp.nRoomId == 1 then
		local tbFind = me.FindItemInBags(unpack(KinGame2.OPEN_KEY_ITEM))
		if #tbFind < 1 then
			Dialog:SendBlackBoardMsg(me,"你身上没有开启书院的钥匙！");
			return 0;
		end
		local nCount = pGame:GetPlayerCount();
		if nCount < KinGame2.MIN_PLAYER then
			Dialog:SendBlackBoardMsg(me, "现在人手还不够，还是再等一会吧");
			return 0;
		end
		local nLastLevel = cKin.GetKinGame2LastPassLevel();
		local szMsg = "";
		if not nLastLevel then
			nLastLevel = 0;
		end
		if nLastLevel == 0 then
			szMsg = string.format("请选择高级家族关卡的难度等级，不同难度的奖励也会不同!你们还未通过高级家族关卡的任何难度，加油!");
		else
			szMsg = string.format("请选择高级家族关卡的难度等级，不同难度的奖励也会不同!你们家族上次通过的关卡等级为<color=yellow>%d<color>星级!",nLastLevel);
		end
		local tbOpt = {};
		if nLastLevel <= 2 then
			nLastLevel = 2;
		end
		if nLastLevel >= 12 then
			nLastLevel = 11;
		end
		for i = 1 , nLastLevel + 1 do
			if i == 11 then
				tbOpt[i] = {string.format("%s星难度(<color=yellow>传说<color>)",i),self.ProcessSwitch,self,nNpcId,i};
			elseif i == 12 then
				tbOpt[i] = {string.format("%s星难度(<color=yellow>地狱<color>)",i),self.ProcessSwitch,self,nNpcId,i};
			else
				tbOpt[i] = {string.format("%s星难度",i),self.ProcessSwitch,self,nNpcId,i};
			end		
		end
		tbOpt[#tbOpt + 1] = "Kết thúc đối thoại";
		Dialog:Say(szMsg,tbOpt);
	end
end

function tbNpc:ProcessSwitch(nNpcId,nLevel)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end	
	GeneralProcess:StartProcess("Đang mở...", KinGame2.TRAP_SWITCH_DELAY * Env.GAME_FPS, {self.DoOnSwitch, self, nNpcId,nLevel or 1}, nil, tbEvent);
end


function tbNpc:DoOnSwitch(nNpcId,nLevel)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end	
	local pGame = KinGame2:GetGameObjByMapId(me.nMapId);
	local tbTmp = pNpc.GetTempTable("KinGame2");
	if not pGame then
		return 0 ;
	end
	if tbTmp.nHasOpen ~= nil then
		Dialog:SendBlackBoardMsg(me, "这个柱子的机关已经被人开动过了。");
		return 0;
	end
	if tbTmp.nRoomId == 1 then
		local tbFind = me.FindItemInBags(unpack(KinGame2.OPEN_KEY_ITEM))
		if #tbFind < 1 then
			return 0;
		end
		me.DelItem(tbFind[1].pItem, Player.emKLOSEITEM_TYPE_EVENTUSED);
		tbTmp.nHasOpen = 1;
		pGame:DelTrapNpc(tbTmp.nRoomId);
		pGame:SetGameDifficulty(nLevel);
		pGame:GameStart();
	end
	pGame:AllBlackBoard("书院里有一种危险的气息，大家小心为妙。");
end
