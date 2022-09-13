--=================================================
-- 文件名　：laxinitem.lua
-- 创建者　：furuilei
-- 创建时间：2010-09-25 17:57:45
-- 功能描述：拉新活动奖励道具
--=================================================

local tbItem = Item:GetClass("laxinitem");

tbItem.TYPE_FACTION	= 1;	-- 奖励类型 门派
tbItem.TYPE_SERIES	= 2;	-- 奖励类型 五行

--按门派分格式   tbYifu[nFaction][nSex][nFaction]
tbItem.tbYifu = {
	 [1] ={
	 	[0] = {
	 		{2,3,629,7},                      -- 天梦装	橙装PVE_刀少天梦装	2	3	629	7	男	
	 		{2,3,609,7},                      -- 山文字甲	橙装PVE_棍少、天王山文字甲	2	3	609	7	男		  
	 		},
	 	[1] = {
	 		{2,3,639,7},                      -- 黑貂裘	橙装PVE_刀少黑貂裘	2	3	639	7	女	
	 		{2,3,619,7},                      -- 红茸甲	橙装PVE_棍少、天王红茸甲	2	3	619	7	女		 		
	 		},	
	 	} ,		-- 少林 刀棍
	 [2] = {
	 	[0] = {
	 		{2,3,609,7},                      -- 山文字甲	橙装PVE_棍少、天王山文字甲	2	3	609	7	男
	 		{2,3,609,7},                      -- 山文字甲	橙装PVE_棍少、天王山文字甲	2	3	609	7	男		  
	 		},
	 	[1] = {
	 		{2,3,619,7},                      -- 红茸甲	橙装PVE_棍少、天王红茸甲	2	3	619	7	女
	 		{2,3,619,7},                      -- 红茸甲	橙装PVE_棍少、天王红茸甲	2	3	619	7	女		 		
	 		},	
	 	},		-- 天王 枪锤
     [3] = {
 	 	[0] = {
	 		{2,3,649,7},                      -- 天梦装	橙装PVE_刀毒、唐门、明教天梦装	2	3	649	7	男	
	 		{2,3,649,7},                      -- 天梦装	橙装PVE_刀毒、唐门、明教天梦装	2	3	649	7	男			  
	 		},
	 	[1] = {
	 		{2,3,659,7},                      -- 黑貂裘	橙装PVE_刀毒、唐门、明教黑貂裘	2	3	659	7	女
	 		{2,3,659,7},                      -- 黑貂裘	橙装PVE_刀毒、唐门、明教黑貂裘	2	3	659	7	女		 		
	 		},	    	
     	},		-- 唐门 飞刀 袖箭
     [4] = {                               
 	 	[0] = {
	 		{2,3,649,7},                      -- 天梦装	橙装PVE_刀毒、唐门、明教天梦装	2	3	649	7	男		
	 		{2,3,669,7},                      -- 相如袍	橙装PVE_掌毒相如袍	2	3	669	7	男	
	 		},
	 	[1] = {
	 		{2,3,659,7},                      -- 黑貂裘	橙装PVE_刀毒、唐门、明教黑貂裘	2	3	659	7	女
	 		{2,3,679,7},                      -- 琼玉衫	橙装PVE_掌毒琼玉衫	2	3	679	7	女		 		
	 		},		
     	},		-- 五毒 刀掌
     [5] = {
 	 	[0] = {
	 		{2,3,709,7},                      -- 相如袍	橙装PVE_峨嵋、翠烟、气段相如袍	2	3	709	7	男	
	 		{2,3,709,7},                      -- 相如袍	橙装PVE_峨嵋、翠烟、气段相如袍	2	3	709	7	男		  
	 		},
	 	[1] = {
	 		{2,3,719,7},                      -- 琼玉衫	橙装PVE_峨嵋、翠烟、气段琼玉衫	2	3	719	7	女
	 		{2,3,719,7},                      -- 琼玉衫	橙装PVE_峨嵋、翠烟、气段琼玉衫	2	3	719	7	女		 		
	 		},	
    	},		-- 峨嵋 掌 辅助
     [6] = {
   	 	[0] = {
	 		{2,3,709,7},                      -- 相如袍	橙装PVE_峨嵋、翠烟、气段相如袍	2	3	709	7	男	
	 		{2,3,709,7},                      -- 相如袍	橙装PVE_峨嵋、翠烟、气段相如袍	2	3	709	7	男			  
	 		},
	 	[1] = {
	 		{2,3,719,7},                      -- 琼玉衫	橙装PVE_峨嵋、翠烟、气段琼玉衫	2	3	719	7	女
	 		{2,3,719,7},                      -- 琼玉衫	橙装PVE_峨嵋、翠烟、气段琼玉衫	2	3	719	7	女		 		
	 		},	
        },		-- 翠烟  剑 刀
     [7] = {
   	 	[0] = {
	 		{2,3,749,7},                      -- 天梦装	橙装PVE_魔忍、丐帮天梦装	2	3	749	7	男
	 		{2,3,749,7},                      -- 天梦装	橙装PVE_魔忍、丐帮天梦装	2	3	749	7	男	  
	 		},
	 	[1] = {
	 		{2,3,759,7},                      -- 黑貂裘	橙装PVE_魔忍、丐帮黑貂裘	2	3	759	7	女
	 		{2,3,759,7},                      -- 黑貂裘	橙装PVE_魔忍、丐帮黑貂裘	2	3	759	7	女	 		
	 		},	
        },		-- 丐帮  掌棍
     [8] = {
		[0] = {
	 		{2,3,729,7},                      -- 山文字甲	橙装PVE_战忍山文字甲	2	3	729	7	男
	 		{2,3,749,7},                      -- 天梦装	橙装PVE_魔忍、丐帮天梦装	2	3	749	7	男	  
	 		},
	 	[1] = {
	 		{2,3,739,7},                      -- 红茸甲	橙装PVE_战忍红茸甲	2	3	739	7	女	
	 		{2,3,759,7},                      -- 黑貂裘	橙装PVE_魔忍、丐帮黑貂裘	2	3	759	7	女		 		
	 		},	
        },		-- 天忍  战 魔
     [9] = {
    	[0] = {
	 		{2,3,789,7},                      -- 相如袍	橙装PVE_气武、昆仑相如袍	2	3	789	7	男
	 		{2,3,769,7},                      -- 山文字甲	橙装PVE_剑武山文字甲	2	3	769	7	男 
	 		},
	 	[1] = {
	 		{2,3,799,7},                      -- 琼玉衫	橙装PVE_气武、昆仑琼玉衫	2	3	799	7	女
	 		{2,3,779,7},                      -- 红茸甲	橙装PVE_剑武红茸甲	2	3	779	7	女		 		
	 		},	
        },		-- 武当 气 剑
     [10] = {
 	 	[0] = {
	 		{2,3,789,7},                      -- 相如袍	橙装PVE_气武、昆仑相如袍	2	3	789	7	男
	 		{2,3,789,7},                      -- 相如袍	橙装PVE_气武、昆仑相如袍	2	3	789	7	男
	 		},
	 	[1] = {
	 		{2,3,799,7},                      -- 琼玉衫	橙装PVE_气武、昆仑琼玉衫	2	3	799	7	女
	 		{2,3,799,7},                      -- 琼玉衫	橙装PVE_气武、昆仑琼玉衫	2	3	799	7	女	 		
	 		},	
        },		-- 昆仑 刀 剑
     [11] = {
	 	[0] = {
	 		{2,3,649,7},                      -- 天梦装	橙装PVE_刀毒、唐门、明教天梦装	2	3	649	7	男	
	 		{2,3,649,7},                      -- 天梦装	橙装PVE_刀毒、唐门、明教天梦装	2	3	649	7	男	  
	 		},
	 	[1] = {
	 		{2,3,659,7},                      -- 黑貂裘	橙装PVE_刀毒、唐门、明教黑貂裘	2	3	659	7	女
	 		{2,3,659,7},                      -- 黑貂裘	橙装PVE_刀毒、唐门、明教黑貂裘	2	3	659	7	女		 		
	 		},		
        },		-- 明教   锤 剑
     [12] = {
 	 	[0] = {
	 		{2,3,689,7},                      -- 山文字甲	橙装PVE_指段山文字甲	2	3	689	7	男	
	 		{2,3,709,7},                      -- 相如袍	橙装PVE_峨嵋、翠烟、气段相如袍	2	3	709	7	男		  
	 		},
	 	[1] = {
	 		{2,3,699,7},                      -- 红茸甲	橙装PVE_指段红茸甲	2	3	699	7	女
	 		{2,3,719,7},                      -- 琼玉衫	橙装PVE_峨嵋、翠烟、气段琼玉衫	2	3	719	7	女		 		
	 		},		
        },		-- 段氏   指 气   
	};
	
tbItem.tbMaozi = {
	 [1] ={
	 	[0] = {
	 		{2,9,627,7},                      -- 青煞发冠	橙装PVE_刀少青煞发冠	2	9	627	7	男
	 		{2,9,607,7},                      -- 异神盔	橙装PVE_棍少、天王异神盔	2	9	607	7	男		  
	 		},
	 	[1] = {
	 		{2,9,637,7},                      -- 赤豚面罩	橙装PVE_刀少赤豚面罩	2	9	637	7	女
	 		{2,9,617,7},                      -- 龙鳞盔	橙装PVE_棍少、天王龙鳞盔	2	9	617	7	女		 		
	 		},	
	 	} ,		-- 少林 刀棍
	 [2] = {
	 	[0] = {
	 		{2,9,607,7},                      -- 异神盔	橙装PVE_棍少、天王异神盔	2	9	607	7	男
	 		{2,9,607,7},                      -- 异神盔	橙装PVE_棍少、天王异神盔	2	9	607	7	男	  
	 		},
	 	[1] = {
	 		{2,9,617,7},                      -- 龙鳞盔	橙装PVE_棍少、天王龙鳞盔	2	9	617	7	女
	 		{2,9,617,7},                      -- 龙鳞盔	橙装PVE_棍少、天王龙鳞盔	2	9	617	7	女	 		
	 		},	
	 	},		-- 天王 枪锤
     [3] = {
 	 	[0] = {
	 		{2,9,647,7},                      -- 青煞发冠	橙装PVE_刀毒、唐门、明教青煞发冠	2	9	647	7	男	
	 		{2,9,647,7},                      -- 青煞发冠	橙装PVE_刀毒、唐门、明教青煞发冠	2	9	647	7	男		  
	 		},
	 	[1] = {
	 		{2,9,657,7},                      -- 赤豚面罩	橙装PVE_刀毒、唐门、明教赤豚面罩	2	9	657	7	女	
	 		{2,9,657,7},                      -- 赤豚面罩	橙装PVE_刀毒、唐门、明教赤豚面罩	2	9	657	7	女		 		
	 		},	    	
     	},		-- 唐门 飞刀 袖箭
     [4] = {                               
 	 	[0] = {
	 		{2,9,647,7},                      -- 青煞发冠	橙装PVE_刀毒、唐门、明教青煞发冠	2	9	647	7	男		
	 		{2,9,667,7},                      -- 绝玉束额	橙装PVE_掌毒绝玉束额	2	9	667	7	男	
	 		},
	 	[1] = {
	 		{2,9,657,7},                      -- 赤豚面罩	橙装PVE_刀毒、唐门、明教赤豚面罩	2	9	657	7	女	
	 		{2,9,677,7},                      -- 朱雀发结	橙装PVE_掌毒朱雀发结	2	9	677	7	女		 		
	 		},		
     	},		-- 五毒 刀掌
     [5] = {
 	 	[0] = {
	 		{2,9,707,7},                      -- 绝玉束额	橙装PVE_气段、翠烟、峨嵋绝玉束额	2	9	707	7	男	
	 		{2,9,707,7},                      -- 绝玉束额	橙装PVE_气段、翠烟、峨嵋绝玉束额	2	9	707	7	男		  
	 		},
	 	[1] = {
	 		{2,9,717,7},                      -- 朱雀发结	橙装PVE_气段、翠烟、峨嵋朱雀发结	2	9	717	7	女
	 		{2,9,717,7},                      -- 朱雀发结	橙装PVE_气段、翠烟、峨嵋朱雀发结	2	9	717	7	女		 		
	 		},	
    	},		-- 峨嵋 掌 辅助
     [6] = {
   	 	[0] = {
	 		{2,9,707,7},                      -- 绝玉束额	橙装PVE_气段、翠烟、峨嵋绝玉束额	2	9	707	7	男	
	 		{2,9,707,7},                      -- 绝玉束额	橙装PVE_气段、翠烟、峨嵋绝玉束额	2	9	707	7	男			  
	 		},
	 	[1] = {
	 		{2,9,717,7},                      -- 朱雀发结	橙装PVE_气段、翠烟、峨嵋朱雀发结	2	9	717	7	女
	 		{2,9,717,7},                      -- 朱雀发结	橙装PVE_气段、翠烟、峨嵋朱雀发结	2	9	717	7	女		 		
	 		},	
        },		-- 翠烟  剑 刀
     [7] = {
   	 	[0] = {
	 		{2,9,747,7},                      -- 青煞发冠	橙装PVE_魔忍、丐帮青煞发冠	2	9	747	7	男
	 		{2,9,747,7},                      -- 青煞发冠	橙装PVE_魔忍、丐帮青煞发冠	2	9	747	7	男	  
	 		},
	 	[1] = {
	 		{2,9,757,7},                      -- 赤豚面罩	橙装PVE_魔忍、丐帮赤豚面罩	2	9	757	7	女
	 		{2,9,757,7},                      -- 赤豚面罩	橙装PVE_魔忍、丐帮赤豚面罩	2	9	757	7	女	 		
	 		},	
        },		-- 丐帮  掌棍
     [8] = {
		[0] = {
	 		{2,9,727,7},                      -- 异神盔	橙装PVE_战忍异神盔	2	9	727	7	男
	 		{2,9,747,7},                      -- 青煞发冠	橙装PVE_魔忍、丐帮青煞发冠	2	9	747	7	男	  
	 		},
	 	[1] = {
	 		{2,9,737,7},                      -- 龙鳞盔	橙装PVE_战忍龙鳞盔	2	9	737	7	女	
	 		{2,9,757,7},                      -- 赤豚面罩	橙装PVE_魔忍、丐帮赤豚面罩	2	9	757	7	女		 		
	 		},	
        },		-- 天忍  战 魔
     [9] = {
    	[0] = {
	 		{2,9,787,7},                      -- 绝玉束额	橙装PVE_气武、昆仑绝玉束额	2	9	787	7	男
	 		{2,9,767,7},                      -- 异神盔	橙装PVE_剑武异神盔	2	9	767	7	男	 
	 		},
	 	[1] = {
	 		{2,9,797,7},                      -- 朱雀发结	橙装PVE_气武、昆仑朱雀发结	2	9	797	7	女
	 		{2,9,777,7},                      -- 龙鳞盔	橙装PVE_剑武龙鳞盔	2	9	777	7	女		 		
	 		},	
        },		-- 武当 气 剑
     [10] = {
 	 	[0] = {
	 		{2,9,787,7},                      -- 绝玉束额	橙装PVE_气武、昆仑绝玉束额	2	9	787	7	男
	 		{2,9,787,7},                      -- 绝玉束额	橙装PVE_气武、昆仑绝玉束额	2	9	787	7	男
	 		},
	 	[1] = {
	 		{2,9,797,7},                      -- 朱雀发结	橙装PVE_气武、昆仑朱雀发结	2	9	797	7	女
	 		{2,9,797,7},                      -- 朱雀发结	橙装PVE_气武、昆仑朱雀发结	2	9	797	7	女	 		
	 		},	
        },		-- 昆仑 刀 剑
     [11] = {
	 	[0] = {
	 		{2,9,647,7},                      -- 青煞发冠	橙装PVE_刀毒、唐门、明教青煞发冠	2	9	647	7	男	
	 		{2,9,647,7},                      -- 青煞发冠	橙装PVE_刀毒、唐门、明教青煞发冠	2	9	647	7	男	  
	 		},
	 	[1] = {
	 		{2,9,657,7},                      -- 赤豚面罩	橙装PVE_刀毒、唐门、明教赤豚面罩	2	9	657	7	女	
	 		{2,9,657,7},                      -- 赤豚面罩	橙装PVE_刀毒、唐门、明教赤豚面罩	2	9	657	7	女		 		
	 		},		
        },		-- 明教   锤 剑
     [12] = {
 	 	[0] = {
	 		{2,9,687,7},                      -- 异神盔	橙装PVE_指段异神盔	2	9	687	7	男		
	 		{2,9,707,7},                      -- 绝玉束额	橙装PVE_气段、翠烟、峨嵋绝玉束额	2	9	707	7	男		  
	 		},
	 	[1] = {
	 		{2,9,697,7},                      -- 龙鳞盔	橙装PVE_指段龙鳞盔	2	9	697	7	女
	 		{2,9,717,7},                      -- 朱雀发结	橙装PVE_气段、翠烟、峨嵋朱雀发结	2	9	717	7	女		 		
	 		},		
        },		-- 段氏   指 气   
	};	
	
--按五行分  格式   tbYaodai[nSeries][nSex]
tbItem.tbYaodai = {
	 [1] ={
	 	[0] = {2,8,307,7},                    
	 	[1] = {2,8,317,7},                    			
	 	} ,		-- 金
	 [2] ={
	 	[0] = {2,8,327,7},                   
	 	[1] = {2,8,337,7},                  	
	 	} ,		-- 木
	 [3] ={
	 	[0] = {2,8,347,7},                 
	 	[1] = {2,8,357,7},                		
	 	} ,		-- 水
	 [4] ={
	 	[0] = {2,8,367,7},                 
	 	[1] = {2,8,377,7},                		
	 	} ,		-- 火
	 [5] ={
	 	[0] = {2,8,387,7},                   
	 	[1] = {2,8,397,7},                  
	 	} ,		-- 土
	};
			
tbItem.tbXiezi = {
	 [1] ={
	 	[0] = {2,7,309,7},                    
	 	[1] = {2,7,319,7},                    			
	 	} ,		-- 金
	 [2] ={
	 	[0] = {2,7,329,7},                   
	 	[1] = {2,7,339,7},                  	
	 	} ,		-- 木
	 [3] ={
	 	[0] = {2,7,349,7},                 
	 	[1] = {2,7,359,7},                		
	 	} ,		-- 水
	 [4] ={
	 	[0] = {2,7,369,7},                 
	 	[1] = {2,7,379,7},                		
	 	} ,		-- 火
	 [5] ={
	 	[0] = {2,7,389,7},                   
	 	[1] = {2,7,399,7},                  
	 	} ,		-- 土
	};
		
tbItem.tbHuwan = {
	 [1] ={
	 	[0] = {2,10,309,7},                    
	 	[1] = {2,10,319,7},                    			
	 	} ,		-- 金
	 [2] ={
	 	[0] = {2,10,329,7},                   
	 	[1] = {2,10,339,7},                  	
	 	} ,		-- 木
	 [3] ={
	 	[0] = {2,10,349,7},                 
	 	[1] = {2,10,359,7},                		
	 	} ,		-- 水
	 [4] ={
	 	[0] = {2,10,369,7},                 
	 	[1] = {2,10,379,7},                		
	 	} ,		-- 火
	 [5] ={
	 	[0] = {2,10,389,7},                   
	 	[1] = {2,10,399,7},                  
	 	} ,		-- 土
	};
	
tbItem.tbYaozhui = {
	 [1] ={
	 	[0] = {2,11,307,7},                    
	 	[1] = {2,11,317,7},                    			
	 	} ,		-- 金
	 [2] ={
	 	[0] = {2,11,327,7},                   
	 	[1] = {2,11,337,7},                  	
	 	} ,		-- 木
	 [3] ={
	 	[0] = {2,11,347,7},                 
	 	[1] = {2,11,357,7},                		
	 	} ,		-- 水
	 [4] ={
	 	[0] = {2,11,367,7},                 
	 	[1] = {2,11,377,7},                		
	 	} ,		-- 火
	 [5] ={
	 	[0] = {2,11,387,7},                   
	 	[1] = {2,11,397,7},                  
	 	} ,		-- 土
	};
	
tbItem.tbHushenfu = {
	 [1] ={
	 	[0] = {2,6,158,7},                    
	 	[1] = {2,6,158,7},                    			
	 	} ,		-- 金
	 [2] ={
	 	[0] = {2,6,168,7},                   
	 	[1] = {2,6,168,7},                  	
	 	} ,		-- 木
	 [3] ={
	 	[0] = {2,6,178,7},                 
	 	[1] = {2,6,178,7},                		
	 	} ,		-- 水
	 [4] ={
	 	[0] = {2,6,188,7},                 
	 	[1] = {2,6,188,7},                		
	 	} ,		-- 火
	 [5] ={
	 	[0] = {2,6,198,7},                   
	 	[1] = {2,6,198,7},                  
	 	} ,		-- 土
	};
	
tbItem.tbXianglian = {
	 [1] ={
	 	[0] = {2,5,157,7},                    
	 	[1] = {2,5,157,7},                    			
	 	} ,		-- 金
	 [2] ={
	 	[0] = {2,5,167,7},                   
	 	[1] = {2,5,167,7},                  	
	 	} ,		-- 木
	 [3] ={
	 	[0] = {2,5,177,7},                 
	 	[1] = {2,5,177,7},                		
	 	} ,		-- 水
	 [4] ={
	 	[0] = {2,5,187,7},                 
	 	[1] = {2,5,187,7},                		
	 	} ,		-- 火
	 [5] ={
	 	[0] = {2,5,197,7},                   
	 	[1] = {2,5,197,7},                  
	 	} ,		-- 土
	};
	
tbItem.tbJiezhi = {
	 [1] ={
	 	[0] = {2,4,157,7},                    
	 	[1] = {2,4,157,7},                    			
	 	} ,		-- 金
	 [2] ={
	 	[0] = {2,4,167,7},                   
	 	[1] = {2,4,167,7},                  	
	 	} ,		-- 木
	 [3] ={
	 	[0] = {2,4,177,7},                 
	 	[1] = {2,4,177,7},                		
	 	} ,		-- 水
	 [4] ={
	 	[0] = {2,4,187,7},                 
	 	[1] = {2,4,187,7},                		
	 	} ,		-- 火
	 [5] ={
	 	[0] = {2,4,197,7},                   
	 	[1] = {2,4,197,7},                  
	 	} ,		-- 土
	};
	
	
--防具集合	
tbItem.tbFangju = {
	[1] = {tbItem.tbYifu,		tbItem.TYPE_FACTION},
	[2] = {tbItem.tbMaozi,		tbItem.TYPE_FACTION},
	[3] = {tbItem.tbYaodai,		tbItem.TYPE_SERIES},
	[4] = {tbItem.tbXiezi,		tbItem.TYPE_SERIES},
	[5] = {tbItem.tbHuwan,		tbItem.TYPE_SERIES},
	};	
	
--首饰集合
tbItem.tbShoushi = {
	[1] = {tbItem.tbHushenfu,	tbItem.TYPE_SERIES},
	[2] = {tbItem.tbJiezhi,		tbItem.TYPE_SERIES},
	[3] = {tbItem.tbYaozhui,	tbItem.TYPE_SERIES},
	[4] = {tbItem.tbXianglian,	tbItem.TYPE_SERIES},
	};
	
--装备集合
tbItem.tbEquip = {
	[1] = tbItem.tbFangju,
	[2] = tbItem.tbShoushi,
	};	
	
--关于装备任务变量的集合
tbItem.tbTask = {
    [1] = {
    	[1] = tbItem.TASK_FANGJU_NUM, 
	 	[2] = tbItem.TASK_FANGJU_SEL,
	 	},
    [2] = {
    	[1] = tbItem.TASK_SHOUSHI_NUM,
		[2] = tbItem.TASK_SHOUSHI_SEL,
		},
	};	
	
function tbItem:OnUse()
	local nLevel = it.nLevel;
	if (not nLevel or (nLevel ~= 1 and nLevel ~= 2)) then
		return 0;
	end
	
	local tbEquip = self.tbEquip[nLevel];
	local nFreeBag = me.CountFreeBagCell();
	if (#tbEquip > nFreeBag) then
		Dialog:Say(string.format("包裹空间不足，请清理出%s个包裹空间再来取出物品吧。", #tbEquip));
		return 0;
	end
	
	if (me.nRouteId == 0 or me.nFaction == 0 or me.nSeries == 0) then
		Dialog:Say("您还没选择武功流派，不能领奖。");
		return 0;
	end
	
	for _, tbInfo in pairs(tbEquip) do
		local tbGDPL = self:GetEquip_GDPL(tbInfo);
		if (tbGDPL and #tbGDPL == 4) then
			local G, D, P, L = tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4];
			local pItem = me.AddItem(G, D, P, L, -1, 8);
			if (pItem) then
				pItem.Bind(1);
			end
		end
	end
		
	return 1;
end

-- 根据选择奖励的类型是门派还是五行获取出具体奖励的gdpl
function tbItem:GetEquip_GDPL(tbInfo)
	local tbSpeEquip = tbInfo[1];
	local nSelectType = tbInfo[2] or 0;
	if (not tbSpeEquip or #tbSpeEquip == 0 or nSelectType == 0) then
		return;
	end
	
	local nFaction = me.nFaction;
	local nRouteId = me.nRouteId;
	local nSeries = me.nSeries;
	
	if (nSelectType == self.TYPE_FACTION) then
		return tbSpeEquip[nFaction][me.nSex][nRouteId];
	elseif (nSelectType == self.TYPE_SERIES) then
		return tbSpeEquip[nSeries][me.nSex];
	end
end
