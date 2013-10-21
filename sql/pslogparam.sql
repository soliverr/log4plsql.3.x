/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE
PACKAGE PLOGPARAM IS
/** 
*  package name : PLOGPARAM                                                       
*<br/>
*<br/>
*See : <a href="http://log4plsql.sourceforge.net">http://log4plsql.sourceforge.net</a>                                 
*<br/>
*<br/>
*Objectif : Store updatable paramter for PLOG.                             
*<br/><br/><br/><br/>
* This package is create befort PLOG
*<br/><br/><br/>
*
*
*@headcom 
*<br/>
*<br/>                                                                         
*<br/>
*History who               date     comment
*V3     Guillaume Moulard 05-AUG-03 Creation      
*V3.2     Greg Woolsey      29-MAR-04 add MDC (Mapped Domain Context) Feature     
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
 


-------------------------------------------------------------------
-- Constants (tools general parameter) 
-- you can update regard your context
-------------------------------------------------------------------

-- LERROR default level for production system.
-- DEFAULT_LEVEL         CONSTANT TLOG.LLEVEL%type     := 30 ; -- LERROR  
-- LDEBUG for developement phase
DEFAULT_LEVEL         CONSTANT TLOG.LLEVEL%type     := 30 ; -- LERROR

-- TRUE default value for Logging in table
DEFAULT_LOG_TABLE     CONSTANT BOOLEAN              := TRUE;     
 
-- if DEFAULT_USE_LOG4J is TRUE log4j Log4JbackgroundProcess are necessary
DEFAULT_USE_LOG4J     CONSTANT BOOLEAN              := FALSE;    

-- TRUE default value for Logging out off transactional limits
DEFAULT_LOG_OUT_TRANS CONSTANT BOOLEAN              := TRUE;     

-- if DEFAULT_LOG_ALERTLOG is true the log is write in alert.log file
DEFAULT_LOG_ALERT     CONSTANT BOOLEAN              := FALSE;  
  
-- if DEFAULT_LOG_TRACE is true the log is write in trace file
DEFAULT_LOG_TRACE     CONSTANT BOOLEAN              := FALSE;    

-- if DEFAULT_DBMS_OUTPUT is true the log is send in standard output (DBMS_OUTPUT.PUT_LINE)
DEFAULT_DBMS_OUTPUT   CONSTANT BOOLEAN              := FALSE;    

  
-- default level for asset 
DEFAULT_ASSET_LEVEL   CONSTANT TLOG.LLEVEL%type            := DEFAULT_LEVEL ;  

-- default level for call_stack_level 
DEFAULT_FULL_CALL_STACK_LEVEL CONSTANT  TLOG.LLEVEL%type   := DEFAULT_LEVEL ;  

-- use for build a string section                                                            
DEFAULT_Section_sep CONSTANT TLOG.LSECTION%type := '.';          

-- default PIPE_NAME
DEFAULT_DBMS_PIPE_NAME CONSTANT VARCHAR2(255) := 'LOG_PIPE';            
  
-- Formats output sent to DBMS_OUTPUT to this width. 
DEFAULT_DBMS_OUTPUT_LINE_WRAP  CONSTANT NUMBER := 100; 

END PLOGPARAM;
/
/*<TOAD_FILE_CHUNK>*/
-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------


