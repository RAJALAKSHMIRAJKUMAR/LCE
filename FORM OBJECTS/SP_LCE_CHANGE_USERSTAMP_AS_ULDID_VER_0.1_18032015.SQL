-- VER0.1 DATE:18/03/2015  DESC:SP FOR CONVERTING USERSTAMP AS ULD_ID done by:RL

DROP PROCEDURE IF EXISTS SP_LCE_CHANGE_USERSTAMP_AS_ULDID;
CREATE PROCEDURE SP_LCE_CHANGE_USERSTAMP_AS_ULDID(
IN USERSTAMP VARCHAR(50),
OUT ULDID INTEGER)
BEGIN
    SET ULDID = (SELECT ULD_ID FROM LCE_USER_MANAGEMENT WHERE ULD_USERNAME = USERSTAMP);
END;