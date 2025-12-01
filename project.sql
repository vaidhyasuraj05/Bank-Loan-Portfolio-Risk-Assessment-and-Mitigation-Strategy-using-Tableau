use project;
select * from bank_data;

-- ------------------------------------------------KPIS    As   View---------------------------------------------------------------------------

-- Total funded amount == 7322582200 
-- Total Loan Count == 65496
-- Tota Amount Collection == 814400091.86
-- Total Interest Received  == 155202526.76

drop view V_Overall_Financial_Summary;

CREATE VIEW V_Overall_Financial_Summary AS
SELECT
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
    CONCAT(ROUND(COUNT(Account_ID) / 1000, 2), ' K') AS Total_Loan_Count,
    CONCAT(ROUND(SUM(Funded_Amount) / 1000000, 2), ' M') AS Total_Funded_Amount,
    CONCAT(ROUND(SUM(Total_Rrec_Int) / 1000000, 2), ' M') AS Total_Interest_Received,
    CONCAT(ROUND(SUM(Total_Payment) / 1000000, 2), ' M') AS Total_Collected_Amount
FROM
    bank_data;

-- To query the view:
SELECT * FROM V_Overall_Financial_Summary;

-- ------------------------------------------------GROUP WISE---------------------------------------------------------------------------

-- Branch Wise Pertformance   Barnala performed least and Mathura is high performer 

select Branch_name,
	CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
    COUNT(Account_ID) AS Total_Loan_Count,
    CONCAT(ROUND(SUM(Funded_Amount) / 1000000, 2), ' M') AS Total_Funded_Amount,
    CONCAT(ROUND(SUM(Total_Rrec_Int) / 100000, 2), ' L') AS Total_Interest_Received,
    CONCAT(ROUND(SUM(Total_Payment) / 100000, 2), ' L') AS Total_Collected_Amount
from bank_data
group by Branch_name, State_name
order by Total_Loan_Amount desc;

-- State Wise Performance   Least = Madhya Pradesh and Highest = Uttarpradesh

select state_name,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
    COUNT(Account_ID) AS Total_Loan_Count,
    CONCAT(ROUND(SUM(Funded_Amount) / 1000000, 2), ' M') AS Total_Funded_Amount,
    CONCAT(ROUND(SUM(Total_Rrec_Int) / 100000, 2), ' L') AS Total_Interest_Received,
    CONCAT(ROUND(SUM(Total_Payment) / 100000, 2), ' L') AS Total_Collected_Amount
from Bank_data
group by State_name
order by Total_Loan_amount desc;


 -- Product Group Wise Loan
 SELECT
    Product_code,
    SUM(Loan_Amount) AS Total_Loan_Amount
FROM bank_data
GROUP BY Product_code
ORDER BY Total_Loan_Amount DESC;


-- Disbursment Trend   
select Date_format(Disbursement_date, '%M') as Disbursement_month,
count(Account_id) as Total_No_of_Loan_count,
sum(loan_amount) as Total_Loan_Amount
from bank_data
group by disbursement_Month
order by Total_loan_amount;

UPDATE bank_data
SET Disbursement_date = STR_TO_DATE(Disbursement_date, '%d-%m-%Y')
WHERE Disbursement_date IS NOT NULL AND Disbursement_date != '';

ALTER TABLE bank_data
MODIFY COLUMN Disbursement_date DATE;


--  ------------------------------------------Default and Delinquency Analysis-----------------------------------------

-- Default Loan = 7,479  
 select count(account_id) as Default_Loan_Count
 from bank_data
 where Loan_status = "default";

-- Default rate = 11.42 %
SELECT
    (SUM(CASE WHEN Loan_Status = 'Default' THEN 1 ELSE 0 END) / COUNT(Account_ID)) * 100 AS Default_Loan_Rate_Percent
FROM bank_data;

-- Delinquency clients = 7,105
select count(distinct client_id) as Delinqunece_client_count
 from bank_data
 where is_delinquent_loan = "yes";
 
 -- Delinquent rate = 10.85 %
 SELECT
    (SUM(CASE WHEN is_Delinquent_Loan = 'Yes' THEN 1 ELSE 0 END) / COUNT(Account_ID)) * 100 AS Delinquent_Loan_Rate_Percent
FROM bank_data;

-- status wise loan
SELECT
    Loan_Status,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
    CONCAT(ROUND(COUNT(Account_ID) / 1000, 2), ' K') AS Total_Loan_Count
FROM bank_data
GROUP BY Loan_Status;

-- --------------------------------------------------------------------------------------------------------------------------

-- Age group wise
SELECT
    CASE
        WHEN Age < 25 THEN '<25'
        WHEN Age >= 25 AND Age < 30 THEN '25-30'
        WHEN Age >= 30 AND Age < 35 THEN '30-35'
        WHEN Age >= 35 AND Age < 40 THEN '35-40'
        WHEN Age >= 40 AND Age < 45 THEN '40-45'
        WHEN Age >= 45 AND Age < 50 THEN '45-50'
        ELSE '50+'
    END AS Age_Group,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
    CONCAT(ROUND(COUNT(Account_ID) / 1000, 2), ' K') AS Total_Loan_Count
FROM bank_data
GROUP BY Age_Group
ORDER BY MIN(Age);

-- Loan Maturity
SELECT
    Account_ID,
    Loan_Amount,
    (Loan_amount - Total_rec_prncp) as Remaining_Balance
FROM bank_data
WHERE Loan_Status = 'Active loan' -- Only need to check active/delinquent loans
    AND (Loan_amount - Total_rec_prncp) > 0
ORDER BY Remaining_Balance DESC;

-- No Verified Loans = 42,700 
SELECT
    count(Account_ID) as No_of_not_verified_loans,
    Verification_Status
FROM bank_data
-- WHERE Verification_Status IS NULL OR Verification_Status NOT IN ('Verified', 'Source Verified')
group by verification_status;

-- -----------------------------------------------------------------------------------------------------------------------------------

-- Branch Head Performance
SELECT
    Branch_Head_Name,
    Branch_Name,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
    CONCAT(ROUND(COUNT(Account_ID) / 1000, 2), ' K') AS Total_Loan_Count
FROM bank_data
GROUP BY
    Branch_Head_Name,
    Branch_Name
ORDER BY
    Total_Loan_Amount DESC;

-- Top 5 Borrowers
WITH RankedBorrowers AS (
    SELECT
        Client_Name_Borrower,
        CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
        RANK() OVER (ORDER BY SUM(Loan_Amount) DESC) AS loan_rank
    FROM
        bank_data
    GROUP BY
        Client_Name_Borrower
)
SELECT
    Client_Name_Borrower,
    Total_Loan_Amount
FROM
    RankedBorrowers
WHERE
    loan_rank <= 5
ORDER BY
    Total_Loan_Amount DESC;
    
-- Average loans ----------------------------- loans that are greater than avg of the group-----------------------------
SELECT
    Account_ID,
    Client_Name_Borrower,
    Loan_Amount
FROM
    bank_data
WHERE
    Loan_Amount > (SELECT AVG(Loan_Amount) FROM bank_data)
ORDER BY
    Loan_Amount DESC; 
    
    
    
-- ----------------------------------------------------stored procedure--------------------------------------------------

Drop PROCEDURE GetStateWiseLoanSummary;
DELIMITER //

CREATE PROCEDURE GetStateWiseLoanSummary()
BEGIN
    SELECT
        State_Name,
        CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount,
        CONCAT(ROUND(COUNT(Account_ID) / 1000, 2), ' K') AS Total_Loan_Count,
        CONCAT(ROUND(SUM(Funded_Amount) / 1000000, 2), ' M') AS Total_Funded_Amount,
        CONCAT(ROUND(SUM(Total_Rrec_Int) / 1000000, 2), ' M') AS Total_Interest_Received,
        CONCAT(ROUND(SUM(Total_Payment) / 1000000, 2), ' M') AS Total_Collected_Amount
    FROM
        bank_data
    GROUP BY
        State_Name
    ORDER BY
        Total_Loan_Amount DESC;
END //

DELIMITER ;

-- To execute the procedure:
CALL GetStateWiseLoanSummary();

-- ------------------------------------------------trigger-----------------------------------------------------

DELIMITER //

CREATE TRIGGER prevent_unverified_loan_insert
BEFORE INSERT ON bank_data
FOR EACH ROW
BEGIN
    IF NEW.Verification_Status IS NULL OR NEW.Verification_Status NOT IN ('Verified', 'Source Verified') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot insert loan record: Verification must be completed (Verified).';
    END IF;
END //

DELIMITER ;

-- -------------------------------------------------------------------------------------------------------------------------






















