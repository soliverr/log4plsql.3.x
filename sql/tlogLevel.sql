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

define L_TABLE_NAME = TLOGLEVEL

-- Create table if it not exists
declare
  l$cnt integer := 0;

  l$sql varchar2(1024) := '
CREATE TABLE &&L_TABLE_NAME  (
 LLEVEL       number (4,0),
 LSYSLOGEQUIV number (4,0),
 LCODE        varchar2(10),
 LDESC        varchar2(255),
 CONSTRAINT pk_TLOGLEVEL PRIMARY KEY (LLEVEL)
)';

begin
  select count(1) into l$cnt
    from sys.all_tables
   where table_name = '&&L_TABLE_NAME'
     and owner = upper('&&ORA_SCHEMA_OWNER');

   if l$cnt = 0 then
     begin
       execute immediate l$sql || ' tablespace &&ORA_TBSP_TBLS';
       dbms_output.put_line('I: Table &&L_TABLE_NAME created' );
     end;
    else
       dbms_output.put_line('W: Table &&L_TABLE_NAME already exists' );
   end if;
end;
/

comment on table "&&L_TABLE_NAME" is
'Message levels';

-- Load initial rows if table is empty
declare
  l$cnt integer := 0;
begin
  select count(1) into l$cnt from &&L_TABLE_NAME;

  if l$cnt = 0 then
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

    select count(1) into l$cnt from &&L_TABLE_NAME;
    dbms_output.put_line('I: ' || l$cnt || ' rows sucessfully loaded');
  end if;
end;
/

undefine L_TABLE_NAME

-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

