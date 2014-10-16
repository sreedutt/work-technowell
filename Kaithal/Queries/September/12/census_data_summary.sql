create or replace function census_data_summary(in_ward_no int,
						in_block_no text,
						in_age int
					       )

returns setof refcursor as $$
declare
	r_gender refcursor := 'gcur';
	r_community refcursor := 'rcur';
begin
	open r_gender
	for select gender,count(1)
	    from census_details
	    where (ward_no = in_ward_no or in_ward_no = 0)
	       and(block_no = in_block_no or in_block_no = 'All')
	       and(age >= in_age)
	    group by gender;   
	return next r_gender;    

	open r_community
	for select community,count(1)
	    from census_details
	    where (ward_no = in_ward_no or in_ward_no = 0)
	       and(block_no = in_block_no or in_block_no = 'All')
	       and(age >= in_age)
	    group by community;   
	return next r_community;    
end;
$$language plpgsql;	