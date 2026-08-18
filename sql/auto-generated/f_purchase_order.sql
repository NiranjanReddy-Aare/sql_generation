/**********************************************************************
artefact name :- f_purchase_order
description   :- f_purchase_order sql generated via multi-pass CTE pipeline
----------------------------------------------------------------------
change log
version :   date :        description :                       changed by
----------------------------------------------------------------------
0.0         2026-08-18    auto-generated multi-pass            ai_agent
**********************************************************************/

with
po_unified as (
    select 
    null as acct_seq_nbr,
    cast((kcbu_quantity - kcbu_dlvd_qty) as double) as base_open_qty,
    cast(kcbu_quantity as double) as base_qty,
    cbu_qnt_unit as base_uom,
    tbu_qnt_unit as base_uom_text,
    null as blkt_cd,
    cbuyer as business_unit,
    cempl_resp as buyer_cd,
    templ_resp as buyer_name,
    cbuyer as co_cd,
    crc_nprc_amt_cur as co_curncy_cd,
    tbuyer as co_name,
    null as coi,
    null as contract_end_date,
    null as contract_flag,
    null as contract_start_date,
    null as contract_type,
    null as coo,
    ccost_centre as cost_centre_cd,
    tcost_centre as cost_centre_nm,
    'byd_brsbn' as src_sys_cd,
    1 as src_priority
from fct_purchase_order
union all
select 
    null as acct_seq_nbr,
    cast((kcbu_quantity - kcbu_dlvd_qty) as double) as base_open_qty,
    cast(kcbu_quantity as double) as base_qty,
    cbu_qnt_unit as base_uom,
    tbu_qnt_unit as base_uom_text,
    null as blkt_cd,
    cbuyer as business_unit,
    cempl_resp as buyer_cd,
    templ_resp as buyer_name,
    cbuyer as co_cd,
    crc_nprc_amt_cur as co_curncy_cd,
    tbuyer as co_name,
    null as coi,
    null as contract_end_date,
    null as contract_flag,
    null as contract_start_date,
    null as contract_type,
    null as coo,
    ccost_centre as cost_centre_cd,
    tcost_centre as cost_centre_nm,
    'byd_brsbn' as src_sys_cd,
    2 as src_priority
from fct_purchase_order_history
),
po_dedup as (
    select 
    acct_seq_nbr,
    cast((kcbu_quantity - kcbu_dlvd_qty) as double) as base_open_qty,
    cast(kcbu_quantity as double) as base_qty,
    cbu_qnt_unit as base_uom,
    tbu_qnt_unit as base_uom_text,
    null as blkt_cd,
    cbuyer as business_unit,
    cempl_resp as buyer_cd,
    templ_resp as buyer_name,
    cbuyer as co_cd,
    crc_nprc_amt_cur as co_curncy_cd,
    tbuyer as co_name,
    null as coi,
    null as contract_end_date,
    null as contract_flag,
    null as contract_start_date,
    null as contract_type,
    null as coo,
    ccost_centre as cost_centre_cd,
    tcost_centre as cost_centre_nm,
    row_number() over (partition by cpo_id, citm_id, ccost_centre order by src_priority) as rn
from po_unified
where rn = 1
),
supplier_extract as (
    select
    null as suplr_cat_no,
    date_format(sap_fct_purchase_order.citm_dlv_eddt, 'yyyyMMdd') as suplr_confrm_dt,
    date_format(sap_fct_purchase_order.citm_dlv_eddt, 'yyyyMMdd') as suplr_promise_delv_dt,
    trim(upper(sap_fct_purchase_order.cseller)) as supplier_cd,
    trim(upper(sap_fct_purchase_order.tseller)) as supplier_name,
    case 
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('DOMESTIC, THIRD PARTY', 'FOREIGN, THIRD PARTY') then '3rdParty'
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('INSIDE/OUTSIDE BG, AFFILIATED', 'INSIDE BG, AFFILIATED', 'EMPLOYEES') then 'IC'
        else null
    end as supplier_type_cd,
    cast(current_timestamp as string) as rec_crt_ts,
    cast(current_timestamp as string) as rec_updt_ts
from sap_fct_purchase_order
union all
select
    null as suplr_cat_no,
    date_format(fct_purchase_order_history.citm_dlv_eddt, 'yyyyMMdd') as suplr_confrm_dt,
    date_format(fct_purchase_order_history.citm_dlv_eddt, 'yyyyMMdd') as suplr_promise_delv_dt,
    trim(upper(fct_purchase_order_history.cseller)) as supplier_cd,
    trim(upper(fct_purchase_order_history.tseller)) as supplier_name,
    case 
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('DOMESTIC, THIRD PARTY', 'FOREIGN, THIRD PARTY') then '3rdParty'
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('INSIDE/OUTSIDE BG, AFFILIATED', 'INSIDE BG, AFFILIATED', 'EMPLOYEES') then 'IC'
        else null
    end as supplier_type_cd,
    cast(current_timestamp as string) as rec_crt_ts,
    cast(current_timestamp as string) as rec_updt_ts
from fct_purchase_order_history
left join dim_supplier_payment_data
    on trim(upper(fct_purchase_order_history.cseller)) = trim(upper(dim_supplier_payment_data.cbp_uuid))
),
product_extract as (
    select
    null as acct_seq_nbr,
    cast((sap_fct_purchase_order.kcbu_quantity - sap_fct_purchase_order.kcbu_dlvd_qty) as double) as base_open_qty,
    cast(sap_fct_purchase_order.kcbu_quantity as double) as base_qty,
    sap_fct_purchase_order.cbu_qnt_unit as base_uom,
    sap_fct_purchase_order.tbu_qnt_unit as base_uom_text,
    null as blkt_cd,
    sap_fct_purchase_order.cbuyer as business_unit,
    sap_fct_purchase_order.cempl_resp as buyer_cd,
    sap_fct_purchase_order.templ_resp as buyer_name,
    sap_fct_purchase_order.cbuyer as co_cd,
    sap_fct_purchase_order.crc_nprc_amt_cur as co_curncy_cd,
    sap_fct_purchase_order.tbuyer as co_name,
    null as coi,
    null as contract_end_date,
    null as contract_flag,
    null as contract_start_date,
    null as contract_type,
    null as coo,
    sap_fct_purchase_order.ccost_centre as cost_centre_cd,
    sap_fct_purchase_order.tcost_centre as cost_centre_nm,
    cast(current_timestamp as string) as rec_crt_ts,
    cast(current_timestamp as string) as rec_updt_ts
from (
    select * from sap_fct_purchase_order
    union all
    select * from fct_purchase_order_history
) sap_fct_purchase_order
),
org_unit_extract as (
    select
    null as acct_seq_nbr,
    cast((sap_fct_purchase_order.kcbu_quantity - sap_fct_purchase_order.kcbu_dlvd_qty) as double) as base_open_qty,
    cast(sap_fct_purchase_order.kcbu_quantity as double) as base_qty,
    sap_fct_purchase_order.cbu_qnt_unit as base_uom,
    sap_fct_purchase_order.tbu_qnt_unit as base_uom_text,
    null as blkt_cd,
    sap_fct_purchase_order.cbuyer as business_unit,
    sap_fct_purchase_order.cempl_resp as buyer_cd,
    sap_fct_purchase_order.templ_resp as buyer_name,
    sap_fct_purchase_order.cbuyer as co_cd,
    sap_fct_purchase_order.crc_nprc_amt_cur as co_curncy_cd,
    sap_fct_purchase_order.tbuyer as co_name,
    null as coi,
    null as contract_end_date,
    null as contract_flag,
    null as contract_start_date,
    null as contract_type,
    null as coo,
    sap_fct_purchase_order.ccost_centre as cost_centre_cd,
    sap_fct_purchase_order.tcost_centre as cost_centre_nm,
    cast(current_timestamp as string) as rec_crt_ts,
    cast(current_timestamp as string) as rec_updt_ts
from (
    select * from fct_purchase_order
    union all
    select * from fct_purchase_order_history
) sap_fct_purchase_order
),
po_receipt_with_row_number as (
    select 
    cref_po_uuid,
    cref_po_item_uuid,
    date_format(citm_dlv_eddt, 'yyyyMMdd') as last_recpt_dt,
    row_number() over (
        partition by cref_po_uuid, cref_po_item_uuid 
        order by citm_dlv_eddt desc
    ) as rn
from 
    sap_fct_purchase_order
union all
select 
    cref_po_uuid,
    cref_po_item_uuid,
    date_format(citm_dlv_eddt, 'yyyyMMdd') as last_recpt_dt,
    row_number() over (
        partition by cref_po_uuid, cref_po_item_uuid 
        order by citm_dlv_eddt desc
    ) as rn
from 
    fct_purchase_order_history
),
master_with_rank as (
    select 
    cmatr_int_id,
    csupplier_id,
    row_number() over (partition by cmatr_int_id order by csupplier_id asc) as rank
from 
    dim_master_ranked
where 
    planning_area != '5192'
),
txn_curr_mth as (
    select 
    yr_mth_nbr,
    from_curncy_cd,
    to_curncy_cd,
    cast(exch_rate as double) as exch_rate
from 
    d_curncy_mth_rt
where 
    trim(upper(to_curncy_cd)) = 'USD'
),
co_curr_mth as (
    select 
    yr_mth_nbr,
    from_curncy_cd,
    to_curncy_cd,
    cast(coalesce(exchange_rt, 0) as double) as exchange_rt
from 
    d_curncy_mth_rt
where 
    trim(upper(to_curncy_cd)) = 'USD'
),
final_joined_cte as (
    select
    po.acct_seq_nbr,
    cast((po.kcbu_quantity - po.kcbu_dlvd_qty) as double) as base_open_qty,
    po.kcbu_quantity as base_qty,
    po.cbu_qnt_unit as base_uom,
    po.tbu_qnt_unit as base_uom_text,
    cast(null as string) as blkt_cd,  -- TODO: review mapping
    po.cbuyer as business_unit,
    po.cempl_resp as buyer_cd,
    po.templ_resp as buyer_name,
    po.cbuyer as co_cd,
    po.crc_nprc_amt_cur as co_curncy_cd,
    po.tbuyer as co_name,
    cast(null as string) as coi,  -- TODO: review mapping
    cast(null as string) as contract_end_date,  -- TODO: review mapping
    cast(null as string) as contract_flag,  -- TODO: review mapping
    cast(null as string) as contract_start_date,  -- TODO: review mapping
    cast(null as string) as contract_type,  -- TODO: review mapping
    cast(null as string) as coo,  -- TODO: review mapping
    po.ccost_centre as cost_centre_cd,
    po.tcost_centre as cost_centre_nm,
    case 
        when po.citm_dlv_st_01 in ('1', '2') then 'N'
        when po.citm_dlv_st_01 = '3' then 'Y'
        else null
    end as delvr_cmplt_flg,
    cast(null as string) as dept_cd,  -- TODO: review mapping
    'DSD' as div_cd,
    cast(null as double) as dock_qty,  -- TODO: review mapping
    po.citm_dlv_eddt as due_dt,
    cast(null as string) as erp_commondity_cd,  -- TODO: review mapping
    cast(null as string) as erp_commondity_nm,  -- TODO: review mapping
    cast(po.kcrc_net_prc_amt * po.kcquantity as double) as ext_prc_co_amt,
    cast(po.kcrc_net_prc_amt * coalesce(co_curr_mth.co_pmar_rt, 0) as double) as ext_prc_co_pmar_amt,
    cast(po.kcnet_prc_amt * po.kcquantity as double) as ext_prc_txn_amt,
    cast(po.kcnet_prc_amt * coalesce(txn_curr_mth.po_pmar_rt, 0) as double) as ext_prc_txn_pmar_amt,
    'NA' as floor_stock_cd,
    po.cgl_acc_alias_cd as gl_account,
    po.cgl_acc_alias_cd as gl_acct_id,
    po.tgl_acc_alias_cd as gl_acct_nm,
    cast(null as string) as good_receipt_ind,  -- TODO: review mapping
    po.clfcycle_st as header_status_cd,
    case 
        when po.clfcycle_st = '10' then 'Closed'
        when po.clfcycle_st = '8' then 'Cancelled'
        else 'Open'
    end as header_status_nm,
    'PSBIOLC' as hfm_entity,
    po.cinc_class_cd as inco_terms_cd,
    po.tinc_class_cd as inco_terms_nm,
    if(trim(upper(po.citm_type)) = '18', 'Y', 'N') as inv_flg,
    if(trim(upper(po.citm_type)) = '18', 'Inventoried Item', 'NonInventoried Item') as inv_flg_text,
    po.citm_description as item_desc,
    po.cprd_uuid as item_nbr,
    po.citm_lfcycle_st as item_status_cd,
    po.titm_lfcycle_st as item_status_nm,
    cast(null as string) as job_no,  -- TODO: review mapping
    date_format(fct_po_receipt_latest.citm_dlv_eddt, 'yyyyMMdd') as last_recpt_dt,
    cast(null as string) as lcr_flag,  -- TODO: review mapping
    cast(null as string) as lcr_region,  -- TODO: review mapping
    cast(null as string) as line_seq,  -- TODO: review mapping
    cast(null as string) as nature,  -- TODO: review mapping
    cast(null as string) as nature_nm,  -- TODO: review mapping
    cast((po.kcquantity - po.kcdlvd_qty) as double) as open_qty,
    cast((po.kcquantity - po.kcdlvd_qty) * po.kcnet_prc_amt as double) as open_txn_amt,
    cast(((po.kcquantity - po.kcdlvd_qty) * po.kcnet_prc_amt) * coalesce(txn_curr_mth.po_pmar_rt, 0) as double) as open_txn_pmar_amt,
    po.kcquantity as orig_po_qty,
    cast(null as string) as part_rev_no,  -- TODO: review mapping
    cast(null as string) as pass_through_field,  -- TODO: review mapping
    cast(null as string) as pass_through_line,  -- TODO: review mapping
    cast(null as string) as payment_compliance_flg,  -- TODO: review mapping
    po.ccashdis_termscd as paymt_terms_cd,
    po.tcashdis_termscd as paymt_terms_desc,
    po.citm_dlv_eddt as plan_delvry_dt,
    cast(null as string) as planner_cd,  -- TODO: review mapping
    cast(null as string) as planner_name,  -- TODO: review mapping
    po.cordered_date as approval_dt_key,
    cast(null as string) as complt_dt_key,  -- TODO: review mapping
    po.citm_creat_date as po_crt_dt,
    coalesce(cast(d_dt.fscl_yr_prd_nbr as string), date_format(po.citm_creat_date, 'yyyyMM')) as po_crt_period,
    po.rcnet_prc_amt as po_curncy_cd,
    cast(null as string) as po_hdr_desc,  -- TODO: review mapping
    if(trim(upper(po.citm_oqtycan_st)) = '4', 'Y', 'N') as po_line_del_flg,
    po.citm_id as po_line_nbr,
    cast(null as string) as po_line_sq,  -- TODO: review mapping
    po.citm_type as po_line_type_cd,
    po.titm_type as po_line_type_nm,
    po.cpo_id as po_nbr,
    po.kcquantity as po_qty,
    dim_org_unit.ccity_name as ship_to_city_nm,
    dim_org_unit.ccntry_code as ship_to_cntry_cd,
    po.cbuyer as ship_to_entity_type_nm,
    po.tbuyer as po_ship_to_name,
    po.cprocess_type as po_type_cd,
    po.tprocess_type as po_type_nm,
    po.cquantity_unit as po_uom,
    po.tquantity_unit as po_uom_text,
    po.cbuyer as profit_cntr,
    cast(null as string) as purch_org_id,  -- TODO: review mapping
    po.cquantity_unit as purch_uom,
    po.tquantity_unit as purch_uom_text,
    cast(null as string) as ref_no,  -- TODO: review mapping
    po.cordered_date as release_dt,
    cast(null as string) as reporting_site,  -- TODO: review mapping
    cast(0 as double) as returned_qty,
    cast(null as string) as sec_supp_cd,  -- TODO: review mapping
    po.creceiving_site as site_id,
    if(trim(upper(po.citm_type)) = '18', 'Direct', 'Indirect') as spend_typ_cd,
    cast(null as string) as src_crt_by,  -- TODO: review mapping
    cast(current_timestamp as string) as src_crt_ts,
    'byd_brsbn' as src_sys_cd,
    cast(dim_master_ranked.kcvalpcomp as double) as stk_unit_price,
    cast(null as double) as stock_qty,  -- TODO: review mapping
    cast(null as string) as suplr_cat_no,  -- TODO: review mapping
    po.citm_dlv_eddt as suplr_confrm_dt,
    po.citm_dlv_eddt as suplr_promise_delv_dt,
    po.cseller as supplier_cd,
    po.tseller as supplier_name,
    case 
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('DOMESTIC, THIRD PARTY', 'FOREIGN, THIRD PARTY') then '3rdParty'
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('INSIDE/OUTSIDE BG, AFFILIATED', 'INSIDE BG, AFFILIATED', 'EMPLOYEES') then 'IC'
        else null
    end as supplier_type_cd,
    po.kcdlvd_qty as ttl_recpt_qty,
    cast(null as double) as txn_co_exch_rt,  -- TODO: review mapping
    cast(null as string) as unit,  -- TODO: review mapping
    cast(null as string) as unit_nm,  -- TODO: review mapping
    po.kcrc_net_prc_amt as unit_prc_co_amt,
    cast(po.kcrc_net_prc_amt * coalesce(co_curr_mth.co_pmar_rt, 0) as double) as unit_prc_co_pmar_amt,
    po.kcnet_prc_amt as unit_prc_txn_amt,
    cast(po.kcnet_prc_amt * coalesce(txn_curr_mth.po_pmar_rt, 0) as double) as unit_prc_txn_pmar_amt,
    round(po.kcbu_quantity / po.kcquantity, 2) as uom_conv_factor,
    dim_product_1.cs1ansd0a4bbea40ddd66 as vendor_mat_no,
    if(po.cprocess_type = 'THPA', 'Y', 'N') as vomi_flag,
    cast(null as string) as warehouse,  -- TODO: review mapping
    cast(null as string) as warehouse_nm,  -- TODO: review mapping
    cast(current_timestamp as string) as rec_crt_ts,
    cast(current_timestamp as string) as rec_updt_ts
from po_dedup po
left join dim_supplier_payment_data on trim(upper(po.cseller)) = trim(upper(dim_supplier_payment_data.cbp_uuid))
left join dim_product_1 on trim(upper(po.cprd_uuid)) = trim(upper(dim_product_1.cmatr_int_id)) and trim(upper(po.creceiving_site)) = trim(upper(dim_product_1.csite_id))
left join dim_org_unit on trim(upper(dim_org_unit.cco_id)) = trim(upper(po.cbuyer))
left join fct_po_receipt_latest on trim(upper(po.cpo_id)) = trim(upper(fct_po_receipt_latest.cref_po_uuid)) and trim(upper(po.citm_id)) = trim(upper(fct_po_receipt_latest.cref_po_item_uuid))
left join dim_master_ranked on trim(upper(po.cprd_uuid)) = trim(upper(dim_master_ranked.cmatr_int_id))
left outer join d_date d_dt on cast(date_format(po.citm_creat_date, 'yyyyMMdd') as string) = cast(d_dt.dt_key as string)
left outer join txn_curr_mth on trim(upper(txn_curr_mth.yr_mth_nbr)) = trim(upper(d_dt.fscl_yr_prd_nbr)) and trim(upper(txn_curr_mth.from_curncy_cd)) = trim(upper(po.rcnet_prc_amt))
left outer join co_curr_mth on trim(upper(co_curr_mth.yr_mth_nbr)) = trim(upper(d_dt.fscl_yr_prd_nbr)) and trim(upper(co_curr_mth.from_curncy_cd)) = trim(upper(po.crc_nprc_amt_cur))
),
main_select_with_left_joins_and_d_date as (
    select
    null as acct_seq_nbr,
    cast((kcbu_quantity - kcbu_dlvd_qty) as double) as base_open_qty,
    cast(kcbu_quantity as double) as base_qty,
    cbu_qnt_unit as base_uom,
    tbu_qnt_unit as base_uom_text,
    null as blkt_cd,
    cbuyer as business_unit,
    cempl_resp as buyer_cd,
    templ_resp as buyer_name,
    cbuyer as co_cd,
    crc_nprc_amt_cur as co_curncy_cd,
    tbuyer as co_name,
    null as coi,
    null as contract_end_date,
    null as contract_flag,
    null as contract_start_date,
    null as contract_type,
    null as coo,
    ccost_centre as cost_centre_cd,
    tcost_centre as cost_centre_nm,
    coalesce(cast(d_dt.fscl_yr_prd_nbr as string), date_format(citm_creat_date, 'yyyyMM')) as po_crt_period,
    date_format(fct_po_receipt_latest.citm_dlv_eddt, 'yyyyMMdd') as last_recpt_dt,
    cast(dim_master_ranked.kcvalpcomp as double) as stk_unit_price,
    if(trim(upper(citm_type)) = '18', 'Y', 'N') as inv_flg,
    if(trim(upper(citm_type)) = '18', 'Inventoried Item', 'NonInventoried Item') as inv_flg_text,
    if(trim(upper(citm_type)) = '18', 'Direct', 'Indirect') as spend_typ_cd,
    case 
        when clfcycle_st = '10' then 'Closed'
        when clfcycle_st = '8' then 'Cancelled'
        else 'Open'
    end as header_status_name,
    case 
        when tacct_det_creditor_group_code = '3rdParty' then '3rdParty'
        when tacct_det_creditor_group_code = 'IC' then 'IC'
        else null
    end as supplier_type,
    'PSBIOLC' as hfm_entity,
    'DSD' as div_cd,
    'NA' as floor_stock_cd,
    cast(0 as double) as returned_qty,
    cast(current_timestamp as string) as rec_crt_ts,
    cast(current_timestamp as string) as rec_updt_ts
from
    final_joined_cte
left join dim_supplier_payment_data on trim(upper(final_joined_cte.cseller)) = trim(upper(dim_supplier_payment_data.cbp_uuid))
left join dim_product_1 on trim(upper(final_joined_cte.cprd_uuid)) = trim(upper(dim_product_1.cmatr_int_id)) 
    and trim(upper(final_joined_cte.creceiving_site)) = trim(upper(dim_product_1.csite_id))
left join dim_org_unit on trim(upper(dim_org_unit.cco_id)) = trim(upper(final_joined_cte.cbuyer))
left join fct_po_receipt_latest on trim(upper(final_joined_cte.cpo_id)) = trim(upper(fct_po_receipt_latest.cref_po_uuid)) 
    and trim(upper(final_joined_cte.citm_id)) = trim(upper(fct_po_receipt_latest.cref_po_item_uuid))
left join dim_master_ranked on trim(upper(final_joined_cte.cprd_uuid)) = trim(upper(dim_master_ranked.cmatr_int_id))
left outer join d_date d_dt on cast(date_format(final_joined_cte.citm_creat_date, 'yyyyMMdd') as string) = cast(d_dt.dt_key as string)
left outer join txn_curr_mth on trim(upper(txn_curr_mth.yr_mth_nbr)) = trim(upper(d_dt.fscl_yr_prd_nbr)) 
    and trim(upper(txn_curr_mth.from_curncy_cd)) = trim(upper(final_joined_cte.rcnet_prc_amt))
left outer join co_curr_mth on trim(upper(co_curr_mth.yr_mth_nbr)) = trim(upper(d_dt.fscl_yr_prd_nbr)) 
    and trim(upper(co_curr_mth.from_curncy_cd)) = trim(upper(final_joined_cte.crc_nprc_amt_cur))
)
select
    null as acct_seq_nbr,
    cast((kcbu_quantity - kcbu_dlvd_qty) as double) as base_open_qty,
    kcbu_quantity as base_qty,
    cbu_qnt_unit as base_uom,
    tbu_qnt_unit as base_uom_text,
    null as blkt_cd,
    cbuyer as business_unit,
    cempl_resp as buyer_cd,
    templ_resp as buyer_name,
    cbuyer as co_cd,
    crc_nprc_amt_cur as co_curncy_cd,
    tbuyer as co_name,
    null as coi,
    null as contract_end_date,
    null as contract_flag,
    null as contract_start_date,
    null as contract_type,
    null as coo,
    ccost_centre as cost_centre_cd,
    tcost_centre as cost_centre_nm,
    case when citm_dlv_st_01 in ('1', '2') then 'N' when citm_dlv_st_01 = '3' then 'Y' else null end as delvr_cmplt_flg,
    null as dept_cd,
    'DSD' as div_cd,
    null as dock_qty,
    citm_dlv_eddt as due_dt,
    null as erp_commondity_cd,
    null as erp_commondity_nm,
    cast(kcrc_net_prc_amt * kcquantity as double) as ext_prc_co_amt,
    cast(kcrc_net_amt_01 * coalesce(co_curr_mth.co_pmar_rt, 0) as double) as ext_prc_co_pmar_amt,
    cast(kcnet_prc_amt * kcquantity as double) as ext_prc_txn_amt,
    cast(kcnet_amt * coalesce(txn_curr_mth.po_pmar_rt, 0) as double) as ext_prc_txn_pmar_amt,
    'NA' as floor_stock_cd,
    cgl_acc_alias_cd as gl_account,
    cgl_acc_alias_cd as gl_acct_id,
    tgl_acc_alias_cd as gl_acct_nm,
    null as good_receipt_ind,
    clfcycle_st as header_status_cd,
    case when clfcycle_st = '10' then 'Closed' when clfcycle_st = '8' then 'Cancelled' else 'Open' end as header_status_nm,
    'PSBIOLC' as hfm_entity,
    cinc_class_cd as inco_terms_cd,
    tinc_class_cd as inco_terms_nm,
    case when trim(upper(citm_type)) = '18' then 'Y' else 'N' end as inv_flg,
    case when trim(upper(citm_type)) = '18' then 'Inventoried Item' else 'NonInventoried Item' end as inv_flg_text,
    citm_description as item_desc,
    cprd_uuid as item_nbr,
    citm_lfcycle_st as item_status_cd,
    titm_lfcycle_st as item_status_nm,
    null as job_no,
    date_format(fct_po_receipt_latest.citm_dlv_eddt, 'yyyyMMdd') as last_recpt_dt,
    null as lcr_flag,
    null as lcr_region,
    null as line_seq,
    null as nature,
    null as nature_nm,
    cast((kcquantity - kcdlvd_qty) as double) as open_qty,
    cast((kcquantity - kcdlvd_qty) * kcnet_prc_amt as double) as open_txn_amt,
    cast(((kcquantity - kcdlvd_qty) * kcnet_prc_amt) * coalesce(txn_curr_mth.po_pmar_rt, 0) as double) as open_txn_pmar_amt,
    kcquantity as orig_po_qty,
    null as part_rev_no,
    null as pass_through_field,
    null as pass_through_line,
    null as payment_compliance_flg,
    ccashdis_termscd as paymt_terms_cd,
    tcashdis_termscd as paymt_terms_desc,
    citm_dlv_eddt as plan_delvry_dt,
    null as planner_cd,
    null as planner_name,
    cordered_date as approval_dt_key,
    null as complt_dt_key,
    citm_creat_date as po_crt_dt,
    coalesce(cast(d_dt.fscl_yr_prd_nbr as string), date_format(citm_creat_date, 'yyyyMM')) as po_crt_period,
    rcnet_prc_amt as po_curncy_cd,
    null as po_hdr_desc,
    case when trim(upper(citm_oqtycan_st)) = '4' then 'Y' else 'N' end as po_line_del_flg,
    citm_id as po_line_nbr,
    null as po_line_sq,
    citm_type as po_line_type_cd,
    titm_type as po_line_type_nm,
    cpo_id as po_nbr,
    kcquantity as po_qty,
    dim_org_unit.ccity_name as ship_to_city_nm,
    dim_org_unit.ccntry_code as ship_to_cntry_cd,
    cbuyer as ship_to_entity_type_nm,
    tbuyer as po_ship_to_name,
    cprocess_type as po_type_cd,
    tprocess_type as po_type_nm,
    cquantity_unit as po_uom,
    tquantity_unit as po_uom_text,
    cbuyer as profit_cntr,
    null as purch_org_id,
    cquantity_unit as purch_uom,
    tquantity_unit as purch_uom_text,
    null as ref_no,
    cordered_date as release_dt,
    null as reporting_site,
    cast(0 as double) as returned_qty,
    null as sec_supp_cd,
    creceiving_site as site_id,
    case when trim(upper(citm_type)) = '18' then 'Direct' else 'Indirect' end as spend_typ_cd,
    null as src_crt_by,
    null as src_crt_ts,
    'byd_brsbn' as src_sys_cd,
    cast(dim_master_ranked.kcvalpcomp as double) as stk_unit_price,
    null as stock_qty,
    null as suplr_cat_no,
    citm_dlv_eddt as suplr_confrm_dt,
    citm_dlv_eddt as suplr_promise_delv_dt,
    cseller as supplier_cd,
    tseller as supplier_name,
    case 
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('DOMESTIC, THIRD PARTY', 'FOREIGN, THIRD PARTY') then '3rdParty'
        when trim(upper(dim_supplier_payment_data.tacct_det_creditor_group_code)) in ('INSIDE/OUTSIDE BG, AFFILIATED', 'INSIDE BG, AFFILIATED', 'EMPLOYEES') then 'IC'
        else null
    end as supplier_type_cd,
    kcdlvd_qty as ttl_recpt_qty,
    null as txn_co_exch_rt,
    null as unit,
    null as unit_nm,
    kcrc_net_prc_amt as unit_prc_co_amt,
    cast(kcrc_net_prc_amt * coalesce(co_curr_mth.co_pmar_rt, 0) as double) as unit_prc_co_pmar_amt,
    kcnet_prc_amt as unit_prc_txn_amt,
    cast(kcnet_prc_amt * coalesce(txn_curr_mth.po_pmar_rt, 0) as double) as unit_prc_txn_pmar_amt,
    round(kcbu_quantity / kcquantity, 2) as uom_conv_factor,
    dim_product_1.cs1ansd0a4bbea40ddd66 as vendor_mat_no,
    case when cprocess_type = 'THPA' then 'Y' else 'N' end as vomi_flag,
    null as warehouse,
    null as warehouse_nm,
    cast(current_timestamp as string) as rec_crt_ts,
    cast(current_timestamp as string) as rec_updt_ts
from main_select_with_left_joins_and_d_date;