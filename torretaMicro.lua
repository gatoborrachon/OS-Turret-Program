--Made by Gato Borrachon --24/04/2020
----LIBRERIAS----
local turret = component.proxy(component.list("os_energyturret")())
local entdetec = component.proxy(component.list("os_entdetector")())
----VARIABLES-ESTATICAS----
local objetivos = {}
local anguloVertical
local anguloHorizontal
local tanXZ 
local tanY
local x
local y
local z
local nombreDeObjetivo
local comprobarX = {0}
local comprobarY = {0}
local comprobarZ = {0}
local mob1 = "Esqueleto" --here you set more variables for more mob objetives, you will need to add the respect condition more below
local mob2 = "Zombi"
local mob3 = "Creeper"
local range = 18 --this is the range of the turret

local function pullFiltered(...)
  local args = table.pack(...)
  local seconds, filter = math.huge

  if type(args[1]) == "function" then
    filter = args[1]
  else
    checkArg(1, args[1], "number", "nil")
    checkArg(2, args[2], "function", "nil")
    seconds = args[1]
    filter = args[2]
  end

  repeat
    local signal = table.pack(computer.pullSignal(seconds))
    if signal.n > 0 then
      if not (seconds or filter) or filter == nil or filter(table.unpack(signal, 1, signal.n)) then
        return table.unpack(signal, 1, signal.n)
      end
    end
  until signal.n == 0
end

local function createPlainFilter(name, ...)
  local filter = table.pack(...)
  if name == nil and filter.n == 0 then
    return nil
  end

  return function(...)
    local signal = table.pack(...)
    if name and not (type(signal[1]) == "string" and signal[1]:match(name)) then
      return false
    end
    for i = 1, filter.n do
      if filter[i] ~= nil and filter[i] ~= signal[i + 1] then
        return false
      end
    end
    return true
  end
end

local function pull(...)
  local args = table.pack(...)
  if type(args[1]) == "string" then
    return pullFiltered(createPlainFilter(...))
  else
    checkArg(1, args[1], "number", "nil")
    checkArg(2, args[2], "string", "nil")
    return pullFiltered(args[1], createPlainFilter(select(2, ...)))
  end
end

local function sleep(timeout)
  checkArg(1, timeout, "number", "nil")
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    pull(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

----PROGRAMA----
for i=1, math.huge do
  objetivos = entdetec.scanEntities(range)
  if objetivos == true or objetivos == false then 

  else
  for k,v in pairs(objetivos) do
    nombreDeObjetivo = v.name
    if nombreDeObjetivo == mob1 or nombreDeObjetivo == mob2 or nombreDeObjetivo == mob3 then --here you will add the conditions to 
			                                                --make the turret attack more mobs, there are 3 examples
	  x = v.x
	  y = v.y+1
	  z = v.z
	  
	  tanXZ = x/z
          tanY = y/(math.sqrt((x*x)+(z*z)))
	  anguloHorizontal = math.deg(math.atan(tanXZ))
	  anguloVertical = math.deg(math.atan(tanY))
	
	  if x >= 0 and z >= 0 then --90-180
	    anguloHorizontal = -anguloHorizontal+180
          elseif x < 0 and z > 0 then --180-270
	    anguloHorizontal = -anguloHorizontal+180
          elseif x > 0 and z < 0 then --0-90
	    anguloHorizontal = -anguloHorizontal
          elseif x < 0 and z < 0 then --270-360
	    anguloHorizontal = -anguloHorizontal+360
          end

	  if anguloVertical >= 45 then
	    anguloVertical = 44
	  elseif anguloVertical <= -45 then
            anguloVertical = -44
	  end
	  
          if x ~= comprobarX[1] or y ~= comprobarY[1] or z ~= comprobarZ[1] then	   
	    table.insert(comprobarX, 1, x)
	    table.insert(comprobarY, 1, y)
	    table.insert(comprobarZ, 1, z)

            turret.powerOn()
            turret.setArmed(true)
	    turret.moveTo(anguloHorizontal,anguloVertical)
            while turret.isOnTarget() == false do
              sleep(0.1)
            end
	    turret.fire()
            sleep(0.5)
	  end
	end
    end
  end
end
