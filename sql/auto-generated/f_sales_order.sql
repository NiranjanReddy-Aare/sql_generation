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
    coalesce(
        (select kunnr 
         from vbap 
         where vbeln = g_order_nbr 
           and posnr = g_order_line_nbr 
           and parvw = 'RE/BP'),
        (select kunnr 
         from vbap 
         where vbeln = g_order_nbr 
           and parvw = 'RE/BP')
    ) as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null or vbap.abgru = '' then 
            case 
                when vbap.aedat = 0 then vbap.erdat 
                else vbap.aedat 
            end 
        else null 
    end as g_cancel_dt_yyyymmdd,
    null as g_cancel_qty_primary_uom,
    case 
        when t001.waers = 'RMB' then 'CNY' 
        else t001.waers 
    end as g_company_currency_cd,
    vbap.kdmat as g_customer_item_nbr,
    null as g_customer_po_line_nbr,
    coalesce(
        (select bstdk 
         from vbkd 
         where vbeln = g_order_nbr 
           and posnr = g_order_line_nbr),
        (select bstdk 
         from vbkd 
         where vbeln = g_order_nbr)
    ) as g_customer_po_nbr,
    coalesce(
        (select bsark 
         from vbkd 
         where vbeln = g_order_nbr 
           and posnr = g_order_line_nbr),
        (select bsark 
         from vbkd 
         where vbeln = g_order_nbr)
    ) as g_customer_po_type,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') then 
            coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') then 
            trim(vbep.request_dt)
        else vbep.edatu 
    end as g_customer_request_dt_yyyymmdd,
    vbep.etenr as g_delivery_schedule_line_nbr,
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
          and (coalesce(mska.kalab, 0) > 0 
            or coalesce(mska.kains, 0) > 0 
            or coalesce(mska.kaspe, 0) > 0 
            or coalesce(mska.kavla, 0) > 0 
            or coalesce(mska.kavin, 0) > 0 
            or coalesce(mska.kavsp, 0) > 0) then 'yes' 
        else 'no' 
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any(select uepos 
                              from vbap as vbap_inner 
                              where vbap_inner.vbeln = vbap.vbeln) then 'yes' 
        else 'no' 
    end as g_flag_is_parent,
    case 
        when vbak.kunnr in (select kna1.kunnr 
                            from kna1 
                            where kna1.ktokd in ('ZSUB', 'IC3P')) then 'yes'
        when (vbak.kunnr, vbak.vkorg, vbak.vtweg, vbak.spart) in 
             (select knvv.kunnr, knvv.vkorg, knvv.vtweg, knvv.spart 
              from knvv 
              where knvv.kdgrp in ('05', '06', '07')) then 'yes'
        else 'no' 
    end as g_flag_is_transfer_order,
    case 
        when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
        when trim(vbup.lfsta) in ('A', 'B', 'C') 
          and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') then 'no'
        when trim(vbup.lfsta) = '' or vbup.lfsta is null then 'no'
        else 'yes' 
    end as g_flag_material_transacted,
    case 
        when vbep.lifsp != '' then 'yes'
        when vbak.lifsk != '' then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no' 
    end as g_flag_on_hold
from vbap
left join vbep on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
left join mska on mska.vbeln = vbap.vbeln and mska.posnr = vbap.posnr
left join mara on vbap.matnr = mara.matnr
left join vbup on vbap.vbeln = vbup.vbeln and vbap.posnr = vbup.posnr
left join vbkd on vbap.vbeln = vbkd.vbeln and vbap.posnr = vbkd.posnr
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
      coalesce(mska.kalab, 0) + 
      coalesce(mska.kains, 0) + 
      coalesce(mska.kaspe, 0) + 
      coalesce(mska.kavla, 0) + 
      coalesce(mska.kavin, 0) + 
      coalesce(mska.kavsp, 0)
    else g_shipped_qty_primary_uom
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
    when vbap.abgru = '' then null
    else coalesce(vbap.aedat, vbap.erdat)
  end as g_cancel_dt_yyyymmdd,
  null as g_cancel_qty_primary_uom,
  case 
    when t001.waers = 'RMB' then 'CNY'
    else t001.waers
  end as g_company_currency_cd,
  (select kdmat from vbap where vbeln = g_order_nbr and posnr = g_order_line_nbr) as g_customer_item_nbr,
  null as g_customer_po_line_nbr,
  case 
    when vbap.posnr is not null then (
      select bstdk 
      from vbkd 
      where vbeln = g_order_nbr 
        and posnr = g_order_line_nbr
    )
    else (
      select bstdk 
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
  case 
    when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
    when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') then trim(vbep.request_dt)
    else vbep.edatu
  end as g_customer_request_dt_yyyymmdd,
  vbep.etenr as g_delivery_schedule_line_nbr,
  case 
    when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
    else 'no'
  end as g_flag_consignment_order,
  case 
    when vbap.uepos is not null and vbap.uepos <> '0' then 'yes'
    else 'no'
  end as g_flag_has_parent,
  case 
    when mska.sobkz = 'E' and (
      coalesce(mska.kalab, 0) + 
      coalesce(mska.kains, 0) + 
      coalesce(mska.kaspe, 0) + 
      coalesce(mska.kavla, 0) + 
      coalesce(mska.kavin, 0) + 
      coalesce(mska.kavsp, 0)
    ) > 0 then 'yes'
    else 'no'
  end as g_flag_inventory_fully_allocated,
  case 
    when vbap.posnr = vbap.uepos then 'yes'
    else 'no'
  end as g_flag_is_parent,
  case 
    when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes'
    when knvv.kdgrp in ('05', '06', '07') then 'yes'
    else 'no'
  end as g_flag_is_transfer_order,
  case 
    when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
    when trim(vbup.lfsta) in ('A', 'B', 'C') and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') then 'no'
    when trim(vbup.lfsta) = '' or vbup.lfsta is null then 'no'
    else 'yes'
  end as g_flag_material_transacted,
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
  coalesce(
    (select kunnr 
     from vbap 
     where vbap.vbeln = vbep.vbeln 
       and vbap.posnr = vbep.posnr 
       and vbap.parvw = 'RE/BP'),
    (select kunnr 
     from vbap 
     where vbap.vbeln = vbep.vbeln 
       and vbap.parvw = 'RE/BP')
  ) as g_bill_to_customer_nbr,
  case 
    when vbap.abgru is null or vbap.abgru = '' then 
      case 
        when vbap.aedat = 0 then vbap.erdat 
        else vbap.aedat 
      end 
    else null 
  end as g_cancel_dt_yyyymmdd,
  null as g_cancel_qty_primary_uom,
  case 
    when t001.waers = 'RMB' then 'CNY' 
    else t001.waers 
  end as g_company_currency_cd,
  vbap.kdmat as g_customer_item_nbr,
  null as g_customer_po_line_nbr,
  coalesce(
    (select bstkd 
     from vbkd 
     where vbkd.vbeln = vbep.vbeln 
       and vbkd.posnr = vbep.posnr),
    (select bstkd 
     from vbkd 
     where vbkd.vbeln = vbep.vbeln)
  ) as g_customer_po_nbr,
  coalesce(
    (select bsark 
     from vbkd 
     where vbkd.vbeln = vbep.vbeln 
       and vbkd.posnr = vbep.posnr),
    (select bsark 
     from vbkd 
     where vbkd.vbeln = vbep.vbeln)
  ) as g_customer_po_type,
  case 
    when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') then 
      coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
    when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') then 
      trim(vbep.request_dt)
    else vbep.edatu 
  end as g_customer_request_dt_yyyymmdd,
  vbep.etenr as g_delivery_schedule_line_nbr,
  case 
    when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes' 
    else 'no' 
  end as g_flag_consignment_order,
  case 
    when vbap.uepos is not null and vbap.uepos <> 0 then 'yes' 
    else 'no' 
  end as g_flag_has_parent,
  case 
    when exists (
      select 1 
      from mska 
      where mska.vbeln = vbep.vbeln 
        and mska.posnr = vbep.posnr 
        and mska.sobkz = 'E' 
        and (mska.kalab > 0 or mska.kains > 0 or mska.kaspe > 0 or mska.kavla > 0 or mska.kavin > 0 or mska.kavsp > 0)
    ) then 'yes' 
    else 'no' 
  end as g_flag_inventory_fully_allocated,
  case 
    when vbap.posnr = vbap.uepos then 'yes' 
    else 'no' 
  end as g_flag_is_parent,
  case 
    when kna1.ktokd in ('ZSUB', 'IC3P') then 'yes' 
    when knvv.kdgrp in ('05', '06', '07') then 'yes' 
    else 'no' 
  end as g_flag_is_transfer_order,
  case 
    when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
    when trim(vbup.lfsta) in ('A', 'B', 'C') and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') then 'no'
    when trim(vbup.lfsta) = '' or vbup.lfsta is null then 'no'
    else 'yes' 
  end as g_flag_material_transacted,
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
),
uom_conversion as (
    select 
    vbap.matnr,
    vbap.vrkme as g_order_uom_cd,
    vbap.meins as g_primary_uom_cd,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.bmeng
        else (marm.umrez / marm.umren) * vbep.bmeng
    end as g_order_qty_primary_uom,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.bmeng
        else vbep.wmeng
    end as g_order_qty_order_uom,
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
    case 
        when order_type = 'DEMO' and ship_lines.sttrg = '7' then 0
        when tvap.fkrel in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') 
        then round(coalesce(order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0), 4)
        when trim(tvap.fkrel) = '' 
        then 0
        else round(
            coalesce(order_qty_primary_uom, 0) - 
            case 
                when lst.shipped_qty <> 0 then lst.shipped_qty
                when lst.shipped_qty = 0 and inv.invoice_qty <> 0 then inv.invoice_qty
                else 0
            end, 
            0
        )
    end - coalesce(cancel_qty_primary_uom, 0) as g_open_qty_primary_uom,
    vbap.trim(vrkme) as g_order_uom_cd,
    vbap.trim(meins) as g_primary_uom_cd,
    case 
        when trim(mbew.vprsv) = 'V'
        then round(
            case 
                when t001.waers in ('KRW', 'JPY') 
                then mbew.verpr * 100 
                else mbew.verpr 
            end / currency_factor, 
            2
        )
        when trim(mbew.vprsv) = 'S' 
        then round(
            case 
                when t001.waers in ('KRW', 'JPY') 
                then mbew.stprs * 100 
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
        else puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk) * (tcurf.tfact / tcurf.ffact)
    end as g_unit_price_company_currency_primary_uom,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.bmeng
        else (marm.umrez / marm.umren) * vbep.bmeng
    end as g_unit_price_order_currency_primary_uom
from vbep
left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
),
document_flow as (
    select
    concat('gbl', vbak.bukrs) as co_key,
    case 
        when exists (
            select 1
            from mska
            where mska.vbeln = vbap.vbeln
              and mska.posnr = vbap.posnr
              and (mska.kalab > 0 or mska.kains > 0 or mska.kaspe > 0 or mska.kavla > 0 or mska.kavin > 0 or mska.kavsp > 0)
        ) then coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)
        else vbep.lfimg
    end as g_allocated_qty_primary_uom,
    null as g_availability_dt_yyyymmdd,
    coalesce(
        (select kna1.kunnr
         from kna1
         left join vbpa on kna1.kunnr = vbpa.kunnr
         where vbpa.vbeln = vbap.vbeln
           and vbpa.posnr = vbap.posnr
           and vbpa.parvw = 'RE/BP'),
        (select kna1.kunnr
         from kna1
         left join vbpa on kna1.kunnr = vbpa.kunnr
         where vbpa.vbeln = vbap.vbeln
           and vbpa.parvw = 'RE/BP')
    ) as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null or vbap.abgru = '' then null
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat
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
           and vbkd.posnr = vbap.posnr),
        (select vbkd.bstkd
         from vbkd
         where vbkd.vbeln = vbap.vbeln)
    ) as g_customer_po_nbr,
    coalesce(
        (select vbkd.bsark
         from vbkd
         where vbkd.vbeln = vbap.vbeln
           and vbkd.posnr = vbap.posnr),
        (select vbkd.bsark
         from vbkd
         where vbkd.vbeln = vbap.vbeln)
    ) as g_customer_po_type,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') then trim(vbep.request_dt)
        else vbep.edatu
    end as g_customer_request_dt_yyyymmdd,
    vbep.etenr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no'
    end as g_flag_consignment_order,
    case 
        when vbap.uepos is not null and vbap.uepos != '0' then 'yes'
        else 'no'
    end as g_flag_has_parent,
    case 
        when exists (
            select 1
            from mska
            where mska.vbeln = vbap.vbeln
              and mska.posnr = vbap.posnr
              and mska.sobkz = 'E'
              and (mska.kalab > 0 or mska.kains > 0 or mska.kaspe > 0 or mska.kavla > 0 or mska.kavin > 0 or mska.kavsp > 0)
        ) then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any (
            select vbap_inner.uepos
            from vbap as vbap_inner
            where vbap_inner.vbeln = vbap.vbeln
        ) then 'yes'
        else 'no'
    end as g_flag_is_parent,
    case 
        when (select kna1.ktokd
              from kna1
              where kna1.kunnr = vbak.kunnr) in ('ZSUB', 'IC3P') then 'yes'
        when (select knvv.kdgrp
              from knvv
              where knvv.kunnr = vbak.kunnr
                and knvv.vkorg = vbak.vkorg
                and knvv.vtweg = vbak.vtweg
                and knvv.spart = vbak.spart) in ('05', '06', '07') then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    case 
        when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
        when trim(vbup.lfsta) in ('A', 'B', 'C') and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') then 'no'
        when trim(vbup.lfsta) = '' or vbup.lfsta is null then 'no'
        else 'yes'
    end as g_flag_material_transacted,
    case 
        when vbep.lifsp != '' then 'yes'
        when vbak.lifsk != '' then 'yes'
        when vbuk.cmgst in ('B', 'C') then 'yes'
        else 'no'
    end as g_flag_on_hold
from vbep
left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
),
last_event_dt as (
    select
    df.vbeln as order_nbr,
    df.posnr as order_line_nbr,
    first_value(df.event_dt) over (
        partition by df.vbeln, df.posnr
        order by df.event_dt desc
    ) as last_event_dt
from
    document_flow df
),
vbep_bmeng as (
    select 
    vbep.vbeln,
    vbep.posnr,
    sum(vbep.bmeng) as calculated_bmeng
from 
    schedule_extract vbep
group by 
    vbep.vbeln, 
    vbep.posnr
),
vbfa_dedup as (
    select 
    df.vbeln,
    df.posnr,
    df.vbtyp,
    df.vbeln_parent,
    df.posnr_parent,
    df.vbeln_child,
    df.posnr_child,
    df.vbfa_erdat,
    df.vbfa_erzet,
    df.vbfa_vornr,
    row_number() over (
        partition by df.vbeln, df.posnr, df.vbtyp, df.vbeln_parent, df.posnr_parent, df.vbeln_child, df.posnr_child
        order by df.vbfa_erdat desc, df.vbfa_erzet desc
    ) as row_num
from document_flow df
where df.vbtyp in ('C', 'J', 'R', 'M', 'N')
),
order_schedule as (
    select 
    vbep.etenr as g_delivery_schedule_line_nbr,
    vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
    sum(vbep_bmeng.confirmed_qty) over (
        partition by vbep.vbeln, vbep.posnr 
        order by vbep.mbdat
        rows between unbounded preceding and current row
    ) as running_total_confirmed_qty
from 
    vbep_bmeng
left join vbep
    on vbep_bmeng.vbeln = vbep.vbeln 
    and vbep_bmeng.posnr = vbep.posnr
),
order_shipment as (
    select
    vbelv,
    vbeln,
    posnv,
    posnn,
    vbtyp_n,
    sum(rfmng) over (partition by vbelv, posnv order by erdat rows between unbounded preceding and current row) as g_shipped_qty_primary_uom,
    first_value(erdat) over (partition by vbelv, posnv order by erdat desc) as g_last_actual_ship_dt_yyyymmdd
from vbfa_dedup
where vbtyp_n = 'J'
),
last_shipped_dt as (
    select 
    vbeln,
    posnr,
    first_value(ship_dt) over (
        partition by vbeln, posnr 
        order by ship_dt desc
        rows between unbounded preceding and unbounded following
    ) as g_last_actual_ship_dt_yyyymmdd
from 
    order_shipment
),
order_invoice as (
    select
    df.vbeln,
    df.posnr,
    first_value(df.erdat) over (
        partition by df.vbeln, df.posnr
        order by df.erdat desc
    ) as g_invoice_dt_yyyymmdd
from
    document_flow df
where
    df.vbtyp = 'M'
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
    tcurf.gdatu <= current_date()
),
final_joined as (
    select
  concat_ws('|', 'gbl', t001.bukrs) as co_key,
  case 
    when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
    then mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp
    else vbfa.shipped_qty_primary_uom
  end as g_allocated_qty_primary_uom,
  cast(null as string) as g_availability_dt_yyyymmdd,
  case 
    when vbpa.parvw = 'RE/BP' and vbpa.posnr is not null 
    then vbpa.kunnr
    when vbpa.parvw = 'RE/BP' 
    then vbpa.kunnr
    else cast(null as string)
  end as g_bill_to_customer_nbr,
  case 
    when vbap.abgru is null or vbap.abgru = '' 
    then null
    else case 
      when vbap.aedat = 0 
      then vbap.erdat
      else vbap.aedat
    end
  end as g_cancel_dt_yyyymmdd,
  cast(null as string) as g_cancel_qty_primary_uom,
  case 
    when t001.waers = 'RMB' 
    then 'CNY'
    else t001.waers
  end as g_company_currency_cd,
  vbap.matnr as g_customer_item_nbr,
  cast(null as string) as g_customer_po_line_nbr,
  case 
    when vbpa.parvw = 'WE' and vbpa.posnr is not null 
    then vbpa.kunnr
    when vbpa.parvw = 'WE' 
    then vbpa.kunnr
    else cast(null as string)
  end as g_customer_po_nbr,
  cast(null as string) as g_customer_po_type,
  case 
    when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
    then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
    when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
    then trim(vbep.request_dt)
    else vbep.edatu
  end as g_customer_request_dt_yyyymmdd,
  vbep.etenr as g_delivery_schedule_line_nbr,
  case 
    when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') 
    then 'yes'
    else 'no'
  end as g_flag_consignment_order,
  case 
    when vbap.uepos is not null and vbap.uepos <> 0 
    then 'yes'
    else 'no'
  end as g_flag_has_parent,
  case 
    when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
    then 'yes'
    else 'no'
  end as g_flag_inventory_fully_allocated,
  case 
    when vbap.posnr = vbap.uepos 
    then 'yes'
    else 'no'
  end as g_flag_is_parent,
  case 
    when knvv.kdgrp in ('05', '06', '07') or kna1.ktokd in ('ZSUB', 'IC3P') 
    then 'yes'
    else 'no'
  end as g_flag_is_transfer_order,
  case 
    when vbak.vbtyp in ('A', 'B', 'D') 
    then 'no'
    when vbup.lfsta in ('A', 'B', 'C') and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') 
    then 'no'
    else 'yes'
  end as g_flag_material_transacted,
  case 
    when vbep.lifsp <> '' 
    then 'yes'
    when vbak.lifsk <> '' 
    then 'yes'
    when vbuk.cmgst in ('B', 'C') 
    then 'yes'
    else 'no'
  end as g_flag_on_hold,
  case 
    when vbak.autlf = 'X' or cancel_qty_primary_uom = order_qty_primary_uom or open_qty_primary_uom <= 0 
    then 'no'
    else 'yes'
  end as g_flag_open_to_ship,
  case 
    when vbak.vbtyp in ('H', 'T') 
    then 'yes'
    else 'no'
  end as g_flag_return,
  case 
    when order_qty_primary_uom = 0 or vbak.vbtyp in ('A', 'B', 'D') 
    then 'no'
    when tvap.prsfd = 'X' 
    then 'yes'
    else 'no'
  end as g_flag_revenue_recognition,
  cast(null as string) as g_inco_terms,
  cast(null as string) as g_invoice_dt_yyyymmdd,
  vbap.matnr as g_item_nbr,
  cast(null as string) as g_last_actual_ship_dt_yyyymmdd,
  case 
    when vbup.gbsta = 'A' 
    then 'NOT YET PROCESSED'
    when vbup.gbsta = 'B' 
    then 'PARTIALLY PROCESSED'
    when vbup.gbsta = 'C' 
    then 'COMPLETELY PROCESSED'
    else 'NOT RELEVANT'
  end as g_line_status_cd,
  case 
    when order_qty_primary_uom > 0 and open_qty_primary_uom < 0 
    then 0
    when order_qty_primary_uom < 0 and open_qty_primary_uom > 0 
    then 0
    else open_qty_primary_uom
  end as g_open_qty_primary_uom,
  vbap.pstyv as g_order_category,
  t001k.bukrs as g_order_company_cd,
  case 
    when waerk = 'RMB' 
    then 'CNY'
    else waerk
  end as g_order_currency_cd,
  cast(null as string) as g_order_dt_yyyymmdd,
  vbep.posnr as g_order_line_nbr,
  vbep.vbeln as g_order_nbr,
  vbep.bmeng as g_order_qty_order_uom,
  case 
    when vbep.vrkme = vbap.meins 
    then vbep.bmeng
    else (marm.umrez / marm.umren) * vbep.bmeng
  end as g_order_qty_primary_uom,
  vbak.auart as g_order_type,
  vbap.vrkme as g_order_uom_cd,
  vbep.edatu as g_original_customer_request_dt_yyyymmdd,
  vbep.edatu as g_original_promised_ship_dt_yyyymmdd,
  vbap.uepos as g_parent_order_line_nbr,
  cast(null as string) as g_payment_terms,
  vbap.werks as g_plant_cd,
  vbap.meins as g_primary_uom_cd,
  vbep.edatu as g_promised_ship_dt_yyyymmdd,
  vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
  vbpa.kunnr as g_ship_to_customer_nbr,
  datediff(vbep.mbdat, vbep.edatu) as g_ship_to_delivery_days,
  vbak.vsbed as g_shipment_mode,
  vbfa.shipped_qty_primary_uom as g_shipped_qty_primary_uom,
  'GBL' as g_source_system_cd,
  cast(null as string) as g_unit_cost_company_currency_primary_uom,
  cast(null as string) as g_unit_price_company_currency_primary_uom,
  cast(null as string) as g_unit_price_order_currency_primary_uom,
  concat_ws('|', 'gbl', vbap.werks) as plant_key,
  concat_ws('|', 'gbl', vbap.matnr) as prod_key,
  concat_ws('|', 'gbl', vbap.matnr, vbap.werks) as prod_plant_key,
  concat_ws('|', 'gbl', t001k.bukrs, vbak.auart, vbep.vbeln) as sls_ord_key,
  concat_ws('|', 'gbl', t001k.bukrs, vbak.auart, vbep.vbeln, vbep.posnr, vbep.etenr) as sls_ord_sched_key,
  cast(null as string) as flag_is_blanket
from
  header_extract he
left join item_extract ie on he.vbeln = ie.vbeln
left join schedule_extract se on ie.vbeln = se.vbeln and ie.posnr = se.posnr
left join uom_conversion uc on ie.matnr = uc.matnr and se.vrkme = uc.meinh
left join document_flow df on se.vbeln = df.vbeln
left join last_event_dt led on se.vbeln = led.vbeln
left join order_schedule os on se.vbeln = os.vbeln
left join order_shipment osh on se.vbeln = osh.vbeln
left join last_shipped_dt lsd on se.vbeln = lsd.vbeln
left join order_invoice oi on se.vbeln = oi.vbeln
left join tcurf_dedup td on he.bukrs = td.bukrs
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
        when bill_to.parvw = 'RE/BP' then bill_to.kunnr
        else null
    end as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null or trim(vbap.abgru) = '' then null
        when vbap.aedat = 0 then vbap.erdat
        else vbap.aedat
    end as g_cancel_dt_yyyymmdd,
    cast(null as string) as g_cancel_qty_primary_uom, -- TODO: review mapping
    case 
        when t001.waers = 'RMB' then 'CNY'
        else t001.waers
    end as g_company_currency_cd,
    vbap.matnr as g_customer_item_nbr,
    cast(null as string) as g_customer_po_line_nbr,
    case 
        when po_data.posnr is not null then po_data.bstkd
        else po_data_no_posnr.bstkd
    end as g_customer_po_nbr,
    case 
        when po_data.posnr is not null then po_data.bstkd
        else po_data_no_posnr.bstkd
    end as g_customer_po_type,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
        then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
        then trim(vbep.request_dt)
        else vbep.edatu
    end as g_customer_request_dt_yyyymmdd,
    vbep.etenr as g_delivery_schedule_line_nbr,
    case 
        when vbap.pstyv in ('KBN', 'KEN', 'KAN', 'KRN') then 'yes'
        else 'no'
    end as g_flag_consignment_order,
    case 
        when vbap.uepos is not null and vbap.uepos != '0' then 'yes'
        else 'no'
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any(select uepos from vbap where vbap.vbeln = final_joined.vbeln) then 'yes'
        else 'no'
    end as g_flag_is_parent,
    case 
        when vbak.kunnr in (select kna1.kunnr from kna1 where kna1.ktokd in ('ZSUB', 'IC3P')) 
        or (vbak.kunnr, vbak.vkorg, vbak.vtweg, vbak.spart) in (select knvv.kunnr, knvv.vkorg, knvv.vtweg, knvv.spart from knvv where knvv.kdgrp in ('05', '06', '07')) 
        then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    case 
        when trim(vbak.vbtyp) in ('A', 'B', 'D') then 'no'
        when trim(vbup.lfsta) in ('A', 'B', 'C') and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') then 'no'
        when trim(vbup.lfsta) = '' or vbup.lfsta is null then 'no'
        else 'yes'
    end as g_flag_material_transacted,
    case 
        when vbep.lifsp != '' then 'yes'
        when vbak.lifsk != '' then 'yes'
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
    po_data.inco1 as g_inco_terms,
    cast(null as string) as g_invoice_dt_yyyymmdd, -- TODO: review mapping
    vbap.matnr as g_item_nbr,
    cast(null as string) as g_last_actual_ship_dt_yyyymmdd,
    case 
        when upper(trim(vbup.gbsta)) = 'A' then 'NOT YET PROCESSED'
        when upper(trim(vbup.gbsta)) = 'B' then 'PARTIALLY PROCESSED'
        when upper(trim(vbup.gbsta)) = 'C' then 'COMPLETELY PROCESSED'
        else 'NOT RELEVANT'
    end as g_line_status_cd,
    case 
        when order_type = 'DEMO' and ship_lines.sttrg = '7' then 0
        when tvap.fkrel in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W') 
        then round((coalesce(order_qty_primary_uom, 0) - coalesce(lst.shipped_qty, 0)), 4)
        when trim(tvap.fkrel) = '' then 0
        else round((coalesce(order_qty_primary_uom, 0) - (case 
            when lst.shipped_qty != 0 then lst.shipped_qty
            when lst.shipped_qty = 0 and inv.invoice_qty != 0 then inv.invoice_qty
            else 0
        end)), 0)
    end - coalesce(cancel_qty_primary_uom, 0) as g_open_qty_primary_uom,
    vbap.pstyv as g_order_category,
    t001k.bukrs as g_order_company_cd,
    case 
        when trim(waerk) = 'RMB' then 'CNY'
        else trim(waerk)
    end as g_order_currency_cd,
    cast(null as string) as g_order_dt_yyyymmdd, -- TODO: review mapping
    vbep.posnr as g_order_line_nbr,
    vbep.vbeln as g_order_nbr,
    vbep.bmeng as g_order_qty_order_uom,
    case 
        when vbep.vrkme = vbap.meins then vbep.bmeng
        else (marm.umrez / marm.umren) * vbep.bmeng
    end as g_order_qty_primary_uom,
    case 
        when vbak.auart = 'TA' then 'OR'
        else vbak.auart
    end as g_order_type,
    trim(vbap.vrkme) as g_order_uom_cd,
    cast(null as string) as g_original_customer_request_dt_yyyymmdd, -- TODO: review mapping
    cast(null as string) as g_original_promised_ship_dt_yyyymmdd, -- TODO: review mapping
    vbap.uepos as g_parent_order_line_nbr,
    cast(null as string) as g_payment_terms, -- TODO: review mapping
    vbap.werks as g_plant_cd,
    trim(vbap.meins) as g_primary_uom_cd,
    case 
        when trim(vbap.werks) = '0070' then vbak.zz_ship_by
        else trim(vbep.edatu)
    end as g_promised_ship_dt_yyyymmdd,
    vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
    case 
        when ship_to.parvw = 'WE' then ship_to.kunnr
        else null
    end as g_ship_to_customer_nbr,
    case 
        when g_order_qty_primary_uom = 0 then 0
        else datediff(vbep.mbdat, vbep.edatu)
    end as g_ship_to_delivery_days,
    tvsbt.vsbed as g_shipment_mode,
    cast(null as string) as g_shipped_qty_primary_uom, -- TODO: review mapping
    'GBL' as g_source_system_cd,
    cast(null as string) as g_unit_cost_company_currency_primary_uom, -- TODO: review mapping
    cast(null as string) as g_unit_price_company_currency_primary_uom, -- TODO: review mapping
    cast(null as string) as g_unit_price_order_currency_primary_uom, -- TODO: review mapping
    concat_ws('|', 'gbl', g_plant_cd) as plant_key,
    concat_ws('|', 'gbl', g_item_nbr) as prod_key,
    concat_ws('|', 'gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key,
    cast(null as string) as flag_is_blanket -- TODO: review mapping
from final_joined
left join mska on final_joined.vbeln = mska.vbeln and final_joined.posnr = mska.posnr
left join bill_to on final_joined.vbeln = bill_to.vbeln and final_joined.posnr = bill_to.posnr
left join po_data on final_joined.vbeln = po_data.vbeln and final_joined.posnr = po_data.posnr
left join po_data_no_posnr on final_joined.vbeln = po_data_no_posnr.vbeln
left join request_date on final_joined.vbeln = request_date.vbeln and final_joined.posnr = request_date.posnr
left join request_date_posnr0 on final_joined.vbeln = request_date_posnr0.vbeln
left join t001 on final_joined.bukrs = t001.bukrs
left join t001k on final_joined.bukrs = t001k.bukrs
left join marm on final_joined.matnr = marm.matnr and final_joined.vrkme = marm.meinh
left join mara on final_joined.matnr = mara.matnr
left join vbap on final_joined.vbeln = vbap.vbeln and final_joined.posnr = vbap.posnr
left join vbep on final_joined.vbeln = vbep.vbeln and final_joined.posnr = vbep.posnr
left join vbup on final_joined.vbeln = vbup.vbeln and final_joined.posnr = vbup.posnr
left join vbak on final_joined.vbeln = vbak.vbeln
left join tvap on vbap.pstyv = tvap.pstyv
left join tvsbt on vbak.vsbed = tvsbt.vsbed
left join ship_to on final_joined.vbeln = ship_to.vbeln and final_joined.posnr = ship_to.posnr
left join lst on final_joined.vbeln = lst.vbeln and final_joined.posnr = lst.posnr
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
from final_joined_with_flags;