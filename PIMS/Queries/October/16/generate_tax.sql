-- Function: generate_tax(text, text, text)

-- DROP FUNCTION generate_tax(text, text, text);

CREATE OR REPLACE FUNCTION generate_tax(iward text, izone text, iproperty_no text)
  RETURNS void AS
$BODY$

declare
	cur1 cursor for select b.old_propertyno,
			       b.property_id,
			       b.usage_type,
			       b.const_class,
			       b.age_factor,
			       b.zone,
			       b.ward,
			       b.occupant_status,
			       b.new_propertyno 
			from   property_details a, flat_details b 
			where  a.old_propertyno = b.old_propertyno
				and (b.zone = izone or izone = 'All')
				and (b.ward = iward or iward = 'All')
				or b.old_propertyno = iproperty_no;
	
	vproperty_no text;
	vnew_propertyno text;
	vproperty_id text;
	vusage_type text;
	vconst_class text;
	vage_factor text;
	vzone text;
	vward text;
	vocc_status text;
	vrate_res numeric(5,2);
	vrate_com numeric(5,2);
	vrate_depr numeric(5,2);
	vrate_comre float;
	vrate_depre float;
	alv1 float;
	alv2 float;
	valv float;
	valv_op float;
	vmaint float;
	vannualrent float;
	vrv float;
	-- vtot_assarea float;
-- 	vtot_rvnotletres float;
-- 	vtot_rvnotletcom float;
-- 	vtot_rvletres float;
-- 	vtot_rvletcom float;
-- 	vrv_proposeres float;
-- 	vrv_proposecom float;
-- 	vrv_totproposerv float;
-- 	vtot_rvletout float;
-- 	vtot_rvnotletout float;
	vratefact float;

	
	
begin

	open cur1;
	loop
		alv1 := 0;
		alv2 := 0;
		valv := 0;
		valv_op := 0;
		vmaint := 0;
		vrv := 0;
		
		fetch cur1 into vproperty_no, vproperty_id, vusage_type, vconst_class, vage_factor, vzone, vward, vocc_status, vnew_propertyno;
		exit when not found;

		if(vocc_status = '1') then
		
			if(vproperty_id = vproperty_id and vusage_type in ('1','3','4','5','6','7','8','9','10') and vconst_class in ('A','B','C','D')) then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
				--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = vproperty_id;
				vratefact := sum(alv1 * (vrate_depr/100));
				valv := sum((alv1-vratefact) * 12);
				vmaint := sum(valv * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set rate_deprciate = vratefact, alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;  
		

			elsif(vproperty_id = vproperty_id and (vusage_type = '1' or vusage_type = '11' ) and vconst_class = 'E') then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res, rate_deprciate = 0 where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv_op - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;  

			elsif(vproperty_id = vproperty_id and (vusage_type = '2') and vconst_class in ('A','B','C','D')) then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
				--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = vproperty_id;
				vratefact := sum(alv1 * (vrate_depr/100));
				valv := sum((alv1-vratefact) * 12);
				vmaint := sum(valv * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set rate_deprciate = vratefact, alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;  
		

			elsif(vproperty_id = vproperty_id and (vusage_type = '2') and vconst_class = 'E') then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com, rate_deprciate = 0 where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv_op - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;  

			
			else
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
				--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = vproperty_id;
				vratefact := sum(alv1 * (vrate_depr/100));
				valv := sum((alv1-vratefact) * 12);
				vmaint := sum(valv * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set rate_deprciate = vratefact, alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;  


			
			end if;
			

			
		elsif(vocc_status = '2' or vocc_status = '3') then
		
			if(vproperty_id = vproperty_id and vusage_type in ('1','3','4','5','6','7','8','9','10') and vconst_class in ('A','B','C','D')) then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
				--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = vproperty_id;
				vratefact := sum(alv1 * (vrate_depr/100));
				valv := sum((alv1-vratefact) * 12);
				select annual_rent from flat_details_test into vannualrent where property_id = vproperty_id;
				if(valv > vannualrent) then
					vmaint := sum(valv * 0.1);
					vrv := valv - vmaint;
					update flat_details_test set rate_deprciate = vratefact, alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;
				else
					vmaint := sum(vannualrent * 0.1);
					vrv := vannualrent - vmaint;
					update flat_details_test set rate_deprciate = vratefact, alv = vannualrent, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;
				end if;

			elsif(vproperty_id = vproperty_id and (vusage_type = '1' or vusage_type = '11') and vconst_class = 'E') then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res, rate_deprciate = 0 where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv_op - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;  

			elsif(vproperty_id = vproperty_id and (vusage_type = '2') and vconst_class in ('A','B','C','D')) then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
				--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = vproperty_id;
				vratefact := sum(alv1 *(vrate_depr/100));
				valv := sum((alv1-vratefact) * 12);
				select annual_rent from flat_details_test into vannualrent where property_id = vproperty_id;
				if(valv > vannualrent) then
					vmaint := sum(valv * 0.1);
					vrv := valv - vmaint;
					update flat_details_test set rate_deprciate = vratefact, alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;
				else
					vmaint := sum(vannualrent * 0.1);
					vrv := vannualrent - vmaint;
					update flat_details_test set rate_deprciate = vratefact, alv = vannualrent, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;
				end if;
			
			elsif(vproperty_id = vproperty_id and (vusage_type = '2') and vconst_class = 'E') then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com, rate_deprciate = 0 where property_id = vproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = vproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv_op - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = vproperty_id;  

			end if;
			
-- 
		end if;	
 			
	end loop;
	close cur1;
	perform generate_taxdetails1(iward,izone,iproperty_no);
end;		
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION generate_tax(text, text, text)
  OWNER TO postgres;
