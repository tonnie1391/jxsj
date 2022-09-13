--10个房间传入的坐标
KinGame.tbHeartMonster = {};
local tbHeartMonster = KinGame.tbHeartMonster;
tbHeartMonster.ITEMID 	= 2958;	 --迷药npc id
tbHeartMonster.MONSTERID = 2885; --心魔Id
tbHeartMonster.MIYAO_ITEM_ID 	= {18,1,107,1,{bTimeOut = 1}};	 --迷药item
tbHeartMonster.MIYAO_ITEM_TIME	= 120	-- 两小时时效
tbHeartMonster.ITEMPOS 	= 
{
	-- 心魔草召唤坐标
	[1] = {62528,85888},
	[2] = {62432,86528},
	[3] = {62848,87008},
	[4] = {63040,85984},
	[5] = {63360,86496},
	[6] = {66336,90848},
	[7] = {66816,90400},
	[8] = {66784,91424},
	[9] = {67360,91008},
	[10] = {67296,91424},
}

tbHeartMonster.MONSTERROOM = 
{
	--房间号:	心魔召唤坐标	玩家传入坐标
	[1] = {tbNpcPos = {52608, 77920}, tbPlayerIn = {52864, 78432}, tbPlayerOut = {62624, 85792}},
	[2] = {tbNpcPos = {52544, 81216}, tbPlayerIn = {52864, 81760}, tbPlayerOut = {62464, 86368}},
	[3] = {tbNpcPos = {54144, 81344}, tbPlayerIn = {54464, 81824}, tbPlayerOut = {62944, 86976}},
	[4] = {tbNpcPos = {54272, 77760}, tbPlayerIn = {54560, 78304}, tbPlayerOut = {63168, 86080}},
	[5] = {tbNpcPos = {56160, 77344}, tbPlayerIn = {56480, 77984}, tbPlayerOut = {63392, 86656}},
	[6] = {tbNpcPos = {55904, 81088}, tbPlayerIn = {56224, 81600}, tbPlayerOut = {66432, 90752}},
	[7] = {tbNpcPos = {58080, 77280}, tbPlayerIn = {58368, 77920}, tbPlayerOut = {66944, 90496}},
	[8] = {tbNpcPos = {58080, 81600}, tbPlayerIn = {58368, 82080}, tbPlayerOut = {66688, 91392}},
	[9] = {tbNpcPos = {60032, 77120}, tbPlayerIn = {60352, 77664}, tbPlayerOut = {67456, 91168}},
	[10] = {tbNpcPos = {60224, 81696}, tbPlayerIn = {60480, 82144}, tbPlayerOut = {67200, 91520}},
}



function tbHeartMonster:AddMonsterItem(nRoomId, nMapId)
		if SubWorldID2Idx(nMapId) < 0 then
			return 0;
		end
		local pGame =  KinGame:GetGameObjByMapId(nMapId) --获得对象	
		if pGame:GetMiYaoCount(nRoomId) >= KinGame.MAX_MIYAO_LIMIT_ITEM then
			return 0;
		end
		local nPosX 	= math.floor(self.ITEMPOS[nRoomId][1]/32);
		local nPosY		= math.floor(self.ITEMPOS[nRoomId][2]/32);
		local pNpc		= KNpc.Add2(self.ITEMID, 1, -1, nMapId, nPosX, nPosY);
		if not pNpc then
			return 0;
		end
		pGame:AddMiYaoCount(nRoomId)
		local tbTmp = pNpc.GetTempTable("KinGame");
		tbTmp.nRoomId = nRoomId;
end

function tbHeartMonster:InIt(nMapId)
		for nRoomId = 1 , 10 do
			self:AddMonsterItem(nRoomId, nMapId);
		end
end
