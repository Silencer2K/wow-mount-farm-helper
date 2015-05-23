local addonName, addon = ...

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)

local frame = AltCraftMFHTabFrame

function frame:OnInitialize()
    self.Title:SetText("Mount Farm Helper")
end

function frame:OnShow()
    local parent = self:GetParent()

    parent.TopLeft:SetTexture('Interface\\Addons\\AltCraft\\assets\\frame\\tl')
    parent.Top:SetTexture('Interface\\Addons\\AltCraft\\assets\\frame\\t')
    parent.TopRight:SetTexture('Interface\\Addons\\AltCraft\\assets\\frame\\tr')

    parent.BottomLeft:SetTexture('Interface\\Addons\\AltCraft\\assets\\frame\\bl')

    parent.Portrait:SetTexture('Interface\\ICONS\\ABILITY_MOUNT_GOLDENGRYPHON')

    self:Update()
end

function frame:Update(what)
    if what then
        return
    end
end
