local RP = game:GetService("ReplicatedStorage")
local LP = game.Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char.HumanoidRootPart
local Humanoid = Char.Humanoid

local Settings = {
	General = {
		AutoFillShelves = false,
		FullBright = false
	},
	ScriptSettings = {
		MarkBusy = true
	}
}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Retail Tycoon 2 Havoc (RT2H)",
	Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
	LoadingTitle = "Rayfield Interface Suite",
	LoadingSubtitle = "by Sirius",
	Theme = "Default",
 
	DisableRayfieldPrompts = true,
	DisableBuildWarnings = true,
 
	ConfigurationSaving = {
	   Enabled = true,
	   FolderName = RetailTycoonHavoc,
	   FileName = "Retail Tycoon 2 Havoc"
	},
 
	Discord = {
	   Enabled = true,
	   Invite = "bxxbsP6RFJ",
	   RememberJoins = true
	},
 })

-- UNIVERSAL .5 FUNCTIONS

local function GetMaxItemsOnShelfAmount(Item, ShelfType)
	for i, v in pairs(RP.Sellables:GetDescendants()) do
		if v.Name == Item then
			if v:FindFirstChild(ShelfType) then
				local Amount = 0
				for i, v in pairs(v:WaitForChild(ShelfType).Items:GetChildren()) do
					Amount = Amount + 1
				end
				return Amount
			end
		end
	end
end

local function FindItemCategory(Item)
	for i, v in pairs(RP.Sellables:GetDescendants()) do
		if v.Name == Item then
			if v.Parent.Name == "Variants" then
				if v.Parent.Parent:IsA("Folder") then
					return v.Parent.Parent.Name
				end
			end
		end
	end
end

local function IdentifyObject(Object)
	if Object:FindFirstChild("Sellables") then
		return "Shelf"
	end
	return nil
end

local function PurchaseStock(Category, Amount, InstantDelivery)
	local args = {
		[1] = Category,
		[2] = Amount,
		[3] = InstantDelivery
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyStorage"):InvokeServer(unpack(args))
end


-- BUTTONS & TABS


-- Main tab

local MainTab = Window:CreateTab("Main")

local AutoFillShelvesNote = MainTab:CreateLabel("Auto refill & purchase shelf stock will automatically purchase stock and restock shelves with the stock, while also looking to performance.")
local AutoFillShelves = MainTab:CreateToggle({
	Name = "Auto refill & purchase shelf stock",
	CurrentValue = false,
	Flag = "AutoFillShelves",
	Callback = function(Value)
		Settings.General.AutoFillShelves = Value
	end,
})

MainTab:CreateDivider()

-- Script settings tab

local MainTab = Window:CreateTab("Main")

local MarkBusy = MainTab:CreateLabel("'Mark busy actions' will for example mark shelves it is restocking with 'Auto Fill Shelves'.")
local MarkBusy = MainTab:CreateToggle({
	Name = "Mark busy actions",
	CurrentValue = true,
	Flag = "MarkBusy",
	Callback = function(Value)
		Settings.ScriptSettings.MarkBusy = Value
	end,
})


-- MECHANICS

for _, v in pairs(Plot.Objects:GetChildren()) do
    for __, vv in pairs(v:GetChildren()) do
        local Shelf = IdentifyObject(vv)
        if Shelf == "Shelf" then
            vv.SellableAmount.Changed:Connect(function(NewAmount)
                if Settings.General.AutoFillShelves then
					local MaxStockOnShelf = GetMaxItemsOnShelfAmount(vv.Sellable.Value, vv.Name)
					if MaxStockOnShelf ~= NewAmount then
						local Highlight = Instance.new("Highlight")
						local function CreateHighlight()
							if Settings.ScriptSettings.MarkBusy then
								Highlight.FillColor = Color3.fromRGB(0, 255, 0)
								Highlight.FillTransparency = .75
								Highlight.OutlineTransparency = .25
								Highlight.Parent = vv
							end
						end
						game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RestockShelfFunction"):InvokeServer({vv})
						print(vv.Name .. " - " .. vv.Sellable.Value .. " " .. NewAmount .. "/" .. MaxStockOnShelf)
						if MaxStockOnShelf >= 3 then
							if MaxStockOnShelf - NewAmount <3 then
								CreateHighlight()
								PurchaseStock(FindItemCategory(vv.Sellable.Value), MaxStockOnShelf - NewAmount, true)
								task.wait(.35)
								game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RestockShelfFunction"):InvokeServer({vv})
								task.wait(.5)
							end
						end
						if MaxStockOnShelf <= 3 then
							CreateHighlight()
							PurchaseStock(FindItemCategory(vv.Sellable.Value), MaxStockOnShelf - NewAmount, true)
							task.wait(.35)
							game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RestockShelfFunction"):InvokeServer({vv})
							task.wait(.5)
						end
						Highlight:Destroy()
					end
				end
            end)
        end
    end
end

--[[ while true do

	-- Auto fill shelves
	if Settings.General.AutoFillShelves then
		print("----------")
		for i, v in pairs(game.Workspace.Map.Plots.Plot_3.Objects:GetChildren()) do
			for ii, vv in pairs(v:GetChildren()) do
				local Shelf = IdentifyObject(vv)
				if Shelf == "Shelf" then
					local Highlight = Instance.new("Highlight")
					-- Restock the shelf just for if there still is shit in the storage
					game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RestockShelfFunction"):InvokeServer({vv})
					-- Calculate how much items are on the shelf
					local StockOnShelf = vv.SellableAmount.Value
					local MaxStockOnShelf = GetMaxItemsOnShelfAmount(vv.Sellable.Value, vv.Name)
					-- Purchase the stock needed
					if MaxStockOnShelf <= 3 and MaxStockOnShelf - StockOnShelf <= 3 and StockOnShelf ~= MaxStockOnShelf then
						PurchaseStock(FindItemCategory(vv.Sellable.Value), MaxStockOnShelf - StockOnShelf, true)
						if Settings.ScriptSettings.MarkBusy then
							Highlight.FillColor = Color3.fromRGB(0, 255, 0)
							Highlight.FillTransparency = .75
							Highlight.OutlineTransparency = .25
							Highlight.Parent = vv
						end
						task.wait(.05)
					end
					if MaxStockOnShelf > 3 and MaxStockOnShelf - StockOnShelf >= 3 then
						PurchaseStock(FindItemCategory(vv.Sellable.Value), MaxStockOnShelf - StockOnShelf, true)
						if Settings.ScriptSettings.MarkBusy then
							Highlight.FillColor = Color3.fromRGB(0, 255, 0)
							Highlight.FillTransparency = .75
							Highlight.OutlineTransparency = .25
							Highlight.Parent = vv
						end
						task.wait(.05)
					end
					-- Restock the shelf
					game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RestockShelfFunction"):InvokeServer({vv})
					Highlight:Destroy()
				end
			end
		end
		task.wait()
	end
	task.wait()

end ]]--
