create or replace view vw_additional_ownerdetails( property_id,
						   old_propertyno,
						   new_propertyno,
						   zone,
						   ward,
						   add_ownername,
						   add_owneraddress
						 )
as

				select concat(prop_id, '/', flat_no) AS property_id,
				       property_no,
				       concat(property_no, '/', 'new') AS new_propertyno,
				       zone,
				       ward,
				       concat(title, first_name, middle_name, last_name) as add_ownername,
				       address
				from svd_additionownerdetails1;