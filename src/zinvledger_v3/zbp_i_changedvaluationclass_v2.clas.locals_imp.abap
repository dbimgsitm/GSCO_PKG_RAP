CLASS lhc_changedvc2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR changedvc2 RESULT result.

    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR changedvc2~beforesave.

ENDCLASS.

CLASS lhc_changedvc2 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD beforesave.

    DATA : lv_error TYPE abap_boolean.
    CLEAR : lv_error.

    READ ENTITIES OF zi_changedvaluationclass_v2 IN LOCAL MODE
    ENTITY changedvc2
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_changedvc2)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

*   날짜필드 유효성 체크
    SELECT validityenddate, validitystartdate
      FROM @lt_changedvc2 AS lt_check
    INTO TABLE @DATA(lt_checkdate).

    LOOP AT lt_checkdate INTO DATA(ls_checkdate).
*       뒤에서 3자리 01~12
      DATA : lv_endmonth TYPE n LENGTH 2,
             lv_stmonth  TYPE n LENGTH 2,
             lv_text TYPE string.
      CLEAR : lv_endmonth, lv_stmonth.

      lv_endmonth = ls_checkdate-validityenddate+4(2).
      lv_stmonth = ls_checkdate-validitystartdate+4(2).

*       효력종료기간 OR 효력시작기간
      IF lv_endmonth > 12 OR lv_endmonth < 1.
        lv_error = abap_true.
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %element-validityenddate = if_abap_behv=>mk-on
                        %msg = new_message(
                        id = 'ZMCGSFI0010'
                        number = '002'
                        severity = if_abap_behv_message=>severity-error )
                      ) TO reported-changedvc2.
      ENDIF.

      IF lv_stmonth > 12 OR lv_stmonth < 1.
        lv_error = abap_true.
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %element-validitystartdate = if_abap_behv=>mk-on
                        %msg = new_message(
                        id = 'ZMCGSFI0010'
                        number = '002'
                        severity = if_abap_behv_message=>severity-error )
                      ) TO reported-changedvc2.
      ENDIF.
    ENDLOOP.

*   중복값 체크
    SELECT companycode, plant, material, validityenddate
    FROM ztgsco0080 AS main
    WHERE EXISTS ( SELECT companycode, plant, material, validityenddate
                     FROM @lt_changedvc2 AS lt_checkdata
                    WHERE lt_checkdata~companycode = main~companycode
                      AND lt_checkdata~plant = main~plant
                      AND lt_checkdata~material = main~material
                      AND lt_checkdata~validityenddate = main~validityenddate
                    )
     AND delete_flag = ''
   INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      lv_error = abap_true.
*     exception
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %element-material = if_abap_behv=>mk-on
                        %msg = new_message(
                        id = 'ZMCGSFI0010'
                        number = '001'
                        v1 = ls_check-validityenddate
                        severity = if_abap_behv_message=>severity-error )
                      ) TO reported-changedvc2.
      ENDLOOP.

    ENDIF.

    IF lv_error = abap_true.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                         %fail-cause = if_abap_behv=>cause-conflict
                         id = ls_key-id
                       ) TO failed-changedvc2.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

CLASS lsc_zi_changedvaluationclass_v DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_changedvaluationclass_v IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0080  TYPE ztgsco0080,
           ls_ztgsco0080h TYPE ztgsco0080h.

**********************************************************************
* Create
**********************************************************************
    IF create-changedvc2 IS NOT INITIAL.
      LOOP AT create-changedvc2 REFERENCE INTO DATA(lr_c_changedvc2).
        ls_ztgsco0080 = VALUE #(  id = lr_c_changedvc2->id
                                  companycode = lr_c_changedvc2->companycode
                                  plant = lr_c_changedvc2->plant
                                  material = lr_c_changedvc2->material
                                  validityenddate = lr_c_changedvc2->validityenddate
                                  validitystartdate = lr_c_changedvc2->validitystartdate
                                  previousvaluationclass = lr_c_changedvc2->previousvaluationclass
                                  currentvaluationclass = lr_c_changedvc2->currentvaluationclass
                                  delete_flag = lr_c_changedvc2->deleteflag
                                  create_by = lr_c_changedvc2->createby
                                  create_at = lr_c_changedvc2->createat
                                  last_changed_by = lr_c_changedvc2->lastchangedby
                                  last_changed_at = lr_c_changedvc2->lastchangedat
                                ).
        INSERT INTO ztgsco0080 VALUES @ls_ztgsco0080.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0080h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_changedvc2->id
                                          action = 'C'
                                          companycode = lr_c_changedvc2->companycode
                                          plant = lr_c_changedvc2->plant
                                          material = lr_c_changedvc2->material
                                          validityenddate = lr_c_changedvc2->validityenddate
                                          validitystartdate = lr_c_changedvc2->validitystartdate
                                          previousvaluationclass = lr_c_changedvc2->previousvaluationclass
                                          currentvaluationclass = lr_c_changedvc2->currentvaluationclass
                                          delete_flag = lr_c_changedvc2->deleteflag
                                          create_by = lr_c_changedvc2->createby
                                          create_at = lr_c_changedvc2->createat
                                          last_changed_by = lr_c_changedvc2->lastchangedby
                                          last_changed_at = lr_c_changedvc2->lastchangedat
                                        ).
              INSERT INTO ztgsco0080h VALUES @ls_ztgsco0080h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-changedvc2 IS NOT INITIAL.
      SELECT *                                "#EC CI_ALL_FIELDS_NEEDED
        FROM ztgsco0080
        WHERE id IN ( SELECT id FROM @delete-changedvc2 AS zchangedvc2 )
        INTO TABLE @DATA(lr_r_changedvc2).

      LOOP AT delete-changedvc2 REFERENCE INTO DATA(lr_d_changedvc2).
        UPDATE ztgsco0080 SET delete_flag = 'X' WHERE id = @lr_d_changedvc2->id.
        READ TABLE lr_r_changedvc2 WITH KEY id = lr_d_changedvc2->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0080h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          companycode = lr_r_data-companycode
                                          plant = lr_r_data-plant
                                          material = lr_r_data-material
                                          validityenddate = lr_r_data-validityenddate
                                          validitystartdate = lr_r_data-validitystartdate
                                          previousvaluationclass = lr_r_data-previousvaluationclass
                                          currentvaluationclass = lr_r_data-currentvaluationclass
                                          delete_flag = lr_r_data-delete_flag
                                          create_by = lr_r_data-create_by
                                          create_at = lr_r_data-create_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0080h VALUES @ls_ztgsco0080h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-changedvc2 IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-changedvc2 REFERENCE INTO DATA(lr_u_changedvc2).
        "효력종료기간
        IF lr_u_changedvc2->%control-validityenddate = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0080 SET validityenddate = @lr_u_changedvc2->validityenddate WHERE id = @lr_u_changedvc2->id.
        ENDIF.

        "효력시작기간
        IF lr_u_changedvc2->%control-validitystartdate = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0080 SET validitystartdate = @lr_u_changedvc2->validitystartdate WHERE id = @lr_u_changedvc2->id.
        ENDIF.

        "이전평가클래스
        IF lr_u_changedvc2->%control-previousvaluationclass = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0080 SET previousvaluationclass = @lr_u_changedvc2->previousvaluationclass WHERE id = @lr_u_changedvc2->id.
        ENDIF.

        "현재평가클래스
        IF lr_u_changedvc2->%control-currentvaluationclass = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0080 SET currentvaluationclass = @lr_u_changedvc2->currentvaluationclass WHERE id = @lr_u_changedvc2->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0080h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_changedvc2->id
                                          action = 'U'
                                          companycode = lr_u_changedvc2->companycode
                                          plant = lr_u_changedvc2->plant
                                          material = lr_u_changedvc2->material
                                          validityenddate = lr_u_changedvc2->validityenddate
                                          validitystartdate = lr_u_changedvc2->validitystartdate
                                          previousvaluationclass = lr_u_changedvc2->previousvaluationclass
                                          currentvaluationclass = lr_u_changedvc2->currentvaluationclass
                                          delete_flag = lr_u_changedvc2->deleteflag
                                          create_by = lr_u_changedvc2->createby
                                          create_at = lr_u_changedvc2->createat
                                          last_changed_by = lr_u_changedvc2->lastchangedby
                                          last_changed_at = lr_u_changedvc2->lastchangedat
                                        ).
              INSERT INTO ztgsco0080h VALUES @ls_ztgsco0080h.

            CATCH cx_uuid_error INTO DATA(exc_u).
              DATA(excu) = exc_u.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
