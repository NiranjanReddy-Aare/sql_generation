with po_dedup as (
    -- Deduplication logic here
)
select 
    cast(null as string) as co_curncy_cd,
    cast(null as string) as cost_cntrl_ind,
    cast(null as string) as cost_unit_qty,
    cast(null as string) as current_rec_flg,
    cast(null as string) as dir_labour_cost_amt,
    cast(null as string) as eff_end_yr_prd_nbr,
    cast(null as string) as eff_start_yr_prd_nbr,
    cast(null as string) as fix_oh_cost_amt,
    cast(null as string) as latest_cost_chng_dt,
    cast(null as string) as ma_cost_amt,
    cast(null as string) as mtl_cost_amt,
    cast(null as string) as other_svc_cost_amt,
    cast(null as string) as plant_cd,
    cast(null as string) as revision,
    cast(null as string) as setup_labour_cost_amt,
    cast(null as string) as sim_env,
    cast(null as string) as sku,
    'e1' as src_sys_cd,
    cast(null as string) as std_cost_amt,
    cast(null as string) as std_cost_pmar_amt,
    cast(null as string) as unit_cost_amt,
    cast(null as string) as val_class_cd,
    cast(null as string) as val_class_nm
from (
    select * from F0005
    union all
    select * from F0010
    union all
    select * from F0014
    union all
    select * from F0411
    union all
    select * from F0101
) po;