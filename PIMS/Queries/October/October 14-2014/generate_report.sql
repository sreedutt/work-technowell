create or replace function generate_report(iward text, izone text, iproperty_no text)
returns setof refcursor as $$
declare
	ref1 refcursor;
	ref2 refcursor;
	ref3 refcursor;
begin
        open ref1 for select * from property_details where (ward = iward or iward = 'All')
							and (zone = izone or izone = 'All')
							or old_propertyno = iproperty_no;
	return next ref1;

	open ref2 for select * from flat_details_test where (ward = iward or iward = 'All')
							and (zone = izone or izone = 'All')
							or old_propertyno = iproperty_no;
	return next ref2;

	open ref3 for select * from property_taxdetails where (ward = iward or iward = 'All')
							and (zone = izone or izone = 'All')
							or old_propertyno = iproperty_no;
	return next ref3;


	return;
end;

$$ LANGUAGE plpgsql;														