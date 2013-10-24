--
-- Drop given procedure
--
define L_PROC_NAME = &1

declare
  l$cnt integer := 0;
begin
  select count(1) into l$cnt
    from sys.all_procedures
   where object_name = upper('&&L_PROC_NAME')
     and owner = upper('&&ORA_SCHEMA_OWNER')
     and procedure_name is NULL;

   if l$cnt > 0 then
     execute immediate 'drop procedure &&L_PROC_NAME';
     dbms_output.put_line('I: Procedure ' || upper('&&L_PROC_NAME') || ' droped' );
   end if;
end;
/

undefine L_PROC_NAME
