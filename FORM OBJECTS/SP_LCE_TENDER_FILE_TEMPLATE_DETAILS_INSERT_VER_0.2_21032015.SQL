-- VER0.1 DATE:18/03/2015  DESC:SP TO SAVE VALUES IN LCE_TENDER_FILE_TEMPLATE_DETAILS TABLE done by:RL

DROP PROCEDURE IF EXISTS SP_LCE_TENDER_FILE_TEMPLATE_DETAILS_INSERT;
CREATE PROCEDURE SP_LCE_TENDER_FILE_TEMPLATE_DETAILS_INSERT(
IN SEARCH_OPTION INTEGER,
IN TMID INTEGER,
IN FILETEMPLATE_ID TEXT,
IN FILETEMPLATE_CHECK_FLAG TEXT,
IN USERSTAMP VARCHAR(50),
OUT SUCCESSFLAG INTEGER)

BEGIN

	DECLARE USERSTAMP_ID INTEGER;
	DECLARE FILETEMPLATEID INTEGER;
	DECLARE FILETEMPLATECHECKFLAG CHAR(1);
	
-- ROLLBACK COMMAND
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET SUCCESSFLAG = 0;
	END;

	START TRANSACTION;
	SET AUTOCOMMIT=0;
	SET SUCCESSFLAG = 0;

-- SUB SP FOR CONVERTING USERSTAMP INTO ULDID
	CALL SP_LCE_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULD_ID);
	SET USERSTAMP_ID=@ULD_ID;

	SET @TEMP_FILETEMPLATE_ID = FILETEMPLATE_ID;
	SET @TEMP_FILETEMPLATE_CHECK_FLAG = FILETEMPLATE_CHECK_FLAG;

	IF SEARCH_OPTION=2 THEN
	
		SET @DELETE_FILE_TEMPATE=(SELECT CONCAT('DELETE FROM LCE_TENDER_FILE_TEMPLATE_DETAILS WHERE FT_ID NOT IN(',FILETEMPLATE_ID,') 
		AND TM_ID=',TMID));
		PREPARE DELETE_FILE_TEMPATE_STMT FROM @DELETE_FILE_TEMPATE;
		EXECUTE DELETE_FILE_TEMPATE_STMT;
		SET SUCCESSFLAG = 1;
		
	END IF;


	IF(TMID IS NOT NULL AND FILETEMPLATE_ID IS NOT NULL AND USERSTAMP IS NOT NULL) THEN

		MAIN_LOOP : LOOP

			CALL SP_LCE_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_FILETEMPLATE_ID,@VALUE,@REMAINING_STRING);
			SELECT @VALUE INTO FILETEMPLATEID;
			SELECT @REMAINING_STRING INTO @TEMP_FILETEMPLATE_ID;

			CALL SP_LCE_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_FILETEMPLATE_CHECK_FLAG,@VALUE,@REMAINING_STRING);
			SELECT @VALUE INTO FILETEMPLATECHECKFLAG;
			SELECT @REMAINING_STRING INTO @TEMP_FILETEMPLATE_CHECK_FLAG;

			IF(FILETEMPLATECHECKFLAG='') THEN
				SET FILETEMPLATECHECKFLAG = NULL;
			END IF;
			
			IF SEARCH_OPTION=1 THEN
			
				IF NOT EXISTS(SELECT FT_ID FROM LCE_TENDER_FILE_TEMPLATE_DETAILS WHERE TM_ID=TMID AND FT_ID=FILETEMPLATEID)THEN
				
					INSERT INTO LCE_TENDER_FILE_TEMPLATE_DETAILS(TM_ID,FT_ID,TFTD_FLAG,ULD_ID) VALUES
					(TMID,FILETEMPLATEID,FILETEMPLATECHECKFLAG,USERSTAMP_ID);
					SET SUCCESSFLAG = 1;
					
				END IF;
				
			END IF;

			IF SEARCH_OPTION=2 THEN
			
				IF NOT EXISTS(SELECT FT_ID FROM LCE_TENDER_FILE_TEMPLATE_DETAILS WHERE TM_ID=TMID AND FT_ID=FILETEMPLATEID)THEN
				
					INSERT INTO LCE_TENDER_FILE_TEMPLATE_DETAILS(TM_ID,FT_ID,TFTD_FLAG,ULD_ID) VALUES
					(TMID,FILETEMPLATEID,FILETEMPLATECHECKFLAG,USERSTAMP_ID);
					SET SUCCESSFLAG = 1;
					
				END IF;
				
			END IF;

			IF(@TEMP_FILETEMPLATE_ID IS NULL) THEN 
				LEAVE  MAIN_LOOP;
			END IF;

		END LOOP;

	END IF;

	COMMIT;

END;

/*

CALL SP_LCE_TENDER_FILE_TEMPLATE_DETAILS_INSERT(1,'1,2,3,4,5',' ,X, ,X, ','ADMIN',@SUCCESSFLAG);
SELECT @SUCCESSFLAG;

*/