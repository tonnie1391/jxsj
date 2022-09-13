-- 文件名　：dragonboatfestival_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-06-08 09:32:39
-- 功能    ：

SpecialEvent.tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012 or {};
local tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012;

--1号锅
local tbNpc= Npc:GetClass("DragonB2012_G1");
tbNpc.nLiveTime 		= 40 * 60 * Env.GAME_FPS;
tbNpc.nFireAllTime 		= 10 * 60 * Env.GAME_FPS;
tbNpc.nPerAwardTime 	= 60 * Env.GAME_FPS;
tbNpc.nExpAwardTime 	= 5 * Env.GAME_FPS;

function tbNpc:OnDialog()
	local tbTemp = him.GetTempTable("Npc");
	local nCount = 0;
	if tbTemp.tbDragonB2012 and tbTemp.tbDragonB2012.nCount then
		nCount = tbTemp.tbDragonB2012.nCount;
	end
	if me.dwKinId ~= tbTemp.tbDragonB2012.dwKinId then
		Dialog:Say("这锅粽子还未煮熟呢，请稍等。");
		return;
	end
	local szMsg = string.format("家族<color=yellow>[雕纹石锅]<color>已摆出，快召集家族成员一起放入粽子吧！\n\n<color=red>【注意】<color>\n1.摆出石锅后的2分钟才可点燃；\n2.摆出石锅后10分钟内必须点燃，否则超时后石锅将会消失；\n3.石锅一旦点燃，将不能再放入粽子；\n4.放入的粽子越多最后的奖励越丰厚哦。\n\n<color=green>当前放入的粽子：%s<color>", nCount);
	local tbOpt = {{"放入家族团圆粽", self.RItem, self, him.dwId},		
		{"Để ta suy nghĩ thêm"}}
	if me.nKinFigure == 1 or me.nKinFigure == 2 then
		table.insert(tbOpt, 1, {"点燃火苗", self.Fire, self, him.dwId});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:RItem(dwId)
	Dialog:OpenGift("请放入1个家族团圆粽", nil ,{self.OnOpenGiftOk, self, dwId});
end

function tbNpc:OnOpenGiftOk(dwId, tbItemObj)
	local pNpc = KNpc.GetById(dwId);
	if not pNpc then
		return;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		return;
	end
	if me.dwKinId ~= tbTemp.tbDragonB2012.dwKinId then
		Dialog:Say("这个锅不是你们家族的。");
		return;
	end
	if Lib:CountTB(tbItemObj) <= 0 then
		Dialog:Say("你好像没有放入东西。");
		return 0;
	end
	if Lib:CountTB(tbItemObj) > 1 then
		Dialog:Say("你放入的东西太多了。");
		return 0;
	end
	for _, pItem in pairs(tbItemObj) do
		local szFollowCryStal 	= string.format("%s,%s,%s,%s", unpack(tbDragonBoatFestival2012.tbKinItem));
		local szItem		= string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if szFollowCryStal ~= szItem then
			Dialog:Say("你放入的东西不正确。");
			return 0;
		end;
	end
	local pItem = tbItemObj[1][1];
	if pItem.nCount > 1 then
		pItem.nCount = pItem.nCount - 1;
	else
		pItem.Delete(me);
	end
	tbTemp.tbDragonB2012[me.szName] = 1;
	tbTemp.tbDragonB2012.nCount = (tbTemp.tbDragonB2012.nCount or 0) + 1;
	Dialog:SendBlackBoardMsg(me, "你向石锅中放入了一个团圆粽，请等待族长点燃石锅。");
	StatLog:WriteStatLog("stat_info", "duanwujie2012", "kiner_putitem", me.nId, 1);
end

function tbNpc:Fire(dwId, nFlag)
	local pNpc = KNpc.GetById(dwId);
	if not pNpc then
		return;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		return;
	end
	if GetTime() - tbTemp.tbDragonB2012.nStarTime < tbDragonBoatFestival2012.nFireLimit then
		Dialog:Say("放下石锅后需要2分钟后才可以点火。");
		return;
	end
	if me.dwKinId ~= tbTemp.tbDragonB2012.dwKinId then
		Dialog:Say("这个锅不是你们家族的。");
		return;
	end
	if me.nKinFigure ~= 1 and me.nKinFigure ~= 2 then
		Dialog:Say("只有家族的族长和副族长才能开始煮粽子。");
		return;
	end
	if not nFlag then
		Dialog:Say("你是否要点燃火苗？\n<color=red>一旦点燃后所有家族成员将不能再投入粽子<color>", {{"是的", self.Fire, self, dwId, 1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	local nMapId, nX, nY = pNpc.GetWorldPos();
	local pNpc2 =  KNpc.Add2(tbDragonBoatFestival2012.nNpcId, 1, -1, nMapId, nX, nY);
	if pNpc2 then
		pNpc2.SetLiveTime(self.nLiveTime);
		local cKin = KKin.GetKin(me.dwKinId);
		if cKin then
			pNpc2.SetTitle("<color=green>"..cKin.GetName().."<color>");
		end
		local tbTemp2 = pNpc2.GetTempTable("Npc");
		tbTemp2.tbDragonB2012 =  tbTemp.tbDragonB2012 or {};
		pNpc.Delete();
		tbTemp2.tbDragonB2012.nTimerId1 = Timer:Register(self.nFireAllTime, tbDragonBoatFestival2012.FinishFire, tbDragonBoatFestival2012, pNpc2.dwId);
		tbTemp2.tbDragonB2012.nTimerId2 = Timer:Register(self.nPerAwardTime, tbDragonBoatFestival2012.RandomAward, tbDragonBoatFestival2012, pNpc2.dwId);
		tbTemp2.tbDragonB2012.nTimerId3 = Timer:Register(self.nExpAwardTime, tbDragonBoatFestival2012.RandomExp, tbDragonBoatFestival2012, pNpc2.dwId);
		Dialog:SendBlackBoardMsg(me, "你点燃了[雕纹石锅]，锅里慢慢咕咚咕咚的冒起泡来。");
		Player:SendMsgToKinOrTong(me, "点燃了[雕纹石锅]，美味的家族粽子即将出锅哦~", 0);
		StatLog:WriteStatLog("stat_info", "duanwujie2012", "kin_item", me.nId, 3);
	end
end

--2号锅
local tbNpc2= Npc:GetClass("DragonB2012_G2");

function tbNpc2:OnDialog()
	local tbTemp = him.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		print("异常npc"..him.dwId);
		return;
	end
	local cKin = KKin.GetKin(tbTemp.tbDragonB2012.dwKinId)
	if not cKin then
		return 0
	end
	if not tbTemp.tbDragonB2012.nTimerId1 then
		Dialog:Say("<color=yellow>"..cKin.GetName().."<color>家族香喷喷的团圆粽出锅啦！！大家快来尝尝！！ ", {{"尝一个粽子", self.OnUse, self, him.dwId}, {"Để ta suy nghĩ thêm"}});
		return;
	end
	local nCount  = tbTemp.tbDragonB2012.nFireCount or 0;
	local nTimeRest  = Timer:GetRestTime(tbTemp.tbDragonB2012.nTimerId1);
	local szMsg = string.format("煮粽子的时候坐在石锅旁就会有惊喜奖励哦！\n<color=green>预计还有%s粽子出锅<enter>  ", Lib:TimeDesc(math.ceil(nTimeRest / Env.GAME_FPS)));
	Dialog:Say(szMsg);
end

function tbNpc2:OnUse(dwId)
	local pNpc = KNpc.GetById(dwId);
	if not pNpc then
		return;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		return;
	end
	local cKin = KKin.GetKin(tbTemp.tbDragonB2012.dwKinId)
	if not cKin then
		return;
	end
	if tbTemp.tbDragonB2012.dwKinId ~= me.dwKinId then
		tbTemp.tbDragonB2012.tbGetItem = tbTemp.tbDragonB2012.tbGetItem or {};
		if tbTemp.tbDragonB2012.tbGetItem[me.szName] then
			Dialog:SendBlackBoardMsg(me, "你吃过这个家族的粽子了，还是换一个家族吧。");
			return;
		end
		tbDragonBoatFestival2012:ChangeTask(me);
		local nCount = me.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_ITEMCOUNT);
		if nCount >=  tbDragonBoatFestival2012.nMaxGetCount then
			Dialog:SendBlackBoardMsg(me, "你今天已经吃的够饱了，再吃会变胖子哦！");
			return;
		end
		tbDragonBoatFestival2012:ExpAwrd(me);
		Dialog:SendBlackBoardMsg(me, string.format("你品尝了1个[%s]家族煮出的粽子，然后扬长而去", cKin.GetName()));
		me.SetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_ITEMCOUNT, nCount + 1);
		tbTemp.tbDragonB2012.tbGetItem[me.szName] = 1;
		StatLog:WriteStatLog("stat_info", "duanwujie2012", "kiner_getitem", me.nId, "1,2");
		return;
	else
		if not tbTemp.tbDragonB2012[me.szName] then
			Dialog:SendBlackBoardMsg(me, "不投粽子，休想白吃！");
			return;
		elseif tbTemp.tbDragonB2012[me.szName] == 2 then
			Dialog:SendBlackBoardMsg(me, "每个人只能从家族的锅里面吃一次粽子。");
			return;
		end
		if me.CountFreeBagCell() < 1 then
			Dialog:SendBlackBoardMsg(me, "Hành trang không đủ 1 ô.");
			return;
		end
		local nCount = 1;
		if tbTemp.tbDragonB2012.nCount > tbDragonBoatFestival2012.nGradeTow then
			nCount = 3;
		elseif tbTemp.tbDragonB2012.nCount <= tbDragonBoatFestival2012.nGradeTow and tbTemp.tbDragonB2012.nCount > tbDragonBoatFestival2012.nGradeOne then
			nCount = 2;
		end
		local tbItem = tbDragonBoatFestival2012.tbRandomBox2;
		tbTemp.tbDragonB2012[me.szName] = 2;
		me.AddStackItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind= 1}, nCount);
		StatLog:WriteStatLog("stat_info", "duanwujie2012", "kiner_getitem", me.nId, nCount..",1");
	end
end
