local _, addon = ...

-- Optional, locally installed companion supplies the user's encrypted import.
-- The native RestedXP importer retains its account checks and cache handling.
if type(_G.PhyzPersonalGuideImport) == 'string' then
    addon.string = _G.PhyzPersonalGuideImport
    _G.PhyzPersonalGuideImport = nil
end
