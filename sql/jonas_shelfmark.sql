update linked_sources set shelfmark=replace(replace(replace(replace(replace(raw_shelfmark, ". ", "."), ".0", "."), ".0","."), ".0", "."), "Ottob", "Ott") 
where link_name = "JONAS"