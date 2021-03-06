-- VERSION:0.8 --DATE:17/04/2015 --DESC:CHANGED SP NAME , REMOVED LPTID,REFERENCE_NO,TMID INPUT VARIABLE --DONE BY:RL
-- VERSION:0.7 --DATE:08/04/2015 --DESC:PROJECT TITLE, Main Contractor ,Architectural Consultant,M&E Consultant DATA TYPE CHANGED AS VARCHAR(200) --DONE BY:RL
-- VERSION:0.6 --DATE:02/04/2015 --DESC:REMOVED REVISION_NO VARIABLE & GENERATE REVISION NO SP IT SELF --DONE BY:RL
-- VERSION:0.5 --DATE:01/04/2015 --DESC:CHANGED SP AS PER NEW TABLE DESIGN --DONEBY:RL
-- VERSION:0.4 --DATE:30/03/2015 --DESC:VALIDATE REC VER SHOULD INCREMENT WITH PARTICULAR PROJECT TYPE --DONE BY :RL
-- VERSION:0.3 --DATE:28/03/2015 --DESC:WHILE SAVING CHECKED PRICE TYPE SHOULD SAVE IN CORRESPONDING PROJECT TYPE DONE BY:RL
-- VER0.2 DATE:25/03/2015  DESC:IF(STATUS=2) MENAS NEW ROW INSERT, IF(STATUS=1) MEANS WE UPDATE IN SAME ROW done by:RL

DROP PROCEDURE IF EXISTS SP_LCE_TENDER_MANAGEMENT_INSERT;
CREATE PROCEDURE SP_LCE_TENDER_MANAGEMENT_INSERT(
IN PROJECT_TITLE VARCHAR(200),
IN START_DATE DATE,
IN CLOSING_DATE DATE,
IN MAIN_CONTRACTOR VARCHAR(200),
IN ARCHITECT_CONSULTANT VARCHAR(200),
IN ME_CONSULTANT VARCHAR(200),
IN PROJECT_TYPE VARCHAR(50),
IN PRICE_TYPE VARCHAR(50),
IN PREPARED_BY VARCHAR(40),
IN CHECKED_BY VARCHAR(40),
IN APPROVED_BY VARCHAR(40),
IN USERSTAMP VARCHAR(40),
OUT SUCCESSFLAG TEXT)

BEGIN

	DECLARE USERSTAMP_ID INTEGER;

	DECLARE PROJECT_ID INTEGER;
	DECLARE PRICE_ID INTEGER;
	DECLARE CHECK_PROJECT_ID INTEGER;
	DECLARE PREPARED_BY_ID INTEGER;
	DECLARE CHECKED_BY_ID INTEGER;
	DECLARE APPROVED_BY_ID INTEGER;

	DECLARE PROJECT_TITLE_ID INTEGER;
	DECLARE REVISION_NO INTEGER;
	DECLARE TABLE_ROWCOUNT INTEGER;

	DECLARE CURRENTDATE DATE;
	DECLARE CURRENTYEAR INTEGER;
	DECLARE CURRENTYEAR_NO INTEGER;

	DECLARE ERROR_DB_REFNO TEXT;
	DECLARE DB_REF_NO VARCHAR(30);
	DECLARE TENDER_REF_NO VARCHAR(30);	

	DECLARE OLD_TENDER_REF_ID VARCHAR(30);
	DECLARE OLD_TENDER_REF_NO INTEGER;
	DECLARE NEW_TENDER_REF_NO VARCHAR(30);
	DECLARE AUTO_ID TEXT;
	DECLARE FINALE_TENDER_REF_NO VARCHAR(30);

	DECLARE ERROR_MSG TEXT;
	DECLARE LPTID INTEGER;
	
-- ROLLBACK COMMAND
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		IF(SUCCESSFLAG!='') THEN
			SET SUCCESSFLAG = 0;
		END IF;
	END;

	START TRANSACTION;
	SET AUTOCOMMIT=0;
	SET SUCCESSFLAG = '';

-- SUB SP FOR CONVERTING USERSTAMP INTO ULDID
	CALL SP_LCE_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@USER_ID);
	SET USERSTAMP_ID=@USER_ID;

	IF(CHECKED_BY='') THEN
		SET CHECKED_BY = NULL;
	END IF;

	IF(APPROVED_BY='') THEN
		SET APPROVED_BY = NULL;
	END IF;

	SET PROJECT_ID = (SELECT TOP_ID FROM LCE_TYPE_OF_PROJECT WHERE TOP_TYPE = PROJECT_TYPE);
	
	SET PRICE_ID = (SELECT PT_ID FROM LCE_PRICE_TYPE WHERE PT_TYPE = PRICE_TYPE);

	SET CHECK_PROJECT_ID = (SELECT TOP_ID FROM LCE_PRICE_TYPE WHERE PT_ID = PRICE_ID);

	SET PREPARED_BY_ID = (SELECT ULD_ID FROM LCE_USER_MANAGEMENT WHERE ULD_USERNAME = PREPARED_BY);

	SET CHECKED_BY_ID = (SELECT ULD_ID FROM LCE_USER_MANAGEMENT WHERE ULD_USERNAME = CHECKED_BY);

	SET APPROVED_BY_ID = (SELECT ULD_ID FROM LCE_USER_MANAGEMENT WHERE ULD_USERNAME = APPROVED_BY);

	IF EXISTS(SELECT LPT_ID FROM LCE_PROJECT_TITLE WHERE LPT_PROJECT_TITLE = PROJECT_TITLE) THEN
		SET PROJECT_TITLE_ID = (SELECT LPT_ID FROM LCE_PROJECT_TITLE WHERE LPT_PROJECT_TITLE = PROJECT_TITLE);
	END IF;

	IF EXISTS (SELECT DISTINCT(LPT_ID) FROM LCE_TENDER_MANAGEMENT WHERE LPT_ID = PROJECT_TITLE_ID) THEN

		SET REVISION_NO = (SELECT MAX(TM_REV_NO) FROM LCE_TENDER_MANAGEMENT WHERE LPT_ID = PROJECT_TITLE_ID);

		SET REVISION_NO = REVISION_NO+1; 

	ELSE

		SET REVISION_NO = 0;

	END IF;

	SET TABLE_ROWCOUNT = (SELECT COUNT(*) FROM LCE_PROJECT_TITLE);

	SET CURRENTDATE = (SELECT CURRENT_DATE());

	SET CURRENTYEAR = (SELECT YEAR(CURRENTDATE));

	SET CURRENTYEAR_NO = (SELECT SUBSTRING(CURRENTYEAR,3,4));

	SET ERROR_DB_REFNO = (SELECT EMC_DATA FROM LCE_ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=27);

	SET DB_REF_NO = (SELECT REPLACE(ERROR_DB_REFNO,'[Y]',CURRENTYEAR_NO));

	SET TENDER_REF_NO = (SELECT SUBSTRING_INDEX(DB_REF_NO,'/',3));

	IF(TABLE_ROWCOUNT > 0) THEN

		SET OLD_TENDER_REF_ID = (SELECT LPT_TENDER_REF_NO FROM LCE_PROJECT_TITLE ORDER BY LPT_ID DESC LIMIT 1);

		SET OLD_TENDER_REF_NO = (SELECT SUBSTRING_INDEX(OLD_TENDER_REF_ID,'/',-1));

		SET NEW_TENDER_REF_NO = OLD_TENDER_REF_NO+1;

		SET @NEWREFLENGTH = (SELECT LENGTH(NEW_TENDER_REF_NO));
						
		IF(@NEWREFLENGTH=1)THEN
			SET AUTO_ID = (SELECT CONCAT('000',NEW_TENDER_REF_NO));
		END IF;

		IF(@NEWREFLENGTH=2)THEN
			SET AUTO_ID = (SELECT CONCAT('00',NEW_TENDER_REF_NO));
		END IF;

		IF(@NEWREFLENGTH=3)THEN
			SET AUTO_ID = (SELECT CONCAT('0',NEW_TENDER_REF_NO));
		END IF;

		IF(@NEWREFLENGTH>=4)THEN
			SET AUTO_ID = NEW_TENDER_REF_NO;
		END IF;

		SET FINALE_TENDER_REF_NO = (SELECT CONCAT(TENDER_REF_NO,'/',AUTO_ID));

	ELSE

		SET FINALE_TENDER_REF_NO = DB_REF_NO;

	END IF;

	IF EXISTS(SELECT LPT_TENDER_REF_NO FROM LCE_PROJECT_TITLE WHERE LPT_TENDER_REF_NO = FINALE_TENDER_REF_NO) THEN

		SET ERROR_MSG = (SELECT EMC_DATA FROM LCE_ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=28);
		SET SUCCESSFLAG = (SELECT REPLACE(ERROR_MSG,'[REFNO]',FINALE_TENDER_REF_NO));

	END IF;

	IF(PROJECT_TITLE IS NOT NULL AND FINALE_TENDER_REF_NO IS NOT NULL AND START_DATE IS NOT NULL AND CLOSING_DATE 
	IS NOT NULL AND MAIN_CONTRACTOR IS NOT NULL AND ARCHITECT_CONSULTANT IS NOT NULL AND ME_CONSULTANT IS NOT NULL 
	AND PROJECT_TYPE IS NOT NULL AND PRICE_TYPE IS NOT NULL AND PREPARED_BY IS NOT NULL AND USERSTAMP IS NOT NULL) THEN

		IF(SUCCESSFLAG='' AND CHECK_PROJECT_ID=PROJECT_ID) THEN

			IF(PROJECT_TITLE IS NOT NULL AND FINALE_TENDER_REF_NO IS NOT NULL AND START_DATE IS NOT NULL
			AND CLOSING_DATE IS NOT NULL AND USERSTAMP_ID IS NOT NULL) THEN

				INSERT INTO LCE_PROJECT_TITLE(LPT_PROJECT_TITLE,LPT_TENDER_REF_NO,LPT_START_DATE,LPT_CLOSING_DATE,ULD_ID)
				VALUES (PROJECT_TITLE,FINALE_TENDER_REF_NO,START_DATE,CLOSING_DATE,USERSTAMP_ID);

			END IF;

			SET LPTID = (SELECT LPT_ID FROM LCE_PROJECT_TITLE WHERE LPT_PROJECT_TITLE = PROJECT_TITLE);

			IF(LPTID IS NOT NULL AND MAIN_CONTRACTOR IS NOT NULL AND ARCHITECT_CONSULTANT IS NOT NULL AND ME_CONSULTANT 
			IS NOT NULL AND PROJECT_ID IS NOT NULL AND PRICE_ID IS NOT NULL AND FINALE_TENDER_REF_NO IS NOT NULL AND
			PREPARED_BY_ID IS NOT NULL AND USERSTAMP_ID IS NOT NULL) THEN

				INSERT INTO LCE_TENDER_MANAGEMENT (LPT_ID,TM_MAIN_CONTRACTOR,TM_ARCHITECT_CONSULTANT,TM_ME_CONSULTANT,
				TS_ID,TOP_ID,PT_ID,TM_REV_NO,TM_PREPARED_BY,TM_CHECKED_BY,TM_APPROVED_BY,ULD_ID) VALUES
				(LPTID,MAIN_CONTRACTOR,ARCHITECT_CONSULTANT,ME_CONSULTANT,1,PROJECT_ID,PRICE_ID,FINALE_TENDER_REF_NO,
				PREPARED_BY_ID,CHECKED_BY_ID,APPROVED_BY_ID,USERSTAMP_ID);

			END IF;

			SET SUCCESSFLAG = 1;

		END IF;

	END IF;

	COMMIT;

END;