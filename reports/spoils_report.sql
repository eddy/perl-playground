set underline off
set colsep ','
set feedback off
set flush off
set newpage none
set pagesize 50000
set linesize 320
set verify off

-- This allows the PROD_STATE name to go through untruncated
COLUMN PROD_STATE FORMAT "A10"

SELECT mips.hb_mips_print_location AS PROD_STATE,
       mips.hb_mips_number AS MIPS_NUMBER,
       qcs.qcs_from_environment || '#' || qcs.qcs_job_name AS JOB_NAME,
       qcs.qcs_sequence_no || '/' || qcs.qcs_batch_no AS JSN_BATCH,
       qcs.qcs_document_count AS HOST_TOTAL,
       ca.hb_mips_spoils AS SPOILS
FROM client_actuals ca,
     hpa_mips_actuals mips,
     client_qcs qcs
WHERE ca.cj_job_ref_no = qcs.cj_job_ref_no
  AND ca.qcs_sequence_no = qcs.qcs_sequence_no
  AND ca.hb_ref_no = mips.hb_ref_no
  AND ca.hb_ref_no in ( SELECT lodge_sub.hb_ref_no
                        FROM hpa_lodgement lodge_sub
                        WHERE lodge_sub.hb_mips_date_lodged = '&1'
                      )
  AND ( select count(*)
        from client_job cj_sub
        where mips.hb_ref_no = cj_sub.hb_ref_no
      ) > 1
ORDER BY mips.hb_mips_print_location,
         qcs.qcs_job_name,
         qcs.qcs_from_environment,
         SUBSTR(qcs.qcs_sequence_no,2)
;
quit
