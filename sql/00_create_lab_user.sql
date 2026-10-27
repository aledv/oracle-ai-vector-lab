-- Creates (or recreates) the LAB schema. Run as SYS in the PDB, with the password as first argument:
--   docker compose exec -T oracle sqlplus -s / as sysdba @/dev/stdin <password> < sql/00_create_lab_user.sql
-- (sqlplus reads config.sql from the current folder: run it from sql/ or pass the defines by hand).
-- To start over: "drop user LAB cascade;" first.
@@config.sql
alter session set container=FREEPDB1;
create user LAB identified by "&1" default tablespace USERS quota 2G on USERS;
grant DB_DEVELOPER_ROLE to LAB;
grant create session, create table, create view, create sequence, create procedure, create mining model to LAB;
grant execute on DBMS_VECTOR to LAB;
grant execute on DBMS_VECTOR_CHAIN to LAB;
-- Let LAB call Ollama over HTTP for the embeddings
begin
  dbms_network_acl_admin.append_host_ace(host => '&ollama_host', lower_port => &ollama_port, upper_port => &ollama_port,
    ace => xs$ace_type(privilege_list => xs$name_list('connect'), principal_name => 'LAB', principal_type => xs_acl.ptype_db));
end;
/
exit
