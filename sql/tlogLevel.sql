-------------------------------------------------------------------
--
--  Nom script         : TLOGLEVEL
--
--  Objectif           : Generic tool of log in a Oracle database 
--                       same prototype and functionality that log4j.  
--                       http://jakarta.apacchhe.org/log4j
-------------------------------------------------------------------
--
-- History : who                 created     comment
--     V1    Guillaume Moulard   27-NOV-03   Creation
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


CREATE TABLE TLOGLEVEL
(
 LLEVEL       number (4,0),
 LSYSLOGEQUIV number (4,0),
 LCODE        varchar2(10),
 LDESC        varchar2(255),
 CONSTRAINT pk_TLOGLEVEL PRIMARY KEY (LLEVEL)
)
/

insert into TLOGLEVEL (LLEVEL, LCODE, LDESC) Values 
(10,'OFF', 'The OFF has the highest possible rank and is intended to turn off logging.');

insert into TLOGLEVEL (LLEVEL, LCODE, LDESC) Values 
(20,'FATAL', 'The FATAL level designates very severe error events that will presumably lead the application to abort.');

insert into TLOGLEVEL (LLEVEL, LCODE, LDESC) Values 
(30,'ERROR', 'the ERROR level designates error events that might still allow the application  to continue running.');

insert into TLOGLEVEL (LLEVEL, LCODE, LDESC) Values 
(40,'WARN', 'The WARN level designates potentially harmful situations.');

insert into TLOGLEVEL (LLEVEL, LCODE, LDESC) Values 
(50,'INFO', 'The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.');

insert into TLOGLEVEL (LLEVEL, LCODE, LDESC) Values 
(60,'DEBUG', 'The DEBUG Level designates fine-grained informational events that are most useful to debug an application.');

insert into TLOGLEVEL (LLEVEL, LCODE, LDESC) Values 
(70,'ALL', 'The ALL has the lowest possible rank and is intended to turn on all logging.');


commit;

-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

