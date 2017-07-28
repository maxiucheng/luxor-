local strategy={}
local timePeriod=cs.m30

local entrytime = 0
local flagtrailing = 0
local buystop = 0
local sellstop = 0
local buytrig = 0
local selltrig = 0
local entrytime1 = 0
local flagtrailing1 = 0
local buystop1 = 0
local sellstop1 = 0
local buytrig1 = 0
local selltrig1 = 0
local entrytime2 = 0
local flagtrailing2 = 0
local buystop2 = 0
local sellstop2 = 0
local buytrig2 = 0
local selltrig2 = 0
local entrytime3 = 0
local flagtrailing3 = 0
local buystop3 = 0
local sellstop3 = 0
local buytrig3 = 0
local selltrig3 = 0
strategy.subscrib={}
strategy.onStart=function(_self)
	strategy.subscrib={MT.getPara('merp'), MT.getPara('merp1'), MT.getPara('merp2'), MT.getPara('merp3')}
	_self.mafast, _self.maslow = MT.idcMA(MT.getPara('merp'), timePeriod, MT.getPara('fast'), MT.getPara('slow') )	
	_self.mafast1, _self.maslow1 = MT.idcMA(MT.getPara('merp1'), timePeriod, MT.getPara('fast1'), MT.getPara('slow1') )	
	_self.mafast2, _self.maslow2 = MT.idcMA(MT.getPara('merp2'), timePeriod, MT.getPara('fast2'), MT.getPara('slow2') )	
	_self.mafast3, _self.maslow3 = MT.idcMA(MT.getPara('merp3'), timePeriod, MT.getPara('fast3'), MT.getPara('slow3') )	
end	
strategy.onUpdate=function(_self)	
    _self:onUpdate1()
    _self:onUpdate2()
    _self:onUpdate3()
	local merpcode = MT.getPara('merp')
	local count = MT.getPara('count')
    local k1 = MT.idcKLINE(merpcode,timePeriod,-1)
    local k2 = MT.idcKLINE(merpcode,timePeriod,-2)	 
    local price = MT.getLastPrice(merpcode)
	local pos = MT.tradePosition(merpcode)
    local mafast =  _self.mafast
    local maslow =  _self.maslow
	local curtime = os.time()
    local stoploss = MT.getPara('stoploss')
	local profittarget = MT.getPara('profittarget')
	local trailingstart = MT.getPara('trailingstart')
	local percent = MT.getPara('percent')
    local str2 = os.date('%H:%M:%S')
	local h11,m1,s1 = string.match(str2,"(%d+):(%d+):(%d+)")
    local time1 = h11 * 3600 + m1 * 60 + s1
	local timetrue = time1 >= 16 * 3600 and time1<=23 * 3600
	if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	    buystop = k2.h
         		
	end   
    if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	    sellstop = k2.l 
		 
	end	 
	if pos[1] and pos then
	    for _,p in ipairs(pos) do
	         
            if p.num > 0 and price - p.price + stoploss < 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplossbuy') 	
	        end
	        if p.num > 0 and price < maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('buyexitduetomaslow')	
	        end
		    if p.num > 0 and price - p.price - profittarget > 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetbuy')	
	        end
		    if p.num > 0 then
			    local poshigh = k2.h
				 
				if k1.h - poshigh  > 0.000000001 then
				    poshigh = k1.h 
				end
				 
				if poshigh - p.price - trailingstart >0.00000001 then
				    flagtrailing = 1
				end
				
				if 1 == flagtrailing and price < poshigh - percent / 100 * (poshigh - p.price) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopbuy')
 					flagtrailing = 0
				end	
		    end
		    if p.num < 0 and price - p.price - stoploss > 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplosssell') 	
	        end
	        if p.num < 0 and price > maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('sellexitduetomaslow')	
	        end
		    if p.num < 0 and p.price - price - profittarget >0.000000001 then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetsell')	
	        end
		    if p.num < 0 then
			    local poslow = k2.l
				if k1.l < poslow then
				    poslow = k1.l
				end
				if p.price - poslow - trailingstart > 0.00000001 then
				    flagtrailing = 1
				end
				if 1 == flagtrailing and price > poslow + percent / 100 * (p.price - poslow) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopsell')
 					flagtrailing = 0
				end	
		    end		
		end	
	else        
        if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	        buytrig = 1          		
	    end   
        if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	        selltrig = 1
		end
		if mafast[-2] > maslow[-2] and price - buystop >0.00000001 and curtime - entrytime > 100 and timetrue  and buystop ~= 0 and 1 == buytrig then
            MT.tradeMarketPriceBuy(merpcode, count)		
	        entrytime = curtime
			buytrig = 0
	        print('buyentry')	
	    end
	    if mafast[-2] < maslow[-2] and price - sellstop <-0.00000001 and curtime - entrytime > 100  and timetrue and 1 == selltrig then
            MT.tradeMarketPriceSell(merpcode, count)		
	        entrytime = curtime
            selltrig = 0			
	        print('sellentry')	
	    end	
	end	
end
strategy.onUpdate1=function(_self)	
	local merpcode = MT.getPara('merp1')
	local count = MT.getPara('count1')
    local k1 = MT.idcKLINE(merpcode,timePeriod,-1)
    local k2 = MT.idcKLINE(merpcode,timePeriod,-2)	 
    local price = MT.getLastPrice(merpcode)
	local pos = MT.tradePositions(merpcode)
    local mafast =  _self.mafast1
    local maslow =  _self.maslow1
	local curtime = os.time()
    local stoploss = MT.getPara('stoploss1')
	local profittarget = MT.getPara('profittarget1')
	local trailingstart = MT.getPara('trailingstart1')
	local percent = MT.getPara('percent1')
	local str2 = os.date('%H:%M:%S')
	local h11,m1,s1 = string.match(str2,"(%d+):(%d+):(%d+)")
    local time1 = h11 * 3600 + m1 * 60 + s1
	local timetrue = time1 >= 16 * 3600 and time1<=23 * 3600
	 
	if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	    buystop1 = k2.h 
	end
   
    if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	    sellstop1 = k2.l 
	end
	
	
	if pos[1] and pos then
	    for _,p in ipairs(pos) do
            if p.num > 0 and price - p.price + stoploss < 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplossbuy1') 	
	        end
	        if p.num > 0 and price < maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('buyexitduetomaslow1')	
	        end
		    if p.num > 0 and price - p.price - profittarget >0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetbuy1')	
	        end
		    if p.num > 0 then
			    local poshigh = k2.h
				if k1.h > poshigh then
				    poshigh = k1.h 
				end
				if poshigh - p.price - trailingstart > 0.00000001 then
				    flagtrailing1 = 1
				end
				if 1 == flagtrailing1 and price < poshigh - percent / 100 * (poshigh - p.price) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopbuy1')
 					flagtrailing1 = 0
				end	
		    end
		    if p.num < 0 and price - p.price - stoploss > 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplosssell1') 	
	        end
	        print(111,p.num,price,maslow[-1])
	        if p.num < 0 and price > maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('sellexitduetomaslow1')	
	        end
		    if p.num < 0 and p.price - price - profittarget >0.00000001  then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetsell1')	
	        end
		    if p.num < 0 then
			    local poslow = k2.l
				if k1.l < poslow then
				    poslow = k1.l
				end
				if p.price - poslow - trailingstart > 0.00000001 then
				    flagtrailing1 = 1
				end
				if 1 == flagtrailing1 and price > poslow + percent / 100 * (p.price - poslow) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopsell1')
 					flagtrailing1 = 0
				end	
		    end		
		end	
	else
        if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	        buytrig1 = 1 
	    end
        if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	        selltrig1 = 1 
	    end 
        if mafast[-2] > maslow[-2] and price - buystop1>0.00000001 and curtime - entrytime1 > 100  and timetrue and buystop1 ~= 0 and 1 == buytrig1 then
            MT.tradeMarketPriceBuy(merpcode, count)		
	        entrytime1 = curtime
  			buytrig1 = 0
	        print('buyentry1')	
	    end
	    if mafast[-2] < maslow[-2] and price - sellstop1 <-0.00000001 and curtime - entrytime1 > 100  and timetrue and 1 == selltrig1  then
            MT.tradeMarketPriceSell(merpcode, count)		
	        entrytime1 = curtime 
	        selltrig1 = 0
			print('sellentry1')	
	    end	
	end	
end
strategy.onUpdate2=function(_self)	
	local merpcode = MT.getPara('merp2')
	local count = MT.getPara('count2')
    local k1 = MT.idcKLINE(merpcode,timePeriod,-1)
    local k2 = MT.idcKLINE(merpcode,timePeriod,-2)	 
    local price = MT.getLastPrice(merpcode)
	local pos = MT.tradePositions(merpcode)
    local mafast =  _self.mafast2
    local maslow =  _self.maslow2
	local curtime = os.time()
    local stoploss = MT.getPara('stoploss2')
	local profittarget = MT.getPara('profittarget2')
	local trailingstart = MT.getPara('trailingstart2')
	local percent = MT.getPara('percent2')
	local str2 = os.date('%H:%M:%S')
	local h11,m1,s1 = string.match(str2,"(%d+):(%d+):(%d+)")
    local time1 = h11 * 3600 + m1 * 60 + s1
	local timetrue = time1 >= 16 * 3600 and time1<=23 * 3600
	if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	      buystop2 = k2.h 
	end
    if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	      sellstop2 = k2.l 
	end
	if pos[1] and pos then
	    for _,p in ipairs(pos) do
            if p.num > 0 and price - p.price + stoploss < 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplossbuy2') 	
	        end
	        if p.num > 0 and price < maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('buyexitduetomaslow2')	
	        end
		    if p.num > 0 and price - p.price - profittarget >0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetbuy2')	
	        end
		    if p.num > 0 then
			    local poshigh = k2.h
				if k1.h > poshigh then
				    poshigh = k1.h 
				end
				if poshigh - p.price - trailingstart > 0.00000001 then
				    flagtrailing2 = 1
				end
				if 1 == flagtrailing2 and price < poshigh - percent / 100 * (poshigh - p.price) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopbuy2')
 					flagtrailing2 = 0
				end	
		    end
		    if p.num < 0 and price - p.price - stoploss >0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplosssell2') 	
	        end
	        if p.num < 0 and price > maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('sellexitduetomaslow2')	
	        end
		    if p.num < 0 and p.price - price - profittarget >0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetsell2')	
	        end
		    if p.num < 0 then
			    local poslow = k2.l
				if k1.l < poslow then
				    poslow = k1.l
				end
				if p.price - poslow - trailingstart >0.00000001 then
				    flagtrailing2 = 1
				end
				if 1 == flagtrailing2 and price > poslow + percent / 100 * (p.price - poslow) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopsell1')
 					flagtrailing2 = 0
				end	
		    end		
		end	
	else
        if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	        buytrig2 = 1 
	    end
        if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	        selltrig2 = 1 
	    end
        if mafast[-2] > maslow[-2] and price - buystop2 > 0.00000001 and curtime - entrytime2 > 100 and timetrue  and buystop2 ~= 0 and 1 == buytrig2 then
            MT.tradeMarketPriceBuy(merpcode, count)		
	        entrytime2 = curtime 
	        buytrig2 =0
			print('buyentry2')	
	    end
	    if mafast[-2] < maslow[-2] and price - sellstop2 <-0.00000001 and curtime - entrytime2 > 100  and timetrue and 1 == selltrig2 then
            MT.tradeMarketPriceSell(merpcode, count)		
	        entrytime2 = curtime 
	        selltrig2 = 0
			print('sellentry2')	
	    end	
	end	
end
strategy.onUpdate3=function(_self)	
	local merpcode = MT.getPara('merp3')
	local count = MT.getPara('count3')
    local k1 = MT.idcKLINE(merpcode,timePeriod,-1)
    local k2 = MT.idcKLINE(merpcode,timePeriod,-2)	 
    local price = MT.getLastPrice(merpcode)
	local pos = MT.tradePositions(merpcode)
    local mafast =  _self.mafast3
    local maslow =  _self.maslow3
	local curtime = os.time()
    local stoploss = MT.getPara('stoploss3')
	local profittarget = MT.getPara('profittarget3')
	local trailingstart = MT.getPara('trailingstart3')
	local percent = MT.getPara('percent3')
	local str2 = os.date('%H:%M:%S')
	local h11,m1,s1 = string.match(str2,"(%d+):(%d+):(%d+)")
    local time1 = h11 * 3600 + m1 * 60 + s1
	local timetrue = time1 >= 16 * 3600 and time1<=23 * 3600
	if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	      buystop3 = k2.h 
	end
    if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	      sellstop3 = k2.l 
	end
	if pos[1] and pos then
	    for _,p in ipairs(pos) do
            if p.num > 0 and price - p.price + stoploss < 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplossbuy3') 	
	        end
	        if p.num > 0 and price < maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('buyexitduetomaslow3')	
	        end
		    if p.num > 0 and price - p.price - profittarget >0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetbuy3')	
	        end
		    if p.num > 0 then
			    local poshigh = k2.h
				if k1.h > poshigh then
				    poshigh = k1.h 
				end
				if poshigh - p.price - trailingstart > 0.00000001 then
				    flagtrailing3 = 1
				end
				if 1 == flagtrailing3 and price < poshigh - percent / 100 * (poshigh - p.price) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopbuy3')
 					flagtrailing3 = 0
				end	
		    end
		    if p.num < 0 and price - p.price - stoploss > 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('stoplosssell3') 	
	        end
	        if p.num < 0 and price > maslow[-1]  then     
	            MT.tradeClosedPosition(p.id)
				print('sellexitduetomaslow3')	
	        end
		    if p.num < 0 and p.price - price - profittarget > 0.00000001 then     
	            MT.tradeClosedPosition(p.id)
				print('profittargetsell3')	
	        end
		    if p.num < 0 then
			    local poslow = k2.l
				if k1.l < poslow then
				    poslow = k1.l
				end
				if p.price - poslow - trailingstart >0.00000001 then
				    flagtrailing3 = 1
				end
				if 1 == flagtrailing3 and price > poslow + percent / 100 * (p.price - poslow) then
				    MT.tradeClosedPosition(p.id)
				    print('trailingstopsell3')
 					flagtrailing3 = 0
				end	
		    end		
		end	
	else
        if mafast[-3] < maslow[-3] and mafast[-2] > maslow[-2] then
	        buytrig3 = 1 
	    end
        if mafast[-3] > maslow[-3] and mafast[-2] < maslow[-2] then
	        selltrig3 = 1 
	    end
        if mafast[-2] > maslow[-2] and price - buystop3 > 0.00000001 and curtime - entrytime3 > 100 and timetrue  and buystop3 ~= 0 and 1 == buytrig3 then
            MT.tradeMarketPriceBuy(merpcode, count)		
	        entrytime3 = curtime 
	        buytrig3 = 0
			print('buyentry3')	
	    end
	    if mafast[-2] < maslow[-2] and price - sellstop3 < -0.00000001 and curtime - entrytime3 > 100  and timetrue and 1 == selltrig3 then
            MT.tradeMarketPriceSell(merpcode, count)		
	        entrytime3 = curtime 
	        selltrig3 = 0
			print('sellentry3')	
	    end	
	end	
end
strategy.paras={count={2,'手数设置0'},merp={'gcq7','选择商品0'},fast = {9,'fastma'}, slow = {27,'slowma'},stoploss = {4,'stoploss'},profittarget = {9,'profittarget'}, trailingstart = {6,'trailingstart'}, percent = {10,'percent'},
count1={2,'手数设置1'},merp1={'6bu7','选择商品1'},fast1 = {10,'fastma1'}, slow1 = {30,'slowma1'},stoploss1 = {0.002,'stoploss1'},profittarget1 = {0.006,'profittarget1'}, trailingstart1 = {0.004,'trailingstart1'}, percent1 = {10,'percent1'},
count2={2,'手数设置1'},merp2={'6eu7','选择商品2'},fast2 = {2,'fastma1'}, slow2 = {24,'slowma1'},stoploss2 = {0.002,'stoploss1'},profittarget2 = {0.006,'profittarget1'}, trailingstart2 = {0.004,'trailingstart1'}, percent2 = {10,'percent1'},
count3={2,'手数设置1'},merp3={'6ju7','选择商品3'},fast3 = {10,'fastma1'}, slow3 = {30,'slowma1'},stoploss3 = {0.00006,'stoploss1'},profittarget3 = {0.00008,'profittarget1'}, trailingstart3 = {0.00007,'trailingstart1'}, percent3 = {10,'percent1'} }-- 可更改参数列表	
MT.registerStrategy(strategy)