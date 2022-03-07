module('AQ.Combat', package.seeall)
require('Services.Combat.UI.PublicFunction.CommonFunction')
---@class AutoFightController
AutoFightController = SingletonClass('AutoFightController')
local instance = AutoFightController
local CommonFunction = AQ.ViewModel.Combat.CommonFunction

function AutoFightController.TryAutoFight(CombatViewModel)
    while (not CommonFunction.CheckCanSendSkillInfo(CombatViewModel)) do
        local actionPet = CombatViewModel:GetNowActionPet()
        -- actionPet: PetCellViewModel
        if actionPet then
            local fightSchemeTranslator =  CombatViewModel:GetAutoFightSchemeTranslator(actionPet )
            if fightSchemeTranslator then
                AutoFightController.AutoFightWithScheme(actionPet,CombatViewModel,fightSchemeTranslator)
            else
                AutoFightController.DoSystemAutoFight(CombatViewModel,actionPet,true)
            end
        end
    end
end