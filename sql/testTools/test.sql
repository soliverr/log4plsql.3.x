-------------------------------------------------------------------
--
--  Nom script         : test log4plsql
--
--  Objectif           : create a generique teqst package
-------------------------------------------------------------------
--
-- History : who                 created     comment
--     V1    Guillaume Moulard   18-AVR-02   Creation
--     V1.0  Guillaume Moulard   21-AUG-02   add trigger test
--
-------------------------------------------------------------------
/*
 * Copyright (C) LOG4PLSQL project team. All rights reserved.
 *
 * This software is published under the terms of the The LOG4PLSQL 
 * Software License, a copy of which has been included with this
 * distribution in the LICENSE.txt file.  
 * see: <http://log4plsql.sourceforge.net>  */
 
set linesize 200
set pagesize 2000

/*
CREATE USER "TESTLOG"  PROFILE "DEFAULT" 
    IDENTIFIED BY "testlog" DEFAULT TABLESPACE "USERS" 
    ACCOUNT UNLOCK;
GRANT "CONNECT" TO "TESTLOG";
GRANT "RESOURCE" TO "TESTLOG";
*/


connect testlog/testlog@gmdb 

alter package ulog.plog compile;
sho error


create or replace function func_test return number
is
    begin
    PLOG.purge;
    PLOG.debug;
    PLOG.info;
    PLOG.warn;
    PLOG.error;
    return 1;
end func_test;
/

create or replace procedure proc_test 
is
ret number;
myLogCtx PLOG.LOG_CTX := PLOG.init;
begin
    ret := func_test;
    PLOG.error (myLogCtx, 'mess error with ctx in proc_test ');
    PLOG.error ('mess error no ctx in proc_test ');
end;
/

drop table t_essais
/

create table t_essais
(
    data varchar2(255)
)
/

CREATE OR REPLACE TRIGGER  LOG_DML BEFORE
INSERT OR UPDATE OR DELETE 
ON T_ESSAIS FOR EACH ROW 
BEGIN
     IF DELETING OR UPDATING THEN 
         PLOG.INFO('T_ESSAIS:OLD:'||USER||':'||:old.data);
     END IF; 
    
     IF INSERTING OR UPDATING THEN 
          PLOG.INFO('T_ESSAIS:NEW:'||USER||':'||:new.data);
     END IF;
end;
/


create or replace package package_test 
is
procedure aproc;
end package_test;
/

create or replace package body package_test  
is
procedure aproc
is
    myLogCtx  PLOG.LOG_CTX := PLOG.init;
    myLogCtx1 PLOG.LOG_CTX := PLOG.init('TEST1');
begin
    plog.PURGE;
    proc_test;
    PLOG.error (myLogCtx, 'mess error with ctx in package_test');
    PLOG.error (myLogCtx1, 'mess error with ctx1 in package_test');
    PLOG.error ('mess error no ctx');

    insert into t_essais (DATA) values ('My data'||sysdate);
    update t_essais set data = data || 'upd'||sysdate;
end;
end package_test;
/


EXEC package_test.aproc;

exec PLOG.INFO('end');


spo c:\temp\az.lst

select * from ulog.vlog;

spo off

/* 
Attendue
LOG                                                                                                                                                                                                     
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
[21/08 23:02:55: 85][OFF    ][TESTLOG][plog.purge][Purge By TESTLOG]                                                                                                                                    
[21/08 23:02:55: 86][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.PROC_TEST.TESTLOG.FUNC_TEST][Mark]                                                                                            
[21/08 23:02:55: 86][WARNING][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.PROC_TEST.TESTLOG.FUNC_TEST][Mark]                                                                                            
[21/08 23:02:55: 99][ERROR  ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.PROC_TEST.TESTLOG.FUNC_TEST][Mark]                                                                                            
[21/08 23:02:55: 99][ERROR  ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.PROC_TEST][mess error with ctx in proc_test ]                                                                                 
[21/08 23:02:55: 99][ERROR  ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.PROC_TEST][mess error no ctx in proc_test ]                                                                                   
[21/08 23:02:55: 00][ERROR  ][TESTLOG][block.TESTLOG.PACKAGE_TEST][mess error with ctx in package_test]                                                                                                 
[21/08 23:02:55: 00][ERROR  ][TESTLOG][TEST1][mess error with ctx1 in package_test]                                                                                                                     
[21/08 23:02:55: 02][ERROR  ][TESTLOG][block.TESTLOG.PACKAGE_TEST][mess error no ctx]                                                                                                                   
[21/08 23:02:55: 03][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.LOG_DML][T_ESSAIS:NEW:TESTLOG:My data21/08/02]                                                                                
[21/08 23:02:55: 03][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.LOG_DML][T_ESSAIS:OLD:TESTLOG:My data21/08/02upd21/08/02upd21/08/02]                                                          
[21/08 23:02:55: 04][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.LOG_DML][T_ESSAIS:NEW:TESTLOG:My data21/08/02upd21/08/02upd21/08/02upd21/08/02]                                               
[21/08 23:02:55: 04][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.LOG_DML][T_ESSAIS:OLD:TESTLOG:My data21/08/02upd21/08/02]                                                                     
[21/08 23:02:55: 05][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.LOG_DML][T_ESSAIS:NEW:TESTLOG:My data21/08/02upd21/08/02upd21/08/02]                                                          
[21/08 23:02:55: 05][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.LOG_DML][T_ESSAIS:OLD:TESTLOG:My data21/08/02]                                                                                
[21/08 23:02:55: 06][INFO   ][TESTLOG][block.TESTLOG.PACKAGE_TEST.TESTLOG.LOG_DML][T_ESSAIS:NEW:TESTLOG:My data21/08/02upd21/08/02]                                                                     
[21/08 23:02:55: 18][INFO   ][TESTLOG][block][end]                                                                                                                                                      

17 ligne(s) sélectionnée(s).

*/




-------------------------------------------------------------------
-- End of document
-------------------------------------------------------------------

