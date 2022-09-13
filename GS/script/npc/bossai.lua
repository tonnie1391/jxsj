------------------------------------------------------
-- 文件名　：bossai.lua
-- 创建者　：dengyong
-- 创建时间：2012-04-19 09:22:27
-- 描  述  ：bossai脚本入口
------------------------------------------------------

function Npc:BossAiScript(szScript, nTargetIndex)
	-- split the szScript str
	local tbRet = self:SplitScriptStr(szScript);
	if not tbRet or Lib:CountTB(tbRet) == 0 then
		return 0;
	end
	
	local pTargeNpc = KNpc.GetByIndex(nTargetIndex);
	
	if tbRet[1] == "script" then
		-- 是一段逻辑脚本,loadstring直接执行
		local fn = loadstring(tbRet[2]);
		if fn then
--			local tbEnv = getfenv(fn);
--			tbEnv.pTargeNpc = pTargeNpc;
--			setfenv(fn, tbEnv);
			fn(pTargeNpc);
		end
	elseif tbRet[1] == "function" then
		-- 是函数，Lib:CallBack
		local tbCallBack = {tbRet[2], pTargeNpc};
		Lib:CallBack(tbCallBack);
	elseif tbRet[1] == "table" then
		-- 还不知道如果填table怎么个使用法，只是格式上支持而已，逻辑上暂未处理
		-- 暂时什么都不做
	else
		assert(false, "bossai InValid Script Setting for Boss:"..him.szName);
		return 0;
	end
	
	return 1;
end

-- <% %>，说明里面是脚本逻辑
-- <* *>, 说明里面是函数名
-- <$ $>, 说明里面是一张张连续的table, 例：<$ {g,d,p,l}{g,d,p,l} $> 
function Npc:SplitScriptStr(str)
	local tbRet = {};
	
	if string.find(str, "<%%(.-)%%>") then
		-- <% %>，说明里面是脚本逻辑
		local _, _, sz = string.find(str, "<%%(.-)%%>");   -- 配置表填写要保证能且只能找到一个！！！
		tbRet = {"script", sz};
	elseif string.find(str, "<%*(.-)%*>") then
		-- <* *>, 说明里面是函数名
		local _, _, sz = string.find(str, "<%*(.-)%*>");   -- 配置表填写要保证能且只能找到一个！！！
		
		-- 注意，if 和 elseif 的顺序不能反，因为要支持a.b:f()这种类型
		if string.find(sz, "%:") then
			tbRet = {"function", sz};	
		elseif string.find(sz, "%.") then
			-- 只用了.来表示层级关系，把它解析a.b:f()的形式
			local _sz = string.reverse(sz);
			local start, stop = string .find(_sz, "%.");	-- 反转，然后把最后一个.改成:即可
			local szFun = string.format("%s:%s", string.sub(_sz, 1, start-1), string.sub(_sz, stop+1, #_sz));
			szFun = string.reverse(szFun);		-- 再反转一次就OK啦
			tbRet = {"function", szFun};			
		else
			assert(false, " InValid function Format For Boss:"..him.szName);
		end	
	elseif string.find(szScript, "<%$%(.-)$>") then
		-- <$ $>, 说明里面是table
		local _, _, sz = string.find(str, "<%$(.-)%$>"); 	-- 配置表填写要保证能且只能找到一个！！！
		local function _StrToTable(sz)
			local tb = {};
			for _str in string.gmatch(str, "{(.-)}") do
				local tbTemp = Lib:SplitStr(_str);
				table.insert(tb, tbTemp);
			end
			return tb;
		end
		tbRet = {"table", _StrToTable(sz)};
	else
		assert(false, "bossai InValid Script Setting for Boss:"..him.szName);
		return;
	end
	
	return tbRet;
end

-- Sample:偷取生命
function Npc:StealLife(pTargeNpc)
	if not pTargeNpc then
		return;
	end
	
	pTargeNpc.ReduceLife(500);
	him.RestoreLife();
end
--新手副本陆往生or金军统领黑条提示
function Npc:Npc10256Skill_01(pTargeNpc)
	if not pTargeNpc then
		return;
	end
	local pPlayer =  pTargeNpc.GetPlayer();
	if pPlayer then
		local szName = him.szName or "kẻ địch";
		local szMsg = string.format("Chạm vào <color=gold>Chân khí<color> trên mặt đất để hạ gục %s.", szName)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);		
	end
	him.AddSkillState(999,30,0,8*18,0,1,0,0,1);
	local nMapId, nMapX, nMapY = him.GetWorldPos();
	for i=1,13 do
		local nRadius	= MathRandom(4*100, 15*100)/100;
		local nAngle	= MathRandom(0, math.pi*100/2)/100;
		local nLvMin,nLvMax = 5,10;
		local x = nRadius*math.cos(nAngle)*32;
		local y = nRadius*math.sin(nAngle)*32*1.2;
		him.CastSkill(2342,MathRandom(nLvMin,nLvMax),nMapX*32+x,nMapY*32+y);
		him.CastSkill(2342,MathRandom(nLvMin,nLvMax),nMapX*32+x,nMapY*32-y);
		him.CastSkill(2342,MathRandom(nLvMin,nLvMax),nMapX*32-x,nMapY*32+y);
		him.CastSkill(2342,MathRandom(nLvMin,nLvMax),nMapX*32-x,nMapY*32-y);
	end
end
