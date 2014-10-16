﻿create or replace function generate_taxdetails()
returns void as $$
declare
	cur2 cursor for select distinct b.old_propertyno,
			       b.new_propertyno,
-- 			       property_id,
 			       a.usage_type,
 			       b.zone,
			       b.ward
-- 			       occupant_status
-- 			       
 			from   flat_details a, property_details b
			where  a.old_propertyno = b.old_propertyno;
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
begin
open cur2;
	loop
 	fetch cur2 into vproperty_no,vnew_propertyno,vusage_type,vzone,vward;
	exit when not found;

	if(vusage_type = '1' or vusage_type = '2') then
		select sum(rateable_value) into vtot_rvletoutres from flat_details_test where old_propertyno = vproperty_no and occupant_status = '2' and usage_type = '1';
		select sum(rateable_value) into vtot_rvletcom from flat_details_test where old_propertyno = vproperty_no and usage_type = '2' and occupant_status = '2';
		select sum(rateable_value) into vtot_rvnotletoutres from flat_details_test where old_propertyno = vproperty_no and occupant_status = '1' and usage_type = '1';
		select sum(rateable_value) into vtot_rvnotletcom from flat_details_test where old_propertyno = vproperty_no and usage_type = '2' and occupant_status = '1';
		select sum(assess_area) into vtot_assarea from flat_details_test where old_propertyno = vproperty_no;

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
		vpropose_rvres := vtot_rvnotletoutres + vtot_rvletoutres;
		vrv_proposecom := vtot_rvnotletoutcom + vtot_rvletoutcom;
		vrv_totproposerv := vpropose_rvres + vrv_proposecom;
		vtot_rvletout := vtot_rvletoutres + vtot_rvletoutcom;
		vtot_rvnotletout := vtot_rvnotletoutres + vtot_rvnotletoutcom;
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
		vtotaltax := vproptax + venvtax + vtreetax + vfiretax + vspeducess + veducess + vegc;						
		
			insert into property_taxdetails		(zone,
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

						values		(vzone,
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

	elsif(vusage_type = '3' or vusage_type = '7') then
		select sum(rateable_value) into vtot_rvletoutres from flat_details_test where old_propertyno = vproperty_no and occupant_status = '2' and usage_type = '1';
		select sum(rateable_value) into vtot_rvletcom from flat_details_test where old_propertyno = vproperty_no and usage_type = '2' and occupant_status = '2';
		select sum(rateable_value) into vtot_rvnotletoutres from flat_details_test where old_propertyno = vproperty_no and occupant_status = '1' and usage_type = '1';
		select sum(rateable_value) into vtot_rvnotletcom from flat_details_test where old_propertyno = vproperty_no and usage_type = '2' and occupant_status = '1';
		select sum(assess_area) into vtot_assarea from flat_details_test where old_propertyno = vproperty_no;

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
		vpropose_rvres := vtot_rvnotletoutres + vtot_rvletoutres;
		vrv_proposecom := vtot_rvnotletoutcom + vtot_rvletoutcom;
		vrv_totproposerv := vpropose_rvres + vrv_proposecom;
		vtot_rvletout := vtot_rvletoutres + vtot_rvletoutcom;
		vtot_rvnotletout := vtot_rvnotletoutres + vtot_rvnotletoutcom;
		vproptax := sum(vrv_totproposerv * 0.24);
		vproptax1 := vproptax/2;
		venvtax := sum(vrv_totproposerv * 0.01);
		venvtax1 := venvtax/2;
		vtreetax := sum(vrv_totproposerv * 0.01);
		vtreetax1 := vtreetax/2;
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



	

		
		
		end loop;
		close cur2;
end;
$$ LANGUAGE plpgsql;			
-- 			