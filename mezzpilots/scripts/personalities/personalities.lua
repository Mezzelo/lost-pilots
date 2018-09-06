-- basically forced to re-declare everything because personalities.lua was scoped almost entirely locally
-- please don't smite my mod for this :')

local ftcsv = dofile(GetWorkingDir().."scripts/personalities/ftcsv.lua") -- script for parsing csv file

local function split(str, pat)
	local t = {} 
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

local PilotPersonality = {Label = "NULL"}
CreateClass(PilotPersonality)

local Names = {}--ret[1]
local Keys = {}--ret[2]

local function GetKey(index)
	if index > 3 and Keys[index] ~= "" then return Keys[index] end
	return ""
end

local new_filelist = { 
	{file = GetWorkingDir().."mods/mezzpilots/scripts/personalities/pilotsmezz.csv", start = 3 }
}
-- mostly just too lazy to rewrite to use a singular file, but hey I might add more files.

for index, curr in ipairs(new_filelist) do
	local ret = ftcsv.parse(curr.file, ',', {headers = false})
	Names = ret[1]
	Keys = ret[2]
	
	for index, id in ipairs(ret[2]) do
		if index > 3 and id ~= "" then
			local parent = ret[3][index]
			
			if Personality[id] == nil then
				if parent == "" or Personality[parent] == nil then
					Personality[id] = PilotPersonality:new()
				else
					Personality[id] = Personality[parent]:new()
				end
			
				Personality[id].Label = Names[index]
				Personality[id].Name = ret[4][index]
			end
		end
	end
	
	for i,row in ipairs(ret) do
		local trigger = row[2]
		if i >= curr.start and trigger ~= "" then
			for index, text in ipairs(row) do
				if GetKey(index) ~= "" and text ~= "" then
					--text = "\""..text
					if string.sub(text,#text) == "," then
						text = string.sub(text,1,#text-1)
					end
					text = string.gsub(text,"“","")
					text = string.gsub(text,"”","")
					text = string.gsub(text,"‘","'")
					text = string.gsub(text,"…","...")
					text = string.gsub(text,"’","'")
					text = string.gsub(text,"–","-")
					
					local final_texts = {text}
                    if trigger ~= "Region_Names" then--don't split up Region_Names
                        final_texts = split(text,"\",%s*\n*")
                    end
                    
					for i, v in ipairs(final_texts) do
						final_texts[i] = string.gsub(v,"\"","")
					end
					
					Personality[GetKey(index)][trigger] = final_texts
					
					--if GetKey(index) == "CEO_Snow" then
					--	LOG("Found text for "..trigger)
					--end
				end
			end
		end
	end
end

function PilotPersonality:GetPilotDialog(event)
	if self[event] ~= nil then 
		if type(self[event]) == "table" then
			return random_element(self[event])
		end
		
		return self[event]
	end
	
	LOG("No pilot dialog found for "..event.." event in "..self.Label)
	return ""
end

function GetPilotDialog(personality, event)
    if Personality[personality] == nil then
        LOG("No  dialog found for personality:"..personality..", event: ".. event)
        return ""
    end
    
    local text = Personality[personality]:GetPilotDialog(event)
	text = string.gsub(text, "#squad", Game:GetSquad())
	text = string.gsub(text, "#corp", Game:GetCorp().name)
	return text
end
