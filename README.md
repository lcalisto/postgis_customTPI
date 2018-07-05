# Postgis custom TPI

This is a generic implementation of TPI based on the current POSTGIS TPI implementation, with the extra ability of allowing a custom focal inner and outter mean radius (different from one).
This implementation of TPI was based on the current implementation of TPI by PostGIS (https://postgis.net/docs/RT_ST_TPI.html) and the folowing document [http://www.jennessent.com/downloads/tpi-poster-tnc_18x22.pdf](http://www.jennessent.com/downloads/tpi-poster-tnc_18x22.pdf)

## Usage:

In order to create the new TPI functions in your database, execute the folowing queries:
1. __st_tpicustom4ma.sql_ 
2. _st_tpicustom.sql_ 

After that you should have *_st_tpicustom4ma* and *st_tpicustom* functions in your database.

*_st_tpicustom4ma* is the callback function used by map algebra. The main function is:

st_tpicustom(raster __rast__, integer __nband__, raster __customextent__, text __pixeltype="32BF"__, integer __inner radius in pixels__, integer __outter radius in pixels__, boolean __interpolate_nodata=FALSE__)

This is an example with a inner annnulus of 5 pixels and outter annulus of 10 pixels:

````
select st_tpicustom(r.rast,5,10) as rast
from srtm as r,parcels as foo
where foo.id=111 and ST_Intersects(foo.geometry,rast)

````

This query will generate a tpi 300 meters if the input is a SRTM of 30 meters of pixel size.
