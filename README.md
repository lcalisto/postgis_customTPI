# postgis_customTPI

This is a generic implementation of TPI based on the current TPI already existing in POSTGIS with the extra ability to allow focal mean radius different from one.

## Usage:

Execute the folowing queries in your database:
1) __st_tpicustom4ma.sql_ 
2) _st_tpicustom.sql_ 

The main function is:

st_tpicustom(raster _rast_, integer _nband_, raster _customextent_,text _pixeltype="32BF"_,integer _inner radius in pixels_,integer _outter radius in pixels_,boolean _interpolate_nodata=FALSE_)

Example with a inner annnulus of 5 pixels and outter annulus of 10 pixels:

````
select st_tpicustom(r.rast,5,10) as rast
from srtm as r,parcels as foo
where foo.id=111 and ST_Intersects(foo.geometry,rast)

````

This will generate a tpi 300 meters if the input is a SRTM of 30 meters of pixel size
