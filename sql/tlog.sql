-------------------------------------------------------------------
--
--  Nom script         : TLOG
--
--  Objectif           : Generic tool of log in a Oracle database 
--                       same prototype and functionality that log4j.  
--                       http://jakarta.apacchhe.org/log4j
-------------------------------------------------------------------
--
-- History : who                 created     comment
--     V1    Guillaume Moulard   18-AVR-02   Creation
--     V1.1  Guillaume Moulard   18-AVR-02   add LHSECS
--                                     
--
-------------------------------------------------------------------
/*
 * Copyright (C) LOG4PLSQL project team. All rights reserved.
 *
 * This software is published under the terms of the The LOG4PLSQL 
 * Software License, a copy of which has been included with this
 * distribution in the LICENSE.txt file.  
 * see: <http://log4plsql.sourceforge.net>  */


CREATE TABLE TLOG
(
 ID         number,
 LSID       number,
 LDate      DATE default sysdate,
 LHSECS     number,
 LLEVEL     number,
 LMODULE    varchar2(2000),
 LACTION    varchar2(2000),
 LSECTION   varchar2(2000),
 LTEXTE     varchar2(2000),
 LUSER      VARCHAR2(30),
 CONSTRAINT pk_TLOG PRIMARY KEY (id)
)
/

-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

