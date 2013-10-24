--
-- Drop given package
--
define L_PKG_NAME = &1

declare
  l$cnt integer := 0;
begin
  select count(1) into l$cnt
    from sys.all_objects
   where object_name = upper('&&L_PKG_NAME')
     and owner = upper('&&ORA_SCHEMA_OWNER')
     and object_type = 'PACKAGE';

   if l$cnt > 0 then
     execute immediate 'drop package &&L_PKG_NAME';
     dbms_output.put_line('I: Package ' || upper('&&L_PKG_NAME') || ' droped' );
   end if;
end;
/

undefine L_PKG_NAME
