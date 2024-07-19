/*DECLARE @intDealRowCnt INT;
SET @intDealRowCnt = (
	SELECT COUNT(DISTINCT Deal)
	FROM Intex.TrusteePerformance
);
*/
/*
WITH cte AS (
	/*SELECT DISTINCT Deal, Year, Month, Delinq30_59, Delinq60_89, Delinq90_plus, CDR_1mo*/
	SELECT DISTINCT Deal, Year, Month, Delinq30_59, Delinq60_89, Delinq90_plus, CDR_1mo
	FROM Intex.TrusteePerformance
)
SELECT Deal, 
Year, 
Month, 
Delinq30_59, 
Delinq60_89, 
Delinq90_plus, 
CDR_1mo, 
LAG(Delinq90_plus, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC) AS PrevDelinq90_plus,
LAG(Delinq60_89, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC) AS PrevDelinq60_89,
LAG(Delinq30_59, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC) AS PrevDelinq30_59,
DENSE_RANK() OVER (ORDER BY Deal ASC) AS RowNum
FROM cte
/*FROM Intex.TrusteePerformance*/
WHERE Deal LIKE '%Paid%'

/*ORDER BY Deal ASC, Year DESC, Month DESC OFFSET 5 ROWS;*/
ORDER BY Deal ASC, Year DESC, Month DESC;
/*ORDER BY Deal ASC
OFFSET 5 ROWS
FETCH NEXT @intDealRowCnt ROWS ONLY;*/
*/
SELECT *
FROM (
	SELECT Deal, 
	Year, 
	Month, 
	Delinq30_59, 
	Delinq60_89, 
	Delinq90_plus, 
	CDR_1mo,
	/*(1+CDR_1mo/100) AS plus_CDR_1mo,*/
	POWER((1+CDR_1mo/100),1.0/12) AS  monthly_CDR_1mo,
	/*(POWER(1+CDR_1mo/100,1.0/12)-1) AS CDR_1mo_monthly_rate,*/
	LAG(Delinq90_plus, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC) AS PrevDelinq90_plus,
	LAG(Delinq60_89, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC) AS PrevDelinq60_89,
	LAG(Delinq30_59, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC) AS PrevDelinq30_59,
	(Delinq60_89)/NULLIF(LAG(Delinq30_59, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC),0)*100 AS RollRate_30_to_60,
	(Delinq90_plus)/NULLIF(LAG(Delinq60_89, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC),0)*100 AS RollRate_60_to_90,
	(POWER(1+CDR_1mo/100,1.0/12))/NULLIF(LAG(Delinq90_plus, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC),0)*100 AS RollRate_90_to_Def,
	(Delinq90_plus)/NULLIF(LAG(Delinq30_59, 2) OVER (ORDER BY Deal ASC, Year ASC, Month ASC),0)*100 AS RollRate_30_to_90,
	(POWER(1+CDR_1mo/100,1.0/12))/NULLIF(LAG(Delinq30_59, 2, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC),0)*100 AS RollRate_30_to_Def,
	(POWER(1+CDR_1mo/100,1.0/12))/NULLIF(LAG(Delinq60_89, 3, 1) OVER (ORDER BY Deal ASC, Year ASC, Month ASC),0)*100 AS RollRate_60_to_Def,
	ROW_NUMBER() OVER (PARTITION BY Deal ORDER BY Deal) AS rownum
	FROM Intex.TrusteePerformance
) AS t
WHERE Deal LIKE '%PAID21H1%' AND
rownum > 6
ORDER BY Deal ASC, Year DESC, Month DESC;
/*
SELECT *
FROM Intex.TrusteePerformance
WHERE Deal LIKE '%Paid%'
ORDER BY Deal ASC, Year DESC, Month DESC;
*/
