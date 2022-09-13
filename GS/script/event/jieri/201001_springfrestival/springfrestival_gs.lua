-- 文件名　：springfrestival_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-29 10:39:32
-- 描  述  ：新年活动gs

if  not MODULE_GAMESERVER then
	return;
end
Require("\\script\\event\\jieri\\201001_springfrestival\\springfrestival_def.lua");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

--永乐镇增加许愿树
function SpringFrestival:AddVowTree()
	if SubWorldID2Idx(SpringFrestival.tbVowTreePosition[1]) >= 0 then	
		 if SpringFrestival.nVowTreenId == 0 then			--没有加载过许愿树，add许愿树
	 		local pNpc = KNpc.Add2(SpringFrestival.nVowTreeTemplId, 100, -1, SpringFrestival.tbVowTreePosition[1], SpringFrestival.tbVowTreePosition[2], SpringFrestival.tbVowTreePosition[3]);
	 		SpringFrestival.nVowTreenId = pNpc.dwId;
		end
		Dialog:GlobalNewsMsg_GS("许愿树已经被栽种，大家带着<color=yellow>希望之种<color>快去许愿！");
	end
end

--删除许愿树
function SpringFrestival.DeleteVowTree()
	if SubWorldID2Idx(SpringFrestival.tbVowTreePosition[1]) >= 0 then
		if SpringFrestival.nVowTreenId and SpringFrestival.nVowTreenId ~= 0 then	--加载过许愿树
			local pNpc = KNpc.GetById(SpringFrestival.nVowTreenId);
			if pNpc then
				pNpc.Delete();
				SpringFrestival.nVowTreenId = 0;
			end			
		end
	end
end

--城市增加50盏花灯
function SpringFrestival:AddNewYearHuaDeng()
	SpringFrestival:DeleteNewYearHuaDeng();
	for nIndex, tbHuaDeng in ipairs(SpringFrestival.HUADENG) do		
		if SubWorldID2Idx(tbHuaDeng.nMapId) >= 0 then
			for i = 1, 50 do	
				local pNpc = KNpc.Add2(SpringFrestival.nHuaDengTemplId, 100, -1, tbHuaDeng.nMapId, SpringFrestival.HUADENG_POS[nIndex][i][1], SpringFrestival.HUADENG_POS[nIndex][i][2]);	
				SpringFrestival.tbHuaDeng[pNpc.dwId] = 1;
				local tbNpcTemp = pNpc.GetTempTable("Npc");
				tbNpcTemp.tbPlayerList = {};
				tbNpcTemp.nPart = MathRandom(2);		--随机上下联（1上联，2下联）
				tbNpcTemp.nCount = MathRandom(#SpringFrestival.tbCoupletList);	--36副对联中随机一副
				pNpc.SetTitle(string.format("<color=yellow>%s<color>",SpringFrestival.tbCoupletList[tbNpcTemp.nCount][1]));
				Dialog:GlobalNewsMsg_GS("巧对春联活动已经开始，大家快去各个城市对春联吧，将会有意想不到的东西哦！");
			end
		end
	end
end

--删除花灯
function SpringFrestival:DeleteNewYearHuaDeng()
	for nNpcId, _ in pairs(SpringFrestival.tbHuaDeng) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
	SpringFrestival.tbHuaDeng = {};
end

--花灯被点亮
function SpringFrestival.AddNewHuaDeng(nNpcId)
	local tbPlayerList = {};	
	local nCount = 0;
	local nPart = 0;
	local nMapId , nX, nY =0, 0, 0;
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then		
		nMapId , nX, nY = pNpc.GetWorldPos();
		local tbNpcTemp = pNpc.GetTempTable("Npc");
		tbNpcTemp.tbPlayerList = tbNpcTemp.tbPlayerList or {};
		nPart = tbNpcTemp.nPart;		--花灯上联还是下联
		nCount = tbNpcTemp.nCount;		--花灯对应的春联
		--对出花灯的人
		for i=1, SpringFrestival.nGetHuaDengMaxNum do
			tbPlayerList[i] = tbNpcTemp.tbPlayerList[i];
		end		
		SpringFrestival.tbHuaDeng[pNpc.dwId] = nil;
		pNpc.Delete();
	end
	--换成点亮的npc
	local pNpc2 = KNpc.Add2(SpringFrestival.nHuaDengTemplId_D, 100, -1, nMapId, nX, nY);
	SpringFrestival.tbHuaDeng[pNpc2.dwId] = 1;
	local tbNpcTemp2 = pNpc2.GetTempTable("Npc");
	tbNpcTemp2.nPart = nPart;
	tbNpcTemp2.nCount = nCount;
	tbNpcTemp2.tbPlayerList = tbPlayerList;
	pNpc2.SetTitle(string.format("<color=yellow>%s<color>",SpringFrestival.tbCoupletList[nCount][1]));
end

--龙五太爷处换取奖励
function SpringFrestival.GetAward()
	local szContent = "请放入1个已收集完全的年画收集册\n活动期间最多兑换<color=yellow>10<color>次";
	local szContent = szContent..string.format("\n您已经兑换的次数：<color=yellow>%s<color>", me.GetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_GETAWARD) or 0);
	Dialog:OpenGift(szContent, nil, {SpringFrestival.OnOpenGiftOk, SpringFrestival});
end

function SpringFrestival:OnOpenGiftOk(tbItemObj)
	--每次一个册子 (只可能一个)
	if #tbItemObj ~= 1 then
		Dialog:Say("每次只能放入1个收集册。奖励换取失败！", {"知道了"});
		return 0;	
	end
	--物品判定
	local pItem = tbItemObj[1][1];
	local szKey = string.format("%s,%s,%s,%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
	local szCoupletKey = string.format("%s,%s,%s,%s", unpack(SpringFrestival.tbNianHua_book));
	if szKey ~= szCoupletKey then
		Dialog:Say("您放的物品不对，请放入1个年画收集册", {"知道了"});
		return 0;			
	end
	
	--是否收集齐东西
	local nFlag = 0;
	for i =1 , 12 do
		local nFlagEx = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOOK + i -1) or 0;
		if nFlagEx ~= 1 then
			nFlag = 1;
		end
	end
	if nFlag == 1 then
		Dialog:Say("您的收集册并没收集完全，居然来骗老朽。", {"知道了"});
		return 0;
	end
	
	--领取次数
	local nCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GETAWARD) or 0;
	if nCount >= SpringFrestival.nGetAward_longwu then
		Dialog:Say(string.format("您已经换取了%s次奖励，不能再获奖了！", SpringFrestival.nGetAward_longwu), {"知道了"});
		return 0;		
	end
	
	--背包判定
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("需要1格背包空间，去整理下再来吧！",{"知道了"});
		return 0;
	end
	
	--清除收集册
	for i =1 , 12 do
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_NIANHUA_BOOK + i -1,  0);
	end
	pItem.Delete(me);
	--给奖励
	local pItemEx =  nil;
	if TimeFrame:GetState("OpenLevel150") == 1 and self.bPartOpen == 1 then
		me.AddItem(unpack(SpringFrestival.tbNianHua_award));
	else
		me.AddItem(unpack(SpringFrestival.tbNianHua_award_N));
	end
	--me.SetItemTimeout(pItemEx, 60*24*30, 0);
	EventManager:WriteLog("[新年活动·年画收集册]获得一个年画收集奖励宝箱", me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[新年活动·年画收集册]获得一个年画收集奖励宝箱");
	--设置领奖次数
	me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_GETAWARD, nCount + 1);	
end

--活动期间内服务器维护或者宕机启动，重新加载npc
function SpringFrestival:ServerStartFunc()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= self.VowTreeOpenTime and nData <= self.VowTreeCloseTime then	--活动期间内启动服务器
		SpringFrestival:AddVowTree();
	end	
	if nData >= self.HuaDengOpenTime and nData <= (self.HuaDengCloseTime + 1) then		--活动期间内启动服务器
		local nTime = tonumber(GetLocalDate("%H%M"))
		if (nData == self.HuaDengOpenTime	and  nTime < SpringFrestival.HuaDengOpenTime_C) or 
						(nData == (self.HuaDengCloseTime + 1) and  nTime > SpringFrestival.HuaDengOpenTime_C) then	--9号12点前和15号12点后，服务器启动不加载花灯
			return;
		end
		SpringFrestival:AddNewYearHuaDeng();
	end
end

ServerEvent:RegisterServerStartFunc(SpringFrestival.ServerStartFunc, SpringFrestival);
