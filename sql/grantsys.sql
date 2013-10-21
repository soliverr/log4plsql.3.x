
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
--     V0    Guillaume Moulard   18-AVR-02   Creation
--     V3.0  Guillaume Moulard   04-AVR-02   Add grant for sys.dbms_system for log in alert.log.
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


SPO GRANTSYS.LOG

CREATE USER &&1  PROFILE "DEFAULT" 
    IDENTIFIED BY &&1
/
    
GRANT CONNECT TO &&1
/

GRANT RESOURCE TO &&1
/

GRANT ALL ON SYS.DBMS_PIPE TO &&1
/


GRANT CREATE PUBLIC SYNONYM TO &&1
/

GRANT DROP PUBLIC SYNONYM TO &&1
/

GRANT EXECUTE ON SYS.DBMS_SYSTEM TO &&1;
/

EXIT 




-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------