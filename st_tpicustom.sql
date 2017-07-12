/***************************************************************************************
This functions are a generic implementation of TPI based on the current TPI already existing in POSTGIS with 
the extra ability to allow focal mean radius different from one.

Usage:

st_tpicustom(raster rast, integer nband, raster customextent,text pixeltype="32BF",integer inner radius in pixels,integer outter radius in pixels,boolean interpolate_nodata=FALSE)

Example whith a inner annnulus of 5 pixels and outter annulus of 10 pixels:

select st_tpicustom(r.rast,5,10) as rast
from srtm as r,parcels as foo
where foo.id=111 and ST_Intersects(foo.geometry,rast)

*****************************************************************************************/

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Function: elevation.st_tpicustom(raster, integer, raster, text, integer, integer, boolean)

--DROP FUNCTION elevation.st_tpicustom(raster, integer, raster, text, integer, integer, boolean);
CREATE OR REPLACE FUNCTION elevation.st_tpicustom(
    rast raster,
    nband integer,
    customextent raster,
    pixeltype text DEFAULT '32BF'::text,
    irad integer DEFAULT 1,
    orad integer DEFAULT 1,
    interpolate_nodata boolean DEFAULT false)
  RETURNS raster AS
$BODY$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
		_irad text;
		_orad integer;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;

		IF interpolate_nodata IS TRUE THEN
			_rast := public.ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
			_irad:=irad::text;
			_orad:=orad;
		END IF;

		-- get properties
		_pixwidth := public.ST_PixelWidth(_rast);
		_pixheight := public.ST_PixelHeight(_rast);
		SELECT width, height INTO _width, _height FROM public.ST_Metadata(_rast);

		RETURN public.ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			' elevation._st_tpicustom4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			_orad, _orad,
			VARIADIC ARRAY[_irad]);
	END;
	$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
  ALTER FUNCTION elevation.st_tpicustom(raster, integer, raster, text, integer, integer, boolean)
  OWNER TO postgres;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
  -- Function: elevation.st_tpicustom(raster, integer, text, integer, integer, boolean)

-- DROP FUNCTION elevation.st_tpicustom(raster, integer, text, integer, integer, boolean);
CREATE OR REPLACE FUNCTION elevation.st_tpicustom(
    rast raster,
    nband integer DEFAULT 1,
    pixeltype text DEFAULT '32BF'::text,
    irad integer DEFAULT 1,
    orad integer DEFAULT 1,
    interpolate_nodata boolean DEFAULT false)
  RETURNS raster AS
' SELECT elevation.st_tpicustom($1, $2, NULL::raster, $3, $4,$5,$6) '
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION elevation.st_tpicustom(raster, integer, text, integer, integer, boolean)
  OWNER TO postgres;
