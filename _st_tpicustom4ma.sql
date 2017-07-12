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
--DROP FUNCTION _st_tpicustom4ma(double precision[], integer[], text[]);
CREATE OR REPLACE FUNCTION _st_tpicustom4ma(
    IN value double precision[],
    IN pos integer[],
    VARIADIC userargs text[] DEFAULT NULL::text[])
  RETURNS double precision AS
$BODY$
	DECLARE
		x integer;
		y integer;
		z integer;
		
		inner_annulus double precision[][][];
		irad integer;
		iradshape_lower integer;
		iradshape_upper integer;
		
		total_sum double precision;
		inner_sum double precision;

		total_count double precision;
		inner_count double precision;

		center_cellx double precision;
		center_celly double precision;
		center_cell double precision;
		tpi double precision;
		mean double precision;
		_value double precision[][][];
		ndims int;
	BEGIN

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := public._ST_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		IF (
			array_lower(_value, 2) != 1 OR array_upper(_value, 2) < 3 OR
			array_lower(_value, 3) != 1 OR array_upper(_value, 3) < 3
		) THEN
			RAISE EXCEPTION 'First parameter of function must be a 1x3x3 array or greather, with each of the lower bounds starting from 1';
		END IF;

		
		
		center_celly:=(array_upper(_value, 2)/2.0)::int;
		center_cellx:=(array_upper(_value, 3)/2.0)::int;
		
		center_cell:=_value[1][center_celly][center_cellx];
		
		-- check if center pixel isn't NODATA
		IF center_cell IS NULL THEN
			RETURN NULL;
		ELSE
		END IF;
		irad=userargs[1]::int;

		IF (irad IS NULL OR irad < 1) THEN
			RAISE EXCEPTION 'Inner radius of annulus must be greather than 1';
		ELSE
		END IF;
		
		-- irad is the inner radius of annulus in cells. The outer radius is the size of the matrix. 
		iradshape_upper=array_upper(_value, 2)-irad;
		iradshape_lower=array_lower(_value, 2)+irad;
		
		-- Subseting inner annulus.
		inner_annulus := _value[z:z][iradshape_lower:iradshape_upper][iradshape_lower:iradshape_upper];
		-- Getting values from inner annulus
		SELECT sum(a),count(a) into inner_sum,inner_count from unnest(inner_annulus) as a;
		-- Getting values from outter annulus
		SELECT sum(a),count(a) into total_sum,total_count from unnest(_value) as a;

		-- If total is null or 0 tpi is also null
		IF total_count = 0 or total_count is null THEN
			RETURN NULL;
		ELSE
		END IF;
		IF total_sum is null THEN
			total_sum := 0;
		ELSE
		END IF;
		IF inner_count is null THEN
			inner_count := 0;
		ELSE
		END IF;
		IF inner_sum is null THEN
			inner_sum := 0;
		ELSE
		END IF;
		-- If total pixels is 1 and inner annulus size is also 1, we should divide by one.
		IF (total_count-inner_count) != 0  THEN
			mean := (total_sum-inner_sum)/(total_count-inner_count);
		ELSE
			mean := (total_sum-inner_sum)/1;
		END IF;
		
		tpi:=((center_cell-mean)+0.5)::int;
			
		return tpi;
		
	END;
	$BODY$
LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION _st_tpicustom4ma(double precision[], integer[], text[])
  OWNER TO postgres;
