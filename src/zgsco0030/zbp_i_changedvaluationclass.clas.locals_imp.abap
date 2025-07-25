CLASS lhc_changedvc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR changedvc RESULT result.
    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR changedvc~beforesave.

ENDCLASS.

CLASS lhc_changedvc IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD beforesave.

    DATA : lv_error TYPE abap_boolean.
    CLEAR : lv_error.

    READ ENTITIES OF zi_changedvaluationclass IN LOCAL MODE
    ENTITY changedvc
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_changedvc)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

*   날짜필드 유효성 체크
    SELECT validityenddate, validitystartdate
      FROM @lt_changedvc AS lt_check
    INTO TABLE @DATA(lt_checkdate).

    LOOP AT lt_checkdate INTO DATA(ls_checkdate).
*       뒤에서 3자리 01~12
      DATA : lv_endmonth TYPE n LENGTH 2,
             lv_stmonth  TYPE n LENGTH 2.
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
                      ) TO reported-changedvc.
      ENDIF.

      IF lv_stmonth > 12 OR lv_stmonth < 1.
        lv_error = abap_true.
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                            %element-validitystartdate = if_abap_behv=>mk-on
                            %msg = new_message(
                            id = 'ZMCGSFI0010'
                            number = '002'
                            severity = if_abap_behv_message=>severity-error )
                          ) TO reported-changedvc.
      ENDIF.
    ENDLOOP.

*   중복값 체크
    SELECT companycode, plant, material, validityenddate
    FROM ztgsco0070 AS main
    WHERE EXISTS ( SELECT companycode, plant, material, validityenddate
                     FROM @lt_changedvc AS lt_checkdata
                    WHERE lt_checkdata~companycode = main~companycode
                      AND lt_checkdata~plant = main~plant
                      AND lt_checkdata~material = main~material
                    )
     AND delete_flag = ''
   INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      lv_error = abap_true.
*     exception
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %msg = new_message(
                        id = 'ZMCGSFI0030'
                        number = '005'
                        v1 = ls_check-material
                        severity = if_abap_behv_message=>severity-error )
                      ) TO reported-changedvc.
      ENDLOOP.
    ENDIF.

    IF lv_error = abap_true.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                         %fail-cause = if_abap_behv=>cause-conflict
                         id = ls_key-id
                       ) TO failed-changedvc.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_changedvaluationclass DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_changedvaluationclass IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0070  TYPE ztgsco0070,
           ls_ztgsco0070h TYPE ztgsco0070h.

**********************************************************************
* Create
**********************************************************************
    IF create-changedvc IS NOT INITIAL.
      LOOP AT create-changedvc REFERENCE INTO DATA(lr_c_changedvc).
        ls_ztgsco0070 = VALUE #(  id = lr_c_changedvc->id
                                  companycode = lr_c_changedvc->companycode
                                  plant = lr_c_changedvc->plant
                                  material = lr_c_changedvc->material
                                  validityenddate = lr_c_changedvc->validityenddate
                                  validitystartdate = lr_c_changedvc->validitystartdate
                                  previousvaluationclass = lr_c_changedvc->previousvaluationclass
                                  currentvaluationclass = lr_c_changedvc->currentvaluationclass
                                  delete_flag = lr_c_changedvc->deleteflag
                                  create_by = lr_c_changedvc->createby
                                  create_at = lr_c_changedvc->createat
                                  last_changed_by = lr_c_changedvc->lastchangedby
                                  last_changed_at = lr_c_changedvc->lastchangedat
                                ).
        INSERT INTO ztgsco0070 VALUES @ls_ztgsco0070.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0070h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_changedvc->id
                                          action = 'C'
                                          companycode = lr_c_changedvc->companycode
                                          plant = lr_c_changedvc->plant
                                          material = lr_c_changedvc->material
                                          validityenddate = lr_c_changedvc->validityenddate
                                          validitystartdate = lr_c_changedvc->validitystartdate
                                          previousvaluationclass = lr_c_changedvc->previousvaluationclass
                                          currentvaluationclass = lr_c_changedvc->currentvaluationclass
                                          delete_flag = lr_c_changedvc->deleteflag
                                          create_by = lr_c_changedvc->createby
                                          create_at = lr_c_changedvc->createat
                                          last_changed_by = lr_c_changedvc->lastchangedby
                                          last_changed_at = lr_c_changedvc->lastchangedat
                                        ).
              INSERT INTO ztgsco0070h VALUES @ls_ztgsco0070h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-changedvc IS NOT INITIAL.
      SELECT *                                "#EC CI_ALL_FIELDS_NEEDED
        FROM ztgsco0070
        WHERE id IN ( SELECT id FROM @delete-changedvc AS zchangedvc )
        INTO TABLE @DATA(lr_r_changedvc).

      LOOP AT delete-changedvc REFERENCE INTO DATA(lr_d_changedvc).
        UPDATE ztgsco0070 SET delete_flag = 'X' WHERE id = @lr_d_changedvc->id.
        READ TABLE lr_r_changedvc WITH KEY id = lr_d_changedvc->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0070h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
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
              INSERT INTO ztgsco0070h VALUES @ls_ztgsco0070h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-changedvc IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-changedvc REFERENCE INTO DATA(lr_u_changedvc).
        "효력종료기간
        IF lr_u_changedvc->%control-validityenddate = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0070 SET validityenddate = @lr_u_changedvc->validityenddate WHERE id = @lr_u_changedvc->id.
        ENDIF.

        "효력시작기간
        IF lr_u_changedvc->%control-validitystartdate = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0070 SET validitystartdate = @lr_u_changedvc->validitystartdate WHERE id = @lr_u_changedvc->id.
        ENDIF.

        "이전평가클래스
        IF lr_u_changedvc->%control-previousvaluationclass = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0070 SET previousvaluationclass = @lr_u_changedvc->previousvaluationclass WHERE id = @lr_u_changedvc->id.
        ENDIF.

        "현재평가클래스
        IF lr_u_changedvc->%control-currentvaluationclass = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0070 SET currentvaluationclass = @lr_u_changedvc->currentvaluationclass WHERE id = @lr_u_changedvc->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0070h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_changedvc->id
                                          action = 'U'
                                          companycode = lr_u_changedvc->companycode
                                          plant = lr_u_changedvc->plant
                                          material = lr_u_changedvc->material
                                          validityenddate = lr_u_changedvc->validityenddate
                                          validitystartdate = lr_u_changedvc->validitystartdate
                                          previousvaluationclass = lr_u_changedvc->previousvaluationclass
                                          currentvaluationclass = lr_u_changedvc->currentvaluationclass
                                          delete_flag = lr_u_changedvc->deleteflag
                                          create_by = lr_u_changedvc->createby
                                          create_at = lr_u_changedvc->createat
                                          last_changed_by = lr_u_changedvc->lastchangedby
                                          last_changed_at = lr_u_changedvc->lastchangedat
                                        ).
              INSERT INTO ztgsco0070h VALUES @ls_ztgsco0070h.

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
