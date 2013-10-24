--
-- Create clean jobs
--

prompt "I: Creating jobs ..."

variable jobno number;


begin
  begin
    select job into :jobno from user_jobs where what = '"&&ORA_SCHEMA_OWNER".log4plsql_clean;';
  exception
    when NO_DATA_FOUND then
      begin
        dbms_job.submit( :jobno,
                         '"&&ORA_SCHEMA_OWNER".log4plsql_clean;',
                         trunc(sysdate+1/24,'HH'),
                         'trunc(SYSDATE+12/24,''HH'')',
                         TRUE,
                         :l_instno );
        commit;
        dbms_output.put_line('I: Job log4plsql_clean installed');
      end;
    when OTHERS then
      raise_application_error(-20101, 'E: ' || SQLERRM(SQLCODE));
  end;
end;
/
