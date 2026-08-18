/**********************************************************************
artefact name :- f_sls_ord_sched_gbl
description   :- f_sls_ord_sched_gbl sql generated via multi-pass CTE pipeline
----------------------------------------------------------------------
change log
version :   date :        description :                       changed by
----------------------------------------------------------------------
0.0         2026-08-18    auto-generated multi-pass            ai_agent
**********************************************************************/

with
vbep_bmeng as (
    select 
    vbep.vbeln,
    vbep.posnr,
    sum(vbep.bmeng) as calculated_bmeng
from 
    vbep
group by 
    vbep.vbeln, 
    vbep.posnr
),
uom_conversion as (
    select 
    vbep.vbeln,
    vbep.posnr,
    case 
        when vbap.meins = vbap.kmein 
        then vbep.bmeng 
        else (marm.umrez / marm.umren) * vbep.bmeng 
    end as g_order_qty_primary_uom,
    case 
        when vbap.meins = vbap.kmein 
        then vbep.bmeng 
        else vbep.wmeng 
    end as g_order_qty_order_uom,
    case 
        when vbap.meins = vbap.kmein 
        then 'yes' 
        else 'no' 
    end as uom_check,
    marm.umrez / marm.umren as conversion_factor
from 
    vbep
left join vbap 
    on vbep.vbeln = vbap.vbeln 
    and vbep.posnr = vbap.posnr
left join marm 
    on vbap.matnr = marm.matnr 
    and vbep.vrkme = marm.meinh
),
vbfa_dedup as (
    select
    row_number() over (
        partition by vbfa.vbelv, vbfa.posnv, vbfa.vbeln, vbfa.posnn
        order by vbfa.aedat desc, vbfa.aezeit desc, vbfa.mandt desc
    ) as row_num,
    concat_ws('|', 'gbl', vbfa.vbelv, vbfa.posnv, vbfa.vbeln, vbfa.posnn) as document_flow_key,
    vbfa.vbelv as preceding_document_nbr,
    vbfa.posnv as preceding_document_line_nbr,
    vbfa.vbeln as succeeding_document_nbr,
    vbfa.posnn as succeeding_document_line_nbr,
    vbfa.vbtyp_v as preceding_document_type,
    vbfa.vbtyp_n as succeeding_document_type,
    vbfa.vbtyp_r as reference_document_type,
    vbfa.aedat as change_date,
    vbfa.aezeit as change_time,
    vbfa.mandt as client
from vbfa
where vbfa.mandt = '100'
),
order_schedule as (
    select
    vbep_bmeng.g_delivery_schedule_line_nbr,
    vbep_bmeng.g_scheduled_ship_dt_yyyymmdd,
    sum(vbep_bmeng.g_order_qty) over (
        partition by vbep_bmeng.g_order_nbr, vbep_bmeng.g_order_line_nbr
        order by vbep_bmeng.g_scheduled_ship_dt_yyyymmdd
    ) as g_running_total_qty
from
    vbep_bmeng
),
order_shipment as (
    select
    vbelv as g_order_nbr,
    posnv as g_order_line_nbr,
    first_value(erdat) over (
        partition by vbelv, posnv 
        order by erdat desc
    ) as g_last_actual_ship_dt_yyyymmdd,
    sum(qty) over (
        partition by vbelv, posnv 
        order by erdat
    ) as g_shipped_qty_primary_uom
from vbfa_dedup
where vbtyp_n = 'J' and qty > 0 and erdat is not null
),
last_shipped_dt as (
    select 
    schedule_line_nbr,
    first_value(actual_ship_dt) over (
        partition by order_nbr, line_nbr, schedule_line_nbr 
        order by actual_ship_dt desc
    ) as g_last_actual_ship_dt_yyyymmdd
from 
    order_shipment
),
order_invoice as (
    select 
    vbep.vbeln,
    vbep.posnr,
    first_value(vbfa.budat) over (
        partition by vbep.vbeln, vbep.posnr 
        order by vbfa.budat desc
    ) as g_invoice_dt_yyyymmdd,
    sum(vbfa.fkimg) over (
        partition by vbep.vbeln, vbep.posnr
    ) as g_invoice_qty
from 
    vbep
left join vbfa
    on vbep.vbeln = vbfa.vbelv
    and vbep.posnr = vbfa.posnv
where 
    vbfa.vbtyp_n = 'M'
),
tcurf_dedup as (
    select 
    tcurf.ffact,
    tcurf.tfact,
    tcurf.from_curncy_cd,
    tcurf.to_curncy_cd,
    tcurf.valid_from_dt,
    tcurf.valid_to_dt,
    row_number() over (
        partition by 
            tcurf.from_curncy_cd, 
            tcurf.to_curncy_cd, 
            tcurf.valid_from_dt 
        order by 
            tcurf.valid_to_dt desc
    ) as row_num
from 
    tcurf
),
final_joined as (
    select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp)
        else g_shipped_qty_primary_uom
    end as g_allocated_qty_primary_uom,
    sales_order_detail.g_availability_dt_yyyymmdd as g_availability_dt_yyyymmdd,
    case 
        when bp.posnr is not null then bp.customer_nbr
        else bp_no_posnr.customer_nbr
    end as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null then null
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat
    end as g_cancel_dt_yyyymmdd,
    cast(null as string) as g_cancel_qty_primary_uom,  -- TODO: review mapping
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers
    end as g_company_currency_cd,
    vbap.matnr as g_customer_item_nbr,
    cast(null as string) as g_customer_po_line_nbr,  -- TODO: review mapping
    case 
        when po.posnr is not null then po.po_nbr
        else po_no_posnr.po_nbr
    end as g_customer_po_nbr,
    case 
        when po.posnr is not null then po.po_type
        else po_no_posnr.po_type
    end as g_customer_po_type,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
        then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
        then trim(vbep.request_dt)
        else vbep.edatu
    end as g_customer_request_dt_yyyymmdd,
    sales_order_detail.g_delivery_schedule_line_nbr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no'
    end as g_flag_consignment_order,
    case 
        when vbap.uepos is not null and vbap.uepos <> 0 then 'yes'
        else 'no'
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any(select vbap.uepos from vbap where vbap.vbeln = vbap.vbeln) then 'yes'
        else 'no'
    end as g_flag_is_parent,
    case 
        when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes'
        when knvv.kdgrp in ('05', '06', '07') then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    case 
        when tvap.bedsd = 'X' then 'yes'
        when tvap.bedsd is null and tvap.knttp in ('M', 'X') then 'yes'
        when coalesce(order_qty_primary_uom, 0) = 0 then 'no'
        else 'no'
    end as g_flag_material_transacted,
    case 
        when vbep.lifsp <> '' then 'yes'
        when vbak.lifsk <> '' then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no'
    end as g_flag_on_hold,
    case 
        when vbak.autlf = 'X' then 'no'
        when cancel_qty_primary_uom = order_qty_primary_uom then 'no'
        when open_qty_primary_uom <= 0 then 'no'
        else 'yes'
    end as g_flag_open_to_ship,
    case 
        when vbak.vbtyp in ('H', 'T') then 'yes'
        else 'no'
    end as g_flag_return,
    case 
        when order_qty_primary_uom = 0 then 'no'
        when vbak.vbtyp in ('A', 'B', 'D') then 'no'
        when tvap.prsfd = 'X' then 'yes'
        else 'no'
    end as g_flag_revenue_recognition,
    case 
        when inco.posnr is not null then inco.inco_terms
        else inco_no_posnr.inco_terms
    end as g_inco_terms,
    cast(null as string) as g_invoice_dt_yyyymmdd,  -- TODO: review mapping
    vbap.matnr as g_item_nbr,
    cast(null as string) as g_last_actual_ship_dt_yyyymmdd,  -- TODO: review mapping
    case 
        when vbup.gbsta = 'A' then 'NOT YET PROCESSED'
        when vbup.gbsta = 'B' then 'PARTIALLY PROCESSED'
        when vbup.gbsta = 'C' then 'COMPLETELY PROCESSED'
        else 'NOT RELEVANT'
    end as g_line_status_cd,
    coalesce(order_qty_primary_uom, 0) - coalesce(shipped_qty_primary_uom, 0) - coalesce(cancel_qty_primary_uom, 0) as g_open_qty_primary_uom,
    vbap.pstyv as g_order_category,
    t001k.bukrs as g_order_company_cd,
    case 
        when vbak.waerk = 'RMB' then 'CNY'
        else vbak.waerk
    end as g_order_currency_cd,
    vbap.erdat as g_order_dt_yyyymmdd,
    vbap.posnr as g_order_line_nbr,
    vbap.vbeln as g_order_nbr,
    vbep.bmeng as g_order_qty_order_uom,
    vbep.bmeng as g_order_qty_primary_uom,
    vbak.auart as g_order_type,
    vbap.meins as g_order_uom_cd,
    vbep.edatu as g_original_customer_request_dt_yyyymmdd,
    vbep.edatu as g_original_promised_ship_dt_yyyymmdd,
    vbap.uepos as g_parent_order_line_nbr,
    vbak.zterm as g_payment_terms,
    vbap.werks as g_plant_cd,
    marm.meinh as g_primary_uom_cd,
    vbep.edatu as g_promised_ship_dt_yyyymmdd,
    vbep.edatu as g_scheduled_ship_dt_yyyymmdd,
    case 
        when ship_to.posnr is not null then ship_to.customer_nbr
        else ship_to_no_posnr.customer_nbr
    end as g_ship_to_customer_nbr,
    datediff(vbep.mbdatu, vbep.edatu) as g_ship_to_delivery_days,
    vbak.vsbed as g_shipment_mode,
    coalesce(shipped_qty_primary_uom, 0) as g_shipped_qty_primary_uom,
    'gbl' as g_source_system_cd,
    cast(null as string) as g_unit_cost_company_currency_primary_uom,  -- TODO: review mapping
    cast(null as string) as g_unit_price_company_currency_primary_uom,  -- TODO: review mapping
    cast(null as string) as g_unit_price_order_currency_primary_uom,  -- TODO: review mapping
    concat_ws('|', 'gbl', vbap.werks) as plant_key,
    concat_ws('|', 'gbl', vbap.matnr) as prod_key,
    concat_ws('|', 'gbl', vbap.matnr, vbap.werks) as prod_plant_key,
    concat_ws('|', 'gbl', t001k.bukrs, vbak.auart, vbap.vbeln) as sls_ord_key,
    concat_ws('|', 'gbl', t001k.bukrs, vbak.auart, vbap.vbeln, vbap.posnr, vbep.etennr) as sls_ord_sched_key,
    cast(null as string) as flag_is_blanket  -- TODO: review mapping
from
    vbep_bmeng
left join
    uom_conversion on vbep_bmeng.vbeln = uom_conversion.vbeln and vbep_bmeng.posnr = uom_conversion.posnr
left join
    order_schedule on vbep_bmeng.vbeln = order_schedule.vbeln and vbep_bmeng.posnr = order_schedule.posnr
left join
    order_shipment on vbep_bmeng.vbeln = order_shipment.vbeln and vbep_bmeng.posnr = order_shipment.posnr
left join
    last_shipped_dt on vbep_bmeng.vbeln = last_shipped_dt.vbeln and vbep_bmeng.posnr = last_shipped_dt.posnr
left join
    order_invoice on vbep_bmeng.vbeln = order_invoice.vbeln and vbep_bmeng.posnr = order_invoice.posnr
left join
    tcurf_dedup on vbep_bmeng.vbeln = tcurf_dedup.vbeln and vbep_bmeng.posnr = tcurf_dedup.posnr
),
final_joined_with_flags as (
    select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp)
        else g_shipped_qty_primary_uom
    end as g_allocated_qty_primary_uom,
    sales_order_detail.g_availability_dt_yyyymmdd as g_availability_dt_yyyymmdd,
    case 
        when bp.posnr is not null then bp.bill_to_customer_nbr
        else bp_no_posnr.bill_to_customer_nbr
    end as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null then null
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat
    end as g_cancel_dt_yyyymmdd,
    cast(null as string) as g_cancel_qty_primary_uom,  -- TODO: review mapping
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers
    end as g_company_currency_cd,
    vbap.matnr as g_customer_item_nbr,
    cast(null as string) as g_customer_po_line_nbr,  -- TODO: review mapping
    case 
        when po.posnr is not null then po.customer_po_nbr
        else po_no_posnr.customer_po_nbr
    end as g_customer_po_nbr,
    case 
        when po.posnr is not null then po.customer_po_type
        else po_no_posnr.customer_po_type
    end as g_customer_po_type,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
        then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
        then trim(vbep.request_dt)
        else vbep.edatu
    end as g_customer_request_dt_yyyymmdd,
    sales_order_detail.g_delivery_schedule_line_nbr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no'
    end as g_flag_consignment_order,
    case 
        when vbap.uepos is not null and vbap.uepos != 0 then 'yes'
        else 'no'
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any(select uepos from vbap where vbap.vbeln = vbap.vbeln) then 'yes'
        else 'no'
    end as g_flag_is_parent,
    case 
        when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes'
        when knvv.kdgrp in ('05', '06', '07') then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    case 
        when tvep.bedsd = 'X' then 'yes'
        when tvep.bedsd is null and tvep.knttp in ('M', 'X') then 'yes'
        when order_qty_primary_uom = 0 then 'no'
        else 'no'
    end as g_flag_material_transacted,
    case 
        when vbep.lifsp is not null then 'yes'
        when vbak.lifsk is not null then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no'
    end as g_flag_on_hold,
    case 
        when vbak.autlf = 'X' then 'no'
        when cancel_qty_primary_uom = order_qty_primary_uom then 'no'
        when open_qty_primary_uom <= 0 then 'no'
        else 'yes'
    end as g_flag_open_to_ship,
    case 
        when vbak.vbtyp in ('H', 'T') then 'yes'
        else 'no'
    end as g_flag_return,
    case 
        when order_qty_primary_uom = 0 then 'no'
        when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
        when trim(tvap.prsfd) = 'X' then 'yes'
        else 'no'
    end as g_flag_revenue_recognition,
    case 
        when inco.posnr is not null then inco.inco_terms
        else inco_no_posnr.inco_terms
    end as g_inco_terms,
    cast(null as string) as g_invoice_dt_yyyymmdd,  -- TODO: review mapping
    vbap.matnr as g_item_nbr,
    cast(null as string) as g_last_actual_ship_dt_yyyymmdd,  -- TODO: review mapping
    case 
        when upper(trim(vbup.gbsta)) = 'A' then 'NOT YET PROCESSED'
        when upper(trim(vbup.gbsta)) = 'B' then 'PARTIALLY PROCESSED'
        when upper(trim(vbup.gbsta)) = 'C' then 'COMPLETELY PROCESSED'
        else 'NOT RELEVANT'
    end as g_line_status_cd,
    case 
        when order_type = 'DEMO' and ship_lines.sttrg = '7' then 0
        when tvap.fkrel in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') 
        then round(coalesce(order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0), 4)
        when trim(tvap.fkrel) = '' then 0
        else round(coalesce(order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0) - coalesce(cancel_qty_primary_uom, 0), 4)
    end as g_open_qty_primary_uom,
    vbap.pstyv as g_order_category,
    t001k.bukrs as g_order_company_cd,
    case 
        when trim(vbak.waerk) = 'RMB' then 'CNY'
        else trim(vbak.waerk)
    end as g_order_currency_cd,
    vbap.erdat as g_order_dt_yyyymmdd,
    vbap.posnr as g_order_line_nbr,
    vbap.vbeln as g_order_nbr,
    case 
        when vbep_bmeng.calculated_bmeng is not null and vbep_bmeng.calculated_bmeng > 0 
        then vbep.bmeng
        else vbep.wmeng
    end as g_order_qty_order_uom,
    case 
        when vbep_bmeng.calculated_bmeng is not null and vbep_bmeng.calculated_bmeng > 0 
        then vbep.bmeng
        else vbep.wmeng
    end as g_order_qty_primary_uom,
    vbak.auart as g_order_type,
    vbap.kmein as g_order_uom_cd,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
        then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
        then trim(vbep.request_dt)
        else vbep.edatu
    end as g_original_customer_request_dt_yyyymmdd,
    case 
        when trim(vbap.werks) = '0070' then vbak.zz_ship_by
        else coalesce(zosdates.lddat, coalesce(vbep.edatu, null))
    end as g_original_promised_ship_dt_yyyymmdd,
    vbap.uepos as g_parent_order_line_nbr,
    vbak.zterm as g_payment_terms,
    vbap.werks as g_plant_cd,
    vbap.meins as g_primary_uom_cd,
    case 
        when trim(vbap.werks) = '0070' then vbak.zz_ship_by
        else trim(vbep.edatu)
    end as g_promised_ship_dt_yyyymmdd,
    sales_order_detail.g_scheduled_ship_dt_yyyymmdd as g_scheduled_ship_dt_yyyymmdd,
    case 
        when ship_to.posnr is not null then ship_to.ship_to_customer_nbr
        else ship_to_no_posnr.ship_to_customer_nbr
    end as g_ship_to_customer_nbr,
    case 
        when g_order_qty_primary_uom = 0 then 0
        else datediff(vbep.mbdatu, vbep.edatu)
    end as g_ship_to_delivery_days,
    vbak.vsbed as g_shipment_mode,
    lst.shipped_qty as g_shipped_qty_primary_uom,
    'gbl' as g_source_system_cd,
    cast(null as string) as g_unit_cost_company_currency_primary_uom,  -- TODO: review mapping
    cast(null as string) as g_unit_price_company_currency_primary_uom,  -- TODO: review mapping
    cast(null as string) as g_unit_price_order_currency_primary_uom,  -- TODO: review mapping
    concat_ws('|', 'gbl', g_plant_cd) as plant_key,
    concat_ws('|', 'gbl', g_item_nbr) as prod_key,
    concat_ws('|', 'gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key,
    cast(null as string) as flag_is_blanket  -- TODO: review mapping
from final_joined
),
sto_join as (
    select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp)
        else g_shipped_qty_primary_uom 
    end as g_allocated_qty_primary_uom,
    sales_order_detail.g_availability_dt_yyyymmdd as g_availability_dt_yyyymmdd,
    case 
        when bp.parvw = 'RE/BP' then bp.kunnr
        else null 
    end as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null then null
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat 
    end as g_cancel_dt_yyyymmdd,
    cast(null as string) as g_cancel_qty_primary_uom,  -- TODO: review mapping
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers 
    end as g_company_currency_cd,
    vbap.matnr as g_customer_item_nbr,
    cast(null as string) as g_customer_po_line_nbr,  -- TODO: review mapping
    case 
        when bp.parvw = 'RE/BP' then bp.kunnr
        else null 
    end as g_customer_po_nbr,
    cast(null as string) as g_customer_po_type,  -- TODO: review mapping
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
        then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
        then trim(vbep.request_dt)
        else vbep.edatu 
    end as g_customer_request_dt_yyyymmdd,
    sales_order_detail.g_delivery_schedule_line_nbr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no' 
    end as g_flag_consignment_order,
    case 
        when vbap.uepos is not null and vbap.uepos <> 0 then 'yes'
        else 'no' 
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then 'yes'
        else 'no' 
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = vbap.uepos then 'yes'
        else 'no' 
    end as g_flag_is_parent,
    case 
        when kna1.ktokd in ('ZSUB', 'IC3P') or knvv.kdgrp in ('05', '06', '07') then 'yes'
        else 'no' 
    end as g_flag_is_transfer_order,
    case 
        when tvap.bedsd = 'X' or tvap.knttp in ('M', 'X') then 'yes'
        when g_order_qty_primary_uom = 0 then 'no'
        else 'no' 
    end as g_flag_material_transacted,
    case 
        when vbep.lifsp <> '' then 'yes'
        when vbak.lifsk <> '' then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no' 
    end as g_flag_on_hold,
    case 
        when vbak.autlf = 'X' then 'no'
        when g_cancel_qty_primary_uom = g_order_qty_primary_uom then 'no'
        when g_open_qty_primary_uom <= 0 then 'no'
        else 'yes' 
    end as g_flag_open_to_ship,
    case 
        when vbak.vbtyp in ('H', 'T') then 'yes'
        else 'no' 
    end as g_flag_return,
    case 
        when g_order_qty_primary_uom = 0 then 'no'
        when vbak.vbtyp in ('A', 'B', 'D') then 'no'
        when tvap.prsfd = 'X' then 'yes'
        else 'no' 
    end as g_flag_revenue_recognition,
    cast(null as string) as g_inco_terms,  -- TODO: review mapping
    cast(null as string) as g_invoice_dt_yyyymmdd,  -- TODO: review mapping
    vbap.matnr as g_item_nbr,
    cast(null as string) as g_last_actual_ship_dt_yyyymmdd,  -- TODO: review mapping
    case 
        when vbup.gbsta = 'A' then 'NOT YET PROCESSED'
        when vbup.gbsta = 'B' then 'PARTIALLY PROCESSED'
        when vbup.gbsta = 'C' then 'COMPLETELY PROCESSED'
        else 'NOT RELEVANT' 
    end as g_line_status_cd,
    case 
        when tvap.fkrel in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') 
        then round(coalesce(g_order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0), 4)
        when tvap.fkrel = '' then 0
        else round(coalesce(g_order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0), 4) 
    end - coalesce(g_cancel_qty_primary_uom, 0) as g_open_qty_primary_uom,
    vbap.pstyv as g_order_category,
    t001k.bukrs as g_order_company_cd,
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers 
    end as g_order_currency_cd,
    vbap.erdat as g_order_dt_yyyymmdd,
    vbap.posnr as g_order_line_nbr,
    vbap.vbeln as g_order_nbr,
    vbep.bmeng as g_order_qty_order_uom,
    vbep.bmeng as g_order_qty_primary_uom,
    vbak.auart as g_order_type,
    vbap.meins as g_order_uom_cd,
    vbep.edatu as g_original_customer_request_dt_yyyymmdd,
    vbep.edatu as g_original_promised_ship_dt_yyyymmdd,
    vbap.uepos as g_parent_order_line_nbr,
    vbak.zterm as g_payment_terms,
    vbap.werks as g_plant_cd,
    vbap.meins as g_primary_uom_cd,
    vbep.edatu as g_promised_ship_dt_yyyymmdd,
    vbep.edatu as g_scheduled_ship_dt_yyyymmdd,
    case 
        when bp.parvw = 'WE' then bp.kunnr
        else null 
    end as g_ship_to_customer_nbr,
    datediff(vbep.mbdatu, vbep.edatu) as g_ship_to_delivery_days,
    vbak.vsbed as g_shipment_mode,
    lst.shipped_qty as g_shipped_qty_primary_uom,
    'gbl' as g_source_system_cd,
    cast(null as string) as g_unit_cost_company_currency_primary_uom,  -- TODO: review mapping
    cast(null as string) as g_unit_price_company_currency_primary_uom,  -- TODO: review mapping
    cast(null as string) as g_unit_price_order_currency_primary_uom,  -- TODO: review mapping
    concat_ws('|', 'gbl', vbap.werks) as plant_key,
    concat_ws('|', 'gbl', vbap.matnr) as prod_key,
    concat_ws('|', 'gbl', vbap.matnr, vbap.werks) as prod_plant_key,
    concat_ws('|', 'gbl', t001k.bukrs, vbak.auart, vbap.vbeln) as sls_ord_key,
    concat_ws('|', 'gbl', t001k.bukrs, vbak.auart, vbap.vbeln, vbap.posnr, vbep.etennr) as sls_ord_sched_key,
    cast(null as string) as flag_is_blanket  -- TODO: review mapping
from final_joined_with_flags
),
main_select_with_union_all_so_sto as (
    select 
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    case 
        when exists (
            select 1 
            from mska 
            where mska.vbeln = final_joined_with_flags.g_order_nbr 
              and mska.posnr = final_joined_with_flags.g_order_line_nbr
        ) 
        then coalesce(
            mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp, 
            g_shipped_qty_primary_uom
        )
        else g_shipped_qty_primary_uom
    end as g_allocated_qty_primary_uom,
    g_availability_dt_yyyymmdd,
    case 
        when exists (
            select 1 
            from kna1 
            where kna1.kunnr = final_joined_with_flags.g_bill_to_customer_nbr 
              and kna1.ktokd in ('RE/BP')
        ) 
        then final_joined_with_flags.g_bill_to_customer_nbr
        else null
    end as g_bill_to_customer_nbr,
    case 
        when vbap.aedat = 0 then coalesce(vbap.erdat, null)
        else vbap.aedat
    end as g_cancel_dt_yyyymmdd,
    g_cancel_qty_primary_uom,
    case 
        when upper(trim(t001.waers)) = 'RMB' then 'CNY'
        else upper(trim(t001.waers))
    end as g_company_currency_cd,
    g_customer_item_nbr,
    null as g_customer_po_line_nbr,
    case 
        when exists (
            select 1 
            from knvv 
            where knvv.vbeln = final_joined_with_flags.g_order_nbr 
              and knvv.posnr = final_joined_with_flags.g_order_line_nbr
        ) 
        then final_joined_with_flags.g_customer_po_nbr
        else null
    end as g_customer_po_nbr,
    case 
        when exists (
            select 1 
            from knvv 
            where knvv.vbeln = final_joined_with_flags.g_order_nbr 
              and knvv.posnr = final_joined_with_flags.g_order_line_nbr
        ) 
        then final_joined_with_flags.g_customer_po_type
        else null
    end as g_customer_po_type,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
        then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
        then trim(vbep.request_dt)
        else vbep.edatu
    end as g_customer_request_dt_yyyymmdd,
    g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no'
    end as g_flag_consignment_order,
    case 
        when vbap.uepos is not null and vbap.uepos != 0 then 'yes'
        else 'no'
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' 
          and (mska.kalab > 0 or mska.kains > 0 or mska.kaspe > 0 or mska.kavla > 0 or mska.kavin > 0 or mska.kavsp > 0) 
        then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any (
            select uepos 
            from vbap as vbap_inner 
            where vbap_inner.vbeln = vbap.vbeln
        ) 
        then 'yes'
        else 'no'
    end as g_flag_is_parent,
    case 
        when vbak.kunnr in (
            select kna1.kunnr 
            from kna1 
            where kna1.ktokd in ('ZSUB', 'IC3P')
        ) 
        or exists (
            select 1 
            from knvv 
            where knvv.kdgrp in ('05', '06', '07') 
              and knvv.vbeln = vbak.vbeln 
              and knvv.vkorg = vbak.vkorg 
              and knvv.vtweg = vbak.vtweg 
              and knvv.spart = vbak.spart
        ) 
        then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    case 
        when t_vep.bedsd = 'X' then 'yes'
        when t_vep.bedsd is null and t_vep.knttp in ('M', 'X') then 'yes'
        when order_qty_primary_uom = 0 then 'no'
        else 'no'
    end as g_flag_material_transacted,
    case 
        when vbep.lifsp != '' then 'yes'
        when vbak.lifsk != '' then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no'
    end as g_flag_on_hold
from final_joined_with_flags
union all
select 
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    g_allocated_qty_primary_uom,
    g_availability_dt_yyyymmdd,
    g_bill_to_customer_nbr,
    g_cancel_dt_yyyymmdd,
    g_cancel_qty_primary_uom,
    g_company_currency_cd,
    g_customer_item_nbr,
    g_customer_po_line_nbr,
    g_customer_po_nbr,
    g_customer_po_type,
    g_customer_request_dt_yyyymmdd,
    g_delivery_schedule_line_nbr,
    g_flag_consignment_order,
    g_flag_has_parent,
    g_flag_inventory_fully_allocated,
    g_flag_is_parent,
    g_flag_is_transfer_order,
    g_flag_material_transacted,
    g_flag_on_hold
from sto_join
)
select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    g_allocated_qty_primary_uom,
    g_availability_dt_yyyymmdd,
    g_bill_to_customer_nbr,
    g_cancel_dt_yyyymmdd,
    g_cancel_qty_primary_uom,
    g_company_currency_cd,
    g_customer_item_nbr,
    g_customer_po_line_nbr,
    g_customer_po_nbr,
    g_customer_po_type,
    g_customer_request_dt_yyyymmdd,
    g_delivery_schedule_line_nbr,
    g_flag_consignment_order,
    g_flag_has_parent,
    g_flag_inventory_fully_allocated,
    g_flag_is_parent,
    g_flag_is_transfer_order,
    g_flag_material_transacted,
    g_flag_on_hold,
    g_flag_open_to_ship,
    g_flag_return,
    g_flag_revenue_recognition,
    g_inco_terms,
    g_invoice_dt_yyyymmdd,
    g_item_nbr,
    g_last_actual_ship_dt_yyyymmdd,
    g_line_status_cd,
    g_open_qty_primary_uom,
    g_order_category,
    g_order_company_cd,
    g_order_currency_cd,
    g_order_dt_yyyymmdd,
    g_order_line_nbr,
    g_order_nbr,
    g_order_qty_order_uom,
    g_order_qty_primary_uom,
    g_order_type,
    g_order_uom_cd,
    g_original_customer_request_dt_yyyymmdd,
    g_original_promised_ship_dt_yyyymmdd,
    g_parent_order_line_nbr,
    g_payment_terms,
    g_plant_cd,
    g_primary_uom_cd,
    g_promised_ship_dt_yyyymmdd,
    g_scheduled_ship_dt_yyyymmdd,
    g_ship_to_customer_nbr,
    g_ship_to_delivery_days,
    g_shipment_mode,
    g_shipped_qty_primary_uom,
    'gbl' as g_source_system_cd,
    g_unit_cost_company_currency_primary_uom,
    g_unit_price_company_currency_primary_uom,
    g_unit_price_order_currency_primary_uom,
    concat_ws('|', 'gbl', g_plant_cd) as plant_key,
    concat_ws('|', 'gbl', g_item_nbr) as prod_key,
    concat_ws('|', 'gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key,
    flag_is_blanket
from final_joined_with_flags
union all
select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    g_allocated_qty_primary_uom,
    g_availability_dt_yyyymmdd,
    g_bill_to_customer_nbr,
    g_cancel_dt_yyyymmdd,
    g_cancel_qty_primary_uom,
    g_company_currency_cd,
    g_customer_item_nbr,
    g_customer_po_line_nbr,
    g_customer_po_nbr,
    g_customer_po_type,
    g_customer_request_dt_yyyymmdd,
    g_delivery_schedule_line_nbr,
    g_flag_consignment_order,
    g_flag_has_parent,
    g_flag_inventory_fully_allocated,
    g_flag_is_parent,
    g_flag_is_transfer_order,
    g_flag_material_transacted,
    g_flag_on_hold,
    g_flag_open_to_ship,
    g_flag_return,
    g_flag_revenue_recognition,
    g_inco_terms,
    g_invoice_dt_yyyymmdd,
    g_item_nbr,
    g_last_actual_ship_dt_yyyymmdd,
    g_line_status_cd,
    g_open_qty_primary_uom,
    g_order_category,
    g_order_company_cd,
    g_order_currency_cd,
    g_order_dt_yyyymmdd,
    g_order_line_nbr,
    g_order_nbr,
    g_order_qty_order_uom,
    g_order_qty_primary_uom,
    g_order_type,
    g_order_uom_cd,
    g_original_customer_request_dt_yyyymmdd,
    g_original_promised_ship_dt_yyyymmdd,
    g_parent_order_line_nbr,
    g_payment_terms,
    g_plant_cd,
    g_primary_uom_cd,
    g_promised_ship_dt_yyyymmdd,
    g_scheduled_ship_dt_yyyymmdd,
    g_ship_to_customer_nbr,
    g_ship_to_delivery_days,
    g_shipment_mode,
    g_shipped_qty_primary_uom,
    'gbl' as g_source_system_cd,
    g_unit_cost_company_currency_primary_uom,
    g_unit_price_company_currency_primary_uom,
    g_unit_price_order_currency_primary_uom,
    concat_ws('|', 'gbl', g_plant_cd) as plant_key,
    concat_ws('|', 'gbl', g_item_nbr) as prod_key,
    concat_ws('|', 'gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key,
    flag_is_blanket
from sto_join;