CLASS zcl_isnodeglcal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES : ty_result TYPE STANDARD TABLE OF zc_incomestatement WITH EMPTY KEY.

    INTERFACES if_rap_query_provider .

    METHODS sumbynode
      IMPORTING
        iv_toyear          TYPE int4
        iv_tomonth         TYPE int4
        iv_compcd          TYPE zc_incomestatement-p_compcd
        iv_runtype         TYPE ckml_run_type
        iv_checkgl         TYPE abap_boolean
      RETURNING
        VALUE(result_data) TYPE ty_result.

    METHODS delete_tempdata.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ISNODEGLCAL IMPLEMENTATION.


  METHOD delete_tempdata.
    DELETE FROM ztgsco0090. "#EC CI_NOWHERE
    COMMIT WORK.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TYPES:t_toyear         TYPE zc_incomestatement-p_toyear,
          t_tomonth        TYPE zc_incomestatement-p_tomonth,
          t_runtype        TYPE zc_incomestatement-p_runtype,
          t_compcd         TYPE zc_incomestatement-p_compcd,
          t_chekgl         TYPE zc_incomestatement-p_chekgl,
          t_hierarchylevel TYPE zc_incomestatement-hierarchylevel,
          t_parentnodeid   TYPE zc_incomestatement-parentnodeid.

    DATA : lr_toyear         TYPE RANGE OF t_toyear,
           lr_tomonth        TYPE RANGE OF t_tomonth,
           lr_runtype        TYPE RANGE OF t_runtype,
           lr_compcd         TYPE RANGE OF t_compcd,
           lr_chekgl         TYPE RANGE OF t_chekgl,
           lr_hierarchylevel TYPE RANGE OF t_hierarchylevel,
           lr_parentnodeid   TYPE RANGE OF t_parentnodeid.

    DATA business_data TYPE TABLE OF zc_incomestatement.
    DATA ls_business_data TYPE zc_incomestatement.

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
        DATA(result) = lx_no_sel_option.
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
          LOOP AT lr_hierarchylevel INTO DATA(ls_hierarchylevel) .
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
*** 노드별 합산 method 호출 ***
**********************************************************************
    IF lv_hierarchylevel EQ 2.
      CALL METHOD delete_tempdata.
      CALL METHOD sumbynode
        EXPORTING
          iv_toyear   = lv_toyear
          iv_tomonth  = lv_tomonth
          iv_compcd   = lv_compcd
          iv_runtype  = lv_runtype
          iv_checkgl  = lv_chekgl
        RECEIVING
          result_data = business_data.

    ELSE.
        SELECT * "#EC CI_ALL_FIELDS_NEEDED
        FROM ztgsco0090 INTO TABLE @business_data. "#EC CI_NOWHERE
    ENDIF.

*    IF lv_parentnodeid = '06130'.
*        CALL METHOD delete_tempdata.
*    ENDIF.

**********************************************************************
*** Return ***
**********************************************************************
    READ TABLE business_data INTO DATA(ls_business_line) WHERE Subject = 1000 ##READ_WHERE_OK.

    IF  top <> 0 AND skip IS NOT INITIAL.
      top = top + skip - 1.
    ELSEIF top <> 0 AND skip IS INITIAL.
      top = top.
    ELSE.
      top = ls_business_line-top.
    ENDIF.

    SELECT *
     FROM @business_data AS a
    WHERE hierarchylevel  IN @lr_hierarchylevel
      AND parentnodeid  IN @lr_parentnodeid
     INTO TABLE @DATA(return_result).


    IF lv_chekgl IS INITIAL.
      SELECT *
         FROM @return_result AS a
        WHERE checkgl = '' OR checkgl IS NULL
         INTO TABLE @return_result.
    ENDIF.

    TRY.
        SORT return_result BY sortindex ASCENDING.
        IF top > 0.
          SELECT *
            FROM @return_result AS a
            ORDER BY sortindex
            INTO TABLE @return_result
           UP TO @top ROWS
            OFFSET @skip.
        ENDIF.

        io_response->set_total_number_of_records( lines( return_result ) ).
        io_response->set_data( return_result ).

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

    ENDTRY.
  ENDMETHOD.


  METHOD sumbynode.

**********************************************************************
*** 기본값 ***
**********************************************************************

    DATA: ls_runtimehierarchy TYPE c LENGTH 40,
          ls_nodeid           TYPE c LENGTH 12,
          ls_business_data    TYPE zc_incomestatement,
          lv_top              TYPE int8.

    CLEAR : ls_runtimehierarchy, ls_nodeid, ls_business_data, lv_top.

    ls_runtimehierarchy = 'H109/YCOA/ZIS_001'.
    ls_nodeid = '0ZIS_001'.

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

      lv_top = LINES( lt_hier ).

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
        AND ( fiscalyear EQ @iv_toyear
          AND fiscalperiod LE @iv_tomonth )
        AND companycode EQ @iv_compcd
         INTO TABLE @DATA(lt_glaccount).

**********************************************************************
*** 수불부 데이터 : 실제원가 ***
**********************************************************************
    DATA : lv_fiscalperiod TYPE fins_fiscalperiod.
    DATA : lv_fiscalyear TYPE fis_gjahr_no_conv.
    CLEAR: lv_fiscalperiod, lv_fiscalyear.

    lv_fiscalperiod = iv_tomonth.
    lv_fiscalyear = iv_toyear.

    SELECT actlcost~inventoryamtindspcrcy,
           actlcost~materialvaluationclass,
           actlcost~materialledgercategory,
           actlcost~processcategory,
           actlcost~ledger,
           actlcost~glaccount_class,
           actlcost~glaccountname_class
      FROM zc_actl(
        p_costingruntype = @iv_runtype ,
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

    IF iv_tomonth < 10.
      lv_month = '00' && iv_tomonth.
    ELSEIF iv_tomonth < 100.
      lv_month = '0' && iv_tomonth.
    ENDIF.

    lv_trparameter = |{ iv_toyear }{ lv_month }|.

    SELECT transmat~inventoryamtindspcrcy,
           transmat~materialvaluationclass,
           transmat~materialledgercategory,
           transmat~processcategory,
           transmat~ledger,
           transmat~glaccount_class,
           transmat~glaccountname_class
      FROM zc_trans(
        p_fromfiscalyearperiod = @lv_trparameter,
        p_tofiscalyearperiod = @lv_trparameter ) AS transmat
      INNER JOIN zc_mtclass_material AS mtclass
        ON mtclass~materialclass = transmat~materialvaluationclass
      WHERE ledger = '0L'
        AND currencyrole = '10'
        AND mtclass~materialtype = 'V'
         INTO TABLE @DATA(lt_transmat).

**********************************************************************
*** 노드 구성 ***
**********************************************************************
    LOOP AT lt_hier INTO DATA(ls_hier).
      DATA(lv_index) = sy-tabix.
      CLEAR : ls_business_data.

*      중복 노드 삭제 (parent node : 0ZIS_001 ~ 04000)
      IF ( ls_hier-parentnode = ls_nodeid AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '06000'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '05000'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '05100'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '05200'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '05210'     AND ( ls_hier-glaccount <> ''
                                               AND ls_hier-glaccount IS NOT INITIAL ) )
       OR ( ls_hier-parentnode = '05220'     AND ( ls_hier-glaccount <> ''
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

      ls_business_data-top = lv_top.
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

*      '0ZIS_001'이면 최상단 위치
      IF ls_business_data-nodeid = ls_nodeid.
        ls_business_data-sortindex = 0.
      ELSEIF ls_business_data-drillstate = 'expanded'.
*      expanded면 위치 유지
        ls_business_data-sortindex = ls_business_data-nodeid.
      ELSE.
*      leaf면 부모 밑
        ls_business_data-sortindex = ls_business_data-parentnodeid + 1.
      ENDIF.

*      GL계정조회 미체크시
      IF iv_checkgl IS INITIAL.
        IF ( ls_hier-hierarchynode+1(1) = '5' AND ls_hier-hierarchynode+3(1) <> '0' )
           OR ( ls_hier-hierarchynode+1(1) = '6' AND ls_hier-hierarchynode+2(1) <> '0' ).
          ls_business_data-drillstate = 'leaf'.
        ENDIF.
      ENDIF.

      APPEND ls_business_data TO result_data.

*      같은 GL계정을 사용하는 노드 구성
      IF ( ls_hier-parentnode = '05211' ).
        ls_business_data-parentnodeid = '05214'.
        ls_business_data-sortindex =  ls_business_data-parentnodeid + 1.
        APPEND ls_business_data TO result_data.
      ELSEIF ( ls_hier-parentnode = '05221' ).
        ls_business_data-parentnodeid = '05225'.
        ls_business_data-sortindex = ls_business_data-parentnodeid + 1.
        APPEND ls_business_data TO result_data.
      ENDIF.

    ENDLOOP.
**********************************************************************
*** 노드 구성 ***
**********************************************************************
    LOOP AT lt_glaccount INTO DATA(ls_glaccount).
*      READ TABLE business_data WITH KEY glaccount = ls_glaccount-glaccount ASSIGNING FIELD-SYMBOL(<fs_businessdata>).

      SELECT *
        FROM @result_data AS a
       WHERE glaccount = @ls_glaccount-glaccount
        INTO TABLE @DATA(lt_bd_glaccount).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

*      계산로직
      LOOP AT lt_bd_glaccount ASSIGNING FIELD-SYMBOL(<fs_businessdata>).
        <fs_businessdata>-companycodecurrency = ls_glaccount-companycodecurrency.
*       필드심볼 사용 : 값 바로 업데이트

**********************************************************************
*****5000
**********************************************************************
        IF <fs_businessdata>-parentnodeid+1(1) = '5'.
*         5100
          IF <fs_businessdata>-parentnodeid+2(1) = '1'.
*          5110 ~ 5150
            DATA(lv_51x0) = <fs_businessdata>-parentnodeid.
            IF ls_glaccount-fiscalperiod EQ iv_tomonth.
              READ TABLE result_data WITH KEY subject = lv_51x0+1(4) ASSIGNING FIELD-SYMBOL(<fs_51x0>).
              IF sy-subrc = 0.
                <fs_51x0>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.
*             5100 합산(매출액)
              READ TABLE result_data WITH KEY subject = '5100'  ASSIGNING FIELD-SYMBOL(<fs_subject_5100>).
              IF sy-subrc = 0.
                <fs_subject_5100>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
              ENDIF.
              <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
          ENDIF.

*         5200
          IF <fs_businessdata>-parentnodeid+2(1) = '2'.
            CASE <fs_businessdata>-parentnodeid.
*             node = 05211 : 기초상품재고액 (0월~from-1) (from=to)
              WHEN '05211'.
                IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE iv_tomonth - 1.
*                 5211 합산
                  READ TABLE result_data WITH KEY subject = '5211' ASSIGNING FIELD-SYMBOL(<fs_5211>).
                  IF sy-subrc = 0.
                    <fs_5211>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5210 합산(상품매출원가(수불))
                  READ TABLE result_data WITH KEY subject = '5210'  ASSIGNING FIELD-SYMBOL(<fs_5211_5210>).
                  IF sy-subrc = 0.
                    <fs_5211_5210>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.

*             node = 05214 : 기말상품재고액 (0월~to)
              WHEN '05214'.
                IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE iv_tomonth.
*                 5214 합산
                  READ TABLE result_data WITH KEY subject = '5214' ASSIGNING FIELD-SYMBOL(<fs_5214>).
                  IF sy-subrc = 0.
                    <fs_5214>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5210 합산(상품매출원가(수불))
                  READ TABLE result_data WITH KEY subject = '5210'  ASSIGNING FIELD-SYMBOL(<fs_5214_5210>).
                  IF sy-subrc = 0.
                    <fs_5214_5210>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.

*         5115
*             node = 05115 : 상품매출원가(재무)
              WHEN '05115'.
                IF ls_glaccount-fiscalperiod EQ iv_tomonth.
                  READ TABLE result_data WITH KEY subject = '5115' ASSIGNING FIELD-SYMBOL(<fs_5115>).
                  IF sy-subrc = 0.
                    <fs_5115>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5200 합산(매출원가)
                  READ TABLE result_data WITH KEY subject = '5200'  ASSIGNING FIELD-SYMBOL(<fs_5115_5200>).
                  IF sy-subrc = 0.
                    <fs_5115_5200>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.

*         5220
*             node = 05221 : 기초제품재고액 (0월~from-1) (from=to)
              WHEN '05221'.
                IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE iv_tomonth - 1.
*                 5221 합산
                  READ TABLE result_data WITH KEY subject = '5221' ASSIGNING FIELD-SYMBOL(<fs_5221>).
                  IF sy-subrc = 0.
                    <fs_5221>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.

*             node = 05225 : 기말제품재고액 (0월~to)
              WHEN '05225'.
                IF + ls_glaccount-fiscalperiod GE 000 AND + ls_glaccount-fiscalperiod LE iv_tomonth.
*                 5225 합산
                  READ TABLE result_data WITH KEY subject = '5225' ASSIGNING FIELD-SYMBOL(<fs_5225>).
                  IF sy-subrc = 0.
                    <fs_5225>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5220 합산(제품매출원가(수불))
                  READ TABLE result_data WITH KEY subject = '5220'  ASSIGNING FIELD-SYMBOL(<fs_5225_5220>).
                  IF sy-subrc = 0.
                    <fs_5225_5220>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.

*         5226
*             node = 05226 : 제품매출원가(재무)
              WHEN '05226'.
                IF ls_glaccount-fiscalperiod EQ iv_tomonth.
                  READ TABLE result_data WITH KEY subject = '5226' ASSIGNING FIELD-SYMBOL(<fs_5226>).
                  IF sy-subrc = 0.
                    <fs_5226>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5200 합산(매출원가)
                  READ TABLE result_data WITH KEY subject = '5200'  ASSIGNING FIELD-SYMBOL(<fs_5226_5200>).
                  IF sy-subrc = 0.
                    <fs_5226_5200>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
*         5230
*             node = 05230 : 용역매출원가
              WHEN '05230'.
                IF ls_glaccount-fiscalperiod EQ iv_tomonth.
                  READ TABLE result_data WITH KEY subject = '5230' ASSIGNING FIELD-SYMBOL(<fs_5230>).
                  IF sy-subrc = 0.
                    <fs_5230>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5200 합산(매출원가)
                  READ TABLE result_data WITH KEY subject = '5200'  ASSIGNING FIELD-SYMBOL(<fs_5230_5200>).
                  IF sy-subrc = 0.
                    <fs_5230_5200>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.

*         5240
*             node = 05240 : 상품매출원가(재무)
              WHEN '05240'.
                IF ls_glaccount-fiscalperiod EQ iv_tomonth.
                  READ TABLE result_data WITH KEY subject = '5240' ASSIGNING FIELD-SYMBOL(<fs_5240>).
                  IF sy-subrc = 0.
                    <fs_5240>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5200 합산(매출원가)
                  READ TABLE result_data WITH KEY subject = '5200'  ASSIGNING FIELD-SYMBOL(<fs_5240_5200>).
                  IF sy-subrc = 0.
                    <fs_5240_5200>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.

*         5250
*             node = 05250 : 상품매출원가(재무)
              WHEN '05250'.
                IF ls_glaccount-fiscalperiod EQ iv_tomonth.
                  READ TABLE result_data WITH KEY subject = '5250' ASSIGNING FIELD-SYMBOL(<fs_5250>).
                  IF sy-subrc = 0.
                    <fs_5250>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
*                 5200 합산(매출원가)
                  READ TABLE result_data WITH KEY subject = '5200'  ASSIGNING FIELD-SYMBOL(<fs_5250_5200>).
                  IF sy-subrc = 0.
                    <fs_5250_5200>-amountincompanycodecurrency -= ls_glaccount-amountincompanycodecurrency.
                  ENDIF.
                  <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
                ENDIF.
            ENDCASE.
          ENDIF.
        ENDIF.

**********************************************************************
*****6000
**********************************************************************
        IF <fs_businessdata>-parentnodeid+1(1) = '6'.
          DATA(lv_61x0) = <fs_businessdata>-parentnodeid.

          IF ls_glaccount-fiscalperiod EQ iv_tomonth.
            READ TABLE result_data WITH KEY subject = lv_61x0+1(4) ASSIGNING FIELD-SYMBOL(<fs_61x0>).
            IF sy-subrc = 0.
              <fs_61x0>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
*             6000 합산(판매비와관리비)
            READ TABLE result_data WITH KEY subject = '6000'  ASSIGNING FIELD-SYMBOL(<fs_subject_6000>).
            IF sy-subrc = 0.
              <fs_subject_6000>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
          ENDIF.
        ENDIF.

**********************************************************************
*****7000
**********************************************************************
        IF <fs_businessdata>-parentnodeid+1(1) = '8' OR <fs_businessdata>-parentnodeid+1(1) = '9'.
          IF ls_glaccount-fiscalperiod EQ iv_tomonth.
            DATA : lv_parentnode TYPE c LENGTH 4,
                   lv_subject    TYPE c LENGTH 4.
            CLEAR : lv_parentnode, lv_subject.

            CASE <fs_businessdata>-parentnodeid.
              WHEN '08100'.
*               8100 합산(기타수익)
                lv_parentnode = '8000'.
                lv_subject = '8100'.
              WHEN '08200'.
*               8100 합산(기타비용)
                lv_parentnode = '8000'.
                lv_subject = '8200'.
              WHEN '09100'.
*               9100 합산(금융수익)
                lv_parentnode = '9000'.
                lv_subject = '9100'.
              WHEN '09200'.
*               9200 합산(금융비용)
                lv_parentnode = '9000'.
                lv_subject = '9200'.
            ENDCASE.

*           7000 합산(영업외손익)
            READ TABLE result_data WITH KEY subject = '7000'  ASSIGNING FIELD-SYMBOL(<fs_7000>).
            IF sy-subrc = 0.
              <fs_7000>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.

*           상위노드 합산(8000:기타손익, 9000:금융손익)
            READ TABLE result_data WITH KEY subject = lv_parentnode  ASSIGNING FIELD-SYMBOL(<fs_parentnode>).
            IF sy-subrc = 0.
              <fs_parentnode>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.

*           노드개별합산
            READ TABLE result_data WITH KEY subject = lv_subject  ASSIGNING FIELD-SYMBOL(<fs_subject>).
            IF sy-subrc = 0.
              <fs_subject>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
          ENDIF.
        ENDIF.

**********************************************************************
*****10000
**********************************************************************
        IF <fs_businessdata>-parentnodeid = '010000'.
*         10000 합산(법인세비용)
          IF ls_glaccount-fiscalperiod EQ iv_tomonth.
            READ TABLE result_data WITH KEY subject = '10000'  ASSIGNING FIELD-SYMBOL(<fs_10000>).
            IF sy-subrc = 0.
              <fs_10000>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_glaccount-amountincompanycodecurrency.
          ENDIF.
        ENDIF.

        READ TABLE result_data
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
      CASE ls_transmat-materialvaluationclass.
        WHEN '3100'.
*       5212 합산(타입)
          IF ls_transmat-materialledgercategory EQ 'ZU' AND ls_transmat-processcategory EQ 'B+'.
            READ TABLE result_data WITH KEY subject = '5212' ASSIGNING FIELD-SYMBOL(<fs_t_5212>).
            IF sy-subrc = 0.
              <fs_t_5212>-amountincompanycodecurrency += ls_transmat-processcategory.
            ENDIF.
*           5210 합산(상품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5210'  ASSIGNING FIELD-SYMBOL(<fs_t_5212_5210>).
            IF sy-subrc = 0.
              <fs_t_5212_5210>-amountincompanycodecurrency += ls_transmat-processcategory.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_transmat-processcategory.

*         5213 합산(타출)
          ELSEIF ls_transmat-materialledgercategory EQ 'VN' AND ls_transmat-processcategory EQ 'VK'.
            READ TABLE result_data WITH KEY subject = '5213' ASSIGNING FIELD-SYMBOL(<fs_t_5213>).
            IF sy-subrc = 0.
              <fs_t_5213>-amountincompanycodecurrency += ls_transmat-processcategory.
            ENDIF.
*           5210 합산(상품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5210'  ASSIGNING FIELD-SYMBOL(<fs_t_5213_5210>).
            IF sy-subrc = 0.
              <fs_t_5213_5210>-amountincompanycodecurrency -= ls_transmat-processcategory.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
          ENDIF.
        WHEN '7920'.
*       5222 합산(당기)
          IF ls_transmat-materialledgercategory EQ 'ZU' AND ls_transmat-processcategory EQ 'BF'.
            READ TABLE result_data WITH KEY subject = '5222' ASSIGNING FIELD-SYMBOL(<fs_t_5222>).
            IF sy-subrc = 0.
              <fs_t_5222>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
*           5220 합산(제품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5220'  ASSIGNING FIELD-SYMBOL(<fs_t_5222_5220>).
            IF sy-subrc = 0.
              <fs_t_5222_5220>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.

          ELSEIF ls_transmat-materialledgercategory EQ 'ZU' AND ls_transmat-processcategory EQ 'B+'.
*         5223 합산(타입)
            READ TABLE result_data WITH KEY subject = '5223' ASSIGNING FIELD-SYMBOL(<fs_t_5223>).
            IF sy-subrc = 0.
              <fs_t_5223>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
*           5220 합산(제품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5220'  ASSIGNING FIELD-SYMBOL(<fs_t_5223_5220>).
            IF sy-subrc = 0.
              <fs_t_5223_5220>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.


*         5224 합산(타출)
          ELSEIF ls_transmat-materialledgercategory EQ 'VN' AND ls_transmat-processcategory EQ 'VK'.
            READ TABLE result_data WITH KEY subject = '5224' ASSIGNING FIELD-SYMBOL(<fs_t_5224>).
            IF sy-subrc = 0.
              <fs_t_5224>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
*           5220 합산(제품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5220'  ASSIGNING FIELD-SYMBOL(<fs_t_5224_5220>).
            IF sy-subrc = 0.
              <fs_t_5224_5220>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_transmat-inventoryamtindspcrcy.

          ENDIF.
      ENDCASE.
    ENDLOOP.


    LOOP AT lt_actlcost INTO DATA(ls_actlcost).
      CASE ls_actlcost-materialvaluationclass.
        WHEN '3100'.
*         5212 합산(타입)
          IF ls_actlcost-materialledgercategory EQ 'ZU' AND ls_actlcost-processcategory EQ 'B+'.
            READ TABLE result_data WITH KEY subject = '5212' ASSIGNING FIELD-SYMBOL(<fs_a_5212>).
            IF sy-subrc = 0.
              <fs_a_5212>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           5210 합산(상품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5210'  ASSIGNING FIELD-SYMBOL(<fs_a_5212_5210>).
            IF sy-subrc = 0.
              <fs_a_5212_5210>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.

*         5213 합산(타출)
          ELSEIF ls_actlcost-materialledgercategory EQ 'VN' AND ls_actlcost-processcategory EQ 'VK'.
            READ TABLE result_data WITH KEY subject = '5213' ASSIGNING FIELD-SYMBOL(<fs_a_5213>).
            IF sy-subrc = 0.
              <fs_a_5213>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           5210 합산(상품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5210'  ASSIGNING FIELD-SYMBOL(<fs_a_5213_5210>).
            IF sy-subrc = 0.
              <fs_a_5213_5210>-amountincompanycodecurrency -= ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
          ENDIF.
        WHEN '7920'.
*         5222 합산(당기)
          IF ls_actlcost-materialledgercategory EQ 'ZU' AND ls_actlcost-processcategory EQ 'BF'.
            READ TABLE result_data WITH KEY subject = '5222' ASSIGNING FIELD-SYMBOL(<fs_a_5222>).
            IF sy-subrc = 0.
              <fs_a_5222>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           5220 합산(제품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5220'  ASSIGNING FIELD-SYMBOL(<fs_a_5222_5220>).
            IF sy-subrc = 0.
              <fs_a_5222_5220>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.

          ELSEIF ls_actlcost-materialledgercategory EQ 'ZU' AND ls_actlcost-processcategory EQ 'B+'.
*         5223 합산(타입)
            READ TABLE result_data WITH KEY subject = '5223' ASSIGNING FIELD-SYMBOL(<fs_a_5223>).
            IF sy-subrc = 0.
              <fs_a_5223>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           5220 합산(제품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5220'  ASSIGNING FIELD-SYMBOL(<fs_a_5223_5220>).
            IF sy-subrc = 0.
              <fs_a_5223_5220>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.


*         5224 합산(타출)
          ELSEIF ls_actlcost-materialledgercategory EQ 'VN' AND ls_actlcost-processcategory EQ 'VK'.
            READ TABLE result_data WITH KEY subject = '5224' ASSIGNING FIELD-SYMBOL(<fs_a_5224>).
            IF sy-subrc = 0.
              <fs_a_5224>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
*           5220 합산(제품매출원가(수불))
            READ TABLE result_data WITH KEY subject = '5220'  ASSIGNING FIELD-SYMBOL(<fs_a_5224_5220>).
            IF sy-subrc = 0.
              <fs_a_5224_5220>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.
            ENDIF.
            <fs_businessdata>-amountincompanycodecurrency += ls_actlcost-inventoryamtindspcrcy.

          ENDIF.
      ENDCASE.
    ENDLOOP.

**********************************************************************
***합산
**********************************************************************

    SELECT subject
          ,amountincompanycodecurrency
      FROM @result_data AS a
     WHERE subject = '5100'
        OR subject = '5200'
        OR subject = '6000'
        OR subject = '7000'
        OR subject = '10000'
     INTO TABLE @DATA(lt_total).

    READ TABLE result_data WITH KEY subject = '2000' ASSIGNING FIELD-SYMBOL(<fs_2000>).
    READ TABLE result_data WITH KEY subject = '3000' ASSIGNING FIELD-SYMBOL(<fs_3000>).
    READ TABLE result_data WITH KEY subject = '4000' ASSIGNING FIELD-SYMBOL(<fs_4000>).
    READ TABLE result_data WITH KEY subject = '5000' ASSIGNING FIELD-SYMBOL(<fs_5000>).

    LOOP AT lt_total INTO DATA(ls_total).
      CASE ls_total-subject.
        WHEN '5100'.
          <fs_5000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_4000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_3000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_2000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
        WHEN '5200'.
          <fs_5000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_4000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_3000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_2000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
        WHEN '6000'.
          <fs_4000>-amountincompanycodecurrency -= ls_total-amountincompanycodecurrency.
          <fs_3000>-amountincompanycodecurrency -= ls_total-amountincompanycodecurrency.
          <fs_2000>-amountincompanycodecurrency -= ls_total-amountincompanycodecurrency.
        WHEN '7000'.
          <fs_3000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
          <fs_2000>-amountincompanycodecurrency += ls_total-amountincompanycodecurrency.
        WHEN '10000'.
          <fs_2000>-amountincompanycodecurrency -= ls_total-amountincompanycodecurrency.
      ENDCASE.
    ENDLOOP.

    INSERT ztgsco0090 FROM TABLE @result_data.

  ENDMETHOD.
ENDCLASS.
