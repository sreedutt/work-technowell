﻿CREATE OR REPLACE FUNCTION generate_tax(iward text, izone text, iproperty_id text)
  RETURNS void AS
$BODY$

declare
	cur1 cursor for select b.old_propertyno,
			       b.property_id,
			       b.usage_type,
			       b.const_class,
			       b.age_factor,
			       b.zone,
			       b.occupant_status 
			from   property_details a, flat_details b 
			where  a.old_propertyno = b.old_propertyno;
	
	vproperty_no text;
	vproperty_id text;
	vusage_type text;
	vconst_class text;
	vage_factor text;
	vzone text;
	vocc_status text;
	vrate_res numeric(5,2);
	vrate_com numeric(5,2);
	vrate_depr numeric(5,2);
	alv1 float;
	alv2 float;
	valv float;
	valv_op float;
	vmaint float;
	vannualrent float;
	vrv float;
	
begin

	open cur1;
	loop
		fetch cur1 into vproperty_no, vproperty_id, vusage_type, vconst_class, vage_factor, vzone, vocc_status;
		exit when not found;

		if(vocc_status = '1') then
		
			if(vproperty_id = iproperty_id and vusage_type = '1' and vconst_class in ('A','B','C','D')) then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res, rate_deprciate = vrate_depr where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
				select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
				valv := sum((alv1-alv2) * 12);
				vmaint := sum(valv * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;  

				insert into property_taxdetails(zone,
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
								
								
							       
		

			elsif(vproperty_id = iproperty_id and vusage_type = '1' and vconst_class = 'E') then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res, rate_deprciate = 0 where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;  

			elsif(vproperty_id = iproperty_id and vusage_type = '2' and vconst_class in ('A','B','C','D')) then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com, rate_deprciate = vrate_depr where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
				select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
				valv := sum((alv1-alv2) * 12);
				vmaint := sum(valv * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;  
		

			elsif(vproperty_id = iproperty_id and vusage_type = '2' and vconst_class = 'E') then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com, rate_deprciate = 0 where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;  

			
			end if;
			
		elsif(vocc_status = '2' or vocc_status = '3') then
		
			if(vproperty_id = iproperty_id and vusage_type = '1' and vconst_class in ('A','B','C','D')) then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res, rate_deprciate = vrate_depr where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
				select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
				valv := sum((alv1-alv2) * 12);
				select annual_rent from flat_details_test into vannualrent where property_id = iproperty_id;
				if(valv > vannualrent) then
					vmaint := sum(valv * 0.1);
					vrv := valv - vmaint;
					update flat_details_test set alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;
				else
					vmaint := sum(vannualrent * 0.1);
					vrv := vannualrent - vmaint;
					update flat_details_test set alv = vannualrent, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;
				end if;

			elsif(vproperty_id = iproperty_id and vusage_type = '1' and vconst_class = 'E') then
				select rate_residential from rate_master into vrate_res where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_res, rate_deprciate = 0 where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;  

			elsif(vproperty_id = iproperty_id and vusage_type = '2' and vconst_class in ('A','B','C','D')) then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
				select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com, rate_deprciate = vrate_depr where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
				select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
				valv := sum((alv1-alv2) * 12);
				select annual_rent from flat_details_test into vannualrent where property_id = iproperty_id;
				if(valv > vannualrent) then
					vmaint := sum(valv * 0.1);
					vrv := valv - vmaint;
					update flat_details_test set alv = valv, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;
				else
					vmaint := sum(vannualrent * 0.1);
					vrv := vannualrent - vmaint;
					update flat_details_test set alv = vannualrent, alv_op = 0, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;
				end if;
			
			elsif(vproperty_id = iproperty_id and vusage_type = '2' and vconst_class = 'E') then
				select rate_commercial from rate_master into vrate_com where zone = vzone and const_class = vconst_class;
			--select depreciation_pc from ratedepr_master into vrate_depr where const_class = vconst_class and age_factor = vage_factor;
				update flat_details_test set rate_sqm = vrate_com, rate_deprciate = 0 where property_id = iproperty_id;
				select sum(assess_area * rate_sqm)  from flat_details_test into alv1 where property_id = iproperty_id;
			--select sum(alv1 * (rate_deprciate/100)) from flat_details_test into alv2 where property_id = iproperty_id;
			 --valv := sum((alv1-alv2) * 12);
				valv_op := alv1;
				vmaint := sum(valv_op * 0.1);
				vrv := valv - vmaint;
				update flat_details_test set alv = 0, alv_op = valv_op, tenpc_maint = vmaint, rateable_value = vrv where property_id = iproperty_id;  

			end if;
		end if;	

			
	end loop;
	close cur1;
end;		
$BODY$
  LANGUAGE plpgsql VOLATILE;
