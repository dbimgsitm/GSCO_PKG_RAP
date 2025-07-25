CLASS lhc_mastermt DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR mastermt RESULT result.
    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR mastermt~beforesave.
ENDCLASS.

CLASS lhc_mastermt IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD beforesave.
    READ ENTITIES OF zi_master_materialtype IN LOCAL MODE
    ENTITY mastermt
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mastermt)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    SELECT processcategory
    FROM ztgsco0031
    WHERE processcategory IN ( SELECT processcategory
                                         FROM @lt_mastermt AS lt_checkmtdata )
      AND delete_flag = ''
    INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                           %fail-cause = if_abap_behv=>cause-conflict
                           id = ls_key-id
                         ) TO failed-mastermt.
      ENDLOOP.

*     exception
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                         %msg = new_message(
                         id = 'ZMCGSFI0030'
                         number = '003'
                         v1 = ls_check-processcategory
                         severity = if_abap_behv_message=>severity-error )
                       ) TO reported-mastermt.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_master_materialtype DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_master_materialtype IMPLEMENTATION.

  METHOD save_modified.

    DATA : ls_ztgsco0031  TYPE ztgsco0031,
           ls_ztgsco0031h TYPE ztgsco0031h.

**********************************************************************
* Create
**********************************************************************
    IF create-mastermt IS NOT INITIAL.
      LOOP AT create-mastermt REFERENCE INTO DATA(lr_c_mastermt).
        ls_ztgsco0031 = VALUE #(  id = lr_c_mastermt->id
                                  materialledgerprocesstype = lr_c_mastermt->materialledgerprocesstype
                                  typetext = lr_c_mastermt->Typetext
                                  processcategory = lr_c_mastermt->processcategory
                                  categorytext = lr_c_mastermt->categorytext
                                  check_detailed = lr_c_mastermt->checkdetailed
                                  delete_flag = lr_c_mastermt->deleteflag
                                  create_by = lr_c_mastermt->createby
                                  create_at = lr_c_mastermt->createat
                                  last_changed_by = lr_c_mastermt->lastchangedby
                                  last_changed_at = lr_c_mastermt->lastchangedat
                                ).
        INSERT INTO ztgsco0031 VALUES @ls_ztgsco0031.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0031h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_mastermt->id
                                          action = 'C'
                                          materialledgerprocesstype = lr_c_mastermt->materialledgerprocesstype
                                          typetext = lr_c_mastermt->Typetext
                                          processcategory = lr_c_mastermt->processcategory
                                          categorytext = lr_c_mastermt->categorytext
                                          check_detailed = lr_c_mastermt->checkdetailed
                                          delete_flag = lr_c_mastermt->deleteflag
                                          create_by = lr_c_mastermt->createby
                                          create_at = lr_c_mastermt->createat
                                          last_changed_by = lr_c_mastermt->lastchangedby
                                          last_changed_at = lr_c_mastermt->lastchangedat
                                        ).
              INSERT INTO ztgsco0031h VALUES @ls_ztgsco0031h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-mastermt IS NOT INITIAL.
      SELECT *
        FROM ztgsco0031
        WHERE id IN ( SELECT id FROM @delete-mastermt AS zmastermt )
        INTO TABLE @DATA(lr_r_mastermt).

      LOOP AT delete-mastermt REFERENCE INTO DATA(lr_d_mastermt).
        UPDATE ztgsco0031 SET delete_flag = 'X' WHERE id = @lr_d_mastermt->id.
        READ TABLE lr_r_mastermt WITH KEY id = lr_d_mastermt->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0031h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          materialledgerprocesstype = lr_r_data-materialledgerprocesstype
                                          typetext = lr_r_data-typetext
                                          processcategory = lr_r_data-processcategory
                                          categorytext = lr_r_data-categorytext
                                          check_detailed = lr_r_data-check_detailed
                                          delete_flag = lr_r_data-delete_flag
                                          create_by = lr_r_data-create_by
                                          create_at = lr_r_data-create_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0031h VALUES @ls_ztgsco0031h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-mastermt IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-mastermt REFERENCE INTO DATA(lr_u_mastermt).
        "입출고타입
        IF lr_u_mastermt->%control-Materialledgerprocesstype = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0031 SET Materialledgerprocesstype = @lr_u_mastermt->Materialledgerprocesstype WHERE id = @lr_u_mastermt->id.
        ENDIF.
        "자재원장범주명
        IF lr_u_mastermt->%control-Typetext = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0031 SET Typetext = @lr_u_mastermt->Typetext WHERE id = @lr_u_mastermt->id.
        ENDIF.
        "자재원장범주
        IF lr_u_mastermt->%control-ProcessCategory = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0031 SET ProcessCategory = @lr_u_mastermt->ProcessCategory WHERE id = @lr_u_mastermt->id.
        ENDIF.
        "자재원장텍스트
        IF lr_u_mastermt->%control-categorytext = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0031 SET categorytext = @lr_u_mastermt->categorytext WHERE id = @lr_u_mastermt->id.
        ENDIF.
        "상세표시여부
        IF lr_u_mastermt->%control-CheckDetailed = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0031 SET check_detailed = @lr_u_mastermt->CheckDetailed WHERE id = @lr_u_mastermt->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0031h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_mastermt->id
                                          action = 'U'
                                          materialledgerprocesstype = lr_u_mastermt->materialledgerprocesstype
                                          typetext = lr_u_mastermt->Typetext
                                          processcategory = lr_u_mastermt->processcategory
                                          categorytext = lr_u_mastermt->categorytext
                                          check_detailed = lr_u_mastermt->checkdetailed
                                          delete_flag = lr_u_mastermt->deleteflag
                                          create_by = lr_u_mastermt->createby
                                          create_at = lr_u_mastermt->createat
                                          last_changed_by = lr_u_mastermt->lastchangedby
                                          last_changed_at = lr_u_mastermt->lastchangedat
                                        ).
              INSERT INTO ztgsco0031h VALUES @ls_ztgsco0031h.

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
