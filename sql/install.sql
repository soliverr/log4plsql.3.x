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
--     v0    guillaume moulard   18-avr-02   creation
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
 

spo install.log

@@pmdc.sql
@@tlog.sql
@@tlogLevel.sql
@@slog.sql
@@plog.sql
@@vlog.sql
@@grant_synonym.sql

exit




-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

