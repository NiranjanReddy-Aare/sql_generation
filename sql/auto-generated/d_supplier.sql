SELECT 
    'Fixed Value' AS e1lsg_d_supplier_src_sys_cd,
    F0401.A6AN8 AS e1lsg_d_supplier_suplr_id,
    'NA' AS e1lsg_d_supplier_alt_suplr_id,
    F0101.ABALPH AS e1lsg_d_supplier_suplr_nm,
    d_supplier.lgl_suplr_nm AS e1lsg_d_supplier_lgl_suplr_nm,
    d_supplier.parent_suplr_nm AS e1lsg_d_supplier_parent_suplr_nm,
    d_supplier.prim_branch_cd AS e1lsg_d_supplier_prim_branch_cd,
    d_supplier.prim_branch_nm AS e1lsg_d_supplier_prim_branch_nm,
    d_supplier.dnb_co_nbr AS e1lsg_d_supplier_dnb_co_nbr,
    d_supplier.addr_crt_dt AS e1lsg_d_supplier_addr_crt_dt,
    F0116.ALADD1 AS e1lsg_d_supplier_suplr_addr_line_1,
    F0116.ALADD2 AS e1lsg_d_supplier_suplr_addr_line_2,
    F0116.ALADD3 AS e1lsg_d_supplier_suplr_addr_line_3,
    F0116.ALADD4 AS e1lsg_d_supplier_suplr_addr_line_4,
    F0116.ALADDZ AS e1lsg_d_supplier_suplr_pstl_cd,
    F0116.ALCTY1 AS e1lsg_d_supplier_suplr_city_nm,
    F0116.ALADDS AS e1lsg_d_supplier_suplr_st_cd,
    F0005.DL01 AS e1lsg_d_supplier_suplr_st_nm,
    d_supplier.suplr_rgn_cd AS e1lsg_d_supplier_suplr_rgn_cd,
    d_supplier.suplr_rgn_nm AS e1lsg_d_supplier_suplr_rgn_nm,
    F0116.ALCTR AS e1lsg_d_supplier_suplr_cntry_cd,
    F0005.DL01 AS e1lsg_d_supplier_suplr_cntry_nm,
    d_supplier.addr_eff_dt AS e1lsg_d_supplier_addr_eff_dt,
    F0115.WPAR1 AS e1lsg_d_supplier_suplr_phn_area_cd,
    F0115.WPPH1 AS e1lsg_d_supplier_suplr_phn_nbr,
    d_supplier.suplr_email_addr AS e1lsg_d_supplier_suplr_email_addr,
    d_supplier.suplr_dvrsty_cd AS e1lsg_d_supplier_suplr_dvrsty_cd,
    d_supplier.suplr_dvrsty_nm AS e1lsg_d_supplier_suplr_dvrsty_nm,
    d_supplier.suplr_class_cd AS e1lsg_d_supplier_suplr_class_cd,
    d_supplier.suplr_class_nm AS e1lsg_d_supplier_suplr_class_nm,
    d_supplier.suplr_indy_cd AS e1lsg_d_supplier_suplr_indy_cd,
    d_supplier.suplr_indy_nm AS e1lsg_d_supplier_suplr_indy_nm,
    'NA' AS e1lsg_d_supplier_suplr_type_cd,
    'NA' AS e1lsg_d_supplier_suplr_type_nm,
    F0401.A6TRAP AS e1lsg_d_supplier_paymt_terms_cd,
    F0014.PNPTD AS e1lsg_d_supplier_paymt_terms_nm,
    d_supplier.suplr_rel_cd AS e1lsg_d_supplier_suplr_rel_cd,
    d_supplier.suplr_lang_cd AS e1lsg_d_supplier_suplr_lang_cd,
    d_supplier.suplr_lang_nm AS e1lsg_d_supplier_suplr_lang_nm,
    d_supplier.contract_id AS e1lsg_d_supplier_contract_id,
    d_supplier.contract_type_nm AS e1lsg_d_supplier_contract_type_nm,
    d_supplier.contract_stat_cd AS e1lsg_d_supplier_contract_stat_cd,
    d_supplier.contract_begin_dt AS e1lsg_d_supplier_contract_begin_dt,
    d_supplier.contract_end_dt AS e1lsg_d_supplier_contract_end_dt,
    d_supplier.cmdty_mgr_nm AS e1lsg_d_supplier_cmdty_mgr_nm,
    d_supplier.mthly_projctd_spend_amt AS e1lsg_d_supplier_mthly_projctd_spend_amt,
    d_supplier.mthly_projctd_saving_amt AS e1lsg_d_supplier_mthly_projctd_saving_amt,
    d_supplier.contract_comment_txt AS e1lsg_d_supplier_contract_comment_txt,
    d_supplier.frt_terms_cd AS e1lsg_d_supplier_frt_terms_cd,
    d_supplier.frt_terms_nm AS e1lsg_d_supplier_frt_terms_nm,
    d_supplier.inco_terms_cd AS e1lsg_d_supplier_inco_terms_cd,
    d_supplier.inco_terms_nm AS e1lsg_d_supplier_inco_terms_nm,
    d_supplier.suplr_assgn_grp_cd AS e1lsg_d_supplier_suplr_assgn_grp_cd,
    d_supplier.suplr_assgn_grp_nm AS e1lsg_d_supplier_suplr_assgn_grp_nm,
    CASE WHEN F0101.AT1 = 'V' THEN 'Active' ELSE 'Inactive' END AS e1lsg_d_supplier_suplr_active_flg,
    d_supplier.status_cd AS e1lsg_d_supplier_status_cd,
    'NA' AS e1lsg_d_supplier_norm_supplier_type
FROM 
    F0401
INNER JOIN 
    F0101 ON F0101.AN8 = F0401.A6AN8
LEFT JOIN 
    F0116 ON F0116.ALAN8 = F0401.A6AN8
LEFT JOIN 
    F0115 ON F0115.WPAN8 = F0401.A6AN8
LEFT JOIN 
    F0005 ON (F0005.SY = '00' AND F0005.RT = 'S' AND F0005.KY = F0116.ALADDS)
LEFT JOIN 
    F0014 ON F0014.PNPTC = F0401.A6TRAP;