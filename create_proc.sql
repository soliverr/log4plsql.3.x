--
-- Clean log table
--

create or replace procedure log4plsql_clean( delta IN integer default 90 )  as
begin
   -- Don't delete last lines
   delete from tlog
    where trunc(ldate, 'HH') < (select trunc(max(ldate)-delta, 'HH') from tlog);
   commit;
end log4plsql_clean;
/
