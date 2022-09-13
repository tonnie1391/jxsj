-- 文件名　：WINE.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-08 10:17:41
-- 描述：酒坛--第一关的酿酒npc


local tbNpc = Npc:GetClass("kingame_wine");

function tbNpc:OnDialog()
	self:OnSwitch(him.dwId);
end

function tbNpc:OnSwitch(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	--获取当前酒坛的进度，由关卡进行进度调整
	local nStep = pNpc.GetTempTable("KinGame2").nStep or 0;
	if nStep <= 0 then
		return 0;
	end
	local nFailed = pNpc.GetTempTable("KinGame2").bFailed or 0;
	if nFailed == 1 then
		Dialog:Say("酿酒已经失败了！");
		return 0;
	end
	local bDead = pNpc.GetTempTable("KinGame2").bDead or 0;
	if bDead == 1 then
		Dialog:Say("该酒坛已经被酒鬼破坏。");
		return 0;
	end
	self:ProcessStep(nStep,nNpcId);	--处理酒坛的不同阶段	
end

function tbNpc:ProcessStep(nStep,nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if nStep == 1 then
		self:ProcessStep01(nNpcId);
	elseif nStep == 2 then
		self:ProcessStep02(nNpcId);
	elseif nStep == 3 then
		self:ProcessStep03(nNpcId);
	end 
end

function tbNpc:ProcessStep01(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbInfo = pNpc.GetTempTable("KinGame2").tbInfo;
	if #tbInfo.tbIdx == 0 and not tbInfo.nNeedNum and not tbInfo.nCurrentNeedIdx then	--已经收集完材料
		local szMsg = "恭喜你,此酒坛已完成第一阶段,安心等待其它酒坛收集完成，并且注意酒坛不被酒鬼破坏！";
		Dialog:Say(szMsg);
		local pGame = KinGame2:GetGameObjByMapId(me.nMapId);
		pGame:GetCurrentRoom():CheckAllFinishCollect();
		return 0;
	end
	local nNeedIdx = tbInfo.nCurrentNeedIdx;
	local nNeedNum = tbInfo.nNeedNum or 0; 
	if not nNeedIdx then
		return 0;
	end
	local szName = KinGame2.WINE_NEED_TABLE[nNeedIdx][1];
	local szMsg = string.format("酒坛现在需要<color=yellow>%d个%s<color>,请在书院之内寻找!",nNeedNum,szName);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"放入材料",self.InputMaterial,self,nNpcId,nNeedNum,szName};
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:InputMaterial(nNpcId,nNeedNum,szName)
	local szMsg = string.format("酒坛现在需要<color=yellow>%d个%s<color>,请在书院之内寻找!",nNeedNum,szName);
	Dialog:OpenGift(szMsg, nil, {self.OnInputMaterial, self,nNpcId});
end

function tbNpc:OnInputMaterial(nNpcId,tbItemObj)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbInfo = pNpc.GetTempTable("KinGame2").tbInfo;
	if not tbInfo then
		return 0;
	end
	local pGame = KinGame2:GetGameObjByMapId(pNpc.nMapId);
	if not pGame then
		return 0;
	end
	local pRoom = pGame:GetCurrentRoom();
	local nRoomId = pGame:GetCurrentStepRoomId();
	if not pRoom or nRoomId ~= 1 then
		return 0;
	end
	if not tbInfo.nCurrentNeedIdx then
		return 0;
	end
	local tbInputGDPL = KinGame2.WINE_NEED_TABLE[tbInfo.nCurrentNeedIdx][3];
	for nCount, pItem in pairs(tbItemObj) do
		if self:CheckInputMaterial(tbInputGDPL,pItem[1].nGenre,pItem[1].nDetail,pItem[1].nParticular,pItem[1].nLevel) == 1 then
			me.DelItem(pItem[1], 0);
			tbInfo.nNeedNum = tbInfo.nNeedNum - 1;
			if tbInfo.nNeedNum <= 0 then
				 tbInfo.nNeedNum = 0;
				 break;
			end
		end
	end
	if tbInfo.nNeedNum > 0 then
		local szMsg = string.format("酒坛现在需要<color=yellow>%d个%s<color>,请在书院之内寻找!",tbInfo.nNeedNum,KinGame2.WINE_NEED_TABLE[tbInfo.nCurrentNeedIdx][1]);
		Dialog:Say(szMsg);
	elseif tbInfo.nNeedNum == 0 then
		tbInfo.nCurrentNeedIdx = nil;
		tbInfo.nNeedNum = nil;
		pRoom:StartWineCollect(nNpcId);
	end
	if #tbInfo.tbIdx == 0 and not tbInfo.nNeedNum and not tbInfo.nCurrentNeedIdx then
		pRoom:HandleCollectFinish(nNpcId);
	end
	pRoom:UpdateWineUi(pRoom.nStep);
end

function tbNpc:CheckInputMaterial(tbNeedGDPL,nGenre, nDetail,nParticular,nLevel)
	if not tbNeedGDPL then
		return 0;
	end
	local szNeed = string.format("%s,%s,%s,%s",unpack(tbNeedGDPL));
	local szInput = string.format("%s,%s,%s,%s",nGenre, nDetail,nParticular,nLevel);
	if szNeed == szInput then
		return 1;
	end
	return 0;
end


function tbNpc:ProcessStep02(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
--	local nSearchFireTimer = pNpc.GetTempTable("KinGame2").nSearchFireTimer;
--	if not nSearchFireTimer or nSearchFireTimer == 0 then
--		pNpc.GetTempTable("KinGame2").nCurrentFireNum = 0;
--		pNpc.GetTempTable("KinGame2").nSearchFireTimer = Timer:Register(self.nSearchFireTime * Env.GAME_FPS, self.SearchFire, self, nNpcId)
--	end
	local nFireNum = pNpc.GetTempTable("KinGame2").nCurrentFireNum or 0;
	if  KinGame2.WINE_NEED_FIRE_MIN_NUM - nFireNum > 0 then
		local nNeedNum = KinGame2.WINE_NEED_FIRE_MIN_NUM - nFireNum;
		local szMsg = string.format("    酒坛现在需要文火加热，快去寻找<color=yellow>火种<color>，据说<color=yellow>火种机关人<color>身上经常带着这种东西，得到火种后，就在酒坛周围使用火种。现在还需要<color=yellow>%d<color>个火种。",nNeedNum);
		Dialog:Say(szMsg,{"Ta hiểu rồi"});
	else
		local szMsg = string.format("    该酒坛已经酿制成功，等其它酒坛酿好，可以进行品酒，并且注意酒坛不被酒鬼破坏！")
		Dialog:Say(szMsg,{"Ta hiểu rồi"});
	end
end

function tbNpc:SearchFire(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local bDead = pNpc.GetTempTable("KinGame2").bDead or 0;
	local bFailed = pNpc.GetTempTable("KinGame2").bFailed or 0;
	if bDead == 1 or bFailed == 1 then
		return 0;
	end
	local nCount = pNpc.GetTempTable("KinGame2").nCurrentFireNum or 0;
	local tbFire,nNpcCount = KNpc.GetAroundNpcListByNpc(nNpcId,KinGame2.WINE_NEED_FIRE_MIN_DISTANCE,KinGame2.WINE_NEED_FIRE_ID);
	local pGame = KinGame2:GetGameObjByMapId(pNpc.nMapId);
	if not pGame then
		return 0;
	end
	local pRoom = pGame:GetCurrentRoom();
	local nRoomId = pGame:GetCurrentStepRoomId();
	if not pRoom or nRoomId ~= 1 then
		return 0;
	end
	if nNpcCount > 0 then
		nCount = nNpcCount;
	end
	if KinGame2.WINE_NEED_FIRE_MIN_NUM - nCount > 0  then
		local szMsg = string.format("火还不够，加把劲!还需要%d个火种",KinGame2.WINE_NEED_FIRE_MIN_NUM - nCount);
 		pNpc.SendChat(szMsg); 
		pNpc.GetTempTable("KinGame2").nCurrentFireNum = nCount;
	else
		local szMsg = "酒已酿好，稍后可进行品尝！"
		pNpc.SendChat(szMsg);
		pRoom:HandleFireFinish(pNpc.dwId); 
		pNpc.GetTempTable("KinGame2").nCurrentFireNum = nCount;
		return 0;
	end		
end

function tbNpc:ProcessStep03(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local szMsg = "现在可以品尝美酒了!品尝后你将感到武艺倍增，相信你一定没有喝过这么好的酒！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"品尝美酒",self.GetDrink,self,nNpcId};
	tbOpt[#tbOpt + 1] = {"我已经品尝过了"};
	Dialog:Say(szMsg,tbOpt);
end

--获取美酒
function tbNpc:GetDrink(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pGame = KinGame2:GetGameObjByMapId(pNpc.nMapId);
	if pGame:FindDrinkPlayer(me.nId) == 1 then
		local szMsg = "每个人只能品尝一次美酒哦，你已经品尝过了，知足了吧!";
		Dialog:Say(szMsg);
	else
		me.AddSkillState(KinGame2.PLAYER_ADD_BUFF_ID,1,0,KinGame2.PLAYER_BUFF_TIME * Env.GAME_FPS,1);
		pGame.tbDrinkPlayer[me.nId] = 1;
	end
end