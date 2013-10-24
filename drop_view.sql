--
-- Drop given view
--

define L_VIEW_NAME = &1

declare
  l$cnt integer := 0;
begin
  select count(1) into l$cnt
    from sys.all_views
   where view_name = upper('&&L_VIEW_NAME')
     and owner = upper('&&ORA_SCHEMA_OWNER');

   if l$cnt > 0 then
     execute immediate 'drop view &&L_VIEW_NAME';
     dbms_output.put_line('I: View ' || upper('&&L_VIEW_NAME') || ' droped' );
   end if;
end;
/

undefine L_VIEW_NAME
