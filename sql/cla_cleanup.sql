## sanitize the CLA data to make the shelfmarks match
update cla_sources set shelfmark=replace(shelfmark, "Lat. ", "Vat.lat.") 
where shelfmark like "lat%";
update cla_sources set shelfmark=replace(shelfmark, "Palatinus Lat. ", "Pal.lat.")
where shelfmark like "Palatinus Lat. %"; 
update cla_sources set shelfmark=replace(shelfmark, "Ottobonianus Lat.", "Ott.lat.")
where shelfmark like "Ottobonianus Lat. %"; 
update cla_sources set shelfmark=replace(shelfmark, "Reginensis Latinus ", "Reg.lat.")
where shelfmark like "Reginensis Latinus%"; 
update cla_sources set shelfmark=replace(shelfmark, "Barberini Lat. ", "Barb.lat.")
where shelfmark like "Barberini Lat.%";