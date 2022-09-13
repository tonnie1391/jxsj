
--	ÃÅÅÉÕÆÃÅÈË;	
local tbMenPaiZhangMenRen = Npc:GetClass("menpaizhangmenren");
local tbNpcTemplate2Faction = 
{
	[3512] = Env.FACTION_ID_SHAOLIN,    
	[3506] = Env.FACTION_ID_TIANWANG,   
	[3518] = Env.FACTION_ID_TANGMEN,    
	[3524] = Env.FACTION_ID_WUDU,       
	[3530] = Env.FACTION_ID_EMEI,       
	[3536] = Env.FACTION_ID_CUIYAN,     
	[3542] = Env.FACTION_ID_GAIBANG,    
	[3548] = Env.FACTION_ID_TIANREN,    
	[3554] = Env.FACTION_ID_WUDANG,     
	[3560] = Env.FACTION_ID_KUNLUN,      
	[3479] = Env.FACTION_ID_MINGJIAO,    
	[3500] = Env.FACTION_ID_DALIDUANSHI,
	[11014] = Env.FACTION_ID_GUMU,
}

function tbMenPaiZhangMenRen:OnDialog()
	Npc.tbMenPaiNpc:DialogMaster(tbNpcTemplate2Faction[him.nTemplateId])
end
