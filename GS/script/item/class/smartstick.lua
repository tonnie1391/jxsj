local tbItem = Item:GetClass("smartstick");

tbItem.RANDOM_BASE  = 100;  --随机基数
tbItem.TIME_START	= 20100428;
tbItem.TIME_END		= 20100511;
tbItem.SKILL_ID		= 1624;
tbItem.DIALOGMSG	= "开心变，变变变。";
tbItem.TIME_BUFF	= 60*60;


tbItem.TSK_GROUP	= 2119;
tbItem.TSK_DAY		= 7; -- 记录使用日期 
tbItem.TSK_CASTID	= 8; -- 三位变量使用 nTransformId, bGetMask, bGetBuff

--tbItem.TIME_START	= 20100301;
--tbItem.TIME_END		= 20100711;

tbItem.tbTransform = {
	[1] = { tbItem = {1,13,50,1}, nBuffId = 386 ,nBuffLevel = 8 , nProbability = 15,}, -- 大熊
	[2] = { tbItem = {1,13,51,1}, nBuffId = 385 ,nBuffLevel = 8 , nProbability = 15,}, -- 乌龟
	[3] = { tbItem = {1,13,52,1}, nBuffId = 387 ,nBuffLevel = 8 , nProbability = 15,}, -- 老虎
	[4] = { tbItem = {1,13,53,1}, nBuffId = 1623,nBuffLevel = 20, nProbability = 30,}, -- 蛇
	[5] = { tbItem = {1,13,54,1}, nBuffId = 880 ,nBuffLevel = 3 , nProbability = 25,}, -- 财宝兔				
	};	
	

function tbItem:OnUse()	
	local nRet, szMsg = self:CheckDate();
	if nRet == 0 then
		Dialog:Say(szMsg);
		return;
	end


	local nTransformId, bGetMask, bGetBuff = self:GetTskData();
	local tbOpt = {};
	
	if bGetMask == 0 then
		table.insert(tbOpt,{"领取变身面具",self.GetMask,self});
	else
		table.insert(tbOpt,{"<color=gray>领取变身面具<color>",self.GetMask,self});	
	end
	
	if bGetBuff == 0 then	
		table.insert(tbOpt,{"获得增益效果",self.GetBuff,self});	
	else
		table.insert(tbOpt,{"<color=gray>获得增益效果<color>",self.GetBuff,self});	
	end
	
	table.insert(tbOpt,{"Để ta suy nghĩ thêm。"});

	Dialog:Say(self.DIALOGMSG, tbOpt); 
end

function tbItem:GetMask()	
	local nRet, szMsg = self:CheckDate();
	if nRet == 0 then
		Dialog:Say(szMsg);
		return;
	end	
	
	local nTransformId, bGetMask, bGetBuff = self:GetTskData();
	if bGetMask == 1 then
		Dialog:Say("您已经领取过今天的面具了。");
		return;
	end
	self:GetMaskEx({nTransformId, bGetMask, bGetBuff});
end

function tbItem:GetBuff()
	local nRet, szMsg = self:CheckDate();
	if nRet == 0 then
		Dialog:Say(szMsg);
		return;
	end	
	
	local nTransformId, bGetMask, bGetBuff = self:GetTskData();
	if bGetBuff == 1 then
		Dialog:Say("您已经领取过今天的增益了。");
		return;
	end	
	
	self:GetBuffEx({nTransformId, bGetMask, bGetBuff});		
end

function tbItem:GetBuffEx(tbData)
	local nCastId = tbData[1];
	if nCastId == 0 then
		nCastId = self:RandomId();
	end	
	
	me.AddSkillState(self.tbTransform[nCastId].nBuffId, self.tbTransform[nCastId].nBuffLevel, 1, self.TIME_BUFF * Env.GAME_FPS, 1, 0, 1);		
	local nData = self:CombData(nCastId,tbData[2],1);	
	me.SetTask(self.TSK_GROUP,self.TSK_CASTID,nData);
end

function tbItem:GetMaskEx(tbData)
	local nCastId = tbData[1];
	if nCastId == 0 then
		nCastId = self:RandomId();
	end
	
	local nRet, szMsg =  self:AddMask(nCastId);
	if nRet == 0 then
		Dialog:Say(szMsg);
		return;
	end
	local nData = self:CombData(nCastId,1,tbData[3]);	
	me.SetTask(self.TSK_GROUP,self.TSK_CASTID,nData);		
	return;
end

function tbItem:AddMask(nCastId)
	if me.CountFreeBagCell() < 1 then
		return 0, "您的包裹空间不够，清出一格再领取吧";
	end

	local szDate = GetLocalDate("%Y%m%d");
	szDate = szDate.."2400";
	local nDate = tonumber(szDate);			
	local pItem = me.AddItem(unpack(self.tbTransform[nCastId].tbItem));
	if pItem then
		pItem.SetTimeOut(0, Lib:GetDate2Time(nDate)); -- 加过期时间
		pItem.Sync();
	end
	return 1;
end

function tbItem:RandomId()	
	local nRandom = MathRandom(self.RANDOM_BASE);
	local nId = 0;
	for i, tbTransform in ipairs(self.tbTransform) do
		if tbTransform.nProbability >= nRandom then
			nId = i;
			break;
		end
		nRandom = nRandom - tbTransform.nProbability;
	end	
	return nId;
end

function tbItem:CheckDate()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.TIME_START then
		return 0,"活动尚未开始呢。" ;
	end
	if nDate > self.TIME_END then
		return 0,"活动已经结束啦。" ;
	end
	return 1;
end

function tbItem:GetTskData()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));		
	local nData		= 0;
	local nFirst, nMid, nLast = 0,0,0;	
	if me.GetTask(self.TSK_GROUP,self.TSK_DAY) ~= nDate then
		me.SetTask(self.TSK_GROUP,self.TSK_DAY,nDate);
		me.SetTask(self.TSK_GROUP,self.TSK_CASTID,0);			
	else
		nData = me.GetTask(self.TSK_GROUP,self.TSK_CASTID);	
	    nFirst, nMid, nLast = self:SpiltData(nData);	
	end	
	return 	nFirst, nMid, nLast;
end

--拿到一个数字的个 十 位 以及 百位以上
function tbItem:SpiltData(num)
	local nLast = num %10;
	local nMid = math.floor((num %100)/10);
	local nFirst = math.floor(num/100);
	return nFirst, nMid, nLast;
end

function tbItem:CombData(nFirst, nMid, nLast)
	return (nFirst *100 + nMid * 10 + nLast);
end
