-- Function: generate_taxdetails1(text, text, text)

-- DROP FUNCTION generate_taxdetails1(text, text, text);

CREATE OR REPLACE FUNCTION generate_taxdetails1(iward text, izone text, iproperty_no text)
  RETURNS void AS
$BODY$
declare
	cur2 cursor for select distinct b.old_propertyno,
			       b.new_propertyno,
-- 			       property_id,
 			       b.usage_type,
 			       b.zone,
			       b.ward
-- 			       occupant_status
-- 			       
 			from   flat_details a, property_details b
			where  a.old_propertyno = b.old_propertyno
				and (b.zone = izone or izone = 'All')
				and (b.ward = iward or iward = 'All')
				or b.old_propertyno = iproperty_no;
 vproperty_no text;
 vnew_propertyno text;
-- vproperty_id text;
 vusage_type text;
 vzone text;
vward text;
-- voccupant_status text;
vtot_assarea float;
	vtot_rvnotletres float;
	vtot_rvnotletcom float;
	vtot_rvlet float;
	vtot_rvletcom float;
	vpropose_rvres numeric(10,2);
	vrv_proposecom float;
	vrv_totproposerv float;
	vtot_rvletoutres float;
	vtot_rvnotletoutres float;
	vtot_rvletoutcom float;
	vtot_rvnotletoutcom float;
	vtot_rvletout float;
	vtot_rvnotletout float;
	vproptax float;
	venvtax float;
	vtreetax float;
	vfiretax float;
	vspeducess float;
	veducess float;
	vegc float;
	vtotaltax float	;
	icount int;	
begin
open cur2;
	loop

	vtot_rvnotletres := 0;
	vtot_rvnotletcom := 0;
	vtot_rvlet := 0;
	vtot_rvletcom := 0;
	vpropose_rvres := 0;
	vrv_proposecom := 0;
	vrv_totproposerv := 0;
	vtot_rvletoutres := 0;
	vtot_rvnotletoutres := 0;
	vtot_rvletoutcom := 0;
	vtot_rvnotletoutcom := 0;
	vtot_rvletout := 0;
	vtot_rvnotletout := 0;
	vproptax := 0;
	venvtax := 0;
	vtreetax := 0;
	vfiretax := 0;
	vspeducess := 0;
	veducess := 0;
	vegc := 0;
	vtotaltax := 0	;

	
 	fetch cur2 into vproperty_no,vnew_propertyno,vusage_type,vzone,vward;
	exit when not found;

		select sum(assess_area) into vtot_assarea from flat_details_test where old_propertyno = vproperty_no;
		
		if (vusage_type in ('1','3','4','5','6','7','8','9','10','11')) then
		
			select sum(rateable_value) into vtot_rvletoutres from flat_details_test where old_propertyno = vproperty_no and occupant_status = '2';
		        select sum(rateable_value) into vtot_rvnotletoutres from flat_details_test where old_propertyno = vproperty_no and occupant_status = '1';

		       	if vtot_rvletoutres is null then
				vtot_rvletoutres := 0;
			end if;	
			if vtot_rvnotletoutres is null then
				vtot_rvnotletoutres := 0;
			end if;

			vpropose_rvres := vtot_rvnotletoutres + vtot_rvletoutres;
			
			
				
		
		elsif(vusage_type = '2') then        
			select sum(rateable_value) into vtot_rvletoutcom from flat_details_test where old_propertyno = vproperty_no and occupant_status = '2';
			select sum(rateable_value) into vtot_rvnotletoutcom from flat_details_test where old_propertyno = vproperty_no and occupant_status = '1';

			if vtot_rvletoutcom is null then
				vtot_rvletoutcom := 0;
			end if;	
			if vtot_rvnotletoutcom is null then
				vtot_rvnotletoutcom := 0;
			end if;	

			vrv_proposecom := vtot_rvnotletoutcom + vtot_rvletoutcom;
			
		end if;

		if vpropose_rvres is null then
			vpropose_rvres :=0;
		end if;
		if vrv_proposecom is null then
			vrv_proposecom :=0;
		end if;	
		if vtot_rvletoutres is null then
			vtot_rvletoutres := 0;
		end if;	
		if vtot_rvnotletoutres is null then
			vtot_rvnotletoutres := 0;
		end if;
		if vtot_rvletoutcom is null then
			vtot_rvletoutcom := 0;
		end if;	
		if vtot_rvnotletoutcom is null then
			vtot_rvnotletoutcom := 0;
		end if;

		vrv_totproposerv := vpropose_rvres + vrv_proposecom;
		vtot_rvletout := vtot_rvletoutres + vtot_rvletoutcom;
		vtot_rvnotletout := vtot_rvnotletoutres + vtot_rvnotletoutcom;

		if (vusage_type in ('3','7')) then
		
			vproptax := sum(vrv_totproposerv * 0.24)/2;
			venvtax := sum(vrv_totproposerv * 0.01)/2;
			vtreetax := sum(vrv_totproposerv * 0.01)/2;
			vfiretax := sum(vrv_totproposerv * 0.01)/2;
			vspeducess := sum(vrv_totproposerv * 0.02)/2;
			veducess := 0;
			vegc := 0;

		else
			vproptax := sum(vrv_totproposerv * 0.24);
			venvtax := sum(vrv_totproposerv * 0.01);
			vtreetax := sum(vrv_totproposerv * 0.01);
			vfiretax := sum(vrv_totproposerv * 0.01);
			vspeducess := sum(vrv_totproposerv * 0.02);


			if(vusage_type = '1' or vusage_type = '9') then

				vegc := 0;
				if (vrv_totproposerv between 75 and 149) then
					veducess := sum(vrv_totproposerv * 0.02);
				elsif ( vrv_totproposerv between 150 and 299) then
					veducess := sum(vrv_totproposerv * 0.03);
				elsif ( vrv_totproposerv between 300 and 2999) then
					veducess := sum(vrv_totproposerv * 0.04);
				elsif ( vrv_totproposerv between 3000 and 5999) then
					veducess := sum(vrv_totproposerv * 0.05);
				elsif ( vrv_totproposerv >= 6000) then
					veducess := sum(vrv_totproposerv * 0.06);
				end if;		

			elsif(vusage_type = '2') then
		
				if (vrv_totproposerv between 75 and 149) then
					veducess := sum(vrv_totproposerv * 0.04);
					vegc := sum(vrv_totproposerv * 0.01);
				elsif ( vrv_totproposerv between 150 and 299) then
					veducess := sum(vrv_totproposerv * 0.06);
					vegc := sum(vrv_totproposerv * 0.015);
				elsif ( vrv_totproposerv between 300 and 2999) then
					veducess := sum(vrv_totproposerv * 0.08);
					vegc := sum(vrv_totproposerv * 0.02);
				elsif ( vrv_totproposerv between 3000 and 5999) then
					veducess := sum(vrv_totproposerv * 0.10);
					vegc := sum(vrv_totproposerv * 0.025);
				elsif ( vrv_totproposerv >= 6000) then
					veducess := sum(vrv_totproposerv * 0.12);
					vegc := sum(vrv_totproposerv * 0.03);
				end if;	
		
				
			else
				veducess := 0;	
				vegc := 0;	
			end if;			

		end if;

		vtotaltax := vproptax + venvtax + vtreetax + vfiretax + vspeducess + veducess + vegc;						

		select count(*) from property_taxdetails into icount;
		--if(icount = 0) then
			insert into property_taxdetails	(zone,
							 ward,
							 new_propertyno,
							 old_propertyno,
							 total_assessarea,
							 total_rvletout,
							 total_rvnotletout,
							 proprv_res,
							 proprv_nres,
							 total_proprv,
							 property_tax,
							 env_tax,
							 tree_tax,
							 fire_tax,
							 special_educess,
							 edu_cess,
							 egc,
							 total_tax,
							 financial_year)

						values	(vzone,
							 vward,
							 vnew_propertyno,
							 vproperty_no,
							 vtot_assarea,
							 vtot_rvletout,
							 vtot_rvnotletout,
							 vpropose_rvres,
							 vrv_proposecom,
							 vrv_totproposerv,
							 vproptax,
							 venvtax,
							 vtreetax,
							 vfiretax,
							 vspeducess,
							 veducess,
							 vegc,
							 vtotaltax,
							 '2014-2015');
		-- else
-- 			update property_taxdetails set 	 zone = vzone,
-- 							 ward = vward ,
-- 							 new_propertyno = vnew_propertyno,
-- 							 old_propertyno = vproperty_no,
-- 							 total_assessarea = vtot_assarea,
-- 							 total_rvletout = vtot_rvletout,
-- 							 total_rvnotletout = vtot_rvnotletout,
-- 							 proprv_res = vpropose_rvres ,
-- 							 proprv_nres = vrv_proposecom,
-- 							 total_proprv = vrv_totproposerv,
-- 							 property_tax = vproptax ,
-- 							 env_tax = venvtax,
-- 							 tree_tax = vtreetax ,
-- 							 fire_tax = vfiretax,
-- 							 special_educess = vspeducess,
-- 							 edu_cess = veducess,
-- 							 egc = vegc,
-- 							 total_tax = vtotaltax,
-- 							 financial_year = '2014-2015'
-- 				where old_propertyno = vproperty_no;
-- 		end if;					 
	end loop;
	close cur2;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION generate_taxdetails1(text, text, text)
  OWNER TO postgres;
