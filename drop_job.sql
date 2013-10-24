--
-- Drop clean job
--
--

prompt "I: Deleting jobs ..."

variable jobno number;
begin
  select job into :jobno
    from user_jobs
   where what = '"&&ORA_SCHEMA_OWNER".log4plsql_clean;';
  dbms_job.remove( :jobno );
exception
  when NO_DATA_FOUND then
     NULL;
  when OTHERS then
     raise_application_error(-20101, 'E: ' || SQLERRM(SQLCODE));
end;
/
