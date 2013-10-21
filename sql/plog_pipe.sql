/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PLOG_PIPE
AS

/**
*  package name : PMDC                                                       
*<br/>
*<br/>
*See : <a href="http://log4plsql.sourceforge.net">http://log4plsql.sourceforge.net</a>                                 
*<br/>
*<br/>
* Read the next message from the given or default pipe, and return each <br/>
* Log4PlSql message component as an OUT variable.  Wait the specified number <br/>
* of seconds before timing out.<br/>
* <br/>
* @param pTIMEOUT			IN		NUMBER seconds to wait for the next pipe message<br/>
* @param pID         		OUT	log message sequence number <br/>
* @param pLDATE      		OUT	date the message was logged, as a DATE <br/>
* @param pLHSECS     		OUT	hundredths of seconds for the pLDATE parameter<br/>
* @param pLLEVEL     		OUT	Level code (number) of the message<br/>
* @param pLSECTION   		OUT	log section<br/>
* @param pLUSER      		OUT	user schema the log message originated from <br/>
* @param pCOMMAND    		OUT	Log4PlSql command - only one value, currently <br/>
* @param pLTEXTE     		OUT	Message text<br/>
* @param pMDC_KEYS	 		OUT	delimited string of MDC keys<br/>
* @param pMDC_VALUES 		OUT	delimited string of MDC values<br/>
* @param pMDC_SEPARATOR	OUT	delimiter for MDC strings<br/>
* @param pPIPE_NAME			IN		VARCHAR2 DEFAULT PLOGPARAM.DEFAULT_DBMS_PIPE_NAME<br/>
* <br/>
* @return the return code from DBMS_PIPE.RECEIVE_MESSAGE.
*
*History who               date     comment
*V1     Greg Woolsey      29-MAR-04 add MDC (Mapped Domain Context) Feature
*<br/>
*<br/>
* Copyright (C) LOG4PLSQL project team. All rights reserved.<br/>
*<br/>
* This software is published under the terms of the The LOG4PLSQL <br/>
* Software License, a copy of which has been included with this<br/>
* distribution in the LICENSE.txt file.  <br/>
* see: <http://log4plsql.sourceforge.net>  <br/><br/>
* 
*/


FUNCTION READ_MESSAGE(
    pTIMEOUT			IN		NUMBER                           ,
    pID         		OUT	TLOG.ID%type                     ,
    pLDATE      		OUT	TLOG.LDATE%type                  ,
    pLHSECS     		OUT	TLOG.LHSECS%type                 ,
    pLLEVEL     		OUT	TLOG.LLEVEL%type                 ,
    pLSECTION   		OUT	TLOG.LSECTION%type               ,
    pLUSER      		OUT	TLOG.LUSER%type                  ,
	 pCOMMAND    		OUT	VARCHAR2									,
    pLTEXTE     		OUT	TLOG.LTEXTE%type						,
	 pMDC_KEYS	 		OUT	VARCHAR2									,
	 pMDC_VALUES 		OUT	VARCHAR2									,
	 pMDC_SEPARATOR	OUT	VARCHAR2									,
	 pPIPE_NAME			IN		VARCHAR2 DEFAULT PLOGPARAM.DEFAULT_DBMS_PIPE_NAME
) RETURN NUMBER;



END PLOG_PIPE;
/
/*<TOAD_FILE_CHUNK>*/

CREATE OR REPLACE PACKAGE BODY PLOG_PIPE
AS




-------------------------------------------------------------------
--
--  Nom package        : PLOG_PIPE
--
--  Objectif           : MDC Features
--
--  Version            : 1.0
-------------------------------------------------------------------
-- see package spec for history
-------------------------------------------------------------------

/*
 * Copyright (C) LOG4PLSQL project team. All rights reserved.
 *
 * This software is published under the terms of the The LOG4PLSQL 
 * Software License, a copy of which has been included with this
 * distribution in the LICENSE.txt file.  
 * see: <http://log4plsql.sourceforge.net>  */
 
-------------------------------------------------------------------



/**
Return log line data from the current pipe. 
The return value is the DBMS_PIPE.receive_message return value.
0 = success
1 = timeout (no message in pTIMEOUT seconds) 
3 = interrupt (don't know when that could happen - session killed?) 
 */
FUNCTION READ_MESSAGE(
    pTIMEOUT			IN		NUMBER                           ,
    pID         		OUT	TLOG.ID%type                     ,
    pLDATE      		OUT	TLOG.LDATE%type                  ,
    pLHSECS     		OUT	TLOG.LHSECS%type                 ,
    pLLEVEL     		OUT	TLOG.LLEVEL%type                 ,
    pLSECTION   		OUT	TLOG.LSECTION%type               ,
    pLUSER      		OUT	TLOG.LUSER%type                  ,
	 pCOMMAND    		OUT	VARCHAR2									,
    pLTEXTE     		OUT	TLOG.LTEXTE%type						,
	 pMDC_KEYS	 		OUT	VARCHAR2									,
	 pMDC_VALUES 		OUT	VARCHAR2									,
	 pMDC_SEPARATOR	OUT	VARCHAR2									,
	 pPIPE_NAME			IN		VARCHAR2 DEFAULT PLOGPARAM.DEFAULT_DBMS_PIPE_NAME
) RETURN NUMBER IS
	retval INTEGER;
	nextItemType INTEGER;
	tmp NUMBER;
	vPIPE_NAME varchar2(128) := pPIPE_NAME;
BEGIN
	if vPIPE_NAME is null then vPIPE_NAME := PLOGPARAM.DEFAULT_DBMS_PIPE_NAME; end if;
	
	retval := DBMS_PIPE.receive_message(vPIPE_NAME, pTIMEOUT);
	
	IF retval = 0 THEN
		DBMS_PIPE.unpack_message(pID);
		DBMS_PIPE.unpack_message(pLDATE);
		DBMS_PIPE.unpack_message(pLHSECS);
		DBMS_PIPE.unpack_message(pLLEVEL);
		DBMS_PIPE.unpack_message(pLSECTION);
		DBMS_PIPE.unpack_message(pLTEXTE);
		DBMS_PIPE.unpack_message(pLUSER);
		DBMS_PIPE.unpack_message(pCOMMAND);
		DBMS_PIPE.unpack_message(pMDC_KEYS);
		DBMS_PIPE.unpack_message(pMDC_VALUES);
		DBMS_PIPE.unpack_message(pMDC_SEPARATOR);
	END IF;
	
	RETURN retval; 
END READ_MESSAGE;

END PLOG_PIPE;
/
