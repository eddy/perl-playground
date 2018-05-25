set underline off
set colsep ','
set feedback off
set flush off
set newpage none
set pagesize 50000
set linesize 1000
set verify off
set heading off

prompt State,Job Seq No.,Batch/Job No.,HPA MIPS No.,Job Name,Form Name,Ctl Docs,Extractions,Lodge QTY,Date,Time,Aust Post Lodgement No,Outstanding

-- Unconsolidated jobs report --
select upper(m.hb_mips_print_location)
     , q.qcs_sequence_no
     , replace(q.qcs_batch_no,'-1',qcs_job_no)
     , m.hb_mips_number
     , replace(j.ca_job_id,'_','#')
     , q.qcs_form_id
     , q.qcs_document_count
     , m.hb_mips_extractions
     , l.hb_mips_docs_lodged
     , l.hb_mips_date_lodged
     , l.hb_mips_time_lodged
     , l.hb_mips_lodgement_dockets
     , case
        when 
     (q.qcs_document_count
     - m.hb_mips_extractions
     - (select sum(hb_mips_docs_lodged)
        from   hpa_lodgement s
        where  s.hb_ref_no = l.hb_ref_no
        and    s.hb_stream = l.hb_stream
        and    to_date(s.hb_mips_date_lodged,'DD-MM-YY') <= to_date('&1','DD-MM-YY'))) < 0
     then '?'
     else to_char
     (q.qcs_document_count
     - m.hb_mips_extractions
     - (select sum(hb_mips_docs_lodged)
        from   hpa_lodgement s
        where  s.hb_ref_no = l.hb_ref_no
        and    s.hb_stream = l.hb_stream
        and    to_date(s.hb_mips_date_lodged,'DD-MM-YY') <= to_date('&1','DD-MM-YY'))) 
     end
from   client_qcs q
     , client_job j
     , hpa_mips_actuals m
     , client_actuals c
     , (select hb_ref_no
             , hb_stream
             , hb_mips_date_lodged
             , hb_mips_time_lodged
             , hb_mips_lodgement_dockets
             , hb_mips_docs_lodged
        from   hpa_lodgement
        where  hb_mips_date_lodged = '&1' ) l
where q.cj_job_ref_no   = j.cj_job_ref_no
and   j.hb_ref_no       = m.hb_ref_no
and   m.hb_ref_no       = l.hb_ref_no
and   m.hb_stream       = l.hb_stream
and   c.hb_ref_no       = m.hb_ref_no
and   c.cj_job_ref_no   = j.cj_job_ref_no
and   c.qcs_sequence_no = q.qcs_sequence_no
and   ( select count(*) from client_job where hb_ref_no = m.hb_ref_no ) = 1
order by m.hb_mips_print_location
       , substr(q.qcs_sequence_no,1,3)
       , to_number(substr(q.qcs_sequence_no,5))
       , replace(q.qcs_batch_no,'-1',qcs_job_no)
;

-- Consolidated jobs report --
SELECT UPPER(m.hb_mips_print_location)
     , 'CONSOLIDATED'
     , 'CONSOLIDATED'
     , m.hb_mips_number
     , cgi.hbci_report_name
     , 'CONSOLIDATED'
     , ( SELECT SUM(qcs_document_count)
         FROM client_qcs qcs_doctotal
            , client_job job_doctotal
         WHERE qcs_doctotal.cj_job_ref_no = job_doctotal.cj_job_ref_no
           AND job_doctotal.hb_ref_no = m.hb_ref_no
       )
     , m.hb_mips_extractions
     , l.hb_mips_docs_lodged
     , l.hb_mips_date_lodged
     , l.hb_mips_time_lodged
     , l.hb_mips_lodgement_dockets
     , to_char
       ( (select sum(q.qcs_document_count)
          from client_qcs q
             , client_job cj
          where q.cj_job_ref_no = cj.cj_job_ref_no
            and cj.hb_ref_no = m.hb_ref_no)
         - m.hb_mips_extractions
         - (select sum(hb_mips_docs_lodged)
            from   hpa_lodgement s
            where  s.hb_ref_no = l.hb_ref_no
            and    s.hb_stream = l.hb_stream
            and    to_date(s.hb_mips_date_lodged,'DD-MM-YY') <= to_date('&1','DD-MM-YY')))
from   hpa_mips_actuals m
     , hpa_batch b
     , hpa_consolidation_group_info cgi
     , hpa_lodgement l
where m.hb_ref_no               = l.hb_ref_no
and   m.hb_stream               = l.hb_stream
and   m.hb_ref_no               = b.hb_ref_no
and   b.hbc_consolidation_group = cgi.hbc_consolidation_group
and   l.hb_mips_date_lodged     = '&1' 
and   ( select count(*) from client_job where hb_ref_no = m.hb_ref_no ) > 1
order by m.hb_mips_print_location
;
quit
