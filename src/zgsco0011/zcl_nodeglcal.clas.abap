CLASS zcl_nodeglcal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_NODEGLCAL IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES:t_toyear         TYPE zc_schedulesofcost-p_toyear,
          t_tomonth        TYPE zc_schedulesofcost-p_tomonth,
          t_runtype        TYPE zc_schedulesofcost-p_runtype,
          t_compcd         TYPE zc_schedulesofcost-p_compcd,
          t_chekgl         TYPE zc_schedulesofcost-p_chekgl,
          t_hierarchylevel TYPE zc_schedulesofcost-hierarchylevel,
          t_parentnodeid   TYPE zc_schedulesofcost-parentnodeid.

    DATA : lr_toyear         TYPE RANGE OF t_toyear,
           lr_tomonth        TYPE RANGE OF t_tomonth,
           lr_runtype        TYPE RANGE OF t_runtype,
           lr_compcd         TYPE RANGE OF t_compcd,
           lr_chekgl         TYPE RANGE OF t_chekgl,
           lr_hierarchylevel TYPE RANGE OF t_hierarchylevel,
           lr_parentnodeid   TYPE RANGE OF t_parentnodeid.

    DATA business_data TYPE TABLE OF zc_schedulesofcost.
    DATA ls_business_data TYPE zc_schedulesofcost.

    CLEAR : business_data, ls_business_data.

    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).
    DATA(lt_param_req) = io_request->get_parameters( ).
    DATA : ls_param_req LIKE LINE OF lt_param_req.
    CLEAR : ls_param_req.
    DATA lv_chekgl TYPE abap_boolean.

    lv_chekgl = abap_true.

**********************************************************************
*** 필터 ***
**********************************************************************
    TRY.
        "get and add filters
        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ). " get_filter_conditions( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        DATA(lx_catch) = lx_no_sel_option.
    ENDTRY.

    LOOP AT lt_filter INTO DATA(ls_filter).
      CASE ls_filter-name.
        WHEN 'P_TOYEAR'.
          MOVE-CORRESPONDING ls_filter-range TO lr_toyear.
          LOOP AT lr_toyear INTO DATA(ls_toyear) .
            DATA(lv_toyear) = CONV int4( ls_toyear-low ).
          ENDLOOP.
        WHEN 'P_TOMONTH'.
          MOVE-CORRESPONDING ls_filter-range TO lr_tomonth.
          LOOP AT lr_tomonth INTO DATA(ls_tomonth) .
            DATA(lv_tomonth) = CONV int4( ls_tomonth-low ).
          ENDLOOP.
        WHEN 'P_RUNTYPE'.
          MOVE-CORRESPONDING ls_filter-range TO lr_runtype.
          LOOP AT lr_runtype INTO DATA(ls_runtype) .
            DATA(lv_runtype) = CONV ckml_run_type( ls_runtype-low ).
          ENDLOOP.
        WHEN 'P_COMPCD'.
          MOVE-CORRESPONDING ls_filter-range TO lr_compcd.
          LOOP AT lr_compcd INTO DATA(ls_compcd) .
            DATA(lv_compcd) = ls_compcd-low.
          ENDLOOP.
        WHEN 'P_CHEKGL'.
          MOVE-CORRESPONDING ls_filter-range TO lr_chekgl.
          LOOP AT lr_chekgl INTO DATA(ls_chekgl) .
            lv_chekgl = ls_chekgl-low.
          ENDLOOP.
        WHEN 'HIERARCHYLEVEL'.
          MOVE-CORRESPONDING ls_filter-range TO lr_hierarchylevel.
          LOOP AT lr_chekgl INTO DATA(ls_hierarchylevel) .
            DATA(lv_hierarchylevel) = ls_hierarchylevel-low.
          ENDLOOP.
        WHEN 'PARENTNODEID'.
          MOVE-CORRESPONDING ls_filter-range TO lr_parentnodeid.
          LOOP AT lr_parentnodeid INTO DATA(ls_parentnodeid) .
            DATA(lv_parentnodeid) = ls_parentnodeid-low.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.

**********************************************************************
*** 기본값 ***
**********************************************************************

    DATA: ls_runtimehierarchy TYPE c LENGTH 40,
          ls_nodeid           TYPE c LENGTH 12.

    ls_runtimehierarchy = 'H109/YCOA/ZCOGM_003'.
    ls_nodeid = '0ZCOGM_003'.

**********************************************************************
*** hierarchy 데이터 : lt_hier ***
**********************************************************************
    SELECT main~hierarchynode
          ,main~parentnode
          ,main~nodetype
          ,main~hierarchynodeval
          ,main~hierarchynodelevel
          ,main~glaccount
          ,gltext~glaccountlongname AS glaccounttext
          ,text~hierarchynodetext
          ,1 AS sourtcount
      FROM i_hierruntimerprstnnode AS main
      LEFT OUTER JOIN i_hierruntimerprstnnodetext AS text
        ON main~runtimehierarchy = text~runtimehierarchy
       AND main~validityenddate = text~validityenddate
       AND main~hierarchynode = text~hierarchynode
       AND main~hierarchynodeclass = text~hierarchynodeclass
       AND main~parentnode = text~parentnode
       AND text~language = '3'
      LEFT OUTER JOIN i_glaccounttext AS gltext
        ON gltext~chartofaccounts = 'YCOA'
       AND gltext~glaccount       = main~glaccount
       AND gltext~language        = '3'
     WHERE main~runtimehierarchy = @ls_runtimehierarchy
     ORDER BY main~hierarchynode ASCENDING
      INTO TABLE @DATA(lt_hier).

**********************************************************************
*** GLAccount 데이터 : lt_glaccount ***
**********************************************************************
    SELECT DISTINCT glaccount
      FROM @lt_hier AS main
      INTO TABLE @DATA(lt_glaccount_only).

    SELECT glaccount~sourceledger
          ,glaccount~glaccount
          ,glaccount~companycode
          ,glaccount~companycodecurrency
          ,glaccount~fiscalperiod
          ,glaccount~amountincompanycodecurrency
          ,glaccount~debitcreditcode
          ,glaccount~materialledgerprocesstype
          ,glaccount~functionalarea
      FROM i_glaccountlineitemrawdata AS glaccount
     INNER JOIN @lt_glaccount_only AS hier
        ON glaccount~glaccount = hier~glaccount
      WHERE sourceledger = '0L'
        AND ( fiscalyear IN @lr_toyear
          AND fiscalperiod LE @lv_tomonth )
        AND companycode IN @lr_compcd
         INTO TABLE @DATA(lt_glaccount).

**********************************************************************
*** 수불부 데이터 : 실제원가 ***
**********************************************************************
    DATA : lv_fiscalperiod TYPE fins_fiscalperiod.
    DATA : lv_fiscalyear TYPE fis_gjahr_no_conv.
    CLEAR: lv_fiscalperiod, lv_fiscalyear.

    lv_fiscalperiod = lv_tomonth.
    lv_fiscalyear = lv_toyear.

    SELECT actlcost~inventoryamtindspcrcy,
           mtclass~materialclass,
           actlcost~materialledgercategory,
           actlcost~processcategory,
           actlcost~ledger,
           actlcost~glaccount_class,
           actlcost~glaccountname_class,
           actlcost~sum_inventory,
           actlcost~material
      FROM zc_actl(
        p_costingruntype = @lv_runtype ,
        p_fiscalperiod = @lv_fiscalperiod,
        p_fiscalyear = @lv_fiscalyear ) AS actlcost
      INNER JOIN zc_mtclass_material AS mtclass
        ON mtclass~materialclass = actlcost~materialvaluationclass
      WHERE ledger = '0L'
        AND currencyrole = '10'
        AND mtclass~materialtype = 'S'
         INTO TABLE @DATA(lt_actlcost).

**********************************************************************
*** 수불부 데이터 : 이동평균 ***
**********************************************************************
    DATA : lv_trparameter TYPE c LENGTH 7,
           lv_month       TYPE c LENGTH 3.
    CLEAR : lv_trparameter, lv_month.

    IF lv_tomonth < 10.
      lv_month = '00' && lv_tomonth.
    ELSEIF lv_tomonth < 100.
      lv_month = '0' && lv_tomonth.
    ENDIF.

    lv_trparameter = |{ lv_toyear }{ lv_month }|.

    SELECT transmat~inventoryamtindspcrcy,
           mtclass~materialclass,
           transmat~materialledgercategory,
           transmat~processcategory,
           transmat~ledger,
           transmat~glaccount_class,
           transmat~glaccountname_class,
           transmat~sum_inventory,
           transmat~material
      FROM zc_trans(
        p_fromfiscalyearperiod = @lv_trparameter,
        p_tofiscalyearperiod = @lv_trparameter ) AS transmat
      INNER JOIN zc_mtclass_material AS mtclass
        ON mtclass~materialclass = transmat~materialvaluationclass
      WHERE ledger = '0L'
        AND currencyrole = '10'
        AND mtclass~materialtype = 'V'
         INTO TABLE @DATA(lt_transmat).

    IF  top <> 0 AND skip IS NOT INITIAL.
      top = top + skip - 1.
    ELSEIF top <> 0 AND skip IS INITIAL.
      top = top.
    ELSE.
      top = lines( lt_hier ).
    ENDIF.

**********************************************************************
*** 노드 구성 ***
**********************************************************************
    LOOP AT lt_hier INTO DATA(ls_hier).
      DATA(lv_index) = sy-tabix.
      CLEAR : ls_business_data.

*      중복 노드 삭제 (parent node : 0ZCOGM_003 ~ 04000)
      IF ( ls_hier-parentnode = ls_nodeid AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '04000'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '03000'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '02000'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '01000'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) ).                                        .

        DELETE lt_hier INDEX lv_index.
        CONTINUE.
      ENDIF.

      ls_business_data-nodeid = ls_hier-hierarchynode.
      ls_business_data-hierarchylevel = ls_hier-hierarchynodelevel.
      ls_business_data-parentnodeid = ls_hier-parentnode.
      ls_business_data-companycodecurrency = 'KRW'.

*      GLAccount 있으면 : 최하위노드(leaf) / 없으면 : 상단노드(expanded)
      IF ( ls_hier-glaccount <> '' AND ls_hier-glaccount IS NOT INITIAL ).
        ls_business_data-checkgl = abap_true.
        ls_business_data-glaccount = ls_hier-glaccount.
        ls_business_data-drillstate = 'leaf'.
        ls_business_data-glaccounttext = ls_hier-glaccounttext.
      ELSE.
        ls_business_data-subject = ls_hier-hierarchynodeval.
        ls_business_data-subjecttext = ls_hier-hierarchynodetext.
        ls_business_data-drillstate = 'expanded'.
      ENDIF.

*      '0ZCOGM_003'이면 최상단 위치
      IF ls_business_data-nodeid = ls_nodeid.
        ls_business_data-sortindex = 0.
      ELSEIF ls_business_data-drillstate = 'expanded'.
*      expanded면 위치 유지
        ls_business_data-sortindex = ls_business_data-nodeid.
      ELSE.
*      leaf면 부모 밑
        ls_business_data-sortindex = ls_business_data-parentnodeid + 1.
      ENDIF.

*      leaf설정
      IF ls_hier-hierarchynode = '09600'
         OR ls_hier-hierarchynode = '09500'
         OR ls_hier-hierarchynode = '09150'
         OR ls_hier-hierarchynode = '09140'
         OR ls_hier-hierarchynode = '08000'
         OR ls_hier-hierarchynode = '07000'
         OR ls_hier-hierarchynode = '05000'.
        ls_business_data-drillstate = 'leaf'.
      ENDIF.

*      GL계정조회 미체크시
      IF lv_chekgl IS INITIAL.
        IF ( ls_hier-hierarchynode+1(1) = '1' AND ls_hier-hierarchynode+2(1) <> '0' )
           OR ( ls_hier-hierarchynode+1(1) = '2' AND ls_hier-hierarchynode+2(1) <> '0' )
           OR ( ls_hier-hierarchynode+1(1) = '3' AND ls_hier-hierarchynode+2(1) <> '0' )
           OR ( ls_hier-hierarchynode+1(1) = '4' AND ls_hier-hierarchynode+2(1) <> '0' )
           OR ls_hier-hierarchynode = '06000'
           OR ( ls_hier-hierarchynode+1(1) = '9' AND ls_hier-hierarchynode+2(1) <> '1' ).
          ls_business_data-drillstate = 'leaf'.
        ENDIF.
      ENDIF.

      APPEND ls_business_data TO business_data.

*      같은 GL계정을 사용하는 노드 구성
      IF ( ls_hier-parentnode = '01100' ).
        ls_business_data-parentnodeid = '01600'.
        ls_business_data-sortindex =  ls_business_data-parentnodeid + 1.
        APPEND ls_business_data TO business_data.
      ENDIF.

      IF ( ls_hier-parentnode = '02100' ).
        ls_business_data-parentnodeid = '02600'.
        ls_business_data-sortindex = ls_business_data-parentnodeid + 1.
        APPEND ls_business_data TO business_data.
      ENDIF.

      IF ( ls_hier-parentnode = '06000' ).
        ls_business_data-parentnodeid = '08000'.
        ls_business_data-sortindex = ls_business_data-parentnodeid + 1.
        APPEND ls_business_data TO business_data.
      ENDIF.

      IF ( ls_hier-parentnode = '09110' ).
        ls_business_data-parentnodeid = '09140'.
        ls_business_data-sortindex = ls_business_data-parentnodeid + 1.
        APPEND ls_business_data TO business_data.
      ENDIF.
    ENDLOOP.
**********************************************************************
*** 노드 구성 ***
**********************************************************************
    LOOP AT lt_glaccount INTO DATA(ls_glaccount).

      SELECT *
        FROM @business_data AS a
       WHERE glaccount = @ls_glaccount-glaccount
        INTO TABLE @DATA(lt_bd_glaccount).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

*      계산로직
      LOOP AT lt_bd_glaccount ASSIGNING FIELD-SYMBOL(<fs_businessdata>).
        <fs_businessdata>-companycodecurrency = ls_glaccount-companycodecurrency.
*       필드심볼 사용 : 값 바로 업데이트
        IF <fs_businessdata>-parentnodeid+1(1) = '1'.
          CASE <fs_businessdata>-parentnodeid.
*       node = 01100 : 기초누계 (0월~from-1)
            WHEN '01100'.
              IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE lv_tomonth - 1.
*               1100 합산
                READ TABLE business_data WITH KEY subject = '1100' ASSIGNING FIELD-SYMBOL(<fs_1100>).
                IF sy-subrc = 0.
                  <fs_1100>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
*                1400 합산(계)
                READ TABLE business_data WITH KEY subject = '1400'  ASSIGNING FIELD-SYMBOL(<fs_1400_1100>).
                IF sy-subrc = 0.
                  <fs_1400_1100>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.

*       node = 01200 : 당월합산
            WHEN '01200'.
              IF ls_glaccount-fiscalperiod EQ lv_tomonth.
*               1200 합산
                READ TABLE business_data WITH KEY subject = '1200'  ASSIGNING FIELD-SYMBOL(<fs_1200>).
                IF sy-subrc = 0.
                  <fs_1200>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
*                1400 합산(계)
                READ TABLE business_data WITH KEY subject = '1400'  ASSIGNING FIELD-SYMBOL(<fs_1400_1200>).
                IF sy-subrc = 0.
                  <fs_1400_1200>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.

*       node = 01600 : 기말누계 (0월~to)
            WHEN '01600'.
              IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE + lv_tomonth.
*               1600 합산
                READ TABLE business_data WITH KEY subject = '1600'  ASSIGNING FIELD-SYMBOL(<fs_1600>).
                IF sy-subrc = 0.
                  <fs_1600>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.
          ENDCASE.

        ELSEIF <fs_businessdata>-parentnodeid+1(1) = '2'.
          CASE <fs_businessdata>-parentnodeid.
*       node = 02100 : 기초누계 (0월~from-1)
            WHEN '02100'.
              IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE lv_tomonth - 1.
*               2100합산
                READ TABLE business_data WITH KEY subject = '2100' ASSIGNING FIELD-SYMBOL(<fs_2100>).
                IF sy-subrc = 0.
                  <fs_2100>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
*               2400 합산
                READ TABLE business_data WITH KEY subject = '2400'  ASSIGNING FIELD-SYMBOL(<fs_2400_2100>).
                IF sy-subrc = 0.
                  <fs_2400_2100>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.

*       node = 02200 : 조회월합산 (from~to)
            WHEN '02200'.
              IF ls_glaccount-fiscalperiod EQ lv_tomonth.
*               2200 합산
                READ TABLE business_data WITH KEY subject = '2200'  ASSIGNING FIELD-SYMBOL(<fs_2200>).
                IF sy-subrc = 0.
                  <fs_2200>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
*               2400 합산
                READ TABLE business_data WITH KEY subject = '2400'  ASSIGNING FIELD-SYMBOL(<fs_2400_2200>).
                IF sy-subrc = 0.
                  <fs_2400_2200>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.

*       node = 02500 : 기말누계 (0월~to)
            WHEN '02600'.
              IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE + lv_tomonth.
*               2600 합산
                READ TABLE business_data WITH KEY subject = '2600'  ASSIGNING FIELD-SYMBOL(<fs_2600>).
                IF sy-subrc = 0.
                  <fs_2600>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.
          ENDCASE.

*       node = 03 ~ : 당월
        ELSEIF <fs_businessdata>-parentnodeid+1(1) = '3'.
          DATA(lv_3x00) = <fs_businessdata>-parentnodeid.
          IF ls_glaccount-fiscalperiod EQ lv_tomonth.
            READ TABLE business_data WITH KEY subject = '3000'  ASSIGNING FIELD-SYMBOL(<fs_3x00_3000>).
            IF sy-subrc = 0.
              <fs_3x00_3000>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            READ TABLE business_data WITH KEY subject = lv_3x00+1(4)  ASSIGNING FIELD-SYMBOL(<fs_3x00>).
            IF sy-subrc = 0.
              <fs_3x00>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
          ENDIF.

*       node = 04 ~ : 당월
        ELSEIF <fs_businessdata>-parentnodeid+1(1) = '4'.
          DATA(lv_4x00) = <fs_businessdata>-parentnodeid.
          IF ls_glaccount-fiscalperiod EQ lv_tomonth.
            READ TABLE business_data WITH KEY subject = '4000'  ASSIGNING FIELD-SYMBOL(<fs_4x00_4000>).
            IF sy-subrc = 0.
              <fs_4x00_4000>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            READ TABLE business_data WITH KEY subject = lv_4x00+1(4)  ASSIGNING FIELD-SYMBOL(<fs_4x00>).
            IF sy-subrc = 0.
              <fs_4x00>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
          ENDIF.

*       node = 06 ~ : 0월~from-1
        ELSEIF <fs_businessdata>-parentnodeid+1(1) = '6'.
          IF + ls_glaccount-fiscalperiod GE + 000 AND + ls_glaccount-fiscalperiod LE + lv_tomonth - 1.
            READ TABLE business_data WITH KEY subject = '6000'  ASSIGNING FIELD-SYMBOL(<fs_6000>).
            IF sy-subrc = 0.
              <fs_6000>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
          ENDIF.

*       node = 08~ : 0월~to
        ELSEIF <fs_businessdata>-parentnodeid+1(1) = '8'.
          IF + ls_glaccount-fiscalperiod GE + 000 AND + ls_glaccount-fiscalperiod LE + lv_tomonth.
            READ TABLE business_data WITH KEY subject = '8000'  ASSIGNING FIELD-SYMBOL(<fs_8000>).
            IF sy-subrc = 0.
              <fs_8000>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
          ENDIF.

*       node = 09~ : from~to
        ELSEIF <fs_businessdata>-parentnodeid+1(1) = '9'.
          CASE <fs_businessdata>-parentnodeid.
**********************************************************************
*****반제품 로직******
*       node = 09110 : 기초반제품 (0월~from-1)
            WHEN '09110'.
              IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE lv_tomonth - 1.
*               9110 합산
                READ TABLE business_data WITH KEY subject = '9110' ASSIGNING FIELD-SYMBOL(<fs_9110>).
                IF sy-subrc = 0.
                  <fs_9110>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
*                 9500 합산(당기제품제조원가)
                READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_9110_9500>).
                IF sy-subrc = 0.
                  <fs_9110_9500>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.

*       node = 09140 : 기말반제품 (0월~to)
            WHEN '09140'.
              IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE + lv_tomonth.
*               9140 합산
                READ TABLE business_data WITH KEY subject = '9140'  ASSIGNING FIELD-SYMBOL(<fs_9140>).
                IF sy-subrc = 0.
                  <fs_9140>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
*                 9500 합산(당기제품제조원가)
                READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_9140_9500>).
                IF sy-subrc = 0.
                  <fs_9140_9500>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                ENDIF.
                <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.
          ENDCASE.
        ENDIF.

        READ TABLE business_data
                WITH KEY glaccount    = <fs_businessdata>-glaccount
                         parentnodeid = <fs_businessdata>-parentnodeid
                         nodeid       = <fs_businessdata>-nodeid
                         subject      = <fs_businessdata>-subject
                ASSIGNING FIELD-SYMBOL(<fs_businessdata_org>).
        IF sy-subrc = 0.
          MOVE-CORRESPONDING <fs_businessdata> TO <fs_businessdata_org>.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

**********************************************************************
*** 수불부 로직 ***
**********************************************************************

    LOOP AT lt_transmat INTO DATA(ls_transmat).
      CASE ls_transmat-materialclass.
        WHEN '3000'.
          IF ls_transmat-materialledgercategory = 'EB'.
            READ TABLE business_data WITH KEY subject = '1500' ASSIGNING FIELD-SYMBOL(<fs_t_sum_1500>).
            IF sy-subrc = 0.
              <fs_t_sum_1500>-amountincompanycodecurrency += ls_transmat-sum_inventory.
            ENDIF.
          ENDIF.

          IF ls_transmat-materialledgercategory EQ 'ZU' AND
            ( ls_transmat-processcategory EQ 'B+' OR
              ls_transmat-processcategory EQ 'BUBS' OR
              ls_transmat-processcategory EQ 'BL' OR
              ls_transmat-processcategory EQ 'BU' ) OR ls_transmat-materialledgercategory EQ 'ND'.
            READ TABLE business_data WITH KEY subject = '1300' ASSIGNING FIELD-SYMBOL(<fs_t_1300>).
            IF sy-subrc = 0.
              <fs_t_1300>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
*           1400 합산(계)
            READ TABLE business_data WITH KEY subject = '1400'  ASSIGNING FIELD-SYMBOL(<fs_t_1400_1300>).
            IF sy-subrc = 0.
              <fs_t_1400_1300>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.

          ELSEIF ls_transmat-materialledgercategory EQ 'VN' AND
            ( ls_transmat-processcategory EQ 'VK' OR
              ls_transmat-processcategory EQ 'VL' OR
              ls_transmat-processcategory EQ 'VU' OR
              ls_transmat-processcategory EQ 'VUBS' OR
              ls_transmat-processcategory EQ 'VKA' ).
            READ TABLE business_data WITH KEY subject = '1500' ASSIGNING FIELD-SYMBOL(<fs_t_1500>).
            IF sy-subrc = 0.
              <fs_t_1500>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.

*         1001 원재료비
          ELSEIF ls_transmat-materialledgercategory EQ 'VN' AND ls_transmat-processcategory EQ 'VF'.
            READ TABLE business_data WITH KEY subject = '1001' ASSIGNING FIELD-SYMBOL(<fs_t_1001>).
            IF sy-subrc = 0.
              <fs_t_1001>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.

          ENDIF.

        WHEN '3032'.
          IF ls_transmat-materialledgercategory = 'EB'.
            READ TABLE business_data WITH KEY subject = '2500' ASSIGNING FIELD-SYMBOL(<fs_t_sum_2500>).
            IF sy-subrc = 0.
              <fs_t_sum_2500>-amountincompanycodecurrency += ls_transmat-sum_inventory.
            ENDIF.
          ENDIF.

          IF ls_transmat-materialledgercategory EQ 'ZU' AND
            ( ls_transmat-processcategory EQ 'B+' OR
              ls_transmat-processcategory EQ 'BUBS' OR
              ls_transmat-processcategory EQ 'BL' OR
              ls_transmat-processcategory EQ 'BU' ) OR ls_transmat-materialledgercategory EQ 'ND'.
            READ TABLE business_data WITH KEY subject = '2300' ASSIGNING FIELD-SYMBOL(<fs_t_2300>).
            IF sy-subrc = 0.
              <fs_t_2300>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
*           1400 합산(계)
            READ TABLE business_data WITH KEY subject = '2400'  ASSIGNING FIELD-SYMBOL(<fs_t_2400_2300>).
            IF sy-subrc = 0.
              <fs_t_2400_2300>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.

          ELSEIF ls_transmat-materialledgercategory EQ 'VN' AND
            ( ls_transmat-processcategory EQ 'VK' OR
              ls_transmat-processcategory EQ 'VL' OR
              ls_transmat-processcategory EQ 'VU' OR
              ls_transmat-processcategory EQ 'VUBS' OR
              ls_transmat-processcategory EQ 'VKA' ).

            READ TABLE business_data WITH KEY subject = '2500' ASSIGNING FIELD-SYMBOL(<fs_t_2500>).
            IF sy-subrc = 0.
              <fs_t_2500>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.

*         2001 부재료비
          ELSEIF ls_transmat-materialledgercategory EQ 'VN' AND ls_transmat-processcategory EQ 'VF'.
            READ TABLE business_data WITH KEY subject = '2001' ASSIGNING FIELD-SYMBOL(<fs_t_2001>).
            IF sy-subrc = 0.
              <fs_t_2001>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
          ENDIF.

        WHEN '7900' OR '7930'.
          IF ls_transmat-materialledgercategory = 'EB'.
            READ TABLE business_data WITH KEY subject = '9130' ASSIGNING FIELD-SYMBOL(<fs_t_sum_9130>).
            IF sy-subrc = 0.
              <fs_t_sum_9130>-amountincompanycodecurrency += ls_transmat-sum_inventory.
            ENDIF.
          ENDIF.
*         9500 합산(당기제품제조원가)
          READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_sum_9500>).
          IF sy-subrc = 0.
            <fs_sum_9500>-amountincompanycodecurrency -= ls_transmat-sum_inventory.
          ENDIF.

          IF ( ls_transmat-materialledgercategory EQ 'ZU'
               AND ( ls_transmat-processcategory EQ 'B+'   OR
                     ls_transmat-processcategory EQ 'BUBS' OR
                     ls_transmat-processcategory EQ 'BL'   OR
                     ls_transmat-processcategory EQ 'BU'   OR
                     ls_transmat-processcategory EQ 'BB' ) ) OR ls_transmat-materialledgercategory EQ 'ND'.

            READ TABLE business_data WITH KEY subject = '9120' ASSIGNING FIELD-SYMBOL(<fs_t_9120>).
            IF sy-subrc = 0.
              <fs_t_9120>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
*           9500 합산(당기제품제조원가)
            READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_t_9120_9500>).
            IF sy-subrc = 0.
              <fs_t_9120_9500>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.

          ELSEIF ls_transmat-materialledgercategory EQ 'VN' AND
            ( ls_transmat-processcategory EQ 'VK' OR
              ls_transmat-processcategory EQ 'VL' OR
              ls_transmat-processcategory EQ 'VU' OR
              ls_transmat-processcategory EQ 'VUBS' OR
              ls_transmat-processcategory EQ 'VKA' ).

            READ TABLE business_data WITH KEY subject = '9130' ASSIGNING FIELD-SYMBOL(<fs_t_9130>).
            IF sy-subrc = 0.
              <fs_t_9130>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
*           9500 합산(당기제품제조원가)
            READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_t_9130_9500>).
            IF sy-subrc = 0.
              <fs_t_9130_9500>-amountincompanycodecurrency -= ls_transmat-inventoryamtindspcrcy.
            ENDIF.

          ENDIF.
        WHEN '7920' OR '7924'.
          IF ls_transmat-materialledgercategory EQ 'ZU' AND ls_transmat-processcategory EQ 'BF'.
            READ TABLE business_data WITH KEY subject = '9600' ASSIGNING FIELD-SYMBOL(<fs_t_9600>).
            IF sy-subrc = 0.
              <fs_t_9600>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    LOOP AT lt_actlcost INTO DATA(ls_actlcost).
      CLEAR : ls_business_data.

      CASE ls_actlcost-materialclass.
        WHEN '3000'.
*         1500노드의 배분되지않음 : 기말 sum_inventory
          IF ls_actlcost-materialledgercategory = 'EB'.
            READ TABLE business_data WITH KEY subject = '1500' ASSIGNING FIELD-SYMBOL(<fs_a_sum_1500>).
            IF sy-subrc = 0.
              <fs_a_sum_1500>-amountincompanycodecurrency += ls_actlcost-sum_inventory.
            ENDIF.
          ENDIF.

*         자재원장범주 ZU에서 프로세스 범주 B+, BUBS, BL, BU, 자재원장범주의 배부되지 않음 조회 당월 '실제 값' 합계
          IF  ( ls_actlcost-materialledgercategory EQ 'ZU'
                AND ( ls_actlcost-processcategory EQ 'B+' OR
                      ls_actlcost-processcategory EQ 'BUBS' OR
                      ls_actlcost-processcategory EQ 'BL' OR
                      ls_actlcost-processcategory EQ 'BU' ) ) OR ls_actlcost-materialledgercategory EQ 'ND'.

            READ TABLE business_data WITH KEY subject = '1300' ASSIGNING FIELD-SYMBOL(<fs_a_1300>).
            IF sy-subrc = 0.
              <fs_a_1300>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           1400 합산(계)
            READ TABLE business_data WITH KEY subject = '1400'  ASSIGNING FIELD-SYMBOL(<fs_a_1400_1300>).
            IF sy-subrc = 0.
              <fs_a_1400_1300>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.

          ELSEIF ls_actlcost-materialledgercategory EQ 'VN'
                  AND ( ls_actlcost-processcategory EQ 'VK' OR
                        ls_actlcost-processcategory EQ 'VL' OR
                        ls_actlcost-processcategory EQ 'VU' OR
                        ls_actlcost-processcategory EQ 'VUBS' OR
                        ls_actlcost-processcategory EQ 'VKA' ).

            READ TABLE business_data WITH KEY subject = '1500' ASSIGNING FIELD-SYMBOL(<fs_a_1500>).
            IF sy-subrc = 0.
              <fs_a_1500>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.

*         1001 원재료비
          ELSEIF ls_actlcost-materialledgercategory EQ 'VN' AND ls_actlcost-processcategory EQ 'VF'.
            READ TABLE business_data WITH KEY subject = '1001' ASSIGNING FIELD-SYMBOL(<fs_a_1001>).
            IF sy-subrc = 0.
              <fs_a_1001>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.

          ENDIF.

        WHEN '3032'.
          IF ls_actlcost-materialledgercategory = 'EB'.
            READ TABLE business_data WITH KEY subject = '2500' ASSIGNING FIELD-SYMBOL(<fs_a_sum_2500>).
            IF sy-subrc = 0.
              <fs_a_sum_2500>-amountincompanycodecurrency += ls_actlcost-sum_inventory.
            ENDIF.
          ENDIF.

          IF ( ls_actlcost-materialledgercategory EQ 'ZU'
                AND ( ls_actlcost-processcategory EQ 'B+' OR
                      ls_actlcost-processcategory EQ 'BUBS' OR
                      ls_actlcost-processcategory EQ 'BL' OR
                      ls_actlcost-processcategory EQ 'BU' ) ) OR ls_actlcost-materialledgercategory EQ 'ND'.

            READ TABLE business_data WITH KEY subject = '2300' ASSIGNING FIELD-SYMBOL(<fs_a_2300>).
            IF sy-subrc = 0.
              <fs_a_2300>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           2400 합산(계)
            READ TABLE business_data WITH KEY subject = '2400'  ASSIGNING FIELD-SYMBOL(<fs_a_2400_2300>).
            IF sy-subrc = 0.
              <fs_a_2400_2300>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.

          ELSEIF ls_actlcost-materialledgercategory EQ 'VN'
                  AND ( ls_actlcost-processcategory EQ 'VK' OR
                        ls_actlcost-processcategory EQ 'VL' OR
                        ls_actlcost-processcategory EQ 'VU' OR
                        ls_actlcost-processcategory EQ 'VUBS' OR
                        ls_actlcost-processcategory EQ 'VKA' ).

            READ TABLE business_data WITH KEY subject = '2500' ASSIGNING FIELD-SYMBOL(<fs_a_2500>).
            IF sy-subrc = 0.
              <fs_a_2500>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.

*         2001 부재료비
          ELSEIF ls_actlcost-materialledgercategory EQ 'VN' AND ls_actlcost-processcategory EQ 'VF'.
            READ TABLE business_data WITH KEY subject = '2001' ASSIGNING FIELD-SYMBOL(<fs_a_2001>).
            IF sy-subrc = 0.
              <fs_a_2001>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
          ENDIF.

        WHEN '7900' OR '7930'.
          IF ls_actlcost-materialledgercategory = 'EB'.
            READ TABLE business_data WITH KEY subject = '9130' ASSIGNING FIELD-SYMBOL(<fs_a_sum_9130>).
            IF sy-subrc = 0.
              <fs_a_sum_9130>-amountincompanycodecurrency += ls_actlcost-sum_inventory.
            ENDIF.
          ENDIF.
*         9500 합산(당기제품제조원가)
          READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_a_sum_9500>).
          IF sy-subrc = 0.
            <fs_a_sum_9500>-amountincompanycodecurrency -= ls_actlcost-sum_inventory.
          ENDIF.

          IF ( ls_actlcost-materialledgercategory EQ 'ZU'
                AND ( ls_actlcost-processcategory EQ 'B+'   OR
                      ls_actlcost-processcategory EQ 'BUBS' OR
                      ls_actlcost-processcategory EQ 'BL'   OR
                      ls_actlcost-processcategory EQ 'BU'   OR
                      ls_actlcost-processcategory EQ 'BB'   ) ) OR ls_actlcost-materialledgercategory EQ 'ND'.

            READ TABLE business_data WITH KEY subject = '9120' ASSIGNING FIELD-SYMBOL(<fs_a_9120>).
            IF sy-subrc = 0.
              <fs_a_9120>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           9500 합산(당기제품제조원가)
            READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_a_9120_9500>).
            IF sy-subrc = 0.
              <fs_a_9120_9500>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.

          ELSEIF ls_actlcost-materialledgercategory EQ 'VN'
                  AND ( ls_actlcost-processcategory EQ 'VK' OR
                        ls_actlcost-processcategory EQ 'VL' OR
                        ls_actlcost-processcategory EQ 'VU' OR
                        ls_actlcost-processcategory EQ 'VUBS' OR
                        ls_actlcost-processcategory EQ 'VKA' ).

            READ TABLE business_data WITH KEY subject = '9130' ASSIGNING FIELD-SYMBOL(<fs_a_9130>).
            IF sy-subrc = 0.
              <fs_a_9130>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           9500 합산(당기제품제조원가)
            READ TABLE business_data WITH KEY subject = '9500'  ASSIGNING FIELD-SYMBOL(<fs_a_9130_9500>).
            IF sy-subrc = 0.
              <fs_a_9130_9500>-amountincompanycodecurrency -= ls_actlcost-inventoryamtindspcrcy.
            ENDIF.

          ENDIF.
        WHEN '7920' OR '7924'.
          IF ls_actlcost-materialledgercategory EQ 'ZU' AND ls_actlcost-processcategory EQ 'BF'.
            READ TABLE business_data WITH KEY subject = '9600' ASSIGNING FIELD-SYMBOL(<fs_a_9600>).
            IF sy-subrc = 0.
              <fs_a_9600>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

**********************************************************************
***최상노드 합산
**********************************************************************
    SELECT subject,
           amountincompanycodecurrency
      FROM @business_data AS data
     WHERE subject = '1400'
        OR subject = '1500'
        OR subject = '1600'
        OR subject = '2400'
        OR subject = '2500'
        OR subject = '2600'
      INTO TABLE @DATA(lt_sum).

    LOOP AT lt_sum INTO DATA(ls_sum).
      CASE ls_sum-subject.
        WHEN '1400'.
          READ TABLE business_data WITH KEY subject = '1000' ASSIGNING FIELD-SYMBOL(<fs_sum_1400>).
          IF sy-subrc = 0.
            <fs_sum_1400>-amountincompanycodecurrency += ls_sum-amountincompanycodecurrency.
          ENDIF.
        WHEN '1500'.
          READ TABLE business_data WITH KEY subject = '1000' ASSIGNING FIELD-SYMBOL(<fs_sum_1500>).
          IF sy-subrc = 0.
            <fs_sum_1500>-amountincompanycodecurrency -= ls_sum-amountincompanycodecurrency.
          ENDIF.
        WHEN '1600'.
          READ TABLE business_data WITH KEY subject = '1000' ASSIGNING FIELD-SYMBOL(<fs_sum_1600>).
          IF sy-subrc = 0.
            <fs_sum_1600>-amountincompanycodecurrency -= ls_sum-amountincompanycodecurrency.
          ENDIF.
        WHEN '2400'.
          READ TABLE business_data WITH KEY subject = '2000' ASSIGNING FIELD-SYMBOL(<fs_sum_2400>).
          IF sy-subrc = 0.
            <fs_sum_2400>-amountincompanycodecurrency += ls_sum-amountincompanycodecurrency.
          ENDIF.
        WHEN '2500'.
          READ TABLE business_data WITH KEY subject = '2000' ASSIGNING FIELD-SYMBOL(<fs_sum_2500>).
          IF sy-subrc = 0.
            <fs_sum_2500>-amountincompanycodecurrency -= ls_sum-amountincompanycodecurrency.
          ENDIF.
        WHEN '2600'.
          READ TABLE business_data WITH KEY subject = '2000' ASSIGNING FIELD-SYMBOL(<fs_sum_2600>).
          IF sy-subrc = 0.
            <fs_sum_2600>-amountincompanycodecurrency -= ls_sum-amountincompanycodecurrency.
          ENDIF.
      ENDCASE.
    ENDLOOP.


**********************************************************************
***합계
**********************************************************************

    SELECT subject
          ,amountincompanycodecurrency
      FROM @business_data AS a
     WHERE subject = '1000'
        OR subject = '2000'
        OR subject = '3000'
        OR subject = '4000'
        OR subject = '6000'
        OR subject = '7000'
        OR subject = '8000'
        OR subject = '9000'
     INTO TABLE @DATA(lt_total).

    READ TABLE business_data WITH KEY subject = '5000' ASSIGNING FIELD-SYMBOL(<fs_5000>).
    READ TABLE business_data WITH KEY subject = '7000' ASSIGNING FIELD-SYMBOL(<fs_7000>).
    READ TABLE business_data WITH KEY subject = '9500' ASSIGNING FIELD-SYMBOL(<fs_9500>).

    LOOP AT lt_total INTO DATA(ls_total).
      CASE ls_total-subject.
        WHEN '1000'.
          <fs_5000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
        WHEN '2000'.
          <fs_5000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
        WHEN '3000'.
          <fs_5000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
        WHEN '4000'.
          <fs_5000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
        WHEN '6000'.
          <fs_7000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_7000>-amountincompanycodecurrency += <fs_5000>-amountincompanycodecurrency.
        WHEN '8000'.
          <fs_9500>-amountincompanycodecurrency += <fs_7000>-amountincompanycodecurrency.
          <fs_9500>-amountincompanycodecurrency -= ls_total-amountincompanycodecurrency.
      ENDCASE.
    ENDLOOP.

    SELECT *
     FROM @business_data AS a
    WHERE hierarchylevel  IN @lr_hierarchylevel
      AND parentnodeid  IN @lr_parentnodeid
     INTO TABLE @business_data.


    IF lv_chekgl IS INITIAL.
      SELECT *
         FROM @business_data AS a
        WHERE checkgl = '' OR checkgl IS NULL
         INTO TABLE @business_data.
    ENDIF.

    TRY.
        SORT business_data BY sortindex ASCENDING.
        IF top > 0.
          SELECT *
            FROM @business_data AS a
            ORDER BY sortindex
            INTO TABLE @business_data
           UP TO @top ROWS
            OFFSET @skip.
        ENDIF.

        io_response->set_total_number_of_records( lines( business_data ) ).
        io_response->set_data( business_data ).

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
