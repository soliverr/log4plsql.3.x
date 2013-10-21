CREATE OR REPLACE
PACKAGE BODY         PLOG IS
-------------------------------------------------------------------
--
--  Nom package        : PLOG
--
--  Objectif           : plog code
--
--  Version            : 3.0
-------------------------------------------------------------------
-- see package spec for history
-------------------------------------------------------------------


-------------------------------------------------------------------
-- Variable global privé au package
-------------------------------------------------------------------
/*
 * Copyright (C) LOG4PLSQL project team. All rights reserved.
 *
 * This software is published under the terms of the The LOG4PLSQL 
 * Software License, a copy of which has been included with this
 * distribution in the LICENSE.txt file.  
 * see: <http://log4plsql.sourceforge.net>  */
 
-------------------------------------------------------------------

LOG4PLSQL_VERSION  VARCHAR2(200) := '3.2.0.0';  


-------------------------------------------------------------------
-- Code privé au package
-------------------------------------------------------------------
-------------------------------------------------------------------

--------------------------------------------------------------------
FUNCTION getNextID
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
) RETURN TLOG.ID%type 
IS
    temp number;
BEGIN
     select SLOG.nextval into temp from dual;
     return temp;
     
end getNextID;


----------------------------------------------------------------------
--function instrLast(ch1 varchar2, ch2 varchar2) return number
--is
--ret number := 0;
--begin
--    FOR i IN REVERSE 0..length(Ch1) LOOP
--        if instr(substr(ch1,i),ch2) > 0 then
--           return i;
--        end if;
--    end loop;
--    return ret;    
--end;

--------------------------------------------------------------------
FUNCTION calleurname return varchar2
IS
    endOfLine   constant    char(1) := chr(10);
    endOfField  constant    char(1) := chr(32);
    nbrLine     number;
    ptFinLigne  number;
    ptDebLigne  number;
    ptDebCode   number;
    pt1         number;
    cpt         number;
    allLines    varchar2(4000);   
    resultat    varchar2(4000);
    Line        varchar2(4000);
    UserCode    varchar2(4000);
    myName      varchar2(2000) := '.PLOG';
begin
    allLines    := dbms_utility.format_call_stack;       
    cpt         := 2;
    ptFinLigne  := length(allLines);
    ptDebLigne  := ptFinLigne;

    While ptFinLigne > 0 and ptDebLigne > 83 loop
       ptDebLigne   := INSTR (allLines, endOfLine, -1, cpt) + 1 ;
       cpt          := cpt + 1;
       -- traite ligne
       Line         := SUBSTR(allLines, ptDebLigne, ptFinLigne - ptDebLigne);
       ptDebCode    := INSTR (Line, endOfField, -1, 1); 
       UserCode     := SUBSTR(Line, ptDebCode+1);

       IF instr(UserCode,myName) = 0 then
           IF cpt > 3 then
             resultat := resultat||'.';
           end IF;
           resultat := resultat||UserCode;
       end if; 
       ptFinLigne := ptDebLigne - 1;
     end loop;
 
return resultat;
end calleurname;


--------------------------------------------------------------------
FUNCTION getDefaultContext
-- Cette fonction est privé, Elle retourne le contexte par default
-- quand il n'est pas précissé 
RETURN LOG_CTX
IS
    newCTX      LOG_CTX; 
    lSECTION    TLOG.LSECTION%type;    
BEGIN
    lSECTION := calleurname;
    newCTX := init (pSECTION => lSECTION);
    RETURN newCTX;
END getDefaultContext;
  



--------------------------------------------------------------------
PROCEDURE     checkAndInitCTX(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
IS
    lSECTION    TLOG.LSECTION%type;    
BEGIN
    IF pCTX.isDefaultInit = FALSE THEN        
        lSECTION := calleurname;
        pCTX := init (pSECTION => lSECTION);
    END IF;
END;
    

  

--------------------------------------------------------------------
procedure addRow
(
  pID         in TLOG.id%type,
  pLDate      in TLOG.ldate%type,
  pLHSECS     in TLOG.lhsecs%type, 
  pLLEVEL     in TLOG.llevel%type,
  pLSECTION   in TLOG.lsection%type,
  pLUSER      in TLOG.luser%type,
  pLTEXTE     in TLOG.ltexte%type
)
is
begin
        insert into TLOG
            (
             ID         ,
             LDate      ,
             LHSECS     , 
             LLEVEL     ,
             LSECTION   ,
             LUSER      ,
             LTEXTE     
             ) VALUES (
             pID,
             pLDate,
             pLHSECS,
             pLLEVEL,
             pLSECTION,
             pLUSER,
             pLTEXTE
            );
end;  

--------------------------------------------------------------------
procedure addRowAutonomous
(
  pID         in TLOG.id%type,
  pLDate      in TLOG.ldate%type,
  pLHSECS     in TLOG.lhsecs%type, 
  pLLEVEL     in TLOG.llevel%type,
  pLSECTION   in TLOG.lsection%type,
  pLUSER      in TLOG.luser%type,
  pLTEXTE     in TLOG.ltexte%type
)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
 addRow
  (
   pID         => pID,
   pLDate      => pLDate,
   pLHSECS     => pLHSECS, 
   pLLEVEL     => pLLEVEL,
   pLSECTION   => pLSECTION,
   pLUSER      => pLUSER,
   pLTEXTE     => pLTEXTE
  );
  commit;
  exception when others then
      PLOG.ERROR;
      rollback;
      raise;
end;

--------------------------------------------------------------------
PROCEDURE log
-- procedure privé pour intégrer les données dans la table
-- RAISE : -20503 'error DBMS_PIPE.send_message.
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pID         IN       TLOG.ID%type                      ,
    pLDate      IN       TLOG.LDATE%type                   ,
    pLHSECS     IN       TLOG.LHSECS%type                  ,
    pLLEVEL     IN       TLOG.LLEVEL%type                  ,
    pLSECTION   IN       TLOG.LSECTION%type                ,
    pLUSER      IN       TLOG.LUSER%type                   ,
    pLTEXTE     IN       TLOG.LTEXTE%type                  
)
IS
    ret number;
    LLTEXTE TLOG.LTEXTE%type ;
    pt number;
BEGIN

    IF pCTX.isDefaultInit = FALSE THEN
        plog.error('please is necessary to use plog.init for yours contexte.');
    END IF;
    
    IF PLTEXTE is null then 
        LLTEXTE := 'SQLCODE:'||SQLCODE ||' SQLERRM:'||SQLERRM;
    ELSE
        BEGIN
            LLTEXTE := pLTEXTE;
        EXCEPTION
            WHEN VALUE_ERROR THEN
                ASSERT (pCTX, length(pLTEXTE) <= 2000, 'Log Message id:'||pID||' too long. ');
                LLTEXTE := substr(pLTEXTE, 0, 2000);
            WHEN OTHERS THEN
                PLOG.FATAL;
        END;
        
    END IF;
  
    IF pCTX.USE_LOGTABLE = TRUE then
    
        IF pCTX.USE_OUT_TRANS = FALSE then
                 addRow
                  (
                   pID         => pID,
                   pLDate      => pLDate,
                   pLHSECS     => pLHSECS, 
                   pLLEVEL     => pLLEVEL,
                   pLSECTION   => pLSECTION,
                   pLUSER      => pLUSER,
                   pLTEXTE     => LLTEXTE
                  );
        ELSE
                 addRowAutonomous
                  (
                   pID         => pID,
                   pLDate      => pLDate,
                   pLHSECS     => pLHSECS, 
                   pLLEVEL     => pLLEVEL,
                   pLSECTION   => pLSECTION,
                   pLUSER      => pLUSER,
                   pLTEXTE     => LLTEXTE
                  );
        END IF;
    END IF; 

    IF pCTX.USE_LOG4J = TRUE then
        DBMS_PIPE.pack_message(pID);                    -- SEQUENTIAL ID
        DBMS_PIPE.pack_message(pLDATE);                 -- TIMESTAMP OF LOG STATEMENT
		DBMS_PIPE.pack_message(MOD(pLHSECS,100));       -- HUNDREDTHS OF SECONDS FOR TIMESTAMP
        DBMS_PIPE.pack_message(pLLEVEL);                -- LOG LEVEL
        DBMS_PIPE.pack_message(pLSECTION);              -- LOG SECTION - ANALOGUE TO LOG4J Logger NAME
        DBMS_PIPE.pack_message(LLTEXTE);                -- LOG MESSAGE
        DBMS_PIPE.pack_message(pLUSER);                 -- CALLING USER
        DBMS_PIPE.pack_message('SAVE_IN_LOG');          -- MESSAGE TYPE?
		DBMS_PIPE.pack_message(PMDC.getKeyString);      -- MAPPED DOMAIN CONTEXT KEYS FOR LOG4J
		DBMS_PIPE.pack_message(PMDC.getValueString);    -- MAPPED DOMAIN CONTEXT VALUES FOR LOG4J
		DBMS_PIPE.pack_message(PMDC.getSeparator);      -- MAPPED DOMAIN CONTEXT SEPARATOR FOR LOG4J

        ret := DBMS_PIPE.send_message(pCTX.DBMS_PIPE_NAME);        
        IF RET <> 0 then
             raise_application_error(ERR_CODE_DBMS_PIPE, MES_CODE_DBMS_PIPE || RET);
        END IF;         
    END IF;
             
    IF pCTX.USE_ALERT = TRUE then        
        sys.dbms_system.ksdwrt(2,'PLOG:'||TO_CHAR(pLDATE, 'YYYY-MM-DD HH24:MI:SS')||':'||LTRIM(TO_CHAR(MOD(pLHSECS,100),'09'))||' user: '||PLUSER||' level: '||getLevelInText(pLLEVEL)||' logid: '||pID ||' '||pLSECTION); 
        sys.dbms_system.ksdwrt(2,substr(LLTEXTE,0,1000));
        if (length(LLTEXTE) >= 1000) then 
            sys.dbms_system.ksdwrt(2,substr(LLTEXTE,1000));
        end if;
    END IF;

    IF pCTX.USE_TRACE = TRUE then        
        sys.dbms_system.ksdwrt(1,'PLOG:'||TO_CHAR(pLDATE, 'YYYY-MM-DD HH24:MI:SS')||':'||LTRIM(TO_CHAR(MOD(pLHSECS,100),'09'))||' user: '||PLUSER||' level: '||getLevelInText(pLLEVEL)||' logid: '||pID ||' '||pLSECTION); 
        sys.dbms_system.ksdwrt(1,substr(LLTEXTE,0,1000));
        if (length(LLTEXTE) >= 1000) then 
            sys.dbms_system.ksdwrt(1,substr(LLTEXTE,1000));
        end if;
    END IF;

    IF pCTX.USE_DBMS_OUTPUT = TRUE then
		 DECLARE
	        pt          number;
	        hdr         varchar2(4000);
	        hdr_len     pls_integer;
			line_len    pls_integer;
	        wrap        number := pCTX.DBMS_OUTPUT_WRAP;   --length to wrap long text.
	    BEGIN
	        hdr := TO_CHAR(pLDATE, 'HH24:MI:SS')||':'||LTRIM(TO_CHAR(MOD(pLHSECS,100),'09'))||'-'||getLevelInText(pLLEVEL)||'-'||pLSECTION||'  ';
			hdr_len := length(hdr);
			line_len := wrap - hdr_len;
	        sys.DBMS_OUTPUT.PUT(hdr);
	        pt := 1;
	        while pt <= length(LLTEXTE) loop
			    if pt = 1 then 
	                sys.DBMS_OUTPUT.PUT_LINE(substr(LLTEXTE,pt,line_len));
				else
	               sys.DBMS_OUTPUT.PUT_LINE(lpad(' ',hdr_len)||substr(LLTEXTE,pt,line_len));
				end if;
	            pt := pt + line_len;
	        end loop;
	    END;
    END IF;

end log;

  

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Code public du package
-------------------------------------------------------------------
-------------------------------------------------------------------


--------------------------------------------------------------------
FUNCTION init
-- initialisation du contexte  
(
    pSECTION        IN TLOG.LSECTION%type default NULL ,                           -- log section
    pLEVEL          IN TLOG.LLEVEL%type   default PLOGPARAM.DEFAULT_LEVEL   ,      -- log level (Use only for debug)
    pLOG4J          IN BOOLEAN            default PLOGPARAM.DEFAULT_USE_LOG4J,     -- if true the log is send to log4j
    pLOGTABLE       IN BOOLEAN            default PLOGPARAM.DEFAULT_LOG_TABLE,     -- if true the log is insert into tlog 
    pOUT_TRANS      IN BOOLEAN            default PLOGPARAM.DEFAULT_LOG_OUT_TRANS, -- if true the log is in transactional log
    pALERT          IN BOOLEAN            default PLOGPARAM.DEFAULT_LOG_ALERT,  -- if true the log is write in alert.log
    pTRACE          IN BOOLEAN            default PLOGPARAM.DEFAULT_LOG_TRACE,     -- if true the log is write in trace file
    pDBMS_OUTPUT    IN BOOLEAN            default PLOGPARAM.DEFAULT_DBMS_OUTPUT,    -- if true the log is send in standard output (DBMS_OUTPUT.PUT_LINE)
    pDBMS_PIPE_NAME IN VARCHAR2           default PLOGPARAM.DEFAULT_DBMS_PIPE_NAME, -- name of pipe to log to for Log4J output
    pDBMS_OUTPUT_WRAP IN PLS_INTEGER      default PLOGPARAM.DEFAULT_DBMS_OUTPUT_LINE_WRAP -- length to wrap output to when using DBMS_OUTPUT 

)
RETURN LOG_CTX
IS
    pCTX       LOG_CTX;                           
BEGIN
    
    pCTX.isDefaultInit   := TRUE;
    pCTX.LSection        := nvl(pSECTION, calleurname);
    pCTX.INIT_LSECTION   := pSECTION;
    pCTX.LLEVEL          := pLEVEL;
    pCTX.INIT_LLEVEL     := pLEVEL;
    pCTX.USE_LOG4J       := pLOG4J;
    pCTX.USE_OUT_TRANS   := pOUT_TRANS;
    pCTX.USE_LOGTABLE    := pLOGTABLE;
    pCTX.USE_ALERT       := pALERT;
    pCTX.USE_TRACE       := pTRACE;
    pCTX.USE_DBMS_OUTPUT := pDBMS_OUTPUT;
    pCTX.DBMS_PIPE_NAME  := pDBMS_PIPE_NAME;
    pCTX.DBMS_OUTPUT_WRAP := pDBMS_OUTPUT_WRAP;

    return pCTX;
end init;

--------------------------------------------------------------------
PROCEDURE setBeginSection
-- initialisation d'un debut de niveaux hierarchique de log
(
    pCTX          IN OUT NOCOPY LOG_CTX                           ,  -- Context
    pSECTION      IN       TLOG.LSECTION%type                        -- Texte du log
) IS 
BEGIN
    checkAndInitCTX(pCTX);
    pCTX.LSection := pCTX.LSection||PLOGPARAM.DEFAULT_Section_sep||pSECTION;

end setBeginSection;

--------------------------------------------------------------------
FUNCTION getSection
-- renvoie la section en cours
(
    pCTX        IN OUT NOCOPY LOG_CTX                        -- Context
)
RETURN TLOG.LSECTION%type 
IS
BEGIN
    
    return pCTX.LSection; 

end getSection;


--------------------------------------------------------------------
FUNCTION getSection
-- renvoie la section en cours
RETURN TLOG.LSECTION%type 
IS
    generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    
    return getSection(pCTX =>generiqueCTX) ; 

end getSection;


--------------------------------------------------------------------
PROCEDURE setEndSection
-- fin d'un niveau hierarchique de log et dee  tout c'est supérieur
-- par default [/]
(
    pCTX          IN OUT NOCOPY LOG_CTX                        ,  -- Context
    pSECTION      IN       TLOG.LSECTION%type  default 'EndAllSection'  -- Texte du log
) IS
BEGIN
    checkAndInitCTX(pCTX);
    if pSECTION = 'EndAllSection' THEN
        pCTX.LSection := nvl(pCTX.INIT_LSECTION, calleurname);
        RETURN; 
    END IF;
    
    pCTX.LSection := substr(pCTX.LSection,1,instr(UPPER(pCTX.LSection), UPPER(pSECTION), -1)-2);


end setEndSection;



-------------------------------------------------------------------
PROCEDURE setTransactionMode
-- utlisation des log dans ou en dehors des transactions 
-- TRUE => Les log sont dans la transaction
-- FALSE => les log sont en dehors de la transaction
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inTransaction IN boolean default TRUE                       -- TRUE => Les log sont dans la transaction, 
                                                                -- FALSE => les log sont en dehors de la transaction
)
IS
BEGIN
    checkAndInitCTX(pCTX);
    pCTX.USE_OUT_TRANS := inTransaction;
   
end setTransactionMode;


-------------------------------------------------------------------
FUNCTION getTransactionMode 
-- TRUE => Les log sont dans la transaction
-- FALSE => les log sont en dehors de la transaction
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean
IS
BEGIN
    return pCTX.USE_OUT_TRANS;
end getTransactionMode;
-------------------------------------------------------------------
FUNCTION getTransactionMode 
RETURN boolean
IS
        generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    return getTransactionMode(pCTX => generiqueCTX);
end getTransactionMode;


-------------------------------------------------------------------
PROCEDURE setUSE_LOG4JMode
--TRUE => Log is send to USE_LOG4J
--FALSE => Log is not send to USE_LOG4J
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inUSE_LOG4J IN boolean default TRUE                         -- TRUE => Log is send to USE_LOG4J, 
                                                                -- FALSE => Log is not send to USE_LOG4J
)
IS
BEGIN
    checkAndInitCTX(pCTX);
    pCTX.USE_LOG4J := inUSE_LOG4J;
   
end setUSE_LOG4JMode;


-------------------------------------------------------------------
FUNCTION getUSE_LOG4JMode 
--TRUE => Log is send to USE_LOG4J
--FALSE => Log is not send to USE_LOG4J
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean
IS
BEGIN
    return pCTX.USE_LOG4J;
end getUSE_LOG4JMode;
-------------------------------------------------------------------
FUNCTION getUSE_LOG4JMode 
RETURN boolean
IS
        generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    return getTransactionMode(pCTX => generiqueCTX);
end getUSE_LOG4JMode;


-------------------------------------------------------------------
PROCEDURE setLOG_TABLEMode
--TRUE => Log is send to LOG_TABLEMODE
--FALSE => Log is not send to LOG_TABLEMODE
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inLOG_TABLE IN boolean default TRUE                         -- TRUE => Log is send to LOG_TABLEMODE, 
                                                                -- FALSE => Log is not send to LOG_TABLEMODE
)
IS
BEGIN
    checkAndInitCTX(pCTX);
    pCTX.USE_LOGTABLE := inLOG_TABLE;
   
end setLOG_TABLEMode;


-------------------------------------------------------------------
FUNCTION getLOG_TABLEMode 
--TRUE => Log is send to LOG_TABLEMODE
--FALSE => Log is not send to LOG_TABLEMODE
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean
IS
BEGIN
    return pCTX.USE_LOGTABLE;
end getLOG_TABLEMode;
-------------------------------------------------------------------
FUNCTION getLOG_TABLEMode 
RETURN boolean
IS
        generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    return getTransactionMode(pCTX => generiqueCTX);
end getLOG_TABLEMode;



-------------------------------------------------------------------
PROCEDURE setLOG_ALERTMode
--TRUE => Log is send to LOG_ALERT
--FALSE => Log is not send to LOG_ALERT
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inLOG_ALERT IN boolean default TRUE                         -- TRUE => Log is send to LOG_ALERT, 
                                                                -- FALSE => Log is not send to LOG_ALERT
)
IS
BEGIN
    checkAndInitCTX(pCTX);
    pCTX.USE_ALERT := inLOG_ALERT;
   
end setLOG_ALERTMode;


-------------------------------------------------------------------
FUNCTION getLOG_ALERTMode 
--TRUE => Log is send to LOG_ALERT
--FALSE => Log is not send to LOG_ALERT
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean
IS
BEGIN
    return pCTX.USE_ALERT;
end getLOG_ALERTMode;
-------------------------------------------------------------------
FUNCTION getLOG_ALERTMode 
RETURN boolean
IS
        generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    return getTransactionMode(pCTX => generiqueCTX);
end getLOG_ALERTMode;



-------------------------------------------------------------------
PROCEDURE setLOG_TRACEMode
--TRUE => Log is send to LOG_TRACE
--FALSE => Log is not send to LOG_TRACE
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inLOG_TRACE IN boolean default TRUE                         -- TRUE => Log is send to LOG_TRACE, 
                                                                -- FALSE => Log is not send to LOG_TRACE
)
IS
BEGIN
    checkAndInitCTX(pCTX);
    pCTX.USE_TRACE := inLOG_TRACE;
   
end setLOG_TRACEMode;


-------------------------------------------------------------------
FUNCTION getLOG_TRACEMode 
--TRUE => Log is send to LOG_TRACE
--FALSE => Log is not send to LOG_TRACE
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean
IS
BEGIN
    return pCTX.USE_TRACE;
end getLOG_TRACEMode;
-------------------------------------------------------------------
FUNCTION getLOG_TRACEMode 
RETURN boolean
IS
        generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    return getTransactionMode(pCTX => generiqueCTX);
end getLOG_TRACEMode;


-------------------------------------------------------------------
PROCEDURE setDBMS_OUTPUTMode
--TRUE => Log is send to DBMS_OUTPUT
--FALSE => Log is not send to DBMS_OUTPUT
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    inDBMS_OUTPUT IN boolean default TRUE                       -- TRUE => Log is send to DBMS_OUTPUT, 
                                                                -- FALSE => Log is not send to DBMS_OUTPUT
)
IS
BEGIN
    checkAndInitCTX(pCTX);
    pCTX.USE_DBMS_OUTPUT := inDBMS_OUTPUT;
    
end setDBMS_OUTPUTMode;


-------------------------------------------------------------------
FUNCTION getDBMS_OUTPUTMode 
--TRUE => Log is send to DBMS_OUTPUT
--FALSE => Log is not send to DBMS_OUTPUT
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN boolean
IS
BEGIN
    checkAndInitCTX(pCTX);
    return pCTX.USE_DBMS_OUTPUT;
end getDBMS_OUTPUTMode;
-------------------------------------------------------------------
FUNCTION getDBMS_OUTPUTMode 
RETURN boolean
IS
        generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    return getTransactionMode(pCTX => generiqueCTX);
end getDBMS_OUTPUTMode;





 

-------------------------------------------------------------------
PROCEDURE setLevel
-- il est possible de modifier avec setLevell  dynamiquement le niveau de log
-- l'appel de setLevel sans paramettre re-poossitionne le niveaux a celuis specifier
-- dans le package.
-- erreur possible : -20501, 'Set Level not in LOG predefine constantes'
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL        IN TLOG.LLEVEL%type   default NOLEVEL         -- Level supérieur attribuer dynamiquement
) IS
    nbrl number;
BEGIN
    checkAndInitCTX(pCTX);
    IF pLEVEL = NOLEVEL then 
        pCTX.LLEVEL := pCTX.INIT_LLEVEL;
    END IF;

    select count(*) into nbrl FROM TLOGLEVEL where TLOGLEVEL.LLEVEL=pLEVEL;
    IF nbrl > 0 then 
        pCTX.LLEVEL := pLEVEL;
    ELSE
        raise_application_error(-20501, 'SetLevel ('||pLEVEL||') not in TLOGLEVEL table');
    END IF;            
EXCEPTION
    WHEN OTHERS THEN
        PLOG.ERROR;    
end setLevel;

PROCEDURE setLevel
-- il est possible de modifier avec setLevell  dynamiquement le niveau de log
-- l'appel de setLevel sans paramettre re-poossitionne le niveaux a celuis specifier
-- dans le package.
-- erreur possible : -20501, 'Set Level not in LOG predefine constantes'
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL        IN TLOGLEVEL.LCODE%type                       -- Level supérieur attribuer dynamiquement
) IS
    nbrl number;
BEGIN

    setLevel (pCTX, getTextInLevel(pLEVEL));

end setLevel;


-------------------------------------------------------------------
FUNCTION getLevel 
-- Retourne le level courant
(
    pCTX       IN LOG_CTX                      -- Context
)
RETURN TLOG.LLEVEL%type 
IS
BEGIN
    return pCTX.LLEVEL;
end getLevel;

FUNCTION getLevel 
RETURN TLOG.LLEVEL%type 
IS
    generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext; 
BEGIN
    return getLevel( pCTX => generiqueCTX);
end getLevel;


-------------------------------------------------------------------------
FUNCTION islevelEnabled 
-- fonction outil appeler par les is[Debug|Info|Warn|Error]Enabled
(
    pCTX        IN   LOG_CTX,                      -- Context
    pLEVEL       IN TLOG.LLEVEL%type                       -- Level a tester    
)
RETURN boolean
IS
BEGIN
    if getLevel(pCTX) >= pLEVEL then 
        return TRUE;
    else
        return FALSE;
    end if;
end islevelEnabled;

FUNCTION islevelEnabled 
(
    pLEVEL       IN TLOG.LLEVEL%type                       -- Level a tester    
)
RETURN boolean
IS
    generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext; 
BEGIN
    return islevelEnabled( pCTX => generiqueCTX, pLEVEL => pLEVEL);
end islevelEnabled;
-------------------------------------------------------------------
FUNCTION isFatalEnabled RETURN boolean is begin return islevelEnabled(getTextInLevel('FATAL')); end;
FUNCTION isErrorEnabled RETURN boolean is begin return islevelEnabled(getTextInLevel('ERROR')); end;
FUNCTION isWarnEnabled  RETURN boolean is begin return islevelEnabled(getTextInLevel('WARN')) ; end;
FUNCTION isInfoEnabled  RETURN boolean is begin return islevelEnabled(getTextInLevel('INFO')) ; end;
FUNCTION isDebugEnabled RETURN boolean is begin return islevelEnabled(getTextInLevel('DEBUG')); end;
FUNCTION isFatalEnabled ( pCTX IN LOG_CTX ) RETURN boolean is begin return islevelEnabled(pCTX, getTextInLevel('FATAL')); end;
FUNCTION isErrorEnabled ( pCTX IN LOG_CTX ) RETURN boolean is begin return islevelEnabled(pCTX, getTextInLevel('ERROR')); end;
FUNCTION isWarnEnabled  ( pCTX IN LOG_CTX ) RETURN boolean is begin return islevelEnabled(pCTX, getTextInLevel('WARN')) ; end;
FUNCTION isInfoEnabled  ( pCTX IN LOG_CTX ) RETURN boolean is begin return islevelEnabled(pCTX, getTextInLevel('INFO')) ; end;
FUNCTION isDebugEnabled ( pCTX IN LOG_CTX ) RETURN boolean is begin return islevelEnabled(pCTX, getTextInLevel('DEBUG')); end;



--------------------------------------------------------------------
PROCEDURE purge
--  Purge de la log
IS
   tempLogCtx PLOG.LOG_CTX;
BEGIN
    purge(tempLogCtx);
end purge;
--------------------------------------------------------------------
PROCEDURE purge
--  Purge de la log
(
    pCTX          IN OUT NOCOPY LOG_CTX                        -- Context
) IS
BEGIN
    checkAndInitCTX(pCTX);
    execute immediate ('truncate table tlog');  
    purge(pCTX, sysdate+1);
end purge;


--------------------------------------------------------------------
PROCEDURE purge
--  Purge de la log avec date max
(
    pCTX          IN OUT NOCOPY LOG_CTX                      ,  -- Context
    DateMax       IN Date                                       -- Tout les enregistrements supperieur a
                                                                -- la date sont purgé
) IS
   tempLogCtx  PLOG.LOG_CTX := PLOG.init(pSECTION => 'plog.purge', pLEVEL => PLOG.LINFO);
BEGIN
   checkAndInitCTX(pCTX);

 delete from tlog where ldate < DateMax;
 INFO(tempLogCtx, 'Purge by user:'||USER);

end purge;



--------------------------------------------------------------------
PROCEDURE log
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL      IN TLOG.LLEVEL%type                        ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
) IS

     lId        TLOG.ID%type        ;
     lLSECTION  TLOG.LSECTION%type  := getSection(pCTX); 
     lLHSECS    TLOG.LHSECS%type                       ;
     m varchar2(100);
     
BEGIN
    checkAndInitCTX(pCTX);
    IF pLEVEL > getLevel(pCTX) THEN
        RETURN;
    END IF;
    lId := getNextID(pCTX);

    log (   pCTX        =>pCTX,
            pID         =>lId,
            pLDate      =>sysdate,
            pLHSECS     =>DBMS_UTILITY.GET_TIME,
            pLLEVEL     =>pLEVEL,
            pLSECTION   =>lLSECTION,
            pLUSER      =>user,
            pLTEXTE     =>pTEXTE
        );                     
  
end log;

PROCEDURE log
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pLEVEL      IN TLOGLEVEL.LCODE%type                    ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel(pLEVEL), pCTX => pCTX, pTEXTE => pTEXTE); 
end log;


PROCEDURE log
(
    pLEVEL      IN TLOG.LLEVEL%type                        ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
) IS
   generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    LOG(pLEVEL => pLEVEL, pCTX => generiqueCTX, pTEXTE => pTEXTE); 
end log;

PROCEDURE log
(
    pLEVEL      IN TLOGLEVEL.LCODE%type                        ,  -- log level
    pTEXTE      IN TLOG.LTEXTE%type default DEFAULTEXTMESS    -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel(pLEVEL), pTEXTE => pTEXTE); 
end log;

--------------------------------------------------------------------
PROCEDURE debug
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null            -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('DEBUG'), pCTX => pCTX, pTEXTE => pTEXTE);
end debug;

PROCEDURE debug
(
    pTEXTE      IN TLOG.LTEXTE%type default null    -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('DEBUG'), pTEXTE => pTEXTE);
end debug;

--------------------------------------------------------------------
PROCEDURE info
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null    -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('INFO'), pCTX => pCTX,  pTEXTE => pTEXTE);
end info;
PROCEDURE info
(
    pTEXTE      IN TLOG.LTEXTE%type default null    -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('INFO'),  pTEXTE => pTEXTE);
end info;

--------------------------------------------------------------------
PROCEDURE warn
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type default null    -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('WARN'), pCTX => pCTX,  pTEXTE => pTEXTE);
end warn;
PROCEDURE warn
(
    pTEXTE      IN TLOG.LTEXTE%type default null    -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('WARN'),  pTEXTE => pTEXTE);
end warn;

--------------------------------------------------------------------
PROCEDURE error
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type  default null                         -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('ERROR'), pCTX => pCTX,  pTEXTE => pTEXTE);
end error;
PROCEDURE error
(
    pTEXTE      IN TLOG.LTEXTE%type  default null                         -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('ERROR'),  pTEXTE => pTEXTE);
end error;

--------------------------------------------------------------------
PROCEDURE fatal
(
    pCTX        IN OUT NOCOPY LOG_CTX                      ,  -- Context
    pTEXTE      IN TLOG.LTEXTE%type  default null             -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('FATAL'), pCTX => pCTX,  pTEXTE => pTEXTE);
end fatal;

PROCEDURE fatal
(
    pTEXTE      IN TLOG.LTEXTE%type default null                          -- log text
) IS
BEGIN
    LOG(pLEVEL => getTextInLevel('FATAL'),  pTEXTE => pTEXTE);
end fatal;

--------------------------------------------------------------------
PROCEDURE assert (
    pCTX                     IN OUT NOCOPY LOG_CTX                        , -- Context
    pCONDITION               IN BOOLEAN                                   , -- error condition 
    pLogErrorMessageIfFALSE  IN VARCHAR2 default 'assert condition error' , -- message if pCondition is true 
    pLogErrorCodeIfFALSE     IN NUMBER   default -20000                   , -- error code is pCondition is true range -20000 .. -20999  
    pRaiseExceptionIfFALSE   IN BOOLEAN  default FALSE                    , -- if true raise pException_in if pCondition is true 
    pLogErrorReplaceError    in BOOLEAN  default FALSE                      -- TRUE, the error is placed on the stack of previous errors. 
                                                                           -- If FALSE (the default), the error replaces all previous errors
                                                                           -- see Oracle Documentation RAISE_APPLICATION_ERROR

)
IS
BEGIN
  checkAndInitCTX(pCTX);
  IF not islevelEnabled(pCTX, PLOGPARAM.DEFAULT_ASSET_LEVEL) then
        RETURN;
  END IF;
  
  IF NOT pCONDITION THEN
     LOG (pLEVEL => PLOGPARAM.DEFAULT_ASSET_LEVEL, pCTX => pCTX,  pTEXTE => 'AAS'||pLogErrorCodeIfFALSE||': '||pLogErrorMessageIfFALSE);
     IF pRaiseExceptionIfFALSE THEN
        raise_application_error(pLogErrorCodeIfFALSE, pLogErrorMessageIfFALSE, pLogErrorReplaceError);
     END IF;
  END IF;
END assert;


PROCEDURE assert (
    pCONDITION               IN BOOLEAN                                   , -- error condition 
    pLogErrorMessageIfFALSE  IN VARCHAR2 default 'assert condition error' , -- message if pCondition is true 
    pLogErrorCodeIfFALSE     IN NUMBER   default -20000                   , -- error code is pCondition is true range -20000 .. -20999  
    pRaiseExceptionIfFALSE   IN BOOLEAN  default FALSE                    , -- if true raise pException_in if pCondition is true 
    pLogErrorReplaceError    in BOOLEAN  default FALSE                      -- TRUE, the error is placed on the stack of previous errors. 
                                                                           -- If FALSE (the default), the error replaces all previous errors
                                                                           -- see Oracle Documentation RAISE_APPLICATION_ERROR
)
IS
   generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
assert (
    pCTX                        => generiqueCTX,  
    pCONDITION                  => pCONDITION,  
    pLogErrorCodeIfFALSE        => pLogErrorCodeIfFALSE,
    pLogErrorMessageIfFALSE     => pLogErrorMessageIfFALSE,
    pRaiseExceptionIfFALSE      => pRaiseExceptionIfFALSE,
    pLogErrorReplaceError       => pLogErrorReplaceError );
END assert ;

--------------------------------------------------------------------
PROCEDURE full_call_stack
IS
   generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext;  
BEGIN
    full_call_stack (Pctx => generiqueCTX);
END full_call_stack;


PROCEDURE full_call_stack (
    pCTX                     IN OUT NOCOPY LOG_CTX                       -- Context
)
IS
BEGIN
     checkAndInitCTX(pCTX);
     LOG (pLEVEL => PLOGPARAM.DEFAULT_FULL_CALL_STACK_LEVEL, pCTX => pCTX,  pTEXTE => dbms_utility.format_call_stack );    
END full_call_stack;

--------------------------------------------------------------------
FUNCTION getLOG4PLSQVersion return varchar2 
IS
begin

    return LOG4PLSQL_VERSION;

end getLOG4PLSQVersion;

--------------------------------------------------------------------
FUNCTION getLevelInText (
    pLevel TLOG.LLEVEL%type default PLOGPARAM.DEFAULT_LEVEL 
) return  varchar2
IS
    ret varchar2(1000);
BEGIN
    
    SELECT LCODE into ret 
    FROM TLOGLEVEL
    WHERE LLEVEL = pLevel;
    RETURN ret;
EXCEPTION
    WHEN OTHERS THEN 
        return 'UNDEFINED';
END getLevelInText;
    
--------------------------------------------------------------------
FUNCTION getTextInLevel (
    pCode TLOGLEVEL.LCODE%type
) return  TLOG.LLEVEL%type 
IS
    ret TLOG.LLEVEL%type ;
BEGIN
    
    SELECT LLEVEL into ret 
    FROM TLOGLEVEL
    WHERE LCODE = pCode;
    RETURN ret;
EXCEPTION
    WHEN OTHERS THEN 
        return PLOGPARAM.DEFAULT_LEVEL;
END getTextInLevel;



FUNCTION getDBMS_PIPE_NAME 
(
    pCTX        IN OUT NOCOPY LOG_CTX                      -- Context
)
RETURN varchar2
IS
BEGIN
    return pCTX.DBMS_PIPE_NAME;
END getDBMS_PIPE_NAME;

FUNCTION getDBMS_PIPE_NAME
RETURN varchar2
IS
    generiqueCTX PLOG.LOG_CTX := PLOG.getDefaultContext; 
BEGIN
    return getDBMS_PIPE_NAME( pCTX => generiqueCTX);
end getDBMS_PIPE_NAME;


PROCEDURE setDBMS_PIPE_NAME
(
    pCTX             IN OUT NOCOPY LOG_CTX          ,  -- Context
    inDBMS_PIPE_NAME IN VARCHAR2 
)
IS
BEGIN
    pCTX.DBMS_PIPE_NAME := inDBMS_PIPE_NAME;
END setDBMS_PIPE_NAME;

--------------------------------------------------------------------
--------------------------------------------------------------------
END PLOG;
/

sho error


-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

