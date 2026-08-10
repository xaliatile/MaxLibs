-- welcome fello exploiter, feel free to look around. -- Made by Max

local __main = {
	__db = true,

	__scriptVer = "1.0.5",
	__scriptBuild = "PA",

	__exeStart = os.clock(),
	__uielements = {
		__uiTemplates = {},
		__mainUI = {}
	},

	__external = {
		__reactLibrary = nil,
		__services = setmetatable({
			__services = {}
		}, {
			__call = function(self, __serviceName : string)
				local services = rawget(self, "__services")

				if not services[__serviceName] then
					local service = game:GetService(__serviceName)
					services[__serviceName] = service
				else
					return
				end
			end,

			__index = function(self, __serviceName)
				local services = rawget(self, "__services")
				return services[__serviceName]
			end
		})
	},

	__runners = {
		__getRepository = function(__repoLink : string)
			local __succ, __result = pcall(function()
				local __repo = game:HttpGet(__repoLink)
				return loadstring(__repo)()
			end)

			if not __succ then
				warn(
					string.format(
						"[MAXUI | LIB INTERNAL ERROR (getRepository)]: MaxUI experienced an internal error and was handled safely / Error: %s", 
						__result
					)
				)
			end

			return __result, __succ
		end,

		__runIf = function(__callback : any, __statement : any)
			if __statement and type(__callback) == "function" then
				__callback()
			end
		end,

		__runLgFunc = function(__callback, __callbackStr : string)
			if type(__callback) == "function" and type(__callbackStr) == "string" then
				__callback(__callbackStr)
			end
		end,

		__runPr = function(__callback : any, __cTag : string)
			local __succ, __result = pcall(__callback)

			if not __succ then
				if __cTag == "main" then
					warn(
						string.format(
							"[MAXUI | FATAL INTERNAL ERROR (main)]: MaxUI experienced a fatal error and cannot continue / Error: %s", 
							__result
						)
					)
				else
					warn(
						string.format(
							"[MAXUI | LIB INTERNAL ERROR (%s)]: MaxUI experienced an internal error and was handled safely / Error: %s", 
							__cTag,
							__result
						)
					)
				end
			end

			return __succ, __result
		end
	}
}

local function __getVerOutdation(__verData : {any})
	local __testEnvVer = rawget(__verData, "TestEnvVersion")
	local __streamVer = rawget(__verData, "Version")
	local __libBuildVer = rawget(__verData, "LibraryBuild")

	local __mainVerString = (__main.__db and __testEnvVer or __streamVer)
	__main.__latestLibVer = __mainVerString

	local __scriptVersion = string.split(__main.__scriptVer, ".")
	local __mainLibVersion = string.split(__mainVerString, ".")

	__scriptVersion[1] = tonumber(__scriptVersion[1])
	__scriptVersion[2] = tonumber(__scriptVersion[2])
	__scriptVersion[3] = tonumber(__scriptVersion[3])

	__mainLibVersion[1] = tonumber(__mainLibVersion[1])
	__mainLibVersion[2] = tonumber(__mainLibVersion[2])
	__mainLibVersion[3] = tonumber(__mainLibVersion[3])

	local __scriptBuildComp = __main.__scriptBuild == __libBuildVer
	local __majorComp = __scriptVersion[1] >= __mainLibVersion[1]
	local __minorComp = __scriptVersion[2] >= __mainLibVersion[2]
	local __patchComp = __scriptVersion[3] >= __mainLibVersion[3]

	local __verdict = false
	local __outdationType = nil

	if not __majorComp then __verdict = true __outdationType = "__major" end
	if not __minorComp then __verdict = true __outdationType = "__minor" end
	if not __patchComp then __verdict = true __outdationType = "__patch" end
	if not __scriptBuildComp then __verdict = true __outdationType = "__build" end

	return __verdict, __outdationType
end

local function __initUI()
	local WorkSansRegular = Font.fromId(12187373327, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	local WorkSansMedium = Font.fromId(12187373327, Enum.FontWeight.Medium, Enum.FontStyle.Normal)

	local MainGui = __main.__external.__reactLibrary.Create("ScreenGui", {
		Name = __main.__external.__services.HttpService:GenerateGUID(false),
		Parent = (__main.__db and __main.__external.__services.CoreGui or gethui()),
		IgnoreGuiInset = true
	})

	local MainFrame = __main.__external.__reactLibrary.Create("Frame", {
		Name = "MainFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(15.000000055879354, 15.000000055879354, 15.000000055879354),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 666, 0, 357),
		Parent = MainGui,
		Children = {
			__main.__external.__reactLibrary.Create("UICorner", {
				TopRightRadius = UDim.new(0, 0),
				TopLeftRadius = UDim.new(0, 0),
				BottomLeftRadius = UDim.new(0, 8),
				BottomRightRadius = UDim.new(0, 8)
			}),

			__main.__external.__reactLibrary.Create("UIShadow", {
				BlurRadius = UDim.new(0, 20),
				Color = Color3.fromRGB(0, 0, 0)
			})
		}
	})

	local Topbar = __main.__external.__reactLibrary.Create("Frame", {
		Name = "Topbar",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(23.000000528991222, 23.000000528991222, 23.000000528991222),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, -45),
		Size = UDim2.new(1, 0, 0, 45),
		ClipsDescendants = true,
		Parent = MainFrame,
		Children = {
			__main.__external.__reactLibrary.Create("UICorner", {
				TopRightRadius = UDim.new(0, 8),
				TopLeftRadius = UDim.new(0, 8),
				BottomLeftRadius = UDim.new(0, 0),
				BottomRightRadius = UDim.new(0, 0)
			}),

			__main.__external.__reactLibrary.Create("UIShadow", {
				BlurRadius = UDim.new(0, 20),
				Color = Color3.fromRGB(0, 0, 0)
			})
		}
	})

	local UIMainButtons = __main.__external.__reactLibrary.Create("Frame", {
		Name = "UIMainButtons",
		AnchorPoint = Vector2.new(1, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 98, 0, 47),
		ClipsDescendants = true,
		Parent = Topbar
	})

	local UIButtonPadding = __main.__external.__reactLibrary.Create("Frame", {
		Name = "InnerPadding",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.800000012, 0, 0.800000012, 0),
		ClipsDescendants = true,
		Parent = UIMainButtons,
		Children = {
			__main.__external.__reactLibrary.Create("UIListLayout", {
				Padding = UDim.new(0.150000006, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		}
	})     

	local ExitButton = __main.__external.__reactLibrary.Create("ImageButton", {
		Image = "rbxassetid://10747384394",
		ScaleType = Enum.ScaleType.Fit,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.562069297, 0, 0.154254988, 0),
		Size = UDim2.new(0, 20, 0, 20),
		Name = "Exit",
		LayoutOrder = 2,
		Parent = UIButtonPadding,
		Children = {
			__main.__external.__reactLibrary.Create("UIAspectRatioConstraint")
		}
	})

	local MaximizeButton = __main.__external.__reactLibrary.Create("ImageButton", {
		Image = "rbxassetid://10734965702",
		ScaleType = Enum.ScaleType.Fit,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.562069297, 0, 0.154254988, 0),
		Size = UDim2.new(0, 18, 0, 18), -- smaller offset to fit into the other button sizes.,
		Name = "Maximize",
		LayoutOrder = 1,
		Parent = UIButtonPadding,
		Children = {
			__main.__external.__reactLibrary.Create("UIAspectRatioConstraint")
		}
	})

	local MinimizeButton = __main.__external.__reactLibrary.Create("ImageButton", {
		Image = "rbxassetid://10734896206",
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ScaleType = Enum.ScaleType.Fit,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.562069297, 0, 0.154254988, 0),
		Size = UDim2.new(0, 20, 0, 20),
		Name = "Minimize",
		LayoutOrder = 0,
		Parent = UIButtonPadding,
		Children = {
			__main.__external.__reactLibrary.Create("UIAspectRatioConstraint")
		}
	})

	local TopbarTitleContainer = __main.__external.__reactLibrary.Create("Frame", {
		Name = "TitleContainer",
		AnchorPoint = Vector2.new(0, 0.5),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 23),
		Size = UDim2.new(0, 201, 0, 15),
		ClipsDescendants = false,
		Parent = Topbar
	})

	local TopbarTitleText = __main.__external.__reactLibrary.Create("TextLabel", {
		Name = "Title",
		Text = "Packet Jet Library",
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		TextWrapped = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.455245584, 0, 0.5, 0),
		Size = UDim2.new(0.658625484, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		FontFace = WorkSansMedium,
		Parent = TopbarTitleContainer
	})
    
    local AboutButtonPadding = __main.__external.__reactLibrary.Create("Frame", {
		Name = "AboutPadding",
		AnchorPoint = Vector2.new(0, 0.5),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0.5),
		Size = UDim2.new(0, 22, 0, 22),
		Parent = TopbarTitleContainer
	})

	local AboutButton = __main.__external.__reactLibrary.Create("ImageButton", {
		Image = "rbxassetid://10709782497",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		ResampleMode = Enum.ResamplerMode.Default,
		ScaleType = Enum.ScaleType.Fit,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Name = "About",
		Parent = AboutButtonPadding,
		Children = {
			__main.__external.__reactLibrary.Create("UIAspectRatioConstraint")
		},

		Attributes = {
			["__animHoverSize"] = UDim2.new(0, 22, 0, 22),
			["__animClickSize"] = UDim2.new(0, 15, 0, 15),
			["__animDefaultSize"] = UDim2.new(0, 18, 0, 18),
			["__anim"] = true,

			["__animTime"] = 0.5,
			["__animStyle"] = "Exponential",
			["__animDir"] = "Out"
		}
	})

	local InnerUI = __main.__external.__reactLibrary.Create("Frame", {
		Name = "InnerUI",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.975, 0, 0.950000048, 0),
		Parent = MainFrame
	})

	local TabsContainer = __main.__external.__reactLibrary.Create("Frame", {
		Name = "TabsContainer",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(0.284829736, 0, 0.022580646, 0),
		Size = UDim2.new(0, 467, 0.954838693, 0),
		Parent = InnerUI
	})

	local TabsSidebarList = __main.__external.__reactLibrary.Create("Frame", {
		Name = "TabsSidebarList",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(23.000000528991222, 23.000000528991222, 23.000000528991222),
		Position = UDim2.new(0, 0, 0.5, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 167, 1, 0),
		Parent = InnerUI,
		Children = {
			__main.__external.__reactLibrary.Create("UICorner", {
				CornerRadius = UDim.new(0, 5)
			}),
		}
	})

	local InnerSidebarPadding = __main.__external.__reactLibrary.Create("Frame", {
		Name = "InnerSidebarPadding",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.499999851, 0, 0.489864826, 0),
		Size = UDim2.new(0.900000036, 0, 0.920270264, 0),
		Parent = TabsSidebarList
	})

	local TabsList = __main.__external.__reactLibrary.Create("ScrollingFrame", {
		Name = "TabsList",
		ScrollBarImageTransparency = 1, 
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(4.060, 0, 1.145, 0),
		Size = UDim2.new(1.0555557, 0, 0.999999881, 0),
		Active = true,
		ScrollBarThickness = 7,
		Parent = InnerSidebarPadding,
		Children = {
			__main.__external.__reactLibrary.Create("UIListLayout", {
				Padding = UDim.new(0.00999999978, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			__main.__external.__reactLibrary.Create("UIPadding", {
				PaddingRight = UDim.new(0, 8)
			})
		}
	})

	__main.__uielements.__uiTemplates["TabCategoryTemplate"] = __main.__external.__reactLibrary.Create("TextLabel", {
		Name = "TabCategorySeparator",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,
		TextWrapped = true,
		BackgroundTransparency = 1,
		TextSize = 12,
		RichText = true,
		TextScaled = true,
		Size = UDim2.new(0.940119743, 0, 0, 15),
		FontFace = WorkSansRegular,
		Visible = false,
	})

	__main.__uielements.__uiTemplates["SidebarTabTemplate"] = __main.__external.__reactLibrary.Create("Frame", {
		Name = "SidebarTabTemplate",
		BackgroundColor3 = Color3.fromRGB(15.000000055879354, 15.000000055879354, 15.000000055879354),
		BorderSizePixel = 0,
		Size = UDim2.new(0.940119684, 0, 0, 35),
		Visible = false,
		Children = {
			-- Display Spice
			__main.__external.__reactLibrary.Create("UICorner", {
				CornerRadius = UDim.new(0, 5)
			}),

			__main.__external.__reactLibrary.Create("UIStroke", {
				Color = Color3.fromRGB(155.00000596046448, 155.00000596046448, 155.00000596046448),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				BorderOffset = UDim.new(0, -3)
			}),

			-- Inner Padding
			__main.__external.__reactLibrary.Create("Frame", {
				Name = "InnerPadding",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.899999976, 0, 0.899999976, 0),
				Children = {
					-- Tab Name
					__main.__external.__reactLibrary.Create("TextLabel", {
						Name = "TabName",
						AnchorPoint = Vector2.new(0.5, 0.5),
						RichText = true,
						FontFace = WorkSansRegular,
						TextScaled = true,
						TextWrapped = true,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.633679271, 0, 0.420636326, 0),
						Parent = TopbarTitleContainer
					}),

					-- Tab Icon
					__main.__external.__reactLibrary.Create("ImageButton", {
						Image = "rbxassetid://10734943448",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0.0500000007, 0, 0.5, 0),
						Size = UDim2.new(0, 16, 0, 16),
						ResampleMode = Enum.ResamplerMode.Pixelated,
						ScaleType = Enum.ScaleType.Fit,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Name = "TabIcon",
						Parent = TopbarTitleContainer,
						Children = {
							__main.__external.__reactLibrary.Create("UIAspectRatioConstraint")
						}
					})
				}         
			})
		}
	})

	__main.__uielements.__uiTemplates["GeneralResultTemplate"] = __main.__external.__reactLibrary.Create("Frame", {
		Name = "GeneralResultTemplate",
		BackgroundColor3 = Color3.fromRGB(23, 23, 23),
		BorderSizePixel = 0,
		Size = UDim2.new(0.940119684, 0, 0, 35),
		Visible = false,
		Children = {
			-- Display Spice
			__main.__external.__reactLibrary.Create("UICorner", {
				CornerRadius = UDim.new(0, 5)
			}),

			__main.__external.__reactLibrary.Create("UIStroke", {
				Color = Color3.fromRGB(0, 255, 0),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				BorderOffset = UDim.new(0, -3)
			}),

			-- Inner Padding
			__main.__external.__reactLibrary.Create("Frame", {
				Name = "InnerPadding",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.899999976, 0, 0.899999976, 0),
				Children = {
					__main.__external.__reactLibrary.Create("TextLabel", {
						Name = "ResultText",
						AnchorPoint = Vector2.new(0.5, 0.5),
						RichText = true,
						FontFace = WorkSansRegular,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						TextWrapped = true,
						Position = UDim2.new(0.105137385, 0, 0, 0),
						Size = UDim2.new(0.895, 0, 0.46, 0),
						Parent = TopbarTitleContainer
					}),

					__main.__external.__reactLibrary.Create("ImageButton", {
						Image = "rbxassetid://10709790644",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0.0500000007, 0, 0.5, 0),
						Size = UDim2.new(0, 16, 0, 16),
						ResampleMode = Enum.ResamplerMode.Pixelated,
						ScaleType = Enum.ScaleType.Fit,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Name = "ResultIconRepresentor",
						Parent = TopbarTitleContainer,
						Children = {
							__main.__external.__reactLibrary.Create("UIAspectRatioConstraint")
						}
					})
				}         
			})
		}
	})

	__main.__uielements.__uiTemplates["TabContainerTemplate"] = __main.__external.__reactLibrary.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0)
	})

	__main.__external.__reactLibrary.AddToJanitor(MainGui)

	for _, AnimatableObject in ipairs(MainGui:GetDescendants()) do
		if AnimatableObject:IsA("GuiObject") and AnimatableObject:GetAttribute("__anim") then
			local RebuiltInfo = TweenInfo.new(
				AnimatableObject:GetAttribute("__animTime") or 0.5,
				Enum.EasingStyle[AnimatableObject:GetAttribute("__animStyle") or "Quad"],
				Enum.EasingDirection[AnimatableObject:GetAttribute("__animDir") or "Out"]
			)
            
            local KeepsOffset = AnimatableObject:GetAttribute("__animKeepPosition") or false

			if __main.__external.__reactLibrary.HasIndex(AnimatableObject, "MouseEnter") and AnimatableObject:GetAttribute("__animHoverSize") then
				__main.__external.__reactLibrary.AddToJanitor(AnimatableObject.MouseEnter:Connect(function()
					__main.__external.__services.TweenService:Create(AnimatableObject, RebuiltInfo, {
						Size = AnimatableObject:GetAttribute("__animHoverSize"),
						Position = (AnimatableObject:GetAttribute("__animKeepPosition") and AnimatableObject.Position or (AnimatableObject:GetAttribute("__animHoverPosition") or AnimatableObject.Position))
					}):Play()
				end))
			end

			if __main.__external.__reactLibrary.HasIndex(AnimatableObject, "MouseLeave") and AnimatableObject:GetAttribute("__animHoverSize") then
				__main.__external.__reactLibrary.AddToJanitor(AnimatableObject.MouseLeave:Connect(function()
					__main.__external.__services.TweenService:Create(AnimatableObject, RebuiltInfo, {
						Size = AnimatableObject:GetAttribute("__animDefaultSize"),
						Position = (AnimatableObject:GetAttribute("__animKeepPosition") and AnimatableObject.Position or (AnimatableObject:GetAttribute("__animDefaultPosition") or AnimatableObject.Position))
					}):Play()
				end))
			end

			if __main.__external.__reactLibrary.HasIndex(AnimatableObject, "MouseButton1Down") and AnimatableObject:GetAttribute("__animClickSize") then
				__main.__external.__reactLibrary.AddToJanitor(AnimatableObject.MouseButton1Down:Connect(function()
					__main.__external.__services.TweenService:Create(AnimatableObject, RebuiltInfo, {
						Size = AnimatableObject:GetAttribute("__animClickSize"),
						Position = (AnimatableObject:GetAttribute("__animKeepPosition") and AnimatableObject.Position or (AnimatableObject:GetAttribute("__animClickPosition") or AnimatableObject.Position))
					}):Play()
				end))
			end

			if __main.__external.__reactLibrary.HasIndex(AnimatableObject, "MouseButton1Up") and AnimatableObject:GetAttribute("__animClickSize") then
				__main.__external.__reactLibrary.AddToJanitor(AnimatableObject.MouseButton1Up:Connect(function()
					__main.__external.__services.TweenService:Create(AnimatableObject, RebuiltInfo, {
						Size = AnimatableObject:GetAttribute("__animHoverSize"),
						Position = (AnimatableObject:GetAttribute("__animKeepPosition") and AnimatableObject.Position or (AnimatableObject:GetAttribute("__animDefaultPosition") or AnimatableObject.Position))
					}):Play()
				end))
			end
		end
	end

    --[[
        Converted["_About1"].AnchorPoint = Vector2.new(0.5, 0.5)
        Converted["_About1"].BackgroundColor3 = Color3.fromRGB(15.000000055879354, 15.000000055879354, 15.000000055879354)
        Converted["_About1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_About1"].BorderSizePixel = 0
        Converted["_About1"].Position = UDim2.new(0.5, 0, 1.5, 0)
        Converted["_About1"].Size = UDim2.new(0, 443, 0, 216)
        Converted["_About1"].ZIndex = 2
        Converted["_About1"].Name = "About"
        Converted["_About1"].Parent = Converted["_UI"]

        Converted["_UICorner5"].CornerRadius = UDim.new(0, 0)
        Converted["_UICorner5"].TopLeftRadius = UDim.new(0, 0)
        Converted["_UICorner5"].TopRightRadius = UDim.new(0, 0)
        Converted["_UICorner5"].Parent = Converted["_About1"]

        Converted["_Inner1"].AnchorPoint = Vector2.new(0.5, 0.5)
        Converted["_Inner1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Inner1"].BackgroundTransparency = 1
        Converted["_Inner1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Inner1"].BorderSizePixel = 0
        Converted["_Inner1"].ClipsDescendants = true
        Converted["_Inner1"].Position = UDim2.new(0.5, 0, 0.5, 0)
        Converted["_Inner1"].Size = UDim2.new(1, 0, 1, 0)
        Converted["_Inner1"].Name = "Inner"
        Converted["_Inner1"].Parent = Converted["_About1"]

        Converted["_Padding3"].AnchorPoint = Vector2.new(0.5, 0.5)
        Converted["_Padding3"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Padding3"].BackgroundTransparency = 1
        Converted["_Padding3"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Padding3"].BorderSizePixel = 0
        Converted["_Padding3"].Position = UDim2.new(0.5, 0, 0.5, 0)
        Converted["_Padding3"].Size = UDim2.new(0.949999988, 0, 0.850000024, 0)
        Converted["_Padding3"].Name = "Padding"
        Converted["_Padding3"].Parent = Converted["_Inner1"]

        Converted["_TextLabel"].Font = Enum.Font.Unknown
        Converted["_TextLabel"].Text = "This script utilizes PackJet library"
        Converted["_TextLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_TextLabel"].TextSize = 14
        Converted["_TextLabel"].TextWrapped = true
        Converted["_TextLabel"].TextYAlignment = Enum.TextYAlignment.Top
        Converted["_TextLabel"].AnchorPoint = Vector2.new(0.5, 0.5)
        Converted["_TextLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_TextLabel"].BackgroundTransparency = 1
        Converted["_TextLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_TextLabel"].BorderSizePixel = 0
        Converted["_TextLabel"].Position = UDim2.new(0.5, 0, 0.5, 0)
        Converted["_TextLabel"].Size = UDim2.new(1, 0, 1, 0)
        Converted["_TextLabel"].Parent = Converted["_Padding3"]

        Converted["_UIShadow2"].BlurRadius = UDim.new(0, 50)
        Converted["_UIShadow2"].Color = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
        Converted["_UIShadow2"].Parent = Converted["_About1"]

        Converted["_TopBar1"].AnchorPoint = Vector2.new(0.5, 0)
        Converted["_TopBar1"].BackgroundColor3 = Color3.fromRGB(23.000000528991222, 23.000000528991222, 23.000000528991222)
        Converted["_TopBar1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_TopBar1"].BorderSizePixel = 0
        Converted["_TopBar1"].ClipsDescendants = true
        Converted["_TopBar1"].Position = UDim2.new(0.5, 0, 0, -45)
        Converted["_TopBar1"].Size = UDim2.new(1, 0, 0, 45)
        Converted["_TopBar1"].Name = "TopBar"
        Converted["_TopBar1"].Parent = Converted["_About1"]

        Converted["_UICorner6"].BottomLeftRadius = UDim.new(0, 0)
        Converted["_UICorner6"].BottomRightRadius = UDim.new(0, 0)
        Converted["_UICorner6"].Parent = Converted["_TopBar1"]

        Converted["_UIFunctionButtons1"].AnchorPoint = Vector2.new(1, 0)
        Converted["_UIFunctionButtons1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_UIFunctionButtons1"].BackgroundTransparency = 1
        Converted["_UIFunctionButtons1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_UIFunctionButtons1"].BorderSizePixel = 0
        Converted["_UIFunctionButtons1"].Position = UDim2.new(1, 0, 0, 0)
        Converted["_UIFunctionButtons1"].Size = UDim2.new(0, 47, 0, 47)
        Converted["_UIFunctionButtons1"].Name = "UIFunctionButtons"
        Converted["_UIFunctionButtons1"].Parent = Converted["_TopBar1"]

        Converted["_Buttons1"].AnchorPoint = Vector2.new(0.5, 0.5)
        Converted["_Buttons1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Buttons1"].BackgroundTransparency = 1
        Converted["_Buttons1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Buttons1"].BorderSizePixel = 0
        Converted["_Buttons1"].Position = UDim2.new(0.5, 0, 0.5, 0)
        Converted["_Buttons1"].Size = UDim2.new(1, 0, 1, 0)
        Converted["_Buttons1"].Name = "Buttons"
        Converted["_Buttons1"].Parent = Converted["_UIFunctionButtons1"]

        Converted["_Exit1"].Image = "rbxassetid://10747384394"
        Converted["_Exit1"].ScaleType = Enum.ScaleType.Tile
        Converted["_Exit1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Exit1"].BackgroundTransparency = 1
        Converted["_Exit1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Exit1"].BorderSizePixel = 0
        Converted["_Exit1"].Size = UDim2.new(0, 20, 0, 20)
        Converted["_Exit1"].Name = "Exit"
        Converted["_Exit1"].Parent = Converted["_Buttons1"]

        Converted["_UIAspectRatioConstraint4"].Parent = Converted["_Exit1"]

        Converted["_UIListLayout3"].FillDirection = Enum.FillDirection.Horizontal
        Converted["_UIListLayout3"].HorizontalAlignment = Enum.HorizontalAlignment.Center
        Converted["_UIListLayout3"].SortOrder = Enum.SortOrder.LayoutOrder
        Converted["_UIListLayout3"].VerticalAlignment = Enum.VerticalAlignment.Center
        Converted["_UIListLayout3"].Parent = Converted["_Buttons1"]

        Converted["_TitleContainer1"].AnchorPoint = Vector2.new(0, 0.5)
        Converted["_TitleContainer1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_TitleContainer1"].BackgroundTransparency = 1
        Converted["_TitleContainer1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_TitleContainer1"].BorderSizePixel = 0
        Converted["_TitleContainer1"].Position = UDim2.new(0, 20, 0, 23)
        Converted["_TitleContainer1"].Size = UDim2.new(0, 201, 0, 15)
        Converted["_TitleContainer1"].Name = "TitleContainer"
        Converted["_TitleContainer1"].Parent = Converted["_TopBar1"]

        Converted["_Title1"].Font = Enum.Font.Unknown
        Converted["_Title1"].Text = "About"
        Converted["_Title1"].TextColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Title1"].TextSize = 14
        Converted["_Title1"].TextWrapped = true
        Converted["_Title1"].TextXAlignment = Enum.TextXAlignment.Left
        Converted["_Title1"].AnchorPoint = Vector2.new(0.5, 0.5)
        Converted["_Title1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Title1"].BackgroundTransparency = 1
        Converted["_Title1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Title1"].BorderSizePixel = 0
        Converted["_Title1"].Position = UDim2.new(0.455245584, 0, 0.5, 0)
        Converted["_Title1"].Size = UDim2.new(0.658625484, 0, 1, 0)
        Converted["_Title1"].Name = "Title"
        Converted["_Title1"].Parent = Converted["_TitleContainer1"]

        Converted["_About2"].Image = "rbxassetid://10723415903"
        Converted["_About2"].AnchorPoint = Vector2.new(0, 0.5)
        Converted["_About2"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_About2"].BackgroundTransparency = 1
        Converted["_About2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_About2"].BorderSizePixel = 0
        Converted["_About2"].Position = UDim2.new(0, 0, 0.5, 0)
        Converted["_About2"].Size = UDim2.new(0, 18, 0, 18)
        Converted["_About2"].Name = "About"
        Converted["_About2"].Parent = Converted["_TitleContainer1"]

        Converted["_UIAspectRatioConstraint5"].Parent = Converted["_About2"]

        Converted["_UIShadow3"].BlurRadius = UDim.new(0, 20)
        Converted["_UIShadow3"].Color = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
        Converted["_UIShadow3"].Parent = Converted["_TopBar1"]

        Converted["_UIShadow4"].BlurRadius = UDim.new(0, 20)
        Converted["_UIShadow4"].Color = Color3.fromRGB(50.000000819563866, 50.000000819563866, 50.000000819563866)
        Converted["_UIShadow4"].Parent = Converted["_UI"]]
end

function __main:CreateTab(__tabData : {any})

end

function __main:Exit()
	__main.__external.__reactLibrary:Exit()

	local function __clearTables(Table : any)
		for _, __tableEntry in pairs(Table) do
			if type(__tableEntry) == "table" then
				__clearTables(__tableEntry)
			end
		end

		table.clear(Table)
	end

	__clearTables(__main)
end

-- Force Initiation. In order to grab __main the script must call the module to get it
return function(...)
	local __mainSuccess = __main.__runners.__runPr(function()
		__main.__external.__services("HttpService")
		__main.__external.__services("CoreGui")
		__main.__external.__services("TweenService")

		local __react, __reactGitSucc = __main.__runners.__getRepository("https://raw.githubusercontent.com/xaliatile/MaxLibs/refs/heads/main/Util/ReactLibrary.lua")
		local __verData, __verGitSucc = __main.__runners.__getRepository("https://raw.githubusercontent.com/xaliatile/MaxLibs/refs/heads/main/MaxUI/Version.lua")

		__main.__runners.__runIf(function()
			__main.__runners.__runLgFunc(
				error,
				string.format(
					"Failed to get external dependencies, dependencies were either not found or have been changed | Error Info: (__reactstat: %s / __verdatastat: %s)",
					tostring(__reactGitSucc),
					tostring(__verGitSucc)
				)
			)
		end, (__reactGitSucc == false and __verGitSucc == false))

		local __outdated, __outdationType = __getVerOutdation(__verData)
		__main.__runners.__runIf(function()
			local __testEnvVer = rawget(__verData, "TestEnvVersion")
			local __streamVer = rawget(__verData, "Version")
			local __libBuildVer = rawget(__verData, "LibraryBuild")

			local __libVersion = (__main.__db and __testEnvVer or __streamVer)

			local __response = (__outdationType == "__build" and string.format(
				"MaxLib is extremely outdated and needs to be updated / Latest Version: Build: %s Ver: %s | Current Version: Build: %s Ver: %s",
				__libBuildVer or "Build not found",
				__libVersion or "Ver not found",
				__main.__scriptBuild or "Build not found",
				__main.__scriptVer or "Ver not found"
				) or string.format(
					"MaxLib is outdated and needs to be updated / Latest Version: Build: %s Ver: %s | Current Version: Build: %s Ver: %s",
					__libBuildVer or "Build not found",
					__libVersion or "Ver not found",
					__main.__scriptBuild or "Build not found",
					__main.__scriptVer or "Ver not found"
				))

			__main.__runners.__runLgFunc(
				warn,
				__response
			)

			if __outdationType == "__build" then
				__main.__runners.__runLgFunc(
					error,
					__response
				)

				return
			else
				__main.__runners.__runLgFunc(
					warn,
					__response
				)
			end
		end, __outdated == true)

		__main.__external.__reactLibrary = __react
		__initUI()
	end, "main")

	if __mainSuccess then
		local Difference = os.clock() - __main.__exeStart

		print(
			string.format(
				"[MAXUI]: MaxUI loaded successfully | Took: %s %s", 
				tostring(Difference),
				(Difference >= 1 and "second(s)" or "millisecond(s)")
			)
		)
	end

	return (__mainSuccess and __main or {})
end
