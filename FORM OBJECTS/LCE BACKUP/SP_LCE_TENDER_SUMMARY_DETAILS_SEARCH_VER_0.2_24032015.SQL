-- VER0.2 DATE:24/03/2015 DESC:ADDED SUBITEM,SUBITEM SNO IN MAIN TABLE done by:RL
-- VER0.1 DATE:23/03/2015 DESC:SP TO SHOW ALL TENDER ITEMS FOR A PROJECT done by:RL

DROP PROCEDURE IF EXISTS SP_LCE_TENDER_SUMMARY_DETAILS_SEARCH;
CREATE PROCEDURE SP_LCE_TENDER_SUMMARY_DETAILS_SEARCH(
IN TMID INTEGER,
IN USERSTAMP VARCHAR(50),
OUT FINALTABLENAME TEXT)

BEGIN

-- VARIABLE DECLARATION
	DECLARE USERSTAMP_ID INTEGER;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);

-- VARIABLE DECLARATION FOR TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS
	DECLARE TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS TEXT;

-- VARIABLE DECLARATION FOR TEMP_LCE_TENDER_MAIN_ITEM_DTLS
	DECLARE TEMP_LCE_TENDER_MAIN_ITEM_DTLS TEXT;
	DECLARE MAINITEM_MINID INTEGER;
	DECLARE MAINITEM_MAXID INTEGER;
	DECLARE TENDER_MAIN_ITEMID INTEGER;
	DECLARE MI_MIN_ID INTEGER;
	DECLARE MI_MAX_ID INTEGER;
	DECLARE MAINITEM_FINALMINID INTEGER;

-- VARIABLE DECLARATION FOR TEMP_LCE_TENDER_SUB_ITEM_DTLS
	DECLARE TEMP_LCE_TENDER_SUB_ITEM_DTLS TEXT;
	DECLARE SUBITEM_MINID INTEGER;
	DECLARE SUBITEM_MAXID INTEGER;
	DECLARE TENDER_SUB_ITEMID INTEGER;
	DECLARE SI_MIN_ID INTEGER;
	DECLARE SI_MAX_ID INTEGER;
	DECLARE SUBITEM_FINALMINID INTEGER;

-- VARIABLE DECLARATION FOR TEMP_LCE_TENDER_SUB_SNO_DTLS
	DECLARE TEMP_LCE_TENDER_SUB_SNO_DTLS TEXT;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE TENDER_SUB_ITEM_SNO INTEGER;
	DECLARE SI_SNO_MIN_ID INTEGER;
	DECLARE SI_SNO_MAX_ID INTEGER;
	DECLARE SUB_SNO_FINALMINIMUMID INTEGER;

-- QUERY FOR ROLLBACK COMMAND
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
		IF(TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS IS NOT NULL) THEN
			SET @DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS));
			PREPARE DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS;
			EXECUTE DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT;
		END IF;
		IF(TEMP_LCE_TENDER_MAIN_ITEM_DTLS IS NOT NULL) THEN
			SET @DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_MAIN_ITEM_DTLS,''));
			PREPARE DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS;
			EXECUTE DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT;
		END IF;
		IF(TEMP_LCE_TENDER_SUB_ITEM_DTLS IS NOT NULL) THEN
			SET @DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_SUB_ITEM_DTLS,''));
			PREPARE DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS;
			EXECUTE DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT;
		END IF;
		IF(TEMP_LCE_TENDER_SUB_SNO_DTLS IS NOT NULL) THEN
			SET @DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_SUB_SNO_DTLS,''));
			PREPARE DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS;
			EXECUTE DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT;
		END IF;	
	END;
	
	START TRANSACTION;

-- SUB SP FOR CONVERTING USERSTAMP INTO ULDID
	CALL SP_LCE_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULD_ID);
	SET USERSTAMP_ID=@ULD_ID;

-- QUERY FOR CONCAT ULDID & SYSDATETIME
	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));

-- QUERY FOR CREATE TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS TABLE
	SET TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS=(SELECT CONCAT('TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS','_',SYSDATEANDULDID));

	SET @CREATE_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS=(SELECT CONCAT('CREATE TABLE ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,'(
	ID INTEGER NOT NULL AUTO_INCREMENT,
	IPD_ID INTEGER,
	TI_ID INTEGER,
	TI_ITEMS VARCHAR(300),
	TSI_ID INTEGER,
	TSI_SNO	VARCHAR(10),
	SUBITEM_SNO VARCHAR(10),
	TSI_ITEMS VARCHAR(300),
	TMD_ID INTEGER,
	TMD_SNO	VARCHAR(10),
	TMD_DESCRIPTION	TEXT,
	TMD_QUANTITY INTEGER,
	TMD_UNIT_RATE DECIMAL(7,2),
	TMD_CPF	DECIMAL(7,2),
	TMD_MATERIAL_COST DECIMAL(7,2),
	TMD_WIRING_COST	DECIMAL(7,2),
	TMD_LABOUR_COST	DECIMAL(7,2),
	PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT FROM @CREATE_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS;
	EXECUTE CREATE_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT;

-- QUERY FOR INSERT VALUES IN TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS TABLE
	SET @INSERT_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS = (SELECT CONCAT('INSERT INTO ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,'
	(IPD_ID,TI_ID,TI_ITEMS,TSI_ID,TSI_SNO,SUBITEM_SNO,TSI_ITEMS,TMD_ID,TMD_SNO,TMD_DESCRIPTION,TMD_QUANTITY,
	TMD_UNIT_RATE,TMD_CPF,TMD_MATERIAL_COST,TMD_WIRING_COST,TMD_LABOUR_COST) 
	SELECT TMD.IPD_ID,IPD.TI_ID,TI.TI_ITEMS,IPD.TSI_ID,TSI.TSI_SNO,TSI.TSI_SNO,TSI.TSI_ITEMS,TMD.TMD_ID,TMD.TMD_SNO,
	TMD.TMD_DESCRIPTION,TMD.TMD_QUANTITY,TMD.TMD_UNIT_RATE,TMD.TMD_CPF,TMD.TMD_MATERIAL_COST,
	TMD.TMD_WIRING_COST,TMD.TMD_LABOUR_COST FROM LCE_TENDER_SUMMARY_DETAILS TMD,LCE_ITEM_PRICE_DETAILS IPD,
	LCE_TENDER_ITEMS TI,LCE_TENDER_SUB_ITEMS TSI WHERE TMD.TM_ID=',TMID,' AND TMD.IPD_ID=IPD.IPD_ID AND 
	IPD.TI_ID=TI.TI_ID AND IPD.TSI_ID=TSI.TSI_ID ORDER BY TI.TI_ID,TI.TI_ITEMS,TMD.TMD_SNO ASC'));
	PREPARE INSERT_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT FROM @INSERT_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS;
	EXECUTE INSERT_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT;

-- QUERY FOR CREATE TEMP_LCE_TENDER_MAIN_ITEM_DTLS TABLE
	SET TEMP_LCE_TENDER_MAIN_ITEM_DTLS=(SELECT CONCAT('TEMP_LCE_TENDER_MAIN_ITEM_DTLS','_',SYSDATEANDULDID));

	SET @CREATE_TEMP_LCE_TENDER_MAIN_ITEM_DTLS = (SELECT CONCAT('CREATE TABLE ',TEMP_LCE_TENDER_MAIN_ITEM_DTLS,' (
	ID INTEGER NOT NULL AUTO_INCREMENT,
	TI_ID INTEGER,
	PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT FROM @CREATE_TEMP_LCE_TENDER_MAIN_ITEM_DTLS;
	EXECUTE CREATE_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT;

	SET @INSERT_TEMP_LCE_TENDER_MAIN_ITEM_DTLS = (SELECT CONCAT('INSERT INTO ',TEMP_LCE_TENDER_MAIN_ITEM_DTLS,' (TI_ID)
	SELECT DISTINCT(TI_ID) FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,''));
	PREPARE INSERT_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT FROM @INSERT_TEMP_LCE_TENDER_MAIN_ITEM_DTLS;
	EXECUTE INSERT_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT;

-- QUERY TO UPDATE TI_ITEMS =""
	SET @MAIN_ITEM_MIN_ID = (SELECT CONCAT('SELECT MIN(ID) INTO @MAIN_ITEM_MINID FROM ',TEMP_LCE_TENDER_MAIN_ITEM_DTLS,''));
	PREPARE MAIN_ITEM_MIN_ID_STMT FROM @MAIN_ITEM_MIN_ID;
	EXECUTE MAIN_ITEM_MIN_ID_STMT;

	SET @MAIN_ITEM_MAX_ID = (SELECT CONCAT('SELECT MAX(ID) INTO @MAIN_ITEM_MAXID FROM ',TEMP_LCE_TENDER_MAIN_ITEM_DTLS,''));
	PREPARE MAIN_ITEM_MAX_ID_STMT FROM @MAIN_ITEM_MAX_ID;
	EXECUTE MAIN_ITEM_MAX_ID_STMT;

	SET MAINITEM_MINID = @MAIN_ITEM_MINID;
	SET MAINITEM_MAXID = @MAIN_ITEM_MAXID;

	WHILE(MAINITEM_MINID <= MAINITEM_MAXID) DO 

		SET @TENDERMAINITEMID = (SELECT CONCAT('SELECT TI_ID INTO @TENDER_MAINITEMID FROM ',TEMP_LCE_TENDER_MAIN_ITEM_DTLS,' 
		WHERE ID = ',MAINITEM_MINID,''));
		PREPARE TENDERMAINITEMID_STMT FROM @TENDERMAINITEMID;
		EXECUTE TENDERMAINITEMID_STMT;

		SET TENDER_MAIN_ITEMID = @TENDER_MAINITEMID;

		SET @MIMINID = (SELECT CONCAT('SELECT MIN(ID) INTO @MI_MINID FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' 
		WHERE TI_ID = ',TENDER_MAIN_ITEMID,''));
		PREPARE MIMINID_STMT FROM @MIMINID;
		EXECUTE MIMINID_STMT;

		SET @MIMAXID = (SELECT CONCAT('SELECT MAX(ID) INTO @MI_MAXID FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' 
		WHERE TI_ID = ',TENDER_MAIN_ITEMID,''));
		PREPARE MIMAXID_STMT FROM @MIMAXID;
		EXECUTE MIMAXID_STMT;

		SET MI_MIN_ID = @MI_MINID;
		SET MI_MAX_ID = @MI_MAXID;
		SET MAINITEM_FINALMINID = MI_MIN_ID+1;

		SET @UPDATEQUERY = (SELECT CONCAT('UPDATE ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' SET TI_ITEMS=""
		WHERE ID BETWEEN ',MAINITEM_FINALMINID,' AND ',MI_MAX_ID,''));
		PREPARE UPDATEQUERY_STMT FROM @UPDATEQUERY;
		EXECUTE UPDATEQUERY_STMT;

		SET MAINITEM_MINID = MAINITEM_MINID+1;

	END WHILE;

-- QUERY FOR CREATE TEMP_LCE_TENDER_SUB_ITEM_DTLS TABLE
	SET TEMP_LCE_TENDER_SUB_ITEM_DTLS = (SELECT CONCAT('TEMP_LCE_TENDER_SUB_ITEM_DTLS','_',SYSDATEANDULDID));

	SET @CREATE_TEMP_LCE_TENDER_SUB_ITEM_DTLS = (SELECT CONCAT('CREATE TABLE ',TEMP_LCE_TENDER_SUB_ITEM_DTLS,' (
	ID INTEGER NOT NULL AUTO_INCREMENT,
	TSI_ID INTEGER,
	PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT FROM @CREATE_TEMP_LCE_TENDER_SUB_ITEM_DTLS;
	EXECUTE CREATE_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT;

	SET @INSERT_TEMP_LCE_TENDER_SUB_ITEM_DTLS = (SELECT CONCAT('INSERT INTO ',TEMP_LCE_TENDER_SUB_ITEM_DTLS,' (TSI_ID)
	SELECT DISTINCT(TSI_ID) FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' WHERE TSI_ITEMS IS NOT NULL'));
	PREPARE INSERT_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT FROM @INSERT_TEMP_LCE_TENDER_SUB_ITEM_DTLS;
	EXECUTE INSERT_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT;

-- QUERY FOR UPDATE TSI_ITEMS=""
	SET @SUB_ITEM_MIN_ID = (SELECT CONCAT('SELECT MIN(ID) INTO @SUB_ITEM_MINID FROM ',TEMP_LCE_TENDER_SUB_ITEM_DTLS,''));
	PREPARE SUB_ITEM_MIN_ID_STMT FROM @SUB_ITEM_MIN_ID;
	EXECUTE SUB_ITEM_MIN_ID_STMT;

	SET @SUB_ITEM_MAX_ID = (SELECT CONCAT('SELECT MAX(ID) INTO @SUB_ITEM_MAXID FROM ',TEMP_LCE_TENDER_SUB_ITEM_DTLS,''));
	PREPARE SUB_ITEM_MAX_ID_STMT FROM @SUB_ITEM_MAX_ID;
	EXECUTE SUB_ITEM_MAX_ID_STMT;

	SET SUBITEM_MINID = @SUB_ITEM_MINID;
	SET SUBITEM_MAXID = @SUB_ITEM_MAXID;

	WHILE(SUBITEM_MINID <= SUBITEM_MAXID) DO 

		SET @TENDERSUBITEMID = (SELECT CONCAT('SELECT TSI_ID INTO @TENDERSUB_ITEMID FROM ',TEMP_LCE_TENDER_SUB_ITEM_DTLS,' 
		WHERE ID = ',SUBITEM_MINID,''));
		PREPARE TENDERSUBITEMID_STMT FROM @TENDERSUBITEMID;
		EXECUTE TENDERSUBITEMID_STMT;

		SET TENDER_SUB_ITEMID = @TENDERSUB_ITEMID;

		SET @SIMINID = (SELECT CONCAT('SELECT MIN(ID) INTO @SI_MINID FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' 
		WHERE TSI_ID = ',TENDER_SUB_ITEMID,''));
		PREPARE SIMINID_STMT FROM @SIMINID;
		EXECUTE SIMINID_STMT;

		SET @SIMAXID = (SELECT CONCAT('SELECT MAX(ID) INTO @SI_MAXID FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' 
		WHERE TSI_ID = ',TENDER_SUB_ITEMID,''));
		PREPARE SIMAXID_STMT FROM @SIMAXID;
		EXECUTE SIMAXID_STMT;

		SET SI_MIN_ID = @SI_MINID;
		SET SI_MAX_ID = @SI_MAXID;
		SET SUBITEM_FINALMINID = SI_MIN_ID+1;

		SET @SUBITEM_UPDATEQUERY = (SELECT CONCAT('UPDATE ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' SET TSI_ITEMS=""
		WHERE ID BETWEEN ',SUBITEM_FINALMINID,' AND ',SI_MAX_ID,''));
		PREPARE SUBITEM_UPDATEQUERY_STMT FROM @SUBITEM_UPDATEQUERY;
		EXECUTE SUBITEM_UPDATEQUERY_STMT;

		SET SUBITEM_MINID = SUBITEM_MINID+1;

	END WHILE;

-- QUERY FOR CREATE TEMP_LCE_TENDER_SUB_SNO_DTLS TABLE
	SET TEMP_LCE_TENDER_SUB_SNO_DTLS = (SELECT CONCAT('TEMP_LCE_TENDER_SUB_SNO_DTLS','_',SYSDATEANDULDID));

	SET @CREATE_TEMP_LCE_TENDER_SUB_SNO_DTLS = (SELECT CONCAT('CREATE TABLE ',TEMP_LCE_TENDER_SUB_SNO_DTLS,' (
	ID INTEGER NOT NULL AUTO_INCREMENT,
	TSI_ID INTEGER,
	PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT FROM @CREATE_TEMP_LCE_TENDER_SUB_SNO_DTLS;
	EXECUTE CREATE_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT;

	SET @INSERT_TEMP_LCE_TENDER_SUB_SNO_DTLS = (SELECT CONCAT('INSERT INTO ',TEMP_LCE_TENDER_SUB_SNO_DTLS,' (TSI_ID)
	SELECT DISTINCT(TSI_ID) FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,''));
	PREPARE INSERT_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT FROM @INSERT_TEMP_LCE_TENDER_SUB_SNO_DTLS;
	EXECUTE INSERT_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT;

-- QUERY FOR UPDATE SUBITEM_SNO=""
	SET @SUB_NO_MINIMUM_ID = (SELECT CONCAT('SELECT MIN(ID) INTO @SI_SNO_MINID FROM ',TEMP_LCE_TENDER_SUB_SNO_DTLS,''));
	PREPARE SUB_NO_MINIMUM_ID_STMT FROM @SUB_NO_MINIMUM_ID;
	EXECUTE SUB_NO_MINIMUM_ID_STMT;

	SET @SUB_NO_MAX_ID = (SELECT CONCAT('SELECT MAX(ID) INTO @SI_SNO_MAXID FROM ',TEMP_LCE_TENDER_SUB_SNO_DTLS,''));
	PREPARE SUB_NO_MAX_ID_STMT FROM @SUB_NO_MAX_ID;
	EXECUTE SUB_NO_MAX_ID_STMT;

	SET SI_SNO_MIN_ID = @SI_SNO_MINID;
	SET SI_SNO_MAX_ID = @SI_SNO_MAXID;

	WHILE(SI_SNO_MIN_ID <= SI_SNO_MAX_ID) DO 

		SET @TENDERSUBITEMSNO = (SELECT CONCAT('SELECT TSI_ID INTO @TENDERSUB_ITEMSNO FROM ',TEMP_LCE_TENDER_SUB_SNO_DTLS,' 
		WHERE ID = ',SI_SNO_MIN_ID,''));
		PREPARE TENDERSUBITEMSNO_STMT FROM @TENDERSUBITEMSNO;
		EXECUTE TENDERSUBITEMSNO_STMT;

		SET TENDER_SUB_ITEM_SNO = @TENDERSUB_ITEMSNO;

		SET @SI_SNOMINID = (SELECT CONCAT('SELECT MIN(ID) INTO @SISNOMINID FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' 
		WHERE TSI_ID = ',TENDER_SUB_ITEM_SNO,''));
		PREPARE SI_SNOMINID_STMT FROM @SI_SNOMINID;
		EXECUTE SI_SNOMINID_STMT;

		SET @SI_SNOMAXID = (SELECT CONCAT('SELECT MAX(ID) INTO @SISNOMAXID FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' 
		WHERE TSI_ID = ',TENDER_SUB_ITEM_SNO,''));
		PREPARE SI_SNOMAXID_STMT FROM @SI_SNOMAXID;
		EXECUTE SI_SNOMAXID_STMT;

		SET MINID = @SISNOMINID;
		SET MAXID = @SISNOMAXID;
		SET SUB_SNO_FINALMINIMUMID = MINID+1;

		SET @SUBITEM_SNO_UPDATEQUERY = (SELECT CONCAT('UPDATE ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' SET SUBITEM_SNO=""
		WHERE ID BETWEEN ',SUB_SNO_FINALMINIMUMID,' AND ',MAXID,''));
		PREPARE SUBITEM_SNO_UPDATEQUERY_STMT FROM @SUBITEM_SNO_UPDATEQUERY;
		EXECUTE SUBITEM_SNO_UPDATEQUERY_STMT;

		SET SI_SNO_MIN_ID = SI_SNO_MIN_ID+1;

	END WHILE;

-- -- QUERY FOR UPDATE TSI_ITEMS="" WHERE TSI_ITEMS IS NULL
	SET @UPDATE_QUERY = (SELECT CONCAT('UPDATE ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' SET TSI_ITEMS=""
	WHERE TSI_ITEMS IS NULL'));
	PREPARE UPDATE_QUERY_STMT FROM @UPDATE_QUERY;
	EXECUTE UPDATE_QUERY_STMT;

	SET @UPDATE_TSI_SNO = (SELECT CONCAT('UPDATE ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,' SET TSI_SNO=""
	WHERE TSI_ITEMS="" '));
	PREPARE UPDATE_TSI_SNO_STMT FROM @UPDATE_TSI_SNO;
	EXECUTE UPDATE_TSI_SNO_STMT;

-- QUERY FOR CREATE,INSERT VALUES IN MAIN TEMP TABLE
	SET FINALTABLENAME=(SELECT CONCAT('TEMP_LCE_TENDER_SUMMARY_DETAILS','_',SYSDATEANDULDID));

	SET @CREATE_FINALTABLENAME=(SELECT CONCAT('CREATE TABLE ',FINALTABLENAME,'(
	ID INTEGER NOT NULL AUTO_INCREMENT,
	IPD_ID INTEGER,
	TI_ID INTEGER,
	TI_ITEMS VARCHAR(300),
	TSI_SNO	VARCHAR(10),
	SUBITEM_SNO VARCHAR(10),
	TSI_ITEMS VARCHAR(300),
	TMD_SNO	VARCHAR(10),
	TMD_DESCRIPTION	TEXT,
	TMD_QUANTITY INTEGER,
	TMD_UNIT_RATE DECIMAL(7,2),
	TMD_CPF	DECIMAL(7,2),
	TMD_MATERIAL_COST DECIMAL(7,2),
	TMD_WIRING_COST	DECIMAL(7,2),
	TMD_LABOUR_COST	DECIMAL(7,2),
	PRIMARY KEY(ID))'));
	PREPARE CREATE_FINALTABLENAME_STMT FROM @CREATE_FINALTABLENAME;
	EXECUTE CREATE_FINALTABLENAME_STMT;

	SET @INSERT_FINALTABLENAME = (SELECT CONCAT('INSERT INTO ',FINALTABLENAME,' (IPD_ID,TI_ID,TI_ITEMS,TSI_SNO,SUBITEM_SNO,TSI_ITEMS,
	TMD_SNO,TMD_DESCRIPTION,TMD_QUANTITY,TMD_UNIT_RATE,TMD_CPF,TMD_MATERIAL_COST,TMD_WIRING_COST,TMD_LABOUR_COST)
	SELECT IPD_ID,TI_ID,TI_ITEMS,TSI_SNO,SUBITEM_SNO,TSI_ITEMS,TMD_SNO,TMD_DESCRIPTION,TMD_QUANTITY,TMD_UNIT_RATE,TMD_CPF,
	TMD_MATERIAL_COST,TMD_WIRING_COST,TMD_LABOUR_COST FROM ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS,''));
	PREPARE INSERT_FINALTABLENAME_STMT FROM @INSERT_FINALTABLENAME;
	EXECUTE INSERT_FINALTABLENAME_STMT;

	IF(TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS IS NOT NULL) THEN
		SET @DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS));
		PREPARE DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS;
		EXECUTE DROP_TEMP_LCE_TENDER_MAIN_SUB_ITEM_DTLS_STMT;
	END IF;

	IF(TEMP_LCE_TENDER_MAIN_ITEM_DTLS IS NOT NULL) THEN
		SET @DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_MAIN_ITEM_DTLS,''));
		PREPARE DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS;
		EXECUTE DROP_TEMP_LCE_TENDER_MAIN_ITEM_DTLS_STMT;
	END IF;

	IF(TEMP_LCE_TENDER_SUB_ITEM_DTLS IS NOT NULL) THEN
		SET @DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_SUB_ITEM_DTLS,''));
		PREPARE DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS;
		EXECUTE DROP_TEMP_LCE_TENDER_SUB_ITEM_DTLS_STMT;
	END IF;

	IF(TEMP_LCE_TENDER_SUB_SNO_DTLS IS NOT NULL) THEN
		SET @DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_LCE_TENDER_SUB_SNO_DTLS,''));
		PREPARE DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT FROM @DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS;
		EXECUTE DROP_TEMP_LCE_TENDER_SUB_SNO_DTLS_STMT;
	END IF;	

	COMMIT;

END;

/*

CALL SP_LCE_TENDER_SUMMARY_DETAILS_SEARCH(1,'admin',@FINALTABLENAME);
select @FINALTABLENAME

*/