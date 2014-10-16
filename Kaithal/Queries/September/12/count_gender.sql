select gender,count(1) from census_details
where ward_no = 1
group by gender;