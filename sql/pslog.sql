CREATE OR REPLACE 
PACKAGE PLOG IS
/** 
*  package name : PLOG                                                       
*<br/>
*<br/>
*See : <a href="http://log4plsql.sourceforge.net">http://log4plsql.sourceforge.net</a>                                 
*<br/>
*<br/>
*Objectif : Generic tool of log in a Oracle database                      
*same prototype and functionality that log4j.                             
*<a href="http://jakarta.apache.org/log4j">http://jakarta.apache.org/log4j </a>                                        
*<br/><br/><br/>
*<b> for exemple and documentation See: http://log4plsql.sourceforge.net/docs/UserGuide.html</b>
*
* Default table of log level
* 1 The OFF has the highest possible rank and is intended to turn off logging. <BR/>
* 2 The FATAL level designates very severe error events that will presumably lead the application to abort.<BR/>
* 3 The ERROR level designates error events that might still allow the application  to continue running.<BR/>
* 4 The WARN level designates potentially harmful situations.<BR/>
* 5 The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.<BR/>
* 6 The DEBUG Level designates fine-grained informational events that are most useful to debug an application.<BR/>
* 7 The ALL has the lowest possible rank and is intended to turn on all logging.<BR/>
*
*
*<br/><br/><br/><br/>
*All data is store in TLOG table<br/>
* ID         number,<br/>
* LDate      DATE default sysdate,<br/>
* LHSECS     number,<br/>
* LLEVEL     number,<br/>
* LSECTION   varchar2(2000),<br/>
* LTEXTE     varchar2(2000),<br/>
* LUSER      VARCHAR2(30),<br/>
* CONSTRAINT pk_TLOG PRIMARY KEY (id)<br/>
*<br/><br/><br/>
*
*
*@headcom 
*<br/>
*<br/>                                                                         
*<br/>
*History who               date     comment
*V0     Guillaume Moulard 08-AVR-98 Creation           
*V1     Guillaume Moulard 16-AVR-02 Add DBMS_PIPE funtionnality
*V1.1   Guillaume Moulard 16-AVR-02 Increase a date log precision for bench user hundredths of seconds of V$TIMER
*V2.0   Guillaume Moulard 07-MAY-02 Extend call prototype for more by add a default value                  
*V2.1   Guillaume Moulard 07-MAY-02 optimisation for purge process
*V2.1.1 Guillaume Moulard 22-NOV-02 patch bug length message identify by Lu Cheng
*V2.2   Guillaume Moulard 23-APR-03 use automuns_transaction use Dan Catalin proposition
*V2.3   Guillaume Moulard 30-APR-03 Add is[Debug|Info|Warn|Error]Enabled requested by Dan Catalin
*V2.3.1 jan-pieter        27-JUN-03 supp to_char(to_char line ( line 219 )
*V3     Guillaume Moulard 05-AUG-03 *update default value of PLOGPARAM.DEFAULT_LEVEL -> DEBUG
*                                   *new: log in alert.log, trace file (thank to andreAs for information)
*                                   *new: log with DBMS_OUTPUT (Wait -> SET SERVEROUTPUT ON) 
*                                   *new: log full_call_stack
*                                   *upd: now is possible to log in table and in log4j
*                                   *upd: ctx and init funtion parameter.  
*                                   *new: getLOG4PLSQVersion return string Version
*                   * use dynamique *upd: create of PLOGPARAM for updatable parameter
*                                   *new: getLevelInText return the text level for one level
*                                   **************************************************************
*                                   I read a very interesting article write by Steven Feuerstein 
*                                   - Handling Exceptional Behavior - 
*                                   this 2 new features is inspired direcly by this article
*                                   **************************************************************
*                                   * new: assert procedure
*                                   * new: new procedure error prototype from log SQLCODE and SQLERRM
*V3.1   Guillaume Moulard 23-DEC-03 add functions for customize the log level
*V3.1.1 Guillaume Moulard 29-JAN-04 increase perf : propose by Detlef 
*V3.1.2 Guillaume Moulard 02-FEV-04 *new: Log4JbackgroundProcess create a thread for each database connexion 
*V3.1.2 Guillaume Moulard 02-FEV-04 *new: Log4JbackgroundProcess create a thread for each database connexion 
*V3.1.2.1 Guillaume Moulard 12-FEV-04 *BUG: bad version number, bad log with purge and isXxxxEnabled Tx to Pascal  Mwakuye
*V3.1.2.2 Guillaume Moulard 27-FEV-04 *BUG: pbs with call stack
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
-- Constants (no modification please)
-------------------------------------------------------------------

NOLEVEL         CONSTANT NUMBER       := -999.99 ;
DEFAULTEXTMESS  CONSTANT VARCHAR2(20) := 'GuillaumeMoulard';

-------------------------------------------------------------------
-- Constants (tools general parameter) 
-- you can update regard your context
-------------------------------------------------------------------
-- in V3 this section is now store in plogparam. Is note necessary for
-- the end user to update this curent package.

-------------------------------------------------------------------
-- Constants (tools internal parameter)
-------------------------------------------------------------------

-- The OFF has the highest possible rank and is intended to turn off logging.
LOFF   CONSTANT number := 10 ;
-- The FATAL level designates very severe error events that will presumably lead the application to abort.
LFATAL CONSTANT number := 20 ;
-- The ERROR level designates error events that might still allow the application  to continue running.
LERROR CONSTANT number := 30 ;
-- The WARN level designates potentially harmful situations.
LWARN  CONSTANT number := 40 ;
-- The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
LINFO  CONSTANT number := 50 ;
-- The DEBUG Level designates fine-grained informational events that are most useful to debug an application.
LDEBUG CONSTANT number := 60 ;
-- The ALL has the lowest possible rank and is intended to turn on all logging.
LALL   CONSTANT number := 70 ;


-- raise constante
ERR_CODE_DBMS_PIPE CONSTANT NUMBER        := -20503;
MES_CODE_DBMS_PIPE CONSTANT VARCHAR2(100) := 'error DBMS_PIPE.send_message. return code :'; 

-------------------------------------------------------------------
-- Public declaration of package
-------------------------------------------------------------------
TYPE LOG_CTX IS RECORD (                     -- Context de log
    isDefaultInit     BOOLEAN default FALSE ,
    LSID              TLOG.LSID%type        ,
    LLEVEL            TLOG.LLEVEL%type      ,
    LSECTION          TLOG.LSECTION%type    ,
    LTEXTE            TLOG.LTEXTE%type      ,
    USE_LOG4J         BOOLEAN               ,
    USE_OUT_TRANS     BOOLEAN               ,
    USE_LOGTABLE      BOOLEAN               ,
    USE_ALERT         BOOLEAN               ,
    USE_TRACE         BOOLEAN               ,
    USE_DBMS_OUTPUT   BOOLEAN               ,
    INIT_LSECTION     TLOG.LSECTION%type    ,
    INIT_LLEVEL       TLOG.LLEVEL%type      ,
    DBMS_PIPE_NAME    VARCHAR2(255)         ,
	DBMS_OUTPUT_WRAP  PLS_INTEGER          
);

-------------------------------------------------------------------
-- Public Procedure and function
-------------------------------------------------------------------

/**
 For use a log debug level
*/
PROCEDURE debug
(
    pTEXTE      IN TLOG.LTEXTE%type default null                          -- log text
);

PROCEDURE debug
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null                          -- log text
);

/**
 For use a log info level
*/
PROCEDURE info
(
    pTEXTE      IN TLOG.LTEXTE%type default null                           -- log text
);
PROCEDURE info
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null                          -- log text
);

/**
 For use a log warning level
*/
PROCEDURE warn
(
    pTEXTE      IN TLOG.LTEXTE%type default null                           -- log text
);
PROCEDURE warn
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null                          -- log text
);

/**
 For use a log error level
 new V3 call without argument or only with one context,  SQLCODE - SQLERRM is log.
*/
PROCEDURE error
(
    pTEXTE      IN TLOG.LTEXTE%type default null                           -- log text
);


PROCEDURE error
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null                          -- log text
);
/**
 For use a log fatal level
*/
PROCEDURE fatal
(
    pTEXTE      IN TLOG.LTEXTE%type default null                         -- log text
);
PROCEDURE fatal
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null                          -- log text
);

/**
 Generique procedure (use only for define your application level DEFINE_APPLICATION_LEVEL=TRUE)
*/

PROCEDURE log
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL      IN TLOG.LLEVEL%type                        ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
);
PROCEDURE log
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL      IN TLOGLEVEL.LCODE%type                    ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
);
PROCEDURE log
(
    pLEVEL      IN TLOG.LLEVEL%type                        ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
);

PROCEDURE log
(
    pLEVEL      IN TLOGLEVEL.LCODE%type                        ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
) ;



/**
context initialisation 
* @param pSECTION         default = NULL                            => PLSQL CALL STACK
* @param pLEVEL           default = PLOGPARAM.DEFAULT_LEVEL         -> LDEBUG
* @param pLOG4J           default = PLOGPARAM.DEFAULT_USE_LOG4J     -> FALSE (If true backgroun process is require)
* @param pLOGTABLE        default = PLOGPARAM.DEFAULT_LOG_TABLE     -> TRUE
* @param pOUT_TRANS       default = PLOGPARAM.DEFAULT_LOG_OUT_TRANS -> TRUE
* @param pALERT           default = PLOGPARAM.DEFAULT_LOG_ALERT     -> FALSE
* @param pTRACE           default = PLOGPARAM.DEFAULT_LOG_TRACE     -> FALSE
* @param pDBMS_OUTPUT     default = PLOGPARAM.DEFAULT_DBMS_OUTPUT   -> FALSE 
* @return new context LOG_CTX
*/
FUNCTION init
(
    pSECTION          IN       TLOG.LSECTION%type default NULL ,                            -- root of the tree section
    pLEVEL            IN       TLOG.LLEVEL%type   default PLOGPARAM.DEFAULT_LEVEL   ,       -- log level (Use only for debug)
    pLOG4J            IN       BOOLEAN            default PLOGPARAM.DEFAULT_USE_LOG4J,      -- if true the log is send to log4j
    pLOGTABLE         IN       BOOLEAN            default PLOGPARAM.DEFAULT_LOG_TABLE,      -- if true the log is insert into tlog 
    pOUT_TRANS        IN       BOOLEAN            default PLOGPARAM.DEFAULT_LOG_OUT_TRANS,  -- if true the log is in transactional log
    pALERT            IN       BOOLEAN            default PLOGPARAM.DEFAULT_LOG_ALERT,      -- if true the log is write in alert.log
    pTRACE            IN       BOOLEAN            default PLOGPARAM.DEFAULT_LOG_TRACE,      -- if true the log is write in trace file
    pDBMS_OUTPUT      IN       BOOLEAN            default PLOGPARAM.DEFAULT_DBMS_OUTPUT,    -- if true the log is send in standard output (DBMS_OUTPUT.PUT_LINE)
    pDBMS_PIPE_NAME   IN       VARCHAR2           default PLOGPARAM.DEFAULT_DBMS_PIPE_NAME, --
    pDBMS_OUTPUT_WRAP IN PLS_INTEGER      default PLOGPARAM.DEFAULT_DBMS_OUTPUT_LINE_WRAP
)
RETURN LOG_CTX;

-- Set default context
--  from init
procedure setDefaultContext
(
    pCTX        IN OUT NOCOPY LOG_CTX                             -- Context
);

/**
<B>Sections management</B> : init a new section
*/
PROCEDURE setBeginSection
(
    pCTX          IN OUT NOCOPY LOG_CTX                        ,  -- Context
    pSECTION      IN       TLOG.LSECTION%type                     -- log text
);

/**
<B>Sections management</B> : get a current section
* @return  current section
*/
FUNCTION getSection
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN TLOG.LSECTION%type;
/**
<B>Sections management</B> : get a default section
* @return  current section
*/
FUNCTION getSection
RETURN TLOG.LSECTION%type;
 
/**
<B>Sections management</B> : close a Section<BR/> 
without pSECTION : clean all section
*/
PROCEDURE setEndSection
(
    pCTX          IN OUT NOCOPY LOG_CTX                        ,  -- Context
    pSECTION      IN       TLOG.LSECTION%type  default 'EndAllSection'  -- log text
);





/**
<B>Levels Management</B> : increase level<BR/> 
 it is possible to dynamically update with setLevell the level of log<BR/> 
 call of setLevel without paramettre repositions the levels has that specifier <BR/> 
 in the package<BR/> 
 erreur possible : -20501, 'Set Level not in LOG predefine constantes'<BR/> 
*/
PROCEDURE setLevel
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL        IN TLOG.LLEVEL%type default NOLEVEL           -- Higher level to allot dynamically
);

PROCEDURE setLevel
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL        IN TLOGLEVEL.LCODE%type                       -- Higher level to allot dynamically
);

PROCEDURE setLevel
(
    pLEVEL        IN TLOG.LLEVEL%type default NOLEVEL           -- Higher level to allot dynamically
);


/**
<B>Levels Management</B> : Get a current level
*/
FUNCTION getLevel 
(
    pCTX        IN LOG_CTX                      -- Context
)
RETURN TLOG.LLEVEL%type;

/**
<B>Levels Management</B> : Get a default level
*/
FUNCTION getLevel 
RETURN TLOG.LLEVEL%type;


/**
<B>Levels Management</B> : return true if current level is Debug
*/
FUNCTION isDebugEnabled
(
    pCTX        IN  LOG_CTX                      -- Context
)
RETURN boolean;

/**
<B>Levels Management</B> : return true if default level is Debug
*/
FUNCTION isDebugEnabled
RETURN boolean;



/**
<B>Levels Management</B> : return true if current level is Info
*/
FUNCTION isInfoEnabled
(
    pCTX        IN  LOG_CTX                      -- Context
)
RETURN boolean;

/**
<B>Levels Management</B> : return true if default level is Info
*/
FUNCTION isInfoEnabled
RETURN boolean;



/**
<B>Levels Management</B> : return true if current level is Warn
*/
FUNCTION isWarnEnabled
(
    pCTX        IN  LOG_CTX                      -- Context
)
RETURN boolean;

/**
<B>Levels Management</B> : return true if default level is Warn
*/
FUNCTION isWarnEnabled
RETURN boolean;

/**
<B>Levels Management</B> : return true if current level is Error
*/
FUNCTION isErrorEnabled
(
    pCTX        IN LOG_CTX                      -- Context
)
RETURN boolean;

/**
<B>Levels Management</B> : return true if default level is Error
*/
FUNCTION isErrorEnabled
RETURN boolean;

/**
<B>Levels Management</B> : return true if current level is Fatal
*/
FUNCTION isFatalEnabled
(
    pCTX        IN LOG_CTX                      -- Context
)
RETURN boolean;

/**
<B>Levels Management</B> : return true if default level is Fatal
*/
FUNCTION isFatalEnabled
RETURN boolean;



/**
<B>Transactional management </B> : define a transaction mode<BR/> 
parameter transactional mode <BR/> 
TRUE => Log in transaction <BR/> 
FALSE => Log out off transaction <BR/> 
*/
PROCEDURE setTransactionMode
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inTransaction IN boolean default TRUE                       -- TRUE => Log in transaction 
                                                                -- FALSE => Log out off transaction 
);

/**
<B>Transactional management </B> : retun a transaction mode<BR/> 
TRUE => Log in transaction <BR/> 
FALSE => Log out off transaction <BR/> 
*/
FUNCTION getTransactionMode 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean;
/**
<B>Transactional management </B> : retun a default transaction mode<BR/> 
TRUE => Log in transaction <BR/> 
FALSE => Log out off transaction <BR/> 
*/
FUNCTION getTransactionMode 
RETURN boolean;


/**
<B>USE_LOG4J management </B> : define a USE_LOG4J destination mode<BR/> 
TRUE => Log is send to log4j<BR/> 
FALSE => Log is not send to log4j<BR/> 
*/
PROCEDURE setUSE_LOG4JMode
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inUSE_LOG4J   IN boolean default TRUE                       -- TRUE => Log is send to USE_LOG4J
                                                                -- FALSE => Log is not send to USE_LOG4J 
);

/**
<B>USE_LOG4J management </B> : retun a USE_LOG4J mode<BR/> 
TRUE => Log is send to USE_LOG4J<BR/> 
FALSE => Log is not send to USE_LOG4J<BR/> 
*/
FUNCTION getUSE_LOG4JMode 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean;
/**
<B>USE_LOG4J management </B> : retun a USE_LOG4J mode<BR/> 
TRUE => Log is send to USE_LOG4J<BR/> 
FALSE => Log is not send to USE_LOG4J<BR/> 
*/
FUNCTION getUSE_LOG4JMode 
RETURN boolean;


/**
<B>LOG_TABLE management </B> : define a LOG_TABLE destination mode<BR/> 
TRUE => Log is send to LOG_TABLE<BR/> 
FALSE => Log is not send to LOG_TABLE<BR/> 
*/
PROCEDURE setLOG_TABLEMode
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inLOG_TABLE       IN boolean default TRUE                   -- TRUE => Log is send to LOG_TABLE
                                                                -- FALSE => Log is not send to LOG_TABLE 
);

/**
<B>LOG_TABLE management </B> : retun a LOG_TABLE mode<BR/> 
TRUE => Log is send to LOG_TABLE<BR/> 
FALSE => Log is not send to LOG_TABLE<BR/> 
*/
FUNCTION getLOG_TABLEMode 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean;
/**
<B>LOG_TABLE management </B> : retun a LOG_TABLE mode<BR/> 
TRUE => Log is send to LOG_TABLE<BR/> 
FALSE => Log is not send to LOG_TABLE<BR/> 
*/
FUNCTION getLOG_TABLEMode 
RETURN boolean;

/**
<B>LOG_ALERT management </B> : define a LOG_ALERT destination mode<BR/> 
TRUE => Log is send to LOG_ALERT<BR/> 
FALSE => Log is not send to LOG_ALERT<BR/> 
*/
PROCEDURE setLOG_ALERTMode
(
    pCTX          IN OUT NOCOPY LOG_CTX                           ,  -- Context
    inLOG_ALERT       IN boolean default TRUE                        -- TRUE => Log is send to LOG_ALERT
                                                                     -- FALSE => Log is not send to LOG_ALERT 
);

/**
<B>LOG_ALERT management </B> : retun a LOG_ALERT mode<BR/> 
TRUE => Log is send to LOG_ALERT<BR/> 
FALSE => Log is not send to LOG_ALERT<BR/> 
*/
FUNCTION getLOG_ALERTMode 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean;
/**
<B>LOG_ALERT management </B> : retun a LOG_ALERT mode<BR/> 
TRUE => Log is send to LOG_ALERT<BR/> 
FALSE => Log is not send to LOG_ALERT<BR/> 
*/
FUNCTION getLOG_ALERTMode 
RETURN boolean;


/**
<B>LOG_TRACE management </B> : define a LOG_TRACE destination mode<BR/> 
TRUE => Log is send to LOG_TRACE<BR/> 
FALSE => Log is not send to LOG_TRACE<BR/> 
*/
PROCEDURE setLOG_TRACEMode
(
    pCTX          IN OUT NOCOPY LOG_CTX                           ,  -- Context
    inLOG_TRACE       IN boolean default TRUE                        -- TRUE => Log is send to LOG_TRACE
                                                                     -- FALSE => Log is not send to LOG_TRACE 
);

/**
<B>LOG_TRACE management </B> : retun a LOG_TRACE mode<BR/> 
TRUE => Log is send to LOG_TRACE<BR/> 
FALSE => Log is not send to LOG_TRACE<BR/> 
*/
FUNCTION getLOG_TRACEMode 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean;
/**
<B>LOG_TRACE management </B> : retun a LOG_TRACE mode<BR/> 
TRUE => Log is send to LOG_TRACE<BR/> 
FALSE => Log is not send to LOG_TRACE<BR/> 
*/
FUNCTION getLOG_TRACEMode 
RETURN boolean;


/**
<B>DBMS_OUTPUT management </B> : define a DBMS_OUTPUT destination mode<BR/> 
TRUE => Log is send to DBMS_OUTPUT<BR/> 
FALSE => Log is not send to DBMS_OUTPUT<BR/> 
*/
PROCEDURE setDBMS_OUTPUTMode
(
    pCTX          IN OUT NOCOPY LOG_CTX                           ,  -- Context
    inDBMS_OUTPUT       IN boolean default TRUE                      -- TRUE => Log is send to DBMS_OUTPUT
                                                                     -- FALSE => Log is not send to DBMS_OUTPUT 
);

/**
<B>DBMS_OUTPUT management </B> : retun a DBMS_OUTPUT mode<BR/> 
TRUE => Log is send to DBMS_OUTPUT<BR/> 
FALSE => Log is not send to DBMS_OUTPUT<BR/> 
*/
FUNCTION getDBMS_OUTPUTMode 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean;
/**
<B>DBMS_OUTPUT management </B> : retun a DBMS_OUTPUT mode<BR/> 
TRUE => Log is send to DBMS_OUTPUT<BR/> 
FALSE => Log is not send to DBMS_OUTPUT<BR/> 
*/
FUNCTION getDBMS_OUTPUTMode 
RETURN boolean;



/**
<B>assert</B> log a messge is pCondition is FALSE if pRaiseExceptionIfFALSE = TRUE the message is raise<BR/> 
* @param     pCTX                     IN OUT NOCOPY LOG_CTX        -> Context
* @param     pCONDITION               IN BOOLEAN                   -> error condition 
* @param     pLogErrorMessageIfFALSE  IN VARCHAR2 default 'assert condition error' -> message if pCondition is true 
* @param     pLogErrorCodeIfFALSE     IN NUMBER  default -20000    -> error code is pCondition is true range -20000 .. -20999  
* @param     pRaiseExceptionIfFALSE   IN BOOLEAN default FALSE     -> if true raise pException_in if pCondition is true 
* @param     pLogErrorReplaceError    IN BOOLEAN default FALSE     -> TRUE, the error is placed on the stack of previous errors. If FALSE (the default), the error replaces all previous errors (see Oracle Documentation RAISE_APPLICATION_ERROR)
* @return log a messge if pCondition is FALSE. If pRaiseExceptionIfFALSE = TRUE the message is raise
*/
PROCEDURE assert (
    pCONDITION               IN BOOLEAN                                   , -- error condition 
    pLogErrorMessageIfFALSE  IN VARCHAR2 default 'assert condition error' , -- message if pCondition is true 
    pLogErrorCodeIfFALSE     IN NUMBER   default -20000                   , -- error code is pCondition is true range -20000 .. -20999  
    pRaiseExceptionIfFALSE   IN BOOLEAN  default FALSE                    , -- if true raise pException_in if pCondition is true 
    pLogErrorReplaceError    in BOOLEAN  default FALSE                      -- TRUE, the error is placed on the stack of previous errors. 
                                                                           -- If FALSE (the default), the error replaces all previous errors
                                                                           -- see Oracle Documentation RAISE_APPLICATION_ERROR
);
/**
<B>assert</B> log a messge is pCondition is FALSE if pRaiseExceptionIfFALSE = TRUE the message is raise<BR/> 
* @param     pCTX                     IN OUT NOCOPY LOG_CTX        -> Context
* @param     pCONDITION               IN BOOLEAN                   -> error condition 
* @param     pLogErrorMessageIfFALSE  IN VARCHAR2 default 'assert condition error' -> message if pCondition is true 
* @param     pLogErrorCodeIfFALSE     IN NUMBER  default -20000    -> error code is pCondition is true range -20000 .. -20999  
* @param     pRaiseExceptionIfFALSE   IN BOOLEAN default FALSE     -> if true raise pException_in if pCondition is true 
* @param     pLogErrorReplaceError    IN BOOLEAN default FALSE     -> TRUE, the error is placed on the stack of previous errors. If FALSE (the default), the error replaces all previous errors (see Oracle Documentation RAISE_APPLICATION_ERROR)
* @return log a messge if pCondition is FALSE. If pRaiseExceptionIfFALSE = TRUE the message is raise

*/
PROCEDURE assert (
    pCTX                     IN OUT NOCOPY LOG_CTX                        , -- Context
    pCONDITION               IN BOOLEAN                                   , -- error condition 
    pLogErrorMessageIfFALSE  IN VARCHAR2 default 'assert condition error' , -- message if pCondition is true 
    pLogErrorCodeIfFALSE     IN NUMBER   default -20000                   , -- error code is pCondition is true range -20000 .. -20999  
    pRaiseExceptionIfFALSE   IN BOOLEAN  default FALSE                    , -- if true raise pException_in if pCondition is true 
    pLogErrorReplaceError    in BOOLEAN  default FALSE                      -- TRUE, the error is placed on the stack of previous errors. 
                                                                           -- If FALSE (the default), the error replaces all previous errors
                                                                           -- see Oracle Documentation RAISE_APPLICATION_ERROR
);

/**
<B>full_call_stack</B> log result of dbms_utility.format_call_stack<BR/> 
some time is necessary for debug code.
*/
PROCEDURE full_call_stack;
PROCEDURE full_call_stack (
    pCTX                     IN OUT NOCOPY LOG_CTX                       -- Context
);

/**
<B>getLOG4PLSQVersion</B> return a string with a current version<BR/> 
*/
FUNCTION getLOG4PLSQVersion return varchar2;


/**
<B>getLevelInText</B> return a string with a level in send in parameter<BR/> 
*/
FUNCTION getLevelInText (
    pLevel TLOG.LLEVEL%type default PLOGPARAM.DEFAULT_LEVEL 
) return varchar2;

/**
<B>getTextInLevel</B> return a level with a String in send in parameter<BR/> 
*/
FUNCTION getTextInLevel (
    pCode TLOGLEVEL.LCODE%type
) return  TLOG.LLEVEL%type ;


/**
<B>DBMS_PIPE_NAME management </B> 
*/
FUNCTION getDBMS_PIPE_NAME 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN varchar2;

FUNCTION getDBMS_PIPE_NAME 
RETURN varchar2;


PROCEDURE setDBMS_PIPE_NAME
(
    pCTX          IN OUT NOCOPY LOG_CTX                           ,  -- Context
    inDBMS_PIPE_NAME IN VARCHAR2
);


-------------------------------------------------------------------
-- 
-------------------------------------------------------------------
/**
<B>admin functionality </B> :  delete rows in table TLOG and commit
*/
PROCEDURE purge ;
PROCEDURE purge
(
    pCTX          IN OUT NOCOPY LOG_CTX                        -- Context
);

/**
<B>admin functionality </B> :  delete rows in table TLOG with date max and commit
*/
PROCEDURE purge
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    DateMax       IN Date                                       -- All record to old as deleted
);

END PLOG;
/

sho error

-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------
