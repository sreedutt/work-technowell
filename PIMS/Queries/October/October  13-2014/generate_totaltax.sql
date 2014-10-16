CREATE OR REPLACE FUNCTION generate_totaltax(iward text, izone text, iproperty_no text)
  RETURNS void AS
$BODY$

declare
	cur1 cursor for select a.old_propertyno,
			       b.property_id,
			       a.new_propertyno,
			       a.usage_type,
			       a.zone,
			       a.ward 
			from   property_details a, flat_details b 
			where  a.old_propertyno = b.old_propertyno;
	
	vproperty_no text;
	vproperty_id text;
	vnew_property_no text;
	vusage_type text;
	vzone text;
	vward text;
	vtot_assarea;
begin

	open cur1;
	loop
		fetch cur1 into vproperty_no, vproperty_id, vnew_property_no, vzone, vward;
		exit when not found;

		select sum(assess_area) into vtot_assarea where vproperty_no = old_propertyno;

		if(vproperty_no = iproperty_no and vusage_type ='1'