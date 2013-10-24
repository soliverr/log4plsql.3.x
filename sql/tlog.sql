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

define L_TABLE_NAME = TLOG

-- Create table if it not exists
declare
  l$cnt integer := 0;

  l$sql varchar2(1024) := '
CREATE TABLE &&L_TABLE_NAME  (
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
'Table to logging messages';

undefine L_TABLE_NAME

-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

