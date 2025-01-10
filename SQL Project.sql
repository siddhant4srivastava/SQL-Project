--SQL Project
--Soln. 1

SELECT TOP 10 th.profile_id, 
             CONCAT(p.first_name, ' ', p.last_name) AS full_name, 
             p.phone
FROM Tenancy_History th
JOIN Profiles p 
ON th.profile_id = p.profile_id
WHERE th.move_out_date IS NOT NULL
ORDER BY DATEDIFF(day, th.move_in_date, th.move_out_date) DESC;


--Soln. 2

SELECT CONCAT(p.first_name, ' ', p.last_name) AS full_name, p.email_id, p.phone
FROM 
Profiles p
JOIN 
Tenancy_History th ON p.profile_id = th.profile_id
WHERE p.marital_status = 'Y'
AND 
th.rent > 9000;


--Soln. 3

SELECT p.profile_id, CONCAT(p.first_name, ' ', p.last_name) AS full_name, p.phone, p.email_id, p.city, th.house_id, th.move_in_date, th.move_out_date, th.rent,
    (SELECT COUNT(ref_id) FROM Referral WHERE Ref_ID = p.profile_id) AS total_referrals,
    ed.latest_employer, ed.Occupational_category
FROM Profiles p
JOIN Tenancy_History th ON p.profile_id = th.profile_id
JOIN Employment_details ed ON p.profile_id = ed.profile_id
WHERE (p.city = 'Bangalore' OR p.city = 'Pune') AND th.move_in_date BETWEEN '2015-01-01' AND '2016-01-31'
ORDER BY th.rent DESC;


--Soln. 4(a)

SELECT CONCAT(p.first_name, ' ', p.last_name) AS full_name, 
       p.email_id, 
       p.phone, 
       p.referral_code,
       COUNT(r.ref_id) AS total_referrals,
       SUM(CASE WHEN r.referral_valid = 1 THEN r.referrer_bonus_amount ELSE 0 END) AS total_bonus_amount
FROM Profiles p
JOIN Referral r ON p.profile_id = r.Ref_ID
GROUP BY p.profile_id, p.first_name, p.last_name, p.email_id, p.phone, p.referral_code
HAVING COUNT(r.ref_id) > 1;


--Soln. 4(b)

SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS Full_Name,
    p.email_id,
    p.phone,
    p.referral_code,
    SUM(r.referrer_bonus_amount) AS Total_Bonus_Amount
FROM Profiles p
JOIN Referral r ON p.profile_id = r.referral_valid
WHERE r.referral_valid = 1
GROUP BY p.profile_id, p.first_name, p.last_name, p.email_id, p.phone, p.referral_code
HAVING COUNT(r.ref_id) > 1;

--Soln. 5

SELECT city, SUM(rent) AS total_rent
FROM Tenancy_History th
JOIN Profiles p ON th.profile_id = p.profile_id
GROUP BY city WITH ROLLUP;


--Soln. 6

CREATE VIEW
vw_tenant AS
SELECT p.profile_id, th.rent, th.move_in_date, h.house_type, h.Beds_vacant, a.description, a.city
FROM Tenancy_History th
JOIN Profiles p ON th.profile_id = p.profile_id
JOIN Houses h ON th.house_id = h.house_id
JOIN Addresses a ON h.house_id = a.house_id
WHERE th.move_in_date >= '2015-04-30' AND h.Beds_vacant > 0;

SELECT * FROM vw_tenant


--Soln. 7

UPDATE Referral
SET valid_till = DATEADD(month, 1, valid_till)
WHERE Ref_ID IN (
    SELECT Ref_ID
    FROM Referral
    GROUP BY Ref_ID
    HAVING COUNT(ref_id) > 1
);


SELECT * FROM Referral


--Soln. 8

SELECT p.profile_id, CONCAT(p.first_name, ' ', p.last_name) AS full_name, p.phone,
    CASE 
        WHEN th.rent > 10000 THEN 'Grade A'
        WHEN th.rent BETWEEN 7500 AND 10000 THEN 'Grade B'
        ELSE 'Grade C'
    END AS Customer_Segment
FROM Tenancy_History th
JOIN Profiles p ON th.profile_id = p.profile_id;


--Soln. 9

SELECT CONCAT(p.first_name, ' ', p.last_name) AS full_name, p.phone, a.city, h.*
FROM Profiles p
JOIN Tenancy_History th ON p.profile_id = th.profile_id
JOIN Houses h ON th.house_id = h.house_id
JOIN Addresses a ON h.house_id = a.house_id
WHERE p.profile_id NOT IN (
    SELECT Ref_ID
    FROM Referral
);


--Soln. 10

SELECT h.*
FROM Houses h
JOIN (
    SELECT TOP 1 house_id, COUNT(profile_id) AS occupancy
    FROM Tenancy_History
    GROUP BY house_id
    ORDER BY occupancy DESC
) AS max_occupancy ON h.house_id = max_occupancy.house_id;
