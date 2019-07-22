
## show all matching manuscripts in both the vatican table and the ptolemy table
select bav.shelfmark, group_concat(pal.author SEPARATOR ", "), group_concat(pal.title SEPARATOR ", "),  group_concat(concat("See [PAL](", pal.url, ") for siglum ", pal.siglum) SEPARATOR ", ") as notes
from manuscripts as bav join ptolemy_sources as pal
on bav.shelfmark=pal.shelfmark
group by bav.shelfmark;

## update the manuscripts table where it's unpopulated from the ptolemy table
update manuscripts as bav join
(select shelfmark, group_concat(author SEPARATOR ", ") as author, group_concat(title SEPARATOR ", ") as title,   group_concat(concat("See [PAL](", url, ") for siglum ", siglum) SEPARATOR ", ") as notes from ptolemy_sources group by shelfmark) as pal on bav.shelfmark=pal.shelfmark
set 
bav.author= pal.author,
bav.title=pal.title,
bav.notes=pal.notes
where bav.author is null and bav.title is null and bav.notes is null
;