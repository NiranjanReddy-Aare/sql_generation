/**********************************************************************
artefact name :- f_sales_order
description   :- f_sales_order sql generated via multi-pass CTE pipeline
----------------------------------------------------------------------
change log
version :   date :        description :                       changed by
----------------------------------------------------------------------
0.0         2026-08-30    auto-generated multi-pass            ai_agent
**********************************************************************/

with
header_extract as (
    select 
    concat('gbl', g_order_company_cd) as co_key,
    case 
        when exists (
            select 1 
            from mska 
            where mska.vbeln = vbap.vbeln 
              and mska.posnr = vbap.posnr
        ) 
        then coalesce(
            (select sum(mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) 
             from mska 
             where mska.vbeln = vbap.vbeln 
               and mska.posnr = vbap.posnr), 
            0
        )
        else g_shipped_qty_primary_uom
    end as g_allocated_qty_primary_uom,
    null as g_availability_dt_yyyymmdd,
    coalesce(
        (select parvw.kunnr 
         from vbpa as parvw 
         where parvw.vbeln = vbap.vbeln 
           and parvw.posnr = vbap.posnr 
           and parvw.parvw = 'RE/BP' 
         limit 1),
        (select parvw.kunnr 
         from vbpa as parvw 
         where parvw.vbeln = vbap.vbeln 
           and parvw.parvw = 'RE/BP' 
         limit 1)
    ) as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null then null
        else coalesce(
            nullif(vbap.aedat, 0), 
            vbap.erdat
        )
    end as g_cancel_dt_yyyymmdd,
    null as g_cancel_qty_primary_uom,
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers
    end as g_company_currency_cd,
    vbap.kdmat as g_customer_item_nbr,
    null as g_customer_po_line_nbr,
    coalesce(
        (select vbkd.bstkd 
         from vbkd 
         where vbkd.vbeln = vbap.vbeln 
           and vbkd.posnr = vbap.posnr 
         limit 1),
        (select vbkd.bstkd 
         from vbkd 
         where vbkd.vbeln = vbap.vbeln 
         limit 1)
    ) as g_customer_po_nbr,
    coalesce(
        (select vbkd.bsark 
         from vbkd 
         where vbkd.vbeln = vbap.vbeln 
           and vbkd.posnr = vbap.posnr 
         limit 1),
        (select vbkd.bsark 
         from vbkd 
         where vbkd.vbeln = vbap.vbeln 
         limit 1)
    ) as g_customer_po_type,
    vbep.edatu as g_customer_request_dt_yyyymmdd,
    vbep.etenr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no'
    end as g_flag_consignment_order,
    vbap.uepos as g_flag_has_parent,
    case 
        when exists (
            select 1 
            from mska 
            where mska.vbeln = vbap.vbeln 
              and mska.posnr = vbap.posnr 
              and mska.sobkz = 'E' 
              and (mska.kalab > 0 or mska.kains > 0 or mska.kaspe > 0 or mska.kavla > 0 or mska.kavin > 0 or mska.kavsp > 0)
        ) 
        then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    vbap.uepos as g_flag_is_parent,
    case 
        when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes'
        when knvv.kdgrp in ('05', '06', '07') then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    vbep.lfrel as g_flag_material_transacted,
    case 
        when vbep.lifsp <> '' then 'yes'
        when vbak.lifsk <> '' then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no'
    end as g_flag_on_hold
from vbap
left join vbep on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
left join kna1 on vbak.kunnr = kna1.kunnr
left join knvv on vbak.kunnr = knvv.kunnr and vbak.vkorg = knvv.vkorg and vbak.vtweg = knvv.vtweg and vbak.spart = knvv.spart
),
item_extract as (
    select 
  concat('gbl', g_order_company_cd) as co_key,
  case 
    when exists (
      select 1 
      from mska 
      where mska.vbeln = vbap.vbeln 
        and mska.posnr = vbap.posnr
    ) then 
      coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)
    else 
      g_shipped_qty_primary_uom
  end as g_allocated_qty_primary_uom,
  null as g_availability_dt_yyyymmdd,
  case 
    when vbap.posnr is not null then (
      select kunnr 
      from vbap 
      where vbeln = g_order_nbr 
        and posnr = g_order_line_nbr 
        and parvw = 'RE/BP'
    )
    else (
      select kunnr 
      from vbap 
      where vbeln = g_order_nbr 
        and parvw = 'RE/BP'
    )
  end as g_bill_to_customer_nbr,
  case 
    when vbap.abgru is null then null
    else 
      case 
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat
      end
  end as g_cancel_dt_yyyymmdd,
  null as g_cancel_qty_primary_uom,
  case 
    when t001.waers = 'RMB' then 'CNY'
    else t001.waers
  end as g_company_currency_cd,
  vbap.kdmat as g_customer_item_nbr,
  null as g_customer_po_line_nbr,
  case 
    when vbap.posnr is not null then (
      select bstk 
      from vbkd 
      where vbeln = g_order_nbr 
        and posnr = g_order_line_nbr
    )
    else (
      select bstk 
      from vbkd 
      where vbeln = g_order_nbr
    )
  end as g_customer_po_nbr,
  case 
    when vbap.posnr is not null then (
      select bsark 
      from vbkd 
      where vbeln = g_order_nbr 
        and posnr = g_order_line_nbr
    )
    else (
      select bsark 
      from vbkd 
      where vbeln = g_order_nbr
    )
  end as g_customer_po_type,
  vbep.edatu as g_customer_request_dt_yyyymmdd,
  vbep.etenr as g_delivery_schedule_line_nbr,
  case 
    when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
    else 'no'
  end as g_flag_consignment_order,
  vbap.uepos as g_flag_has_parent,
  case 
    when mska.sobkz = 'E' 
      and (coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)) > 0 
    then 'yes'
    else 'no'
  end as g_flag_inventory_fully_allocated,
  vbap.uepos as g_flag_is_parent,
  case 
    when exists (
      select 1 
      from kna1 
      where kna1.kunnr = vbak.kunnr 
        and kna1.ktokd in ('ZSUB', 'IC3P')
    ) or exists (
      select 1 
      from knvv 
      where knvv.kunnr = vbak.kunnr 
        and knvv.vkorg = vbak.vkorg 
        and knvv.vtweg = vbak.vtweg 
        and knvv.spart = vbak.spart 
        and knvv.kdgrp in ('05', '06', '07')
    ) then 'yes'
    else 'no'
  end as g_flag_is_transfer_order,
  vbep.lfrel as g_flag_material_transacted,
  case 
    when vbep.lifsp is not null then 'yes'
    when vbak.lifsk is not null then 'yes'
    when vbuk.cmgst in ('B', 'C') then 'yes'
    else 'no'
  end as g_flag_on_hold
from vbap
left join vbep on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
),
schedule_extract as (
    select 
  concat('gbl', vbak.bukrs_vf) as co_key,
  case 
    when exists (
      select 1 
      from mska 
      where mska.vbeln = vbep.vbeln 
        and mska.posnr = vbep.posnr
    ) then 
      coalesce(
        sum(mska.kalab) + sum(mska.kains) + sum(mska.kaspe) + sum(mska.kavla) + sum(mska.kavin) + sum(mska.kavsp), 
        vbep.bmng
      )
    else 
      vbep.bmng
  end as g_allocated_qty_primary_uom,
  null as g_availability_dt_yyyymmdd,
  case 
    when vbap.posnr is not null then (
      select kunnr 
      from vbap 
      where vbeln = vbep.vbeln 
        and posnr = vbep.posnr 
        and parvw = 'RE/BP'
    )
    else (
      select kunnr 
      from vbap 
      where vbeln = vbep.vbeln 
        and parvw = 'RE/BP'
    )
  end as g_bill_to_customer_nbr,
  case 
    when vbap.abgru is null then null
    else 
      case 
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat
      end
  end as g_cancel_dt_yyyymmdd,
  null as g_cancel_qty_primary_uom,
  case 
    when t001.waers = 'RMB' then 'CNY'
    else t001.waers
  end as g_company_currency_cd,
  vbap.kdmat as g_customer_item_nbr,
  null as g_customer_po_line_nbr,
  case 
    when vbap.posnr is not null then (
      select bstk 
      from vbkd 
      where vbeln = vbep.vbeln 
        and posnr = vbep.posnr
    )
    else (
      select bstk 
      from vbkd 
      where vbeln = vbep.vbeln
    )
  end as g_customer_po_nbr,
  case 
    when vbap.posnr is not null then (
      select bsark 
      from vbkd 
      where vbeln = vbep.vbeln 
        and posnr = vbep.posnr
    )
    else (
      select bsark 
      from vbkd 
      where vbeln = vbep.vbeln
    )
  end as g_customer_po_type,
  vbep.edatu as g_customer_request_dt_yyyymmdd,
  vbep.etenr as g_delivery_schedule_line_nbr,
  case 
    when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
    else 'no'
  end as g_flag_consignment_order,
  vbap.uepos as g_flag_has_parent,
  case 
    when mska.sobkz = 'E' 
      and (mska.kalab > 0 or mska.kains > 0 or mska.kaspe > 0 or mska.kavla > 0 or mska.kavin > 0 or mska.kavsp > 0) 
    then 'yes'
    else 'no'
  end as g_flag_inventory_fully_allocated,
  vbap.uepos as g_flag_is_parent,
  case 
    when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes'
    when knvv.kdgrp in ('05', '06', '07') then 'yes'
    else 'no'
  end as g_flag_is_transfer_order,
  vbep.lfrel as g_flag_material_transacted,
  case 
    when vbep.lifsp is not null then 'yes'
    when vbak.lifsk is not null then 'yes'
    when vbuk.cmgst in ('B', 'C') then 'yes'
    else 'no'
  end as g_flag_on_hold
from vbep
left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
left join kna1 on vbak.kunnr = kna1.kunnr
left join knvv on vbak.kunnr = knvv.kunnr and vbak.vkorg = knvv.vkorg and vbak.vtweg = knvv.vtweg and vbak.spart = knvv.spart
left join mska on mska.vbeln = vbep.vbeln and mska.posnr = vbep.posnr
),
uom_conversion as (
    select 
    vbep.vbeln,
    vbep.posnr,
    case 
        when exists (
            select 1 
            from mska 
            where mska.vbeln = vbep.vbeln 
              and mska.posnr = vbep.posnr
        ) 
        then coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)
        else g_shipped_qty_primary_uom
    end as g_allocated_qty_primary_uom,
    null as g_cancel_qty_primary_uom,
    case
        when vbak.auart = 'DEMO' and ship_lines.sttrg = '7' then 0
        when trim(vbap.fkrel) in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') 
        then round(coalesce(vbep.bmeng, 0) - coalesce(lst.shipped_qty, 0), 4)
        when trim(vbap.fkrel) = '' then 0
        else round(
            coalesce(vbep.bmeng, 0) - 
            case 
                when lst.shipped_qty <> 0 then lst.shipped_qty
                when lst.shipped_qty = 0 and inv.invoice_qty <> 0 then inv.invoice_qty
                else 0
            end, 
            0
        )
    end - coalesce(cancel_qty_primary_uom, 0) as g_open_qty_primary_uom,
    vbep.bmeng as g_order_qty_order_uom,
    vbep.bmeng as g_order_qty_primary_uom,
    trim(vbap.vrkme) as g_order_uom_cd,
    trim(vbap.meins) as g_primary_uom_cd,
    case 
        when trim(mbew.vprsv) = 'V'
        then round(
            case 
                when t001.waers in ('KRW', 'JPY') then mbew.verpr * 100 
                else mbew.verpr 
            end / currency_factor, 
            2
        )
        when trim(mbew.vprsv) = 'S' 
        then round(
            case 
                when t001.waers in ('KRW', 'JPY') then mbew.stprs * 100 
                else mbew.stprs 
            end / currency_factor, 
            2
        )
    end as g_unit_cost_company_currency_primary_uom,
    case 
        when trim(vbap.waerk) = trim(t001.waers) 
        then 
            case 
                when trim(vbap.waerk) = 'JPY' 
                then puom.price_uom * 100 * coalesce(vbkd.kursk, vbkd_derived.kursk) * (tcurf.tfact / tcurf.ffact)
                else puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk) * (tcurf.tfact / tcurf.ffact)
            end
        else (puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact)
    end as g_unit_price_company_currency_primary_uom,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.bmeng
        else (marm.umrez / marm.umren) * vbep.bmeng
    end as g_order_qty_primary_uom,
    case 
        when uom_check = 'yes' 
        then 
            case 
                when netpr = 0 then netwr / order_qty 
                else (netpr / kpein) 
            end
        else 
            case 
                when netpr = 0 then netwr / order_qty 
                else (netpr / kpein) / conversion_factor 
            end
    end as g_unit_price_order_currency_primary_uom
),
document_flow as (
    select
    concat('gbl', g_order_company_cd) as co_key,
    case 
        when exists (
            select 1
            from mska
            where mska.vbeln = vbap.vbeln
              and mska.posnr = vbap.posnr
        ) then (
            coalesce(mska.kalab, 0) +
            coalesce(mska.kains, 0) +
            coalesce(mska.kaspe, 0) +
            coalesce(mska.kavla, 0) +
            coalesce(mska.kavin, 0) +
            coalesce(mska.kavsp, 0)
        )
        else g_shipped_qty_primary_uom
    end as g_allocated_qty_primary_uom,
    null as g_availability_dt_yyyymmdd,
    case 
        when vbap.posnr is not null then (
            select kunnr
            from vbpa
            where vbeln = vbap.vbeln
              and posnr = vbap.posnr
              and parvw = 'RE/BP'
            limit 1
        )
        else (
            select kunnr
            from vbpa
            where vbeln = vbap.vbeln
              and parvw = 'RE/BP'
            limit 1
        )
    end as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null then null
        else case 
            when vbap.aedat = 0 then vbap.erdat
            else vbap.aedat
        end
    end as g_cancel_dt_yyyymmdd,
    null as g_cancel_qty_primary_uom,
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers
    end as g_company_currency_cd,
    vbap.kdmat as g_customer_item_nbr,
    null as g_customer_po_line_nbr,
    case 
        when vbap.posnr is not null then (
            select bstdk
            from vbkd
            where vbeln = vbap.vbeln
              and posnr = vbap.posnr
            limit 1
        )
        else (
            select bstdk
            from vbkd
            where vbeln = vbap.vbeln
            limit 1
        )
    end as g_customer_po_nbr,
    case 
        when vbap.posnr is not null then (
            select bsark
            from vbkd
            where vbeln = vbap.vbeln
              and posnr = vbap.posnr
            limit 1
        )
        else (
            select bsark
            from vbkd
            where vbeln = vbap.vbeln
            limit 1
        )
    end as g_customer_po_type,
    vbep.edatu as g_customer_request_dt_yyyymmdd,
    vbep.etenr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no'
    end as g_flag_consignment_order,
    vbap.uepos as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' 
          and (coalesce(mska.kalab, 0) > 0 
            or coalesce(mska.kains, 0) > 0 
            or coalesce(mska.kaspe, 0) > 0 
            or coalesce(mska.kavla, 0) > 0 
            or coalesce(mska.kavin, 0) > 0 
            or coalesce(mska.kavsp, 0) > 0) then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    vbap.uepos as g_flag_is_parent,
    case 
        when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes'
        when knvv.kdgrp in ('05', '06', '07') then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    vbep.lfrel as g_flag_material_transacted,
    case 
        when vbep.lifsp <> '' then 'yes'
        when vbak.lifsk <> '' then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no'
    end as g_flag_on_hold
from vbep
left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
left join mska on mska.vbeln = vbap.vbeln and mska.posnr = vbap.posnr
left join kna1 on vbak.kunnr = kna1.kunnr
left join knvv on vbak.kunnr = knvv.kunnr and vbak.vkorg = knvv.vkorg and vbak.vtweg = knvv.vtweg and vbak.spart = knvv.spart
left join vbpa on vbpa.vbeln = vbap.vbeln and vbpa.posnr = vbap.posnr
),
last_event_dt as (
    select
    df.vbeln as order_nbr,
    df.posnr as order_line_nbr,
    first_value(df.event_dt) over (
        partition by df.vbeln, df.posnr
        order by df.event_dt desc
        rows between unbounded preceding and unbounded following
    ) as last_event_dt
from
    document_flow df
where
    df.event_dt is not null
),
vbep_bmeng as (
    select 
    vbep.vbeln,
    vbep.posnr,
    sum(vbep.bmeng) over (partition by vbep.vbeln, vbep.posnr) as g_order_qty_order_uom,
    sum(vbep.bmeng) over (partition by vbep.vbeln, vbep.posnr) as g_order_qty_primary_uom
from 
    vbep
),
vbfa_dedup as (
    select 
    vbeln,
    posnr,
    row_number() over (
        partition by vbeln, posnr 
        order by erdat desc, erzet desc, vbfa_key desc
    ) as dedup_rank
from document_flow
where dedup_rank = 1
),
order_schedule as (
    select
  vbep.etenr as g_delivery_schedule_line_nbr,
  vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
  sum(vbep_bmeng.confirmed_qty) over (
    partition by vbep.vbeln, vbep.posnr
    order by vbep.mbdat
    rows between unbounded preceding and current row
  ) as running_total_qty
from
  schedule_extract
left join
  vbep_bmeng
on
  schedule_extract.vbeln = vbep_bmeng.vbeln
  and schedule_extract.posnr = vbep_bmeng.posnr
  and schedule_extract.etenr = vbep_bmeng.etenr
),
order_shipment as (
    select
    vbelv,
    vbeln,
    posnn,
    posnv,
    vbtyp_n,
    sum(rfmng) over (partition by vbelv, posnv order by erdat rows between unbounded preceding and current row) as shipped_qty_primary_uom,
    first_value(erdat) over (partition by vbelv, posnv order by erdat desc) as g_last_actual_ship_dt_yyyymmdd
from
    vbfa_dedup
where
    vbtyp_n = 'J'
),
last_shipped_dt as (
    select 
    schedule_id,
    first_value(shipped_date) over (
        partition by schedule_id 
        order by shipped_date desc
    ) as g_last_actual_ship_dt_yyyymmdd
from 
    order_shipment
),
order_invoice as (
    select 
    vbeln,
    posnr,
    first_value(erdat) over (
        partition by vbeln, posnr 
        order by erdat desc
    ) as g_invoice_dt_yyyymmdd
from 
    vbfa_dedup
),
tcurf_dedup as (
    select 
    tcurf.ffact as from_currency,
    tcurf.tfact as to_currency,
    tcurf.ukurs as exchange_rate,
    row_number() over (
        partition by tcurf.ffact, tcurf.tfact 
        order by tcurf.gdatu desc
    ) as row_num
from 
    tcurf
where 
    tcurf.ffact is not null 
    and tcurf.tfact is not null
),
final_joined as (
    select
  concat_ws('|', 'gbl', g_order_company_cd) as co_key,
  case
    when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0
    then mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp
    else g_shipped_qty_primary_uom
  end as g_allocated_qty_primary_uom,
  cast(null as string) as g_availability_dt_yyyymmdd,
  case
    when bp.posnr is not null then bp.kunnr
    else bp_no_posnr.kunnr
  end as g_bill_to_customer_nbr,
  case
    when vbap.abgru <> '' then null
    when vbap.aedat = 0 then vbap.erdat
    else vbap.aedat
  end as g_cancel_dt_yyyymmdd,
  cast(null as string) as g_cancel_qty_primary_uom,
  case
    when t001.waers = 'RMB' then 'CNY'
    else t001.waers
  end as g_company_currency_cd,
  vbap.kdmat as g_customer_item_nbr,
  cast(null as string) as g_customer_po_line_nbr,
  case
    when po.posnr is not null then po.bstnk
    else po_no_posnr.bstnk
  end as g_customer_po_nbr,
  case
    when po.posnr is not null then po.bstkd
    else po_no_posnr.bstkd
  end as g_customer_po_type,
  vbep.edatu as g_customer_request_dt_yyyymmdd,
  vbep.etenr as g_delivery_schedule_line_nbr,
  case
    when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
    else 'no'
  end as g_flag_consignment_order,
  vbap.uepos as g_flag_has_parent,
  case
    when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0
    then 'yes'
    else 'no'
  end as g_flag_inventory_fully_allocated,
  case
    when vbap.uepos = '' then 'yes'
    else 'no'
  end as g_flag_is_parent,
  case
    when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes'
    when knvv.kdgrp in ('05', '06', '07') then 'yes'
    else 'no'
  end as g_flag_is_transfer_order,
  vbep.lfrel as g_flag_material_transacted,
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
  vbak.vbtyp as g_flag_return,
  case
    when order_qty_primary_uom = 0 then 'no'
    when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
    when trim(tvap.prsfd) = 'X' then 'yes'
    else 'no'
  end as g_flag_revenue_recognition,
  vbkd.inco1 as g_inco_terms,
  vbfa.erdat as g_invoice_dt_yyyymmdd,
  vbap.matnr as g_item_nbr,
  cast(null as string) as g_last_actual_ship_dt_yyyymmdd,
  vbup.gbsta as g_line_status_cd,
  case
    when order_qty_primary_uom > 0 then greatest(order_qty_primary_uom - coalesce(lst.shipped_qty, 0) - coalesce(inv.invoice_qty, 0) - coalesce(cancel_qty_primary_uom, 0), 0)
    when order_qty_primary_uom < 0 then least(order_qty_primary_uom - coalesce(lst.shipped_qty, 0) - coalesce(inv.invoice_qty, 0) - coalesce(cancel_qty_primary_uom, 0), 0)
    else 0
  end as g_open_qty_primary_uom,
  vbap.pstyv as g_order_category,
  t001k.bukrs as g_order_company_cd,
  case
    when trim(vbak.waerk) = 'RMB' then 'CNY'
    else trim(vbak.waerk)
  end as g_order_currency_cd,
  vbap.erdat as g_order_dt_yyyymmdd,
  vbep.posnr as g_order_line_nbr,
  vbep.vbeln as g_order_nbr,
  vbep.bmeng as g_order_qty_order_uom,
  vbep.bmeng as g_order_qty_primary_uom,
  vbak.auart as g_order_type,
  trim(vbap.vrkme) as g_order_uom_cd,
  cast(null as string) as g_original_customer_request_dt_yyyymmdd,
  case
    when trim(vbap.werks) = '0070' then vbak.zz_ship_by
    else coalesce(zosdates.lddat, vbep.edatu)
  end as g_original_promised_ship_dt_yyyymmdd,
  vbap.uepos as g_parent_order_line_nbr,
  cast(null as string) as g_payment_terms,
  vbap.werks as g_plant_cd,
  trim(vbap.meins) as g_primary_uom_cd,
  case
    when trim(vbap.werks) = '0070' then vbak.zz_ship_by
    else trim(vbep.edatu)
  end as g_promised_ship_dt_yyyymmdd,
  vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
  case
    when we.posnr is not null then we.kunnr
    else we_no_posnr.kunnr
  end as g_ship_to_customer_nbr,
  case
    when g_order_qty_primary_uom = 0 then 0
    else datediff(vbep.mbdat, vbep.edatu)
  end as g_ship_to_delivery_days,
  tvsbt.vsbed as g_shipment_mode,
  coalesce(lst.shipped_qty, inv.invoice_qty, 0) as g_shipped_qty_primary_uom,
  'GBL' as g_source_system_cd,
  case
    when trim(mbew.vprsv) = 'V' then round(if(t001.waers in ('KRW', 'JPY'), mbew.verpr * 100, mbew.verpr) / currency_factor, 2)
    when trim(mbew.vprsv) = 'S' then round(if(t001.waers in ('KRW', 'JPY'), mbew.stprs * 100, mbew.stprs) / currency_factor, 2)
    else null
  end as g_unit_cost_company_currency_primary_uom,
  case
    when trim(vbap.waerk) = trim(t001.waers) then
      if(trim(vbap.waerk) = 'JPY', puom.price_uom * 100 * coalesce(vbkd.kursk, vbkd_derived.kursk), puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact)
    else
      (puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact)
  end as g_unit_price_company_currency_primary_uom,
  case
    when vbep.vrkme = vbap.meins then vbep.bmeng
    else (marm.umrez / marm.umren) * vbep.bmeng
  end as g_unit_price_order_currency_primary_uom,
  concat_ws('|', 'gbl', g_plant_cd) as plant_key,
  concat_ws('|', 'gbl', g_item_nbr) as prod_key,
  concat_ws('|', 'gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
  concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
  concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key,
  cast(null as string) as flag_is_blanket
from header_extract he
left join item_extract ie on he.vbeln = ie.vbeln
left join schedule_extract se on ie.vbeln = se.vbeln and ie.posnr = se.posnr
left join uom_conversion uc on ie.matnr = uc.matnr and se.vrkme = uc.meinh
left join document_flow df on se.vbeln = df.vbeln
left join last_event_dt led on se.vbeln = led.vbeln and se.posnr = led.posnr
left join order_schedule os on se.vbeln = os.vbeln and se.posnr = os.posnr
left join order_shipment osht on se.vbeln = osht.vbeln and se.posnr = osht.posnr
left join last_shipped_dt lsd on se.vbeln = lsd.vbeln and se.posnr = lsd.posnr
left join order_invoice oi on se.vbeln = oi.vbeln and se.posnr = oi.posnr
left join tcurf_dedup tcd on se.vbeln = tcd.vbeln and se.posnr = tcd.posnr
),
final_joined_with_flags as (
    select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp)
        else g_shipped_qty_primary_uom 
    end as g_allocated_qty_primary_uom,
    cast(null as string) as g_availability_dt_yyyymmdd,
    case 
        when bp.vbeln is not null then bp.kunnr
        else null 
    end as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null then null
        when vbap.abgru = '' then null
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat 
    end as g_cancel_dt_yyyymmdd,
    cast(null as string) as g_cancel_qty_primary_uom,
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers 
    end as g_company_currency_cd,
    vbap.kdmat as g_customer_item_nbr,
    cast(null as string) as g_customer_po_line_nbr,
    case 
        when bp.vbeln is not null then bp.bstnk
        else null 
    end as g_customer_po_nbr,
    case 
        when bp.vbeln is not null then bp.bstkd
        else null 
    end as g_customer_po_type,
    vbep.edatu as g_customer_request_dt_yyyymmdd,
    vbep.etenr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no' 
    end as g_flag_consignment_order,
    case 
        when vbap.uepos > 0 then 'yes'
        else 'no' 
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then 'yes'
        else 'no' 
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.uepos = 0 then 'yes'
        else 'no' 
    end as g_flag_is_parent,
    case 
        when knvv.ktokd in ('ZSUB', 'IC3P') or knvv.kdgrp in ('05', '06', '07') then 'yes'
        else 'no' 
    end as g_flag_is_transfer_order,
    vbep.lfrel as g_flag_material_transacted,
    case 
        when vbep.lifsp <> '' then 'yes'
        when vbak.lifsk <> '' then 'yes'
        when vbuk.cmgs = 'B' or vbuk.cmgs = 'C' then 'yes'
        else 'no' 
    end as g_flag_on_hold,
    case 
        when vbak.autlf = 'X' then 'no'
        when cancel_qty_primary_uom = order_qty_primary_uom then 'no'
        when open_qty_primary_uom <= 0 then 'no'
        else 'yes' 
    end as g_flag_open_to_ship,
    vbak.vbtyp as g_flag_return,
    case 
        when coalesce(order_qty_primary_uom, 0) = 0 then 'no'
        when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
        when trim(tvap.prsfd) = 'X' then 'yes'
        else 'no' 
    end as g_flag_revenue_recognition,
    vbkd.inco1 as g_inco_terms,
    vbfa.erdat as g_invoice_dt_yyyymmdd,
    vbap.matnr as g_item_nbr,
    cast(null as string) as g_last_actual_ship_dt_yyyymmdd,
    vbup.gbsta as g_line_status_cd,
    case 
        when order_type = 'DEMO' and ship_lines.sttrg = '7' then 0
        when tvap.fkrel in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') 
        then round((coalesce(order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0)), 4)
        when trim(tvap.fkrel) = '' then 0
        else round((coalesce(order_qty_primary_uom, 0) - 
            (case 
                when lst.shipped_qty <> 0 then lst.shipped_qty
                when lst.shipped_qty = 0 and inv.invoice_qty <> 0 then inv.invoice_qty
                else 0 
            end)), 0) 
    end - coalesce(cancel_qty_primary_uom, 0) as g_open_qty_primary_uom,
    vbap.pstyv as g_order_category,
    t001k.bukrs as g_order_company_cd,
    case 
        when trim(waerk) = 'RMB' then 'CNY'
        else trim(waerk) 
    end as g_order_currency_cd,
    vbap.erdat as g_order_dt_yyyymmdd,
    vbep.posnr as g_order_line_nbr,
    vbep.vbeln as g_order_nbr,
    vbep.bmeng as g_order_qty_order_uom,
    vbep.bmeng as g_order_qty_primary_uom,
    vbak.auart as g_order_type,
    trim(vbap.vrkme) as g_order_uom_cd,
    cast(null as string) as g_original_customer_request_dt_yyyymmdd,
    case 
        when trim(vbap.werks) = '0070' then vbak.zz_ship_by
        else coalesce(case 
            when sls.original_promised_ship_dt_yyyymmdd is null then vbep.edatu
            else sls.original_promised_ship_dt_yyyymmdd 
        end, null) 
    end as g_original_promised_ship_dt_yyyymmdd,
    vbep.uepos as g_parent_order_line_nbr,
    cast(null as string) as g_payment_terms,
    vbap.werks as g_plant_cd,
    trim(vbap.meins) as g_primary_uom_cd,
    case 
        when trim(vbap.werks) = '0070' then vbak.zz_ship_by
        else trim(vbep.edatu) 
    end as g_promised_ship_dt_yyyymmdd,
    vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
    case 
        when we.vbeln is not null then we.kunnr
        else null 
    end as g_ship_to_customer_nbr,
    case 
        when g_order_qty_primary_uom = 0 then 0
        else datediff(vbep.mbdat, vbep.edatu) 
    end as g_ship_to_delivery_days,
    tvsbt.vsbed as g_shipment_mode,
    d_vbfa.qty as g_shipped_qty_primary_uom,
    'GBL' as g_source_system_cd,
    case 
        when trim(mbew.vprsv) = 'V' then round(if(t001.waers in ('KRW', 'JPY'), mbew.verpr * 100, mbew.verpr) / currency_factor, 2)
        when trim(mbew.vprsv) = 'S' then round(if(t001.waers in ('KRW', 'JPY'), mbew.stprs * 100, mbew.stprs) / currency_factor, 2) 
    end as g_unit_cost_company_currency_primary_uom,
    case 
        when trim(vbap.waerk) = trim(t001.waers) 
        then if(trim(vbap.waerk) = 'JPY', puom.price_uom * 100 * coalesce(vbkd.kursk, vbkd_derived.kursk), puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact)
        else (puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact) 
    end as g_unit_price_company_currency_primary_uom,
    case 
        when vbep.vrkme = vbap.meins then vbep.bmeng
        else (marm.umrez / marm.umren) * vbep.bmeng 
    end as g_unit_price_order_currency_primary_uom,
    concat_ws('|', 'gbl', g_plant_cd) as plant_key,
    concat_ws('|', 'gbl', g_item_nbr) as prod_key,
    concat_ws('|', 'gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key,
    cast(null as string) as flag_is_blanket
from final_joined
left join mska on final_joined.vbeln = mska.vbeln and final_joined.posnr = mska.posnr
left join vbap on final_joined.vbeln = vbap.vbeln and final_joined.posnr = vbap.posnr
left join vbep on final_joined.vbeln = vbep.vbeln and final_joined.posnr = vbep.posnr
left join vbfa on final_joined.vbeln = vbfa.vbelv and final_joined.posnr = vbfa.posnv
left join vbkd on final_joined.vbeln = vbkd.vbeln
left join vbak on final_joined.vbeln = vbak.vbeln
left join vbuk on final_joined.vbeln = vbuk.vbeln
left join tvap on vbap.pstyv = tvap.pstyv
left join t001 on vbak.bukrs_vf = t001.bukrs
left join t001k on vbap.werks = t001k.bwkey
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join knvv on vbak.kunnr = knvv.kunnr
left join tvsbt on vbak.vsbed = tvsbt.vsbed
left join d_vbfa on final_joined.vbeln = d_vbfa.vbelv and final_joined.posnr = d_vbfa.posnv
left join sls on final_joined.vbeln = sls.vbeln and final_joined.posnr = sls.posnr
left join inv on final_joined.vbeln = inv.vbeln and final_joined.posnr = inv.posnr
left join ship_lines on final_joined.vbeln = ship_lines.vbeln and final_joined.posnr = ship_lines.posnr
)
select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    g_allocated_qty_primary_uom,
    g_availability_dt_yyyymmdd,
    g_bill_to_customer_nbr,
    g_cancel_dt_yyyymmdd,
    g_cancel_qty_primary_uom,
    case when g_order_currency_cd = 'RMB' then 'CNY' else g_order_currency_cd end as g_company_currency_cd,
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
from final_joined_with_flags;