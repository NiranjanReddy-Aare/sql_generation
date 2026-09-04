/**********************************************************************
artefact name :- f_sales_order
description   :- f_sales_order sql generated via multi-pass CTE pipeline
----------------------------------------------------------------------
change log
version :   date :        description :                       changed by
----------------------------------------------------------------------
0.0         2026-09-04    auto-generated multi-pass            ai_agent
**********************************************************************/

with
header_extract as (
    select 
  concat('gbl', g_order_company_cd) as co_key,
  case 
    when exists (
      select 1 
      from mska 
      where mska.vbeln = g_order_nbr 
        and mska.posnr = g_order_line_nbr
    ) then 
      coalesce(kalab, 0) + coalesce(kains, 0) + coalesce(kaspe, 0) + coalesce(kavla, 0) + coalesce(kavin, 0) + coalesce(kavsp, 0)
    else g_shipped_qty_primary_uom
  end as g_allocated_qty_primary_uom,
  null as g_availability_dt_yyyymmdd,
  case 
    when exists (
      select 1 
      from vbap 
      where vbap.vbeln = g_order_nbr 
        and vbap.posnr = g_order_line_nbr 
        and vbap.parvw = 'RE/BP'
    ) then vbap.kunnr
    else (
      select kunnr 
      from vbap 
      where vbap.vbeln = g_order_nbr 
        and vbap.parvw = 'RE/BP'
    )
  end as g_bill_to_customer_nbr,
  case 
    when vbap.abgru is null then null
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
  case 
    when exists (
      select 1 
      from vbkd 
      where vbkd.vbeln = g_order_nbr 
        and vbkd.posnr = g_order_line_nbr
    ) then vbkd.bstkd
    else (
      select bstkd 
      from vbkd 
      where vbkd.vbeln = g_order_nbr
    )
  end as g_customer_po_nbr,
  case 
    when exists (
      select 1 
      from vbkd 
      where vbkd.vbeln = g_order_nbr 
        and vbkd.posnr = g_order_line_nbr
    ) then vbkd.bsark
    else (
      select bsark 
      from vbkd 
      where vbkd.vbeln = g_order_nbr
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
    when vbap.uepos is not null and vbap.uepos != 0 then 'yes'
    else 'no'
  end as g_flag_has_parent,
  case 
    when mska.sobkz = 'E' 
      and (kalab > 0 or kains > 0 or kaspe > 0 or kavla > 0 or kavin > 0 or kavsp > 0) then 'yes'
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
from vbep
left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
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
            from vbap as vbap_inner 
            where vbap_inner.vbeln = vbap.vbeln 
              and vbap_inner.posnr = vbap.posnr 
              and vbap_inner.parvw = 'RE/BP'
        )
        else (
            select kunnr 
            from vbap as vbap_inner 
            where vbap_inner.vbeln = vbap.vbeln 
              and vbap_inner.parvw = 'RE/BP'
        )
    end as g_bill_to_customer_nbr,
    case 
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
    case 
        when vbap.posnr is not null then (
            select bstdk 
            from vbkd 
            where vbkd.vbeln = vbap.vbeln 
              and vbkd.posnr = vbap.posnr
        )
        else (
            select bstdk 
            from vbkd 
            where vbkd.vbeln = vbap.vbeln
        )
    end as g_customer_po_nbr,
    case 
        when vbap.posnr is not null then (
            select bsark 
            from vbkd 
            where vbkd.vbeln = vbap.vbeln 
              and vbkd.posnr = vbap.posnr
        )
        else (
            select bsark 
            from vbkd 
            where vbkd.vbeln = vbap.vbeln
        )
    end as g_customer_po_type,
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
            where mska.vbeln = vbap.vbeln 
              and mska.posnr = vbap.posnr 
              and mska.sobkz = 'E' 
              and (
                  coalesce(mska.kalab, 0) > 0 or 
                  coalesce(mska.kains, 0) > 0 or 
                  coalesce(mska.kaspe, 0) > 0 or 
                  coalesce(mska.kavla, 0) > 0 or 
                  coalesce(mska.kavin, 0) > 0 or 
                  coalesce(mska.kavsp, 0) > 0
              )
        ) then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any (
            select uepos 
            from vbap as vbap_inner 
            where vbap_inner.vbeln = vbap.vbeln
        ) then 'yes'
        else 'no'
    end as g_flag_is_parent,
    case 
        when exists (
            select 1 
            from knvv 
            where knvv.kunnr = vbak.kunnr 
              and knvv.vkorg = vbak.vkorg 
              and knvv.vtweg = vbak.vtweg 
              and knvv.spart = vbak.spart 
              and knvv.kdgrp in ('05', '06', '07')
        ) or exists (
            select 1 
            from kna1 
            where kna1.kunnr = vbak.kunnr 
              and kna1.ktokd in ('ZSUB', 'IC3P')
        ) then 'yes'
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
from vbap
left join vbep on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
left join mska on mska.vbeln = vbap.vbeln and mska.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join mara on vbap.matnr = mara.matnr
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
    ) then (
      coalesce(mska.kalab, 0) + 
      coalesce(mska.kains, 0) + 
      coalesce(mska.kaspe, 0) + 
      coalesce(mska.kavla, 0) + 
      coalesce(mska.kavin, 0) + 
      coalesce(mska.kavsp, 0)
    )
    else vbep.bmeng
  end as g_allocated_qty_primary_uom,
  null as g_availability_dt_yyyymmdd,
  case 
    when vbap.posnr is not null then (
      select kunnr 
      from vbap 
      where vbap.vbeln = vbep.vbeln 
        and vbap.posnr = vbep.posnr 
        and vbap.parvw = 'RE/BP'
    )
    else (
      select kunnr 
      from vbap 
      where vbap.vbeln = vbep.vbeln 
        and vbap.parvw = 'RE/BP'
    )
  end as g_bill_to_customer_nbr,
  case 
    when vbap.abgru = '' then null
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
  case 
    when vbap.posnr is not null then (
      select bstk 
      from vbkd 
      where vbkd.vbeln = vbep.vbeln 
        and vbkd.posnr = vbep.posnr
    )
    else (
      select bstk 
      from vbkd 
      where vbkd.vbeln = vbep.vbeln
    )
  end as g_customer_po_nbr,
  case 
    when vbap.posnr is not null then (
      select bsark 
      from vbkd 
      where vbkd.vbeln = vbep.vbeln 
        and vbkd.posnr = vbep.posnr
    )
    else (
      select bsark 
      from vbkd 
      where vbkd.vbeln = vbep.vbeln
    )
  end as g_customer_po_type,
  case 
    when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
    when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') then trim(vbep.edatu)
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
    when vbak.vbtyp in ('A', 'B', 'D') then 'no'
    when vbup.lfsta in ('A', 'B', 'C') and mara.mtart in ('DIEN', 'NSTK', 'SERV', 'ZSRV') then 'no'
    when vbup.lfsta = '' or vbup.lfsta is null then 'no'
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
    vbap.werks,
    vbap.vrkme as order_uom,
    vbap.meins as primary_uom,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.bmeng
        else (marm.umrez / marm.umren) * vbep.bmeng
    end as order_qty_primary_uom,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.wmeng
        else (marm.umrez / marm.umren) * vbep.wmeng
    end as shipped_qty_primary_uom,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.klmeng
        else (marm.umrez / marm.umren) * vbep.klmeng
    end as cancel_qty_primary_uom,
    case
        when vbak.auart = 'DEMO' and vbep.sttrg = '7' then 0
        when vbap.fkrel in ('A', 'H', 'J', 'K', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'V', 'W')
        then round(coalesce(vbep.bmeng, 0) - coalesce(vbfa.shipped_qty, 0), 4)
        when trim(vbap.fkrel) = ''
        then 0
        else round(coalesce(vbep.bmeng, 0) - 
            case 
                when vbfa.shipped_qty <> 0 then vbfa.shipped_qty
                when vbfa.shipped_qty = 0 and invoice.invoice_qty <> 0 then invoice.invoice_qty
                else 0
            end, 0)
    end - coalesce(vbep.klmeng, 0) as open_qty_primary_uom,
    case 
        when vbep.bmeng > 0 and (round(coalesce(vbep.bmeng, 0) - coalesce(vbfa.shipped_qty, 0), 4) < 0) then 0
        when vbep.bmeng < 0 and (round(coalesce(vbep.bmeng, 0) - coalesce(vbfa.shipped_qty, 0), 4) > 0) then 0
        else round(coalesce(vbep.bmeng, 0) - coalesce(vbfa.shipped_qty, 0), 4)
    end as adjusted_open_qty_primary_uom
from 
    vbep
left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join vbfa on vbep.vbeln = vbfa.vbelv and vbep.posnr = vbfa.posnv
left join invoice on vbep.vbeln = invoice.vbeln and vbep.posnr = invoice.posnr
),
document_flow as (
    select
    concat('gbl', vbak.vkorg) as co_key,
    case 
        when exists (
            select 1 
            from mska 
            where mska.vbeln = vbap.vbeln 
              and mska.posnr = vbap.posnr
        ) 
        then coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)
        else vbep.lfimg
    end as g_allocated_qty_primary_uom,
    null as g_availability_dt_yyyymmdd,
    case 
        when vbpa.parvw = 'RE/BP' and vbpa.posnr is not null 
        then vbpa.kunnr
        when vbpa.parvw = 'RE/BP' 
        then first_value(vbpa.kunnr) over (partition by vbap.vbeln order by vbpa.posnr)
        else null
    end as g_bill_to_customer_nbr,
    case 
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
    case 
        when vbkd.posnr is not null 
        then vbkd.bstkd
        else first_value(vbkd.bstkd) over (partition by vbap.vbeln order by vbap.posnr)
    end as g_customer_po_nbr,
    case 
        when vbkd.posnr is not null 
        then vbkd.bsark
        else first_value(vbkd.bsark) over (partition by vbap.vbeln order by vbap.posnr)
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
        when vbap.uepos is not null and vbap.uepos != 0 then 'yes'
        else 'no'
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' 
          and (coalesce(mska.kalab, 0) + coalesce(mska.kains, 0) + coalesce(mska.kaspe, 0) + coalesce(mska.kavla, 0) + coalesce(mska.kavin, 0) + coalesce(mska.kavsp, 0)) > 0 
        then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any(select uepos from vbap as vbap_inner where vbap_inner.vbeln = vbap.vbeln) 
        then 'yes'
        else 'no'
    end as g_flag_is_parent,
    case 
        when kna1.ktokd in ('ZSUB', 'IC3P') 
          or knvv.kdgrp in ('05', '06', '07') 
        then 'yes'
        else 'no'
    end as g_flag_is_transfer_order,
    case 
        when vbak.vbtyp in ('A', 'B', 'D') then 'no'
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
from vbap
left join vbep on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join vbak on vbep.vbeln = vbak.vbeln
left join vbpa on vbpa.vbeln = vbap.vbeln and vbpa.posnr = vbap.posnr
left join vbkd on vbkd.vbeln = vbap.vbeln and vbkd.posnr = vbap.posnr
left join t001 on t001.bukrs = vbak.bukrs_vf
left join mska on mska.vbeln = vbap.vbeln and mska.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join mara on vbap.matnr = mara.matnr
left join kna1 on vbak.kunnr = kna1.kunnr
left join knvv on vbak.kunnr = knvv.kunnr and vbak.vkorg = knvv.vkorg and vbak.vtweg = knvv.vtweg and vbak.spart = knvv.spart
),
last_event_dt as (
    select 
    df.vbeln as order_nbr,
    df.posnr as order_line_nbr,
    first_value(df.aedat) over (
        partition by df.vbeln, df.posnr 
        order by df.aedat desc
    ) as last_event_dt
from 
    document_flow df
where 
    df.aedat is not null
),
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
vbfa_dedup as (
    select 
    vbeln,
    posnr,
    row_number() over (
        partition by vbeln, posnr 
        order by erdat desc, erzet desc, vbelv desc, posnv desc
    ) as row_num
from 
    document_flow
where 
    vbelv is not null and posnv is not null
),
order_schedule as (
    select
  vbep.etenr as g_delivery_schedule_line_nbr,
  vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
  sum(schedule_extract.order_qty) over (
    partition by schedule_extract.vbeln, schedule_extract.posnr
    order by vbep.mbdat
    rows between unbounded preceding and current row
  ) as running_total_order_qty
from
  schedule_extract
left join vbep
  on schedule_extract.vbeln = vbep.vbeln
  and schedule_extract.posnr = vbep.posnr
),
order_shipment as (
    select
    vbelv,
    vbeln,
    posnn,
    posnv,
    vbtyp_n,
    sum(rfmng) over (partition by vbelv, posnv order by erdat rows between unbounded preceding and current row) as g_shipped_qty_primary_uom,
    first_value(erdat) over (partition by vbelv, posnv order by erdat desc) as g_last_actual_ship_dt_yyyymmdd
from
    vbfa_dedup
where
    vbtyp_n = 'J'
),
last_shipped_dt as (
    select 
    order_id,
    schedule_id,
    first_value(shipped_date) over (
        partition by order_id, schedule_id 
        order by shipped_date desc
        rows between unbounded preceding and unbounded following
    ) as g_last_actual_ship_dt_yyyymmdd
from 
    order_shipment
),
order_invoice as (
    select 
    vbfa.vbeln,
    vbfa.posnr,
    first_value(vbfa.erdat) over (
        partition by vbfa.vbeln, vbfa.posnr 
        order by vbfa.erdat desc
    ) as g_invoice_dt_yyyymmdd
from 
    vbfa
where 
    vbfa.vbtyp = 'M'
),
tcurf_dedup as (
    select 
    tcurf.ffact,
    tcurf.tfact,
    tcurf.kurst,
    tcurf.datab,
    tcurf.datbi,
    tcurf.ukurs,
    row_number() over (
        partition by tcurf.ffact, tcurf.tfact, tcurf.kurst 
        order by tcurf.datbi desc
    ) as row_num
from 
    tcurf
where 
    tcurf.datab <= current_date and tcurf.datbi >= current_date
),
final_joined as (
    select
    concat_ws('|', 'gbl', g_order_company_cd) as co_key,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp)
        else g_shipped_qty_primary_uom
    end as g_allocated_qty_primary_uom,
    cast(null as string) as g_availability_dt_yyyymmdd,
    case 
        when bp.bill_to_customer_nbr is not null then bp.bill_to_customer_nbr
        else bp_alt.bill_to_customer_nbr
    end as g_bill_to_customer_nbr,
    case 
        when vbap.abgru is null then null
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
        when po.customer_po_nbr is not null then po.customer_po_nbr
        else po_alt.customer_po_nbr
    end as g_customer_po_nbr,
    case 
        when po.customer_po_type is not null then po.customer_po_type
        else po_alt.customer_po_type
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
        when vbap.uepos is not null and vbap.uepos <> '0' then 'yes'
        else 'no'
    end as g_flag_has_parent,
    case 
        when mska.sobkz = 'E' and (mska.kalab + mska.kains + mska.kaspe + mska.kavla + mska.kavin + mska.kavsp) > 0 
        then 'yes'
        else 'no'
    end as g_flag_inventory_fully_allocated,
    case 
        when vbap.posnr = any(select vbap.uepos from vbap where vbap.vbeln = vbep.vbeln) then 'yes'
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
    vbap.inco1 as g_inco_terms,
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
        when order_qty_primary_uom > 0 and open_qty_primary_uom < 0 then 0
        when order_qty_primary_uom < 0 and open_qty_primary_uom > 0 then 0
        else open_qty_primary_uom
    end as g_open_qty_primary_uom,
    vbap.pstyv as g_order_category,
    t001k.bukrs as g_order_company_cd,
    case 
        when trim(vbap.waerk) = 'RMB' then 'CNY'
        else trim(vbap.waerk)
    end as g_order_currency_cd,
    vbak.audat as g_order_dt_yyyymmdd,
    vbep.posnr as g_order_line_nbr,
    vbep.vbeln as g_order_nbr,
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
    case 
        when vbak.auart = 'TA' then 'OR'
        else vbak.auart
    end as g_order_type,
    trim(vbap.vrkme) as g_order_uom_cd,
    case 
        when coalesce(request_date.land1, request_date_posnr0.land1) not in ('US', 'CA') 
        then coalesce(request_date.vdatu, request_date_posnr0.vbdatu)
        when coalesce(request_date.land1, request_date_posnr0.land1) in ('US', 'CA') 
        then trim(vbep.request_dt)
        else vbep.edatu
    end as g_original_customer_request_dt_yyyymmdd,
    vbep.edatu as g_original_promised_ship_dt_yyyymmdd,
    vbap.uepos as g_parent_order_line_nbr,
    vbak.zterm as g_payment_terms,
    vbap.werks as g_plant_cd,
    trim(vbap.meins) as g_primary_uom_cd,
    case 
        when trim(vbap.werks) = '0070' then vbak.zz_ship_by
        else trim(vbep.edatu)
    end as g_promised_ship_dt_yyyymmdd,
    vbep.mbdat as g_scheduled_ship_dt_yyyymmdd,
    case 
        when bp.ship_to_customer_nbr is not null then bp.ship_to_customer_nbr
        else bp_alt.ship_to_customer_nbr
    end as g_ship_to_customer_nbr,
    datediff(vbep.mbdat, vbep.edatu) as g_ship_to_delivery_days,
    tvsbt.vsbed as g_shipment_mode,
    vbfa.rfmng as g_shipped_qty_primary_uom,
    'GBL' as g_source_system_cd,
    case 
        when trim(mbew.vprsv) = 'V' 
        then round(if(t001.waers in ('KRW', 'JPY'), mbew.verpr * 100, mbew.verpr) / currency_factor, 2)
        when trim(mbew.vprsv) = 'S' 
        then round(if(t001.waers in ('KRW', 'JPY'), mbew.stprs * 100, mbew.stprs) / currency_factor, 2)
    end as g_unit_cost_company_currency_primary_uom,
    case 
        when trim(vbap.waerk) = trim(t001.waers) 
        then if(trim(vbap.waerk) = 'JPY', puom.price_uom * 100 * coalesce(vbkd.kursk, vbkd_derived.kursk), puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact)
        else (puom.price_uom * coalesce(vbkd.kursk, vbkd_derived.kursk)) * (tcurf.tfact / tcurf.ffact)
    end as g_unit_price_company_currency_primary_uom,
    case 
        when vbep.vrkme = vbap.meins 
        then vbep.bmeng
        else (marm.umrez / marm.umren) * vbep.bmeng
    end as g_unit_price_order_currency_primary_uom,
    concat_ws('|', 'gbl', g_plant_cd) as plant_key,
    concat_ws('|', 'gbl', g_item_nbr) as prod_key,
    concat_ws('|', 'gbl', g_item_nbr, g_plant_cd) as prod_plant_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr) as sls_ord_key,
    concat_ws('|', 'gbl', g_order_company_cd, g_order_type, g_order_nbr, g_order_line_nbr, g_delivery_schedule_line_nbr) as sls_ord_sched_key,
    cast(null as string) as flag_is_blanket
from
    vbep
left join vbap on vbep.vbeln = vbap.vbeln and vbep.posnr = vbap.posnr
left join marm on vbap.matnr = marm.matnr and vbep.vrkme = marm.meinh
left join mbew on vbap.matnr = mbew.matnr and vbap.werks = mbew.bwkey
left join vbak on vbep.vbeln = vbak.vbeln
left join t001 on t001.bukrs = vbak.bukrs_vf
left join mska on vbep.vbeln = mska.vbeln and vbep.posnr = mska.posnr
left join vbfa on vbep.vbeln = vbfa.vbelv and vbep.posnr = vbfa.posnv
left join tcurf_dedup as tcurf on vbap.waerk = tcurf.ffact and t001.waers = tcurf.tfact
left join vbkd on vbep.vbeln = vbkd.vbeln
left join vbkd as vbkd_derived on vbep.vbeln = vbkd_derived.vbeln
left join header_extract as bp on vbep.vbeln = bp.vbeln
left join header_extract as bp_alt on vbep.vbeln = bp_alt.vbeln
left join item_extract as po on vbep.vbeln = po.vbeln and vbep.posnr = po.posnr
left join item_extract as po_alt on vbep.vbeln = po_alt.vbeln
left join schedule_extract as request_date on vbep.vbeln = request_date.vbeln and vbep.posnr = request_date.posnr
left join schedule_extract as request_date_posnr0 on vbep.vbeln = request_date_posnr0.vbeln
left join document_flow as lst on vbep.vbeln = lst.vbeln and vbep.posnr = lst.posnr
left join last_event_dt as zosdates on vbep.vbeln = zosdates.vbeln and vbep.posnr = zosdates.posnr
left join vbep_bmeng on vbep.vbeln = vbep_bmeng.vbeln and vbep.posnr = vbep_bmeng.posnr
left join uom_conversion on vbap.matnr = uom_conversion.matnr
left join tcurf_dedup as d_curncy_mth_rt on vbap.waerk = d_curncy_mth_rt.ffact and t001.waers = d_curncy_mth_rt.tfact.
),
final_joined_with_flags as (
    select
    g_order_nbr,
    g_order_line_nbr,
    g_delivery_schedule_line_nbr,
    g_order_company_cd,
    g_order_type,
    g_order_qty_primary_uom,
    g_order_qty_order_uom,
    g_primary_uom_cd,
    g_order_uom_cd,
    g_order_currency_cd,
    g_company_currency_cd,
    g_unit_price_order_currency_primary_uom,
    g_unit_price_company_currency_primary_uom,
    g_unit_cost_company_currency_primary_uom,
    g_allocated_qty_primary_uom,
    g_shipped_qty_primary_uom,
    g_open_qty_primary_uom,
    g_cancel_qty_primary_uom,
    g_flag_open_to_ship,
    g_flag_material_transacted,
    g_flag_return,
    g_flag_consignment_order,
    g_flag_is_transfer_order,
    g_flag_inventory_fully_allocated,
    g_flag_on_hold,
    g_flag_revenue_recognition,
    g_flag_is_parent,
    g_flag_has_parent,
    g_order_dt_yyyymmdd,
    g_customer_request_dt_yyyymmdd,
    g_original_customer_request_dt_yyyymmdd,
    g_promised_ship_dt_yyyymmdd,
    g_original_promised_ship_dt_yyyymmdd,
    g_scheduled_ship_dt_yyyymmdd,
    g_last_actual_ship_dt_yyyymmdd,
    g_cancel_dt_yyyymmdd,
    g_invoice_dt_yyyymmdd,
    g_availability_dt_yyyymmdd,
    g_ship_to_delivery_days,
    g_line_status_cd,
    g_order_category,
    g_payment_terms,
    g_inco_terms,
    g_shipment_mode,
    g_bill_to_customer_nbr,
    g_ship_to_customer_nbr,
    g_customer_po_nbr,
    g_customer_po_line_nbr,
    g_customer_po_type,
    g_customer_item_nbr,
    g_item_nbr,
    g_plant_cd,
    co_key,
    plant_key,
    prod_key,
    prod_plant_key,
    sls_ord_key,
    sls_ord_sched_key,
    flag_is_blanket
from final_joined
where 1 = 1
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