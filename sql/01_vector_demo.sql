-- Semantic search inside Oracle Database 23ai/26ai Free: AI Vector Search with embeddings computed by Ollama,
-- called from PL/SQL. Re-runnable (recreates the table). Made-up data.
--   sql -name lab @sql/01_vector_demo.sql
@@config.sql

-- Helper: text -> vector, calling Ollama from the database
create or replace function embed(p_text in varchar2) return vector is
begin
  return dbms_vector.utl_to_embedding(
    p_text,
    json('{"provider":"ollama","host":"local","url":"&ollama_url/api/embeddings","model":"&embed_model"}'));
end;
/

begin execute immediate 'drop table faq purge'; exception when others then null; end;
/

create table faq (
  id       number generated always as identity primary key,
  category varchar2(30),
  text     varchar2(400),
  emb      vector(1024, float32)
);

insert into faq (category, text) values ('accounts', 'How can I open a joint current account with my wife?');
insert into faq (category, text) values ('accounts', 'Which documents do I need to close a savings account?');
insert into faq (category, text) values ('cards',    'I lost my debit card: how do I block it right away?');
insert into faq (category, text) values ('cards',    'Can the monthly spending limit of my credit card be raised?');
insert into faq (category, text) values ('mortgage', 'I would like to renegotiate the rate of my first-home mortgage.');
insert into faq (category, text) values ('mortgage', 'What is the difference between a fixed and a variable rate?');
insert into faq (category, text) values ('savings',  'How do I transfer my securities portfolio from another bank?');
insert into faq (category, text) values ('savings',  'How much does the yearly custody of investment funds cost?');
insert into faq (category, text) values ('access',   'I forgot my online banking password, how do I reset it?');
insert into faq (category, text) values ('access',   'The app asks for a one-time code but my phone does not get the SMS.');

-- Embeddings: one Ollama call per row, a few seconds in total
update faq set emb = embed(text);
commit;

-- Search by meaning: the words of the question do NOT appear in the rows it finds
set linesize 200
column text format a90
column category format a10
prompt
prompt === Question: "someone stole the card I use at the cash machine" ===
select category, round(vector_distance(emb, embed('someone stole the card I use at the cash machine'), cosine), 3) as distance, text
from faq order by distance fetch first 3 rows only;

prompt
prompt === Question in Italian: "tasso del mutuo della casa" (the rows are in English) ===
select category, round(vector_distance(emb, embed('tasso del mutuo della casa'), cosine), 3) as distance, text
from faq order by distance fetch first 3 rows only;

exit
