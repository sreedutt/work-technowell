-- Function: census_data_search(integer, integer, text, text, text, integer, text)

-- DROP FUNCTION census_data_search(integer, integer, text, text, text, integer, text);

CREATE OR REPLACE FUNCTION census_data_search(in_search_type integer, in_ward_no integer, in_block_no text, in_gender text, in_community text, in_age integer, in_house_no text)
  RETURNS refcursor AS
$BODY$
DECLARE
    result refcursor := 'cur';
    cmale int;
    cfemale int;
    csc int;
    cgn int;
    cbc int;
    ctotal int;
    
BEGIN
	IF in_search_type = 1
	THEN	
	   OPEN result
	   FOR  SELECT * FROM census_details WHERE     (ward_no = in_ward_no OR in_ward_no = 0)
						   AND (block_no = in_block_no OR in_block_no = 'All')
						   AND (gender = in_gender OR in_gender = 'All')
						   AND (community = in_community  OR in_community = 'All')
						   AND (age >= in_age OR in_age = 0)
						   AND (house_no = in_house_no OR in_house_no = 'All');
	  RETURN result; 					   
	ELSE
	 RETURN 1;																			   
	END IF;    
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION census_data_search(integer, integer, text, text, text, integer, text)
  OWNER TO postgres;
