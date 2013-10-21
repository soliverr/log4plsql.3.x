-------------------------------------------------------------------
--
--  Nom script         : Workload.sql
--
--  Objectif           : test a time use by log4plsql for loggin data
-------------------------------------------------------------------
--
-- History : who                 created     comment
--     V1    Guillaume Moulard   11-Jui-02   Creation
--                                     
--
-------------------------------------------------------------------
set linesize 200
set pagesize 2000

connect testlog/testlog@gmdb 

declare
    myLogCtx PLOG.LOG_CTX := PLOG.init;
begin 
    PLOG.purge (myLogCtx);
end;
/


Create or replace procedure testWorkload1 
is
    lCtx PLOG.LOG_CTX := PLOG.init ('perfTestWithoutlog', PLOG.LINFO);
begin
    plog.info(lCtx, 'Begin');
    commit;   
    for i in 1..1000000 loop
        plog.DEBUG (lCtx, 'neverInsertInTable');
    end loop;
    plog.info(lCtx, 'End');
    commit;        
end;
/


Create or replace procedure testWorkload2 
is
    lCtx PLOG.LOG_CTX := PLOG.init ('perfTestWithlog', PLOG.LINFO);
begin
    plog.info(lCtx, 'Begin');   
    for i in 1..100 loop
        for i in 1..10000 loop
            plog.WARN (lCtx, 'InsertInTable');
        end loop
        commit;
    end loop;
    plog.info(lCtx, 'End');
    commit;
end;
/


Create or replace procedure testWorkload3 
is
    lCtx PLOG.LOG_CTX := PLOG.init ('perfTestWithlog', PLOG.LINFO, TRUE);
begin
    PLOG.setTransactionMode(lCtx,TRUE);
    plog.info(lCtx, 'Begin');   
    for i in 1..1000000 loop
            plog.WARN (lCtx, 'InsertInTable');
    end loop;
    plog.info(lCtx, 'End');
    commit;
end;
/
l


begin
   testWorkload3;
end;
/
l

select count(*) "nbr line insert by log" from  ulog.tlog where LLEVEL = 4

l
/

select to_char(LDATE,'HH24:MI:SS  ') || LTEXTE from ulog.tlog where LLEVEL = 5

l
/


select min(nbr), max(nbr), avg(nbr)
from (select d, count(*) nbr 
      from (select to_char(LDATE,'HH24MISS') d
            from ulog.tlog where LLEVEL = 4 ) 
            group by d)


l
/            

