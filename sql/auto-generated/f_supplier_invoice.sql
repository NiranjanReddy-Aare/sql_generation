/**********************************************************************
artefact name :- f_supplier_invoice
description   :- f_supplier_invoice sql generated via multi-pass CTE pipeline
----------------------------------------------------------------------
change log
version :   date :        description :                       changed by
----------------------------------------------------------------------
0.0         2026-08-18    auto-generated multi-pass            ai_agent
**********************************************************************/

with
branch_excluded as (
    select 
    branch_cd
from 
    d_branch_excluded
),
org_structure_map as (
    select distinct 
  company,
  bu as business_unit,
  region,
  division,
  legal_entity
from TODO_HYDRATE_ORG_STRUCTURE_MAPPING
),
gl_segment_split as (
    select 
    f0411.rpaid2 as gl_acct_id,
    f0901.gmdl01 as gl_acct_nm,
    case 
        when length(trim(f0411.rpaid2)) >= 8 then substr(trim(f0411.rpaid2), 1, 2)
        else null
    end as company_cd,
    case 
        when length(trim(f0411.rpaid2)) >= 8 then substr(trim(f0411.rpaid2), 3, 4)
        else null
    end as bu_cd,
    case 
        when length(trim(f0411.rpaid2)) >= 8 then substr(trim(f0411.rpaid2), 7, 6)
        else null
    end as account_cd,
    case 
        when length(trim(f0411.rpaid2)) >= 8 then substr(trim(f0411.rpaid2), 13)
        else null
    end as subaccount_cd
from f0411
left join f0901 
    on f0411.rpaid2 = f0901.gmaid
),
hfm_entity_map as (
    select 
    company,
    business_unit,
    hfm_entity,
    'e1' as src_sys_cd
from 
    TODO_HYDRATE_HFM_ENTITIES
),
payment_term_map as (
    select 
    f0411.rpptc as ap_payment_term_cd,
    f0014.pnptd as ap_payment_term_desc,
    case 
        when f0411.rpapp = f0411.rpag then cast(null as string) -- TODO: No payment made
        when f0411.rpapp <> f0411.rpag then (
            select max(f0413.rmdmtj) 
            from f0414 
            left join f0413 
            on f0414.rnpyid = f0413.rmpyid 
            where f0414.rndoc = f0411.rpdoc 
            and f0414.rndct = f0411.rpdct 
            and f0414.rnkco = f0411.rpkco
        )
        else cast(null as string) -- TODO: Handle unexpected cases
    end as actual_payment_dt,
    f_supplier_invoice.being_done_outside_of_system as payment_compliance_flg
from f0411
left join f0014 
on f0411.rpptc = f0014.ptc
),
invoice_header as (
    select 
    cast(
        cast(cast(f0411.rpctry as int) as string) ||
        cast(
            case
                when f0411.rpfy < 10 then concat('0', cast(cast(f0411.rpfy as integer) as string))
                else cast(cast(f0411.rpfy as integer) as string)
            end
        as string) ||
        cast(
            case
                when f0411.rppn < 10 then concat('0', cast(cast(f0411.rppn as integer) as string))
                else cast(cast(f0411.rppn as integer) as string)
            end
        as string)
    as string) as invc_entry_period,
    f0411.rpdicj as invc_entry_dt,
    f0411.rpdivj as suplr_invc_dt,
    f0411.rpvinv as suplr_invc_nbr,
    cast(null as string) as invc_apprv_id,
    f43121.pruptd / 10000 as invc_qty,
    case 
        when upper(trim(f0411.rpcrrm)) = 'D' then coalesce(f43121.praptd / 100, 0)
        when upper(trim(f0411.rpcrrm)) = 'F' then coalesce(f43121.prfapt / 100, 0)
    end as invc_txn_amt,
    case 
        when upper(trim(f0411.rpcrrm)) = 'D' then coalesce(f43121.praptd / 100, 0)
        when upper(trim(f0411.rpcrrm)) = 'F' then coalesce(f43121.prfapt / 100, 0)
    end as invc_co_amt,
    cast(null as string) as invc_txn_pmar_amt,
    cast(null as string) as invc_co_pmar_amt,
    f43121.pruom as invc_uom_cd,
    cast(null as string) as invc_txn_amt_clsfctn, -- TODO: Add logic for classification
    f0411.rpdgj as invc_post_dt,
    f0411z1 as extrnl_invc_nbr,
    cast(null as string) as extrnl_invc_sys_nm
from f0411
left join f43121
    on f0411.rpdoc = f43121.prdoc
    and f0411.rppkco = f43121.prkcoo
    and trim(f43121.prmatc) in ('2')
left join f4311
    on f0411.rppo = f4311.pddoco
    and f0411.rpdct = f4311.pddcto
    and f0411.rppkco = f4311.pdkco
where f0411.rpdoc is not null
),
invoice_distribution as (
    select 
    'e1' as src_sys_cd,
    cast(
        cast(cast(f0411.rpctry as int) as string) ||
        cast(
            case
                when f0411.rpfy < 10 then concat('0', cast(cast(f0411.rpfy as integer) as string))
                else cast(cast(f0411.rpfy as integer) as string)
            end
        as string) ||
        cast(
            case
                when f0411.rppn < 10 then concat('0', cast(cast(f0411.rppn as integer) as string))
                else cast(cast(f0411.rppn as integer) as string)
            end
        as string)
    as string) as invc_entry_period,
    f43121.prdoco as po_nbr,
    case 
        when f0411.rpdoc = f43121.prdoc 
             and f0411.rppkco = f43121.prkcoo 
             and trim(f43121.prmatc) in ('2') 
        then f43121.prlnid 
        else null 
    end as c,
    f0411.rpdoc as vchr_nbr,
    f0411.rplnid as vchr_line_nbr,
    concat(f0411.rpctry, f0411.rpfy) as fscl_yr_nbr,
    f0411.rpdct as vchr_type_cd,
    cast(null as string) as vchr_status,
    case 
        when f43121.prdoco = f4311.pddoco 
             and f43121.prlnid = f4311.pdlnid 
             and f43121.prkcoo = f4311.pdkcoo 
        then f4311.pditm 
        else null 
    end as item_nbr,
    sum(f0911.glaa / 100.0) as dist_amt
from f0911
left join f0411
    on f0911.gldoc = f0411.rpdoc 
    and f0911.gldct = f0411.rpdct 
    and f0911.glco = f0411.rpco
left join f43121
    on f0411.rpdoc = f43121.prdoc 
    and f0411.rppkco = f43121.prkcoo 
    and trim(f43121.prmatc) in ('2')
left join f4311
    on f0411.rppo = f4311.pddoco 
    and f0411.rpdct = f4311.pddcto 
    and f0411.rppkco = f4311.pdkco
group by 
    f0911.glco, 
    f0911.gldoc, 
    f0911.gldct, 
    f0411.rpdoc, 
    f0411.rplnid, 
    f0411.rpctry, 
    f0411.rpfy, 
    f0411.rppn, 
    f0411.rpdct, 
    f43121.prdoco, 
    f43121.prdoc, 
    f43121.prlnid, 
    f43121.prkcoo, 
    f4311.pddoco, 
    f4311.pddcto, 
    f4311.pdkcoo, 
    f4311.pditm
),
supplier_extract as (
    select 
    f0101.aban8 as supplier_cd,
    f0101.abalph as supplier_name,
    case 
        when f0401.aban8 is not null and f0101.aban8 < 10000 then 'Intercompany'
        else 'External'
    end as supplier_type_cd,
    to_date(cast(f0411.rpdivj as string), 'YYYYDDD') as suplr_invc_dt,
    f0411.rpvinv as suplr_invc_nbr,
    f0401.a6trap as suplr_paymt_terms_cd,
    f0014.pnptd as suplr_paymt_terms_desc,
    'supplier_invoice' as suplr_nm_src
from 
    f0411
left join 
    f0101 on f0411.rpan8 = f0101.aban8
left join 
    f0401 on f0101.aban8 = f0401.aban8
left join 
    f0014 on f0014.ptc = f0411.rpptc
),
po_detail as (
    select
    'e1' as src_sys_cd,
    cast(
        cast(cast(f0411.rpctry as int) as string) ||
        cast(
            case
                when f0411.rpfy < 10 then concat('0', cast(cast(f0411.rpfy as integer) as string))
                else cast(cast(f0411.rpfy as integer) as string)
            end
        as string) ||
        cast(
            case
                when f0411.rppn < 10 then concat('0', cast(cast(f0411.rppn as integer) as string))
                else cast(cast(f0411.rppn as integer) as string)
            end
        as string
    ) as string
    ) as invc_entry_period,
    f43121.prdoco as po_nbr,
    f0411.rpdoc = f43121.prdoc and f0411.rppkco = f43121.prkcoo and trim(f43121.prmatc) in ('2') as c,
    f0411.rpdoc as vchr_nbr,
    f0411.rplnid as vchr_line_nbr,
    concat(f0411.rpctry, f0411.rpfy) as fscl_yr_nbr,
    f0411.rpdct as vchr_type_cd,
    null as vchr_status,
    f4311.pditm as item_nbr,
    f4311.pddsc1 as item_desc,
    f4311.pdlitm as thermo_item_nbr,
    f0411.rpan8 as supplier_cd,
    f0101.abalph as supplier_name,
    case
        when f0411.rpan8 < 10000 then 'Intercompany'
        else null
    end as supplier_type_cd,
    f4311.anby as buyer_cd,
    f0101.abalph as buyer_name,
    f43121.kcoo as co_cd,
    f0411.rpco as co_name,
    null as hfm_entity
from f0411
left join f43121
    on f0411.rpdoc = f43121.prdoc
    and f0411.rppkco = f43121.prkcoo
    and trim(f43121.prmatc) in ('2')
left join f4311
    on f0411.rppo = f4311.pddoco
    and f0411.rpdct = f4311.pddcto
    and f0411.rppkco = f4311.pdkco
left join f0101
    on f0411.rpan8 = f0101.aban8
),
po_receipt as (
    select 
    'e1' as src_sys_cd,
    cast(
        cast(cast(f0411.rpctry as int) as string) ||
        cast(
            case
                when f0411.rpfy < 10 then concat('0', cast(cast(f0411.rpfy as integer) as string))
                else cast(cast(f0411.rpfy as integer) as string)
            end
        as string) ||
        cast(
            case
                when f0411.rppn < 10 then concat('0', cast(cast(f0411.rppn as integer) as string))
                else cast(cast(f0411.rppn as integer) as string)
            end
        as string)
    as string) as invc_entry_period,
    f43121.prdoco as po_nbr,
    f0411.rpdoc as vchr_nbr,
    f0411.rplnid as vchr_line_nbr,
    concat(f0411.rpctry, f0411.rpfy) as fscl_yr_nbr,
    f0411.rpdct as vchr_type_cd,
    null as vchr_status,
    case 
        when f43121.prdoco = f4311.pddoco 
             and f43121.prlnid = f4311.pdlnid 
             and f43121.prkcoo = f4311.pdkcoo 
        then f4311.pditm 
        else null 
    end as item_nbr,
    null as item_desc,
    null as thermo_item_nbr,
    f0411.rpan8 as supplier_cd,
    null as supplier_name,
    null as supplier_type_cd,
    null as buyer_cd,
    null as buyer_name,
    f43121.prkcoo as co_cd,
    f0411.rpco as co_name,
    null as hfm_entity
from f0411
inner join f43121 
    on f0411.rpdoc = f43121.prdoc 
    and f0411.rppkco = f43121.prkcoo 
    and trim(f43121.prmatc) in ('2')
left join f4311 
    on f0411.rppo = f4311.pddoco 
    and f0411.rpdct = f4311.pddcto 
    and f0411.rppkco = f4311.pdkco
),
address_book_ext as (
    select 
    f0116.aban8 as address_book_number,
    f0116.alky as address_type,
    f0116.aladd1 as address_line_1,
    f0116.aladd2 as address_line_2,
    f0116.aladd3 as address_line_3,
    f0116.aladd4 as address_line_4,
    f0116.alcity as city,
    f0116.alcty1 as county,
    f0116.alstate as state,
    f0116.alctr as country,
    f0116.alzip as postal_code,
    f0101.abalph as supplier_name
from f0116
left join f0101
    on f0116.aban8 = f0101.aban8
),
account_master as (
    select 
    'e1' as src_sys_cd,
    cast(
        cast(cast(f0411.rpctry as int) as string) ||
        cast(
            case
                when f0411.rpfy < 10 then concat('0', cast(cast(f0411.rpfy as integer) as string))
                else cast(cast(f0411.rpfy as integer) as string)
            end
        as string) ||
        cast(
            case
                when f0411.rppn < 10 then concat('0', cast(cast(f0411.rppn as integer) as string))
                else cast(cast(f0411.rppn as integer) as string)
            end
        as string)
    as string) as invc_entry_period,
    f43121.prdoco as po_nbr,
    case 
        when f0411.rpdoc = f43121.prdoc 
             and f0411.rppkco = f43121.prkcoo 
             and trim(f43121.prmatc) in ('2') 
        then f43121.prlnid 
        else null 
    end as c,
    f0411.rpdoc as vchr_nbr,
    f0411.rplnid as vchr_line_nbr,
    concat(f0411.rpctry, f0411.rpfy) as fscl_yr_nbr,
    f0411.rpdct as vchr_type_cd,
    null as vchr_status,
    case 
        when f43121.prdoco = f4311.pddoco 
             and f43121.prlnid = f4311.pdlnid 
             and f43121.prkcoo = f4311.pdkcoo 
        then f4311.pditm 
        else null 
    end as item_nbr,
    f4311.pddsc1 as item_desc,
    f4311.pdlitm as thermo_item_nbr,
    f0411.rpan8 as supplier_cd,
    f0101.abalph as supplier_name,
    case 
        when f0411.rpan8 < 10000 then f0401.abmcu 
        else null 
    end as supplier_type_cd,
    f4311.anby as buyer_cd,
    f0101.alph as buyer_name,
    f43121.kcoo as co_cd,
    f0411.rpco as co_name,
    null as hfm_entity
from f0411
left join f43121 
    on f0411.rpdoc = f43121.prdoc 
    and f0411.rppkco = f43121.prkcoo 
    and trim(f43121.prmatc) in ('2')
left join f4311 
    on f0411.rppo = f4311.pddoco 
    and f0411.rpdct = f4311.pddcto 
    and f0411.rppkco = f4311.pdkco
left join f0101 
    on f0411.rpan8 = f0101.aban8
left join f0401 
    on f0411.rpan8 = f0401.aban8
),
payment_term_lookup as (
    select 
    f0014.ptc as ap_payment_term_cd,
    f0014.pnptd as ap_payment_term_desc
from 
    f0014
),
business_unit_lookup as (
    select 
    'e1' as src_sys_cd,
    mcu as business_unit_cd,
    substr(drmcu, 1, 12) as business_unit_name
from 
    f0006
where 
    substr(mcu, 1, 12) not in (select branch_cd from branch_excluded)
),
final_joined as (
    select
    'e1' as src_sys_cd,
    cast(
        cast(cast(f0411.rpctry as int) as string) ||
        cast(
            case
                when f0411.rpfy < 10 then concat('0', cast(cast(f0411.rpfy as integer) as string))
                else cast(cast(f0411.rpfy as integer) as string)
            end
        as string) ||
        cast(
            case
                when f0411.rppn < 10 then concat('0', cast(cast(f0411.rppn as integer) as string))
                else cast(cast(f0411.rppn as integer) as string)
            end
        as string)
    as string) as invc_entry_period,
    f43121.prdoco as po_nbr,
    f0411.rpdoc as vchr_nbr,
    f0411.rplnid as vchr_line_nbr,
    concat(f0411.rpctry, f0411.rpfy) as fscl_yr_nbr,
    f0411.rpdct as vchr_type_cd,
    cast(null as string) as vchr_status, -- TODO: review mapping
    f4311.pdlitm as item_nbr,
    f4311.pddsc1 as item_desc,
    f4311.pdlitm as thermo_item_nbr,
    f0411.rpan8 as supplier_cd,
    f0101.abalph as supplier_name,
    cast(null as string) as supplier_type_cd, -- TODO: review mapping
    f4311.anby as buyer_cd,
    f0101.abalph as buyer_name,
    f43121.kcoo as co_cd,
    f0411.rpco as co_name,
    hfm_entity_map.hfm_entity as hfm_entity,
    f0411.rpmcu as business_unit,
    cast(null as string) as lcr_flag, -- TODO: review mapping
    cast(null as string) as lcr_region, -- TODO: review mapping
    case when f43121.pxnrou in ('SPKC', 'CONS') then 'Y' else 'N' end as vomi_flag,
    cast(null as string) as payment_compliance_flg, -- TODO: review mapping
    f0411.rpcrcd as po_curncy_cd,
    f0006.co_curncy_cd as co_curncy_cd,
    cast(
        cast(cast(f0411.rpctry as int) as string) ||
        cast(
            case
                when f0411.rpfy < 10 then concat('0', cast(cast(f0411.rpfy as integer) as string))
                else cast(cast(f0411.rpfy as integer) as string)
            end
        as string) ||
        cast(
            case
                when f0411.rppn < 10 then concat('0', cast(cast(f0411.rppn as integer) as string))
                else cast(cast(f0411.rppn as integer) as string)
            end
        as string)
    as string) as post_yr_mth_nbr,
    to_date(cast(f0411.rpdicj as string), 'YYYYDDD') as invc_entry_dt,
    to_date(cast(f0411.rpddj as string), 'YYYYDDD') as paymt_due_dt,
    to_date(cast(f0411.rpdivj as string), 'YYYYDDD') as suplr_invc_dt,
    cast(null as string) as aprval_dt, -- TODO: review mapping
    f0411.rptxa1 as txn_orig_id,
    f0411.rpvinv as suplr_invc_nbr,
    cast(null as string) as invc_apprv_id, -- TODO: review mapping
    cast(
        case
            when upper(trim(f0411.rpcrrm)) = 'D' then coalesce(
                case
                    when f43121.pruom = f43121.pruom3 then f43121.prprrc / 10000
                    else (f43121.prprrc / 10000) * coalesce(ccost.conv_cost, 1)
                end, 0)
            when upper(trim(f0411.rpcrrm)) = 'F' then coalesce(
                case
                    when f43121.pruom = f43121.pruom3 then f43121.prfrrc / 10000
                    else (f43121.prfrrc / 10000) * coalesce(ccost.conv_cost, 1)
                end, 0)
        end as double) as unit_prc,
    f43121.pruptd / 10000 as invc_qty,
    cast(
        case
            when f43121.pruom = f4101.imuom1 then f43121.pruptd / 10000
            else (f43121.pruptd / 10000) * coalesce(cqty.conv_qty, 1)
        end as double) as base_qty,
    case
        when upper(trim(f0411.rpcrrm)) = 'D' then coalesce(f43121.praptd / 100, 0)
        when upper(trim(f0411.rpcrrm)) = 'F' then coalesce(f43121.prfapt / 100, 0)
    end as invc_txn_amt,
    case
        when upper(trim(f0411.rpcrrm)) = 'D' then coalesce(f43121.praptd / 100, 0)
        when upper(trim(f0411.rpcrrm)) = 'F' then coalesce(f43121.prfapt / 100, 0)
    end as invc_co_amt,
    cast(null as double) as invc_txn_pmar_amt, -- TODO: review mapping
    cast(null as double) as invc_co_pmar_amt, -- TODO: review mapping
    cast(null as double) as unit_prc_pmar_amt, -- TODO: review mapping
    cast(null as double) as txn_curncy_mth_rt, -- TODO: review mapping
    cast(null as double) as co_curncy_mth_rt, -- TODO: review mapping
    cast(null as double) as uom_conv_factor, -- TODO: review mapping
    f43121.pruom as invc_uom_cd,
    f4101.imuom1 as base_uom_cd,
    f4102.srp2 as profit_cntr,
    div_lkup.lkup_val_01 as div_cd,
    f0411.rpmcu as site_cd,
    cast(null as string) as site_name, -- TODO: review mapping
    f43121.prkcoo as reporting_site,
    cast(null as string) as warehouse, -- TODO: review mapping
    cast(null as string) as warehouse_nm, -- TODO: review mapping
    cast(null as string) as unit, -- TODO: review mapping
    cast(null as string) as nature, -- TODO: review mapping
    case
        when upper(trim(f4311.pdlnty)) = 'Z' then 'N'
        else 'Y'
    end as inv_flg,
    case
        when trim(f4311.pdlnty) = 'S' then 'Inventoried Item'
        else 'Non-Inventoried Item'
    end as inv_flg_text,
    case
        when trim(f40205.ivi) in ('Y', 'D') then 'Direct'
        else 'Indirect'
    end as spend_type_cd,
    f4311.pdptc as po_paymt_terms_cd,
    f0014.ptdsc as po_paymt_terms_desc,
    f0411.rpptc as ap_payment_term_cd,
    f0014.ptdsc as ap_payment_term_desc,
    f0401.a6trap as suplr_paymt_terms_cd,
    f0014.ptdsc as suplr_paymt_terms_desc,
    cast(null as string) as contract_flag, -- TODO: review mapping
    cast(null as string) as contract_type, -- TODO: review mapping
    cast(null as date) as contract_start_date, -- TODO: review mapping
    cast(null as date) as contract_end_date, -- TODO: review mapping
    cast(null as string) as fk_orig, -- TODO: review mapping
    cast(null as string) as floor_stock_cd, -- TODO: review mapping
    cast(null as string) as erp_commondity_cd, -- TODO: review mapping
    cast(null as string) as erp_commondity_nm, -- TODO: review mapping
    cast(null as string) as sec_supp_cd, -- TODO: review mapping
    cast(null as string) as part_rev_no, -- TODO: review mapping
    f0411.rpmcu as cost_centre_cd,
    f0006.dl01 as cost_centre_nm,
    f4104.ivitm as vendor_mat_no,
    f0411.rpaid2 as gl_acct_id,
    f0901.gmdl01 as gl_acct_nm,
    cast(null as string) as pass_through_field, -- TODO: review mapping
    cast(null as string) as pass_through_line, -- TODO: review mapping
    f0411.rprmk as inv_line_desc,
    f0116.aladd1 as remit_to_addr_line_1,
    f0116.aladd2 as remit_to_addr_line_2,
    f0116.aladd3 as remit_to_addr_line_3,
    f0116.aladd4 as remit_to_addr_line_4,
    f0116.alcty1 as remit_to_city_nm,
    f0116.aladds as remit_to_st_cd,
    cast(null as string) as remit_to_rgn_cd, -- TODO: review mapping
    cast(null as string) as remit_to_rgn_nm, -- TODO: review mapping
    f0116.alctr as remit_to_cntry_cd,
    cast(null as string) as remit_to_cntry_nm, -- TODO: review mapping
    'supplier_invoice' as suplr_nm_src,
    cast(null as string) as invc_txn_amt_clsfctn, -- TODO: review mapping
    cast(null as date) as actual_payment_dt, -- TODO: review mapping
    to_date(cast(f0411.rpdgj as string), 'YYYYDDD') as invc_post_dt,
    cast(null as string) as extrnl_invc_nbr, -- TODO: review mapping
    cast(null as string) as extrnl_invc_sys_nm -- TODO: review mapping
from
    invoice_header f0411
left join
    invoice_distribution f0911 on f0411.rpdoc = f0911.gldoc and f0411.rpdct = f0911.gldct and f0411.rpco = f0911.glco
left join
    supplier_extract f0101 on f0411.rpan8 = f0101.aban8
left join
    po_receipt f43121 on f0411.rpdoc = f43121.prdoc and f0411.rppkco = f43121.prkcoo and trim(f43121.prmatc) in ('2')
left join
    po_detail f4311 on f0411.rppo = f4311.pddoco and f0411.rpdct = f4311.pddcto and f0411.rppkco = f4311.pdkco
left join
    address_book_ext f0116 on f0411.rppye = f0116.alan8
left join
    account_master f0901 on f0411.rpaid2 = f0901.gmaid
left join
    payment_term_lookup f0014 on f0411.rpptc = f0014.ptc
left join
    business_unit_lookup f0006 on f0411.rpmcu = f0006.mcu
left join
    gl_segment_split gls on f0911.globj = gls.gl_account_cd
left join
    hfm_entity_map hem on f0411.rpco = hem.company and f0411.rpmcu = hem.business_unit
left join
    org_structure_map osm on f0411.rpmcu = osm.business_unit
left join
    branch_excluded be on f0411.rpmcu = be.branch_cd
where
    be.branch_cd is null
)
with branch_excluded as (
    select branch_cd
    from d_branch_excluded
),
org_structure_map as (
    select *
    from TODO_HYDRATE_ORG_STRUCTURE_MAP
),
gl_segment_split as (
    select *
    from TODO_HYDRATE_GL_SEGMENT_SPLIT
),
hfm_entity_map as (
    select *
    from TODO_HYDRATE_HFM_ENTITIES
),
payment_term_map as (
    select *
    from TODO_HYDRATE_PAYMENT_TERM_MAP
),
invoice_header as (
    select *
    from TODO_HYDRATE_INVOICE_HEADER
),
invoice_distribution as (
    select *
    from TODO_HYDRATE_INVOICE_DISTRIBUTION
),
supplier_extract as (
    select *
    from TODO_HYDRATE_SUPPLIER_EXTRACT
),
po_detail as (
    select *
    from TODO_HYDRATE_PO_DETAIL
),
po_receipt as (
    select *
    from TODO_HYDRATE_PO_RECEIPT
),
address_book_ext as (
    select *
    from TODO_HYDRATE_ADDRESS_BOOK_EXT
),
account_master as (
    select *
    from TODO_HYDRATE_ACCOUNT_MASTER
),
payment_term_lookup as (
    select *
    from TODO_HYDRATE_PAYMENT_TERM_LOOKUP
),
business_unit_lookup as (
    select *
    from TODO_HYDRATE_BUSINESS_UNIT_LOOKUP
),
final_joined as (
    select 
        'e1' as src_sys_cd,
        cast(null as string) as invc_entry_period,
        cast(null as string) as po_nbr,
        cast(null as string) as c,
        cast(null as string) as vchr_nbr,
        cast(null as string) as vchr_line_nbr,
        cast(null as string) as fscl_yr_nbr,
        cast(null as string) as vchr_type_cd,
        cast(null as string) as vchr_status,
        cast(null as string) as item_nbr,
        cast(null as string) as item_desc,
        cast(null as string) as thermo_item_nbr,
        cast(null as string) as supplier_cd,
        cast(null as string) as supplier_name,
        cast(null as string) as supplier_type_cd,
        cast(null as string) as buyer_cd,
        cast(null as string) as buyer_name,
        cast(null as string) as co_cd,
        cast(null as string) as co_name,
        cast(null as string) as hfm_entity,
        cast(null as string) as business_unit,
        cast(null as string) as lcr_flag,
        cast(null as string) as lcr_region,
        cast(null as string) as vomi_flag,
        cast(null as string) as payment_compliance_flg,
        cast(null as string) as po_curncy_cd,
        cast(null as string) as co_curncy_cd,
        cast(null as string) as post_yr_mth_nbr,
        cast(null as string) as invc_entry_dt,
        cast(null as string) as paymt_due_dt,
        cast(null as string) as suplr_invc_dt,
        cast(null as string) as aprval_dt,
        cast(null as string) as txn_orig_id,
        cast(null as string) as suplr_invc_nbr,
        cast(null as string) as invc_apprv_id,
        cast(null as string) as unit_prc,
        cast(null as string) as invc_qty,
        cast(null as string) as base_qty,
        cast(null as string) as invc_txn_amt,
        cast(null as string) as invc_co_amt,
        cast(null as string) as invc_txn_pmar_amt,
        cast(null as string) as invc_co_pmar_amt,
        cast(null as string) as unit_prc_pmar_amt,
        cast(null as string) as txn_curncy_mth_rt,
        cast(null as string) as co_curncy_mth_rt,
        cast(null as string) as uom_conv_factor,
        cast(null as string) as invc_uom_cd,
        cast(null as string) as base_uom_cd,
        cast(null as string) as profit_cntr,
        cast(null as string) as div_cd,
        cast(null as string) as site_cd,
        cast(null as string) as site_name,
        cast(null as string) as reporting_site,
        cast(null as string) as warehouse,
        cast(null as string) as warehouse_nm,
        cast(null as string) as unit,
        cast(null as string) as nature,
        cast(null as string) as inv_flg,
        cast(null as string) as inv_flg_text,
        cast(null as string) as spend_type_cd,
        cast(null as string) as po_paymt_terms_cd,
        cast(null as string) as po_paymt_terms_desc,
        cast(null as string) as ap_payment_term_cd,
        cast(null as string) as ap_payment_term_desc,
        cast(null as string) as suplr_paymt_terms_cd,
        cast(null as string) as suplr_paymt_terms_desc,
        cast(null as string) as contract_flag,
        cast(null as string) as contract_type,
        cast(null as string) as contract_start_date,
        cast(null as string) as contract_end_date,
        cast(null as string) as fk_orig,
        cast(null as string) as floor_stock_cd,
        cast(null as string) as erp_commondity_cd,
        cast(null as string) as erp_commondity_nm,
        cast(null as string) as sec_supp_cd,
        cast(null as string) as part_rev_no,
        cast(null as string) as cost_centre_cd,
        cast(null as string) as cost_centre_nm,
        cast(null as string) as vendor_mat_no,
        cast(null as string) as gl_acct_id,
        cast(null as string) as gl_acct_nm,
        cast(null as string) as pass_through_field,
        cast(null as string) as pass_through_line,
        cast(null as string) as inv_line_desc,
        cast(null as string) as remit_to_addr_line_1,
        cast(null as string) as remit_to_addr_line_2,
        cast(null as string) as remit_to_addr_line_3,
        cast(null as string) as remit_to_addr_line_4,
        cast(null as string) as remit_to_city_nm,
        cast(null as string) as remit_to_st_cd,
        cast(null as string) as remit_to_rgn_cd,
        cast(null as string) as remit_to_rgn_nm,
        cast(null as string) as remit_to_cntry_cd,
        cast(null as string) as remit_to_cntry_nm,
        cast(null as string) as suplr_nm_src,
        cast(null as string) as invc_txn_amt_clsfctn,
        cast(null as string) as actual_payment_dt,
        cast(null as string) as invc_post_dt,
        cast(null as string) as extrnl_invc_nbr,
        cast(null as string) as extrnl_invc_sys_nm
)
select *
from final_joined fj;