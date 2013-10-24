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

define L_SEQ_NAME = SLOG

-- Create sequence, if it not exists
declare
  l$cnt integer := 0;
  l$sql varchar2(1024) := '
CREATE SEQUENCE &&L_SEQ_NAME
    INCREMENT BY 1
    START WITH 1
    MAXVALUE 1.0E28
    CYCLE';
begin
  select count(1) into l$cnt
    from sys.all_sequences
   where sequence_name = '&&L_SEQ_NAME'
     and sequence_owner = upper('&&ORA_SCHEMA_OWNER');

   if l$cnt = 0 then
     begin
       execute immediate l$sql;
       dbms_output.put_line('I: Sequence &&L_SEQ_NAME created' );
     end;
   else
       dbms_output.put_line('W: Sequence &&L_SEQ_NAME already exists' );
   end if;
end;
/

-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

