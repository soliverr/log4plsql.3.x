-------------------------------------------------------------------
--
--  nom script         : tlog
--
--  objectif           : generic tool of log in a oracle database 
--                       same prototype and functionality that log4j.  
--                       http://jakarta.apacchhe.org/log4j
-------------------------------------------------------------------
--
-- history : who                 created     comment
--     v0    guillaume moulard   16-jul-02   creation
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

spo unInstall.log

DROP USER &&1  CASCADE
/

exit



-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

