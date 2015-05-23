local addonName, addon = ...

local L = LibStub('AceLocale-3.0'):GetLocale(addonName)

local LIST_SCROLL_ITEM_HEIGHT = 60

local frame = AltCraftMFHTabFrame

function frame:OnInitialize()
    self.Title:SetText("Mount Farm Helper")

    self.ListScroll:OnInitialize()
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

    self.ListScroll:OnInitialize()
end

function frame.ListScroll:OnInitialize()
    self.scrollBar.doNotHide = 1

    HybridScrollFrame_OnLoad(self)
    self.update = function() self:Update() end

    HybridScrollFrame_CreateButtons(self, 'AltCraftMFHButtonTemplate', 0, 0)
    self:Update()
end

function frame.ListScroll:Update()
    local numRows = 20

    HybridScrollFrame_Update(self, numRows * LIST_SCROLL_ITEM_HEIGHT, self:GetHeight())

    local scrollOffset = HybridScrollFrame_GetOffset(self)

    local i
    for i = 1, #self.buttons do
        local button = self.buttons[i]
    end
end
