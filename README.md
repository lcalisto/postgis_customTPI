# Postgis custom TPI

This is a generic implementation of TPI based on the current POSTGIS TPI implementation, with the extra ability of allowing a custom focal mean radius (different from one).

## Usage:

Execute the folowing queries in your database:
1) __st_tpicustom4ma.sql_ 
2) _st_tpicustom.sql_ 

The main function is:

st_tpicustom(raster __rast__, integer __nband__, raster __customextent__, text __pixeltype="32BF"__, integer __inner radius in pixels__, integer __outter radius in pixels__, boolean __interpolate_nodata=FALSE__)

Example with a inner annnulus of 5 pixels and outter annulus of 10 pixels:

````
select st_tpicustom(r.rast,5,10) as rast
from srtm as r,parcels as foo
where foo.id=111 and ST_Intersects(foo.geometry,rast)

````

This will generate a tpi 300 meters if the input is a SRTM of 30 meters of pixel size
