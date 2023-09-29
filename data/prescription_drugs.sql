
--------------------------------------------------------------------------------------------------------------------------------------------------------
1- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
 SELECT p.npi, p.nppes_provider_first_name,p.nppes_provider_last_org_name, SUM(pr.total_claim_count) AS total_claims
 FROM prescriber AS p
 INNER JOIN prescription AS pr
 ON p.npi = pr.npi
 GROUP BY p.npi, p.nppes_provider_first_name, p.nppes_provider_last_org_name
 ORDER BY total_claims DESC
 LIMIT 1;
 
 --ANSWER:  1881634483	"BRUCE"	"PENDLEY"	99707
  
-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT p.npi, p.nppes_provider_first_name, p.nppes_provider_last_org_name, p.specialty_description, SUM(pr.total_claim_count) AS total_claims
 FROM prescriber AS p
 INNER JOIN prescription AS pr
 ON p.npi = pr.npi
 GROUP BY p.npi, p.nppes_provider_first_name, p.nppes_provider_last_org_name, p.specialty_description
 ORDER BY total_claims DESC
 LIMIT 1;
ANSWER: 1881634483	"BRUCE"	"PENDLEY"	"Family Practice"	99707

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--2. 

--a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT p.specialty_description, SUM(pr.total_claim_count) AS total_numof_claims
FROM prescriber AS p
JOIN prescription AS pr 
ON p.npi = pr.npi
--INNER JOIN drug AS d ON 
GROUP BY p.specialty_description
ORDER BY total_numof_claims DESC
LIMIT 1;
-- ANSWER-  "Family Practice"	 9752347

--b. Which specialty had the most total number of claims for opioids?
SELECT p.specialty_description, SUM(total_claim_count) AS total_num_claims
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
INNER JOIN drug AS d
ON pr.drug_name = d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY p.specialty_description
ORDER BY total_num_claims DESC
LIMIT 1;

--ANSWER:  "Nurse Practitioner"	  900845


--c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT p.specialty_description, sum(pr.total_claim_count ) as total_Claims
FROM prescriber AS p
LEFT JOIN prescription AS pr
ON p.npi = pr.npi
--WHERE pr.total_claim_count IS NULL
GROUP BY p.specialty_description --, pr.total_claim_count
HAVING sum(pr.total_claim_count ) is null;

--ANSWER: YES, 15 Specialities appeared


--NOT DONE--    d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
--SELECT * FROM prescription 

WITH specialtytotalclaims AS 
(SELECT p.specialty_description, d.opioid_drug_flag, SUM(pr.total_claim_count) AS totalclaims
FROM prescriber AS p
INNER JOIN prescription AS pr ON p.npi = pr.npi
INNER JOIN drug AS d 
ON pr.drug_name = d.drug_name
GROUP BY p.specialty_description,opioid_drug_flag
)

SELECT specialty_description, total_claim_count, opioid_drug_flag,
(opioid_drug_flag / total_claim_count) * 100 AS opioid_percentage
FROM specialtytotalclaims
WHERE d.opioid_drug_flag = 'Y' 
--total_claim_count >0
ORDER BY opioid_percentage DESC;


---
SELECT p.specialty_description, SUM(pr.total_claim_count) AS opioid_claims
FROM prescriber AS p
INNER JOIN prescription AS pr ON p.npi = pr.npi
INNER JOIN drug AS d 
ON pr.drug_name = d.drug_name
 WHERE d.opioid_drug_flag = 'Y'
 GROUP BY p.specialty_description
 )
 


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--3. 
--  a. Which drug (generic_name) had the highest total drug cost?

SELECT d.generic_name, SUM(p.total_drug_cost)AS total_drug_cost
FROM prescription AS p
INNER JOIN drug AS d
ON d.drug_name = p.drug_name
GROUP BY d.generic_name
ORDER BY total_drug_cost DESC
LIMIT 1;
--ANSWER:  "INSULIN GLARGINE,HUM.REC.ANLOG"	  104264066.35

-- b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT  d.generic_name, pr.total_day_supply, ROUND(MAX(pr.total_drug_cost/pr.total_day_supply), 2) AS  highest_total_cost
FROM prescription AS pr
INNER JOIN drug AS d
ON pr.drug_name = d.drug_name
GROUP BY d.generic_name, pr.total_day_supply;



------------------------------------------------------------------------------
--4. 
--  a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
--SELECT * FROM drug;
SELECT drug_name,
CASE
WHEN opioid_drug_flag ='Y' THEN 'opioid'
WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug;

--  b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT 
CASE
WHEN d.opioid_drug_flag ='Y' THEN 'opioid'
WHEN d.antibiotic_drug_flag ='Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type,
SUM(pr.total_drug_cost) AS total_cost
FROM drug AS d
INNER JOIN prescription AS pr
ON d.drug_name  = pr.drug_name
WHERE ( d.opioid_drug_flag ='Y' OR d.antibiotic_drug_flag ='Y' )
GROUP BY d.opioid_drug_flag, d.antibiotic_drug_flag
ORDER BY total_cost DESC;


------------------------------------------------------------------------------------------------------
--5. 
--  a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
--SELECT * FROM cbsa;
--SELECT * FROM fips_county
SELECT COUNT(*) AS cbsa_in_tennessee
FROM cbsa AS cbsa
INNER JOIN fips_county AS fc
ON cbsa.fipscounty = fc.fipscounty
WHERE fc.state = 'TN'
ORDER BY cbsa_in_tennessee;

--  b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
--SELECT * FROM population;
--SELECT * FROM zip_fips
--SELECT * FROM fips_county
--SELECT * FROM cbsa;
SELECT c.cbsaname, SUM(p.population) AS total_population
FROM cbsa AS c
INNER JOIN fips_county AS fc
ON c.fipscounty = fc.fipscounty
INNER JOIN population AS p
ON p.fipscounty = fc.fipscounty
GROUP BY c.cbsaname
ORDER BY total_population DESC
LIMIT 1;
--ANSWER: The largest combined population is "Nashville-Davidson--Murfreesboro--Franklin, TN"	1830410
SELECT c.cbsaname, SUM(p.population) AS total_population
FROM cbsa AS c
INNER JOIN fips_county AS fc
ON c.fipscounty = fc.fipscounty
INNER JOIN population AS p
ON p.fipscounty = fc.fipscounty
GROUP BY c.cbsaname
ORDER BY total_population ASC
LIMIT 1;
--ANSWER: The smallest combined population is "Morristown, TN"	116352

--  c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
--SELECT * FROM fips_county
SELECT fc.county, p.population AS largest_county
FROM fips_county AS fc
LEFT JOIN cbsa AS c
ON fc.fipscounty = c.fipscounty
INNER JOIN population AS p
ON fc.fipscounty = p.fipscounty
WHERE c.fipscounty IS NULL
ORDER BY largest_county DESC
LIMIT 1;
--ANSWER: "SEVIER"	95523

--------------------------------------------------------------------------------------------

--6. 
--  a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
--SELECT * FROM prescription;
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--  b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT pr.drug_name, pr.total_claim_count,d.opioid_drug_flag AS drug_is_opioid
FROM prescription AS pr
INNER JOIN drug AS d
ON pr.drug_name = d.drug_name
WHERE total_claim_count >= 3000 AND opioid_drug_flag IS NOT NULL;

--  c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
--SELECT * FROM prescriber;
SELECT pr.drug_name, pr.total_claim_count,p.nppes_provider_first_name,p.nppes_provider_last_org_name,d.opioid_drug_flag AS drug_is_opioid
FROM prescription AS pr
INNER JOIN drug AS d
ON pr.drug_name = d.drug_name
INNER JOIN prescriber AS p
ON p.npi = pr.npi
WHERE total_claim_count >= 3000 AND opioid_drug_flag IS NOT NULL
ORDER BY p.nppes_provider_first_name,p.nppes_provider_last_org_name;
---------------------------------------------------------------------------------------------------------------------------------------
--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--    a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
--SELECT distinct specialty_description FROM prescriber WHERE specialty_description = 'Pain Management';

SELECT p.npi, pr.drug_name
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
INNER JOIN drug AS d
ON pr.drug_name = d.drug_name
WHERE p.specialty_description  = 'Pain Management' AND p.nppes_provider_city = 'NASHVILLE';

--    b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
 SELECT p.npi, pr.npi, pr.drug_name, SUM(pr.total_claim_count) AS total_claims
 FROM prescriber AS p
 LEFT JOIN prescription AS pr
 ON p.npi = pr.npi
 GROUP BY p.npi, pr.npi,pr.drug_name
 ORDER BY total_claims desc;
  
--    c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
 
SELECT p.npi, pr.npi, pr.drug_name, COALESCE(SUM(pr.total_claim_count),0) AS total_claims
 FROM prescriber AS p
 LEFT JOIN prescription AS pr
 ON p.npi = pr.npi
 GROUP BY p.npi, pr.npi,pr.drug_name
 ORDER BY total_claims asc;
 
 
---------------------------------------------------------------------------------------------------------------------------- 
----------------------------------------------------------------------------------------------------------------------------
--BONUS QUESTIONS:

-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
--SELECT * FROM prescriber;
SELECT COUNT(DISTINCT p.npi) AS npi_count
FROM prescriber AS p
LEFT JOIN prescription AS pr
ON p.npi = pr.npi
WHERE pr.npi IS NULL;
--ANSWER:  npi numbers appear in the prescriber is 4458
---------------------------------------------------------------------------------------------------------------------------------------
--2.
--SELECT * FROM prescriber
--  a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT d.generic_name, p.specialty_description,SUM(pr.total_claim_count) as total_claims
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
INNER JOIN drug AS d 
ON pr.drug_name =d.drug_name
WHERE p.specialty_description = 'Family Practice'
GROUP BY d.generic_name, p.specialty_description
ORDER by total_claims DESC
LIMIT 5;


--  b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT d.generic_name, p.specialty_description,SUM(pr.total_claim_count) as total_claims
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
INNER JOIN drug AS d 
ON pr.drug_name =d.drug_name
WHERE p.specialty_description = 'Cardiology'
GROUP BY d.generic_name, p.specialty_description
ORDER by total_claims DESC
LIMIT 5;
--  c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

--Combining both Family Practice and Cardiology:

SELECT d.generic_name, p.specialty_description,SUM(pr.total_claim_count) as total_claims
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
INNER JOIN drug AS d 
ON pr.drug_name =d.drug_name
WHERE p.specialty_description IN ('Family Practice' , 'Cardiology')
GROUP BY d.generic_name, p.specialty_description
ORDER by total_claims DESC
LIMIT 5;

------------------------------------------------------------------------------------------------------------------------------------------------------

--3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--  a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
-- SELECT * FROM prescriber;   

SELECT p.npi, p.nppes_provider_city, SUM(pr.total_claim_count) AS total_numberofclaims
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
WHERE p.nppes_provider_city = 'NASHVILLE'
GROUP BY p.npi, p.nppes_provider_city
ORDER BY total_numberofclaims DESC
LIMIT 5;


--  b. Now, report the same for Memphis.
SELECT p.npi, p.nppes_provider_city, SUM(pr.total_claim_count) AS total_numberofclaims
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
WHERE p.nppes_provider_city = 'MEMPHIS'
GROUP BY p.npi, p.nppes_provider_city
ORDER BY total_numberofclaims DESC
LIMIT 5;
    
--  c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.
SELECT p.npi, p.nppes_provider_city, SUM(pr.total_claim_count) AS total_numberofclaims
FROM prescriber AS p
INNER JOIN prescription AS pr
ON p.npi = pr.npi
WHERE p.nppes_provider_city IN ('NASHVILLE', 'MEMPHIS', 'KNOXVILLE', 'CHATTANOOGA')
GROUP BY p.npi, p.nppes_provider_city
ORDER BY total_numberofclaims DESC
LIMIT 5;
---------------------------------------------------------------------------------------------------
--4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.
--SELECT * FROM fips_county limit 10;
--SELECT * FROM overdose_deaths limit 10;
SELECT fc.county,AVG(od.overdose_deaths) AS avg_overdose_deaths
FROM fips_county AS fc
INNER JOIN overdose_deaths AS od
ON CAST(fc.fipscounty AS INTEGER) = od.fipscounty
GROUP BY fc.county
HAVING AVG(od.overdose_deaths) > (SELECT AVG(overdose_deaths) FROM overdose_deaths)
ORDER BY avg_overdose_deaths ASC;

--5.
--   a. Write a query that finds the total population of Tennessee.
--SELECT * FROM population
--SELECT * FROM fips_county
SELECT fc.state, SUM(p.population) AS total_popin_tennessee
FROM fips_county AS fc
INNER JOIN population AS p
ON fc.fipscounty = p.fipscounty
WHERE fc.state = 'TN'
GROUP BY fc.state;
--ANSWER: "TN"	6597381

--   b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

WITH total_population_tn AS
(
	SELECT fc.state, SUM(p.population) AS total_popin_tennessee
FROM fips_county AS fc
INNER JOIN population AS p
ON fc.fipscounty = p.fipscounty
WHERE fc.state = 'TN'
GROUP BY fc.state
)
SELECT fc.county, p.population, ROUND((p.population / total_popin_tennessee) * 100, 2) AS percentage_of_totpopulation
FROM fips_county AS fc
INNER JOIN population AS p
ON fc.fipscounty = p.fipscounty
INNER JOIN total_population_tn AS tp
ON fc.state = tp.state
WHERE fc.state = 'TN';

