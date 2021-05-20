alter table manuscripts_copy 
   add column bibliography_count int after high_quality,
   add column details_count int after high_quality,
   add column details_page bool after high_quality;