------------------------------------------------------------------
--    CleverPet - Created by Smokey - https://smokeydev.pl/     --
------------------------------------------------------------------    

--------------------------------------------------
--    Description:
--    This simple AddOn shows a big text
--    on the screen informing that your
--    pet/minion has lost his target.
--    This info lasts for 5 seconds by
--    default. When your pet/minion will
--    find a new targer, text will dissapear.
--    You can change text color and duration
--    in the config below.
--------------------------------------------------

-- Config

local Config = {}
Config.Color = {
   ['red'] = false,
   ['pink'] = false,
   ['purple'] = false,
   ['blue'] = false,
   ['cyan'] = true,
   ['green'] = false,
   ['yellow'] = false
}
Config.Seconds = 5

-- Variables

local CleverPet = {}
CleverPet.Colors = {
   ['red'] = 'ff0000',
   ['pink'] = 'ff00dd',
   ['purple'] = '9000ff',
   ['blue'] = '0033ff',
   ['cyan'] = '00fff7',
   ['green'] = '0dff00',
   ['yellow'] = 'fff700'
}
CleverPet.CanDisplay = true
CleverPet.WaitTable = {}
CleverPet.WaitFrame = nil

-- Text display handler

local f1 = CreateFrame("Frame", nil, UIParent)
f1:SetWidth(1) 
f1:SetHeight(1) 
f1:SetAlpha(.90)
f1:SetPoint("CENTER", 0, 150)
f1.text = f1:CreateFontString(nil, "ARTWORK") 
f1.text:SetFont("Fonts\\ARIALN.ttf", 40, "THICKOUTLINE")
f1.text:SetPoint("CENTER", 0, 0)
f1:Hide()

-- Updating display text

function displayupdate(show, message)
   if show then
      f1.text:SetText(message)
      f1:Show()
      if CleverPet.Wait ~= nil then
         CleverPet.Wait(Config.Seconds + 0.0, displayupdate, false)
      end
   else
      f1:Hide()
   end
end

-- Actual script stuff

f1:RegisterEvent("UNIT_TARGET")
CleverPet.Text = function(self, event, ...)
   if event == "UNIT_TARGET" then
      local hp = UnitHealth("pettarget")
      local petHp = UnitHealth("pet")
      if hp ~= nil and petHp ~= nil then
         if tonumber(hp) < 1 and tonumber(petHp) > 1 then
            if CleverPet.CanDisplay then
               local name = "Your pet"
               local petName = UnitName("pet")
               if petName ~= nil then
                  name = petName
               end
               local color = CleverPet.Colors['red']
               for k,v in next, Config.Color do
                  if v == true then
                     if CleverPet.Colors[k] ~= nil then
                        color = CleverPet.Colors[k]
                     end
                     break
                  end
               end
               displayupdate(true, "|cff"..color..name.."'s target is dead!|r")
            end
         end
         if tonumber(hp) > 1 then
            CleverPet.CanDisplay = true
            displayupdate(false)
         else
            CleverPet.CanDisplay = false
         end
      end
   end
end
f1:SetScript("OnEvent", CleverPet.Text)

-- Simple delay function

CleverPet.Wait = function(delay, func, ...)
   if type(delay) ~= "number" or type(func) ~= "function" then
      if type(delay) ~= "number" then
         print("You have selected wrong [delay] time!")
      end
      return false
   end
   if CleverPet.WaitFrame == nil then
      CleverPet.WaitFrame = CreateFrame("Frame", "CleverPet.WaitFrame", UIParent)
      CleverPet.WaitFrame:SetScript("onUpdate", function(self,elapse)
         local count = #CleverPet.WaitTable
         local i = 1
         while i <= count do
            local waitRecord = tremove(CleverPet.WaitTable, i)
            local d = tremove(waitRecord, 1)
            local f = tremove(waitRecord, 1)
            local p = tremove(waitRecord, 1)
            if d > elapse then
               tinsert(CleverPet.WaitTable, i, {d-elapse, f, p})
               i = i + 1
            else
               count = count - 1
               f(unpack(p))
            end
         end
      end)
   end
   tinsert(CleverPet.WaitTable, {delay, func, {...}})
end