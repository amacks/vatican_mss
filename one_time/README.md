# One Time Use Code

A collection of scripts that are only used once as part of data migration or importing 3rd-party databases.

* add_sort_shelfmark.pl - Update the database with a sortable shelfmark. This helps with cases like *Vat.lat.10000* vs. *Vat.lat.20*
* get_diamm.pl - Download records from [DIAMM](https://www.diamm.ac.uk/),  Digital Image Archive of Medieval Music, and load them in to a side table
* parse_dbbe.pl - Parse downloaded records from the Database of Byzantine Book Epigrams, [DBBE](https://www.dbbe.ugent.be/) and load them into a side table
* bulk_thumbnails.pl - Download all the thumbnails for high-resolution scans
* get_iter.pl - Download records from [Iter Liturgicum Italicum](https://liturgicum.irht.cnrs.fr/) and load them into a side table
* parse_mmmo.pl - Parse downloaded records from the [Medieval Music Manuscripts Online Database ](http://musmed.eu/) and load them into a side table
