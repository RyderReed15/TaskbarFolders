function Generate()
	root = SKIN:GetVariable('ROOTCONFIGPATH');
	size = SKIN:GetVariable('IconSize')*5;
	dialogNames = scanDir(root.."Dialogs")
	dialogs = {}
	settings = readFile(root.."@Resources/UserSettingsTemplate.ini")
	taskbar = readFile(root.."@Resources/TaskbarTemplate.ini")
	j=0
	for i,dir in pairs(dialogNames) do
		if string.find(dir,".",0,true) == nil then
		j=j+1
			files = scanDir(root.."Dialogs/"..dir.."/")
			links = {}
			linksFull = {}
			
			for k,file in pairs(files) do
				
				p = string.find(file,".",0,true)
				if p ~= nil then
					table.insert(links,string.sub(file,0,p-1))
					table.insert(linksFull,file)
				end
				
			end
			
			-- Open Template File
			
			dialog = readFile(root.."@Resources/TemplateIcon.ini")
			

			
			for l,link in pairs(links) do
				
				-- Create New Icons
				width = table.maxn(links)*size
				dialog = dialog..'[MeterIcon'..l..']\nMeter=Image\nMeterStyle=IconStyle\nX=(960+'..size*(l-1)..'-'..width..'/2)\nY=(540-'..size..'/2)\nImageName=#ROOTCONFIGPATH#Dialogs/' ..dir..'/Icons/'..link .. '.png\nLeftMouseUpAction=["#ROOTCONFIGPATH#Dialogs/' ..dir..'/'.. linksFull[l]  .. '"]#ExitAction#\n\n'
				if l > 1 then 
					dialog = dialog..'[MeterBar'..l-1 ..']\nSolidColor=255,255,255,100\nMeter=Image\nGroup=Icons\nX=(959+'..size*(l-1)..'-'..width..'/2)\nY=(550-'..size..'/2)\nW=2\nH=('..size..'-20)\nImageName=\nDynamicVariables=1\n\n'
				end	
			end
			-- Write New Icons
			WriteFile(root.."Skins/"..dir..".ini", dialog)
			
			-- Write To Taskbar File
			
			settings = settings .. 'Icon'..j..'Picture=#ROOTCONFIGPATH#Dialogs/' ..dir..'/Icons/icon.png\nAlt'..j..'Picture=#ROOTCONFIGPATH#Dialogs/' ..dir..'/Icons/iconAlt.png\nIcon'..j..'OpenAction=[!ToggleConfig "TaskbarFolders\\Skins" "'..dir..'.ini"][!SetOption MeterIcon'..j..' ImageName "#Alt'..j..'Picture#"][!SetOptionGroup Icons LeftMouseUpAction "#CloseAction#"][!UpdateMeter MeterIcon'..j..'][!Redraw]\n\n'
			taskbar = taskbar .. '[MeterIcon'..j..']\nMeter=Image\nMeterStyle=IconStyle\nX=('..10-j..'*#XorientationIcons#)\nY=(#IconSize# - #UnCropW#)\nImageName=#Icon'..j..'Picture#\nLeftMouseUpAction=#Icon'..j..'OpenAction#\n\n'
		end
	end
	
	settings = settings..'CloseAction=[!DeactivateConfig "TaskbarFolders\\Skins"][!ToggleConfig "TaskbarFolders" "Taskbar.ini"][!ToggleConfig "TaskbarFolders" "Taskbar.ini"]'
	WriteFile(root.."@Resources/UserSettings.ini", settings)
	WriteFile(root.."Taskbar.ini", taskbar)
	SKIN:Bang("!RefreshApp")
end

function scanDir(path)
        callit = os.tmpname()
        os.execute('dir /B "'..path..'"'.. " > " .. callit)
        f = io.open(callit,"r")
		dir = {}
		for line in f:lines() do 
			table.insert(dir, line)
		end
        f:close()
        os.remove(callit)
		return dir
end

function readFile(filePath)
	-- HANDLE RELATIVE PATH OPTIONS.
	filePath = SKIN:MakePathAbsolute(filePath)

	-- OPEN FILE.
	local File = io.open(filePath)

	-- HANDLE ERROR OPENING FILE.
	if not File then
		print('ReadFile: unable to open file at ' .. filePath)
		return
	end

	-- READ FILE CONTENTS AND CLOSE.
	local Contents = File:read('*all')
	File:close()

	return Contents
end

function WriteFile(FilePath, Contents)
	-- HANDLE RELATIVE PATH OPTIONS.
	FilePath = SKIN:MakePathAbsolute(FilePath)

	-- OPEN FILE.
	local File = io.open(FilePath, 'w')

	-- HANDLE ERROR OPENING FILE.
	if not File then
		print('WriteFile: unable to open file at ' .. FilePath)
		return
	end

	-- WRITE CONTENTS AND CLOSE FILE
	File:write(Contents)
	File:close()

	return true
end