CLASS lhc_masterglv3v3 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR masterglv3 RESULT result.

    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR masterglv3~beforesave.

ENDCLASS.

CLASS lhc_masterglv3v3 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD beforesave.

    READ ENTITIES OF zi_mtmaster_gl_distinct IN LOCAL MODE
    ENTITY masterglv3
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_masterglv3)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    SELECT materialvaluationclass
    FROM ztgsco0032
    WHERE materialvaluationclass IN ( SELECT materialvaluationclass
                                         FROM @lt_masterglv3 AS lt_checkgldata )
      AND delete_flag = ''
    INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                         %fail-cause = if_abap_behv=>cause-conflict
                         id = ls_key-id
                       ) TO failed-masterglv3.
      ENDLOOP.

*     exception
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %msg = new_message(
                        id = 'ZMCGSFI0030'
                        number = '004'
                        v1 = ls_check-materialvaluationclass
                        severity = if_abap_behv_message=>severity-error )
                      ) TO reported-masterglv3.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_mtmaster_gl_distinct DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_mtmaster_gl_distinct IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0032  TYPE ztgsco0032,
           ls_ztgsco0032h TYPE ztgsco0032h.

**********************************************************************
* Create
**********************************************************************
    IF create-masterglv3 IS NOT INITIAL.
      LOOP AT create-masterglv3 REFERENCE INTO DATA(lr_c_masterglv3).
        ls_ztgsco0032 = VALUE #(  id = lr_c_masterglv3->id
                                  companycode = lr_c_masterglv3->companycode
                                  materialvaluationclass = lr_c_masterglv3->materialvaluationclass
                                  classname = lr_c_masterglv3->classname
                                  glaccount = lr_c_masterglv3->glaccount
                                  glaccountname = lr_c_masterglv3->glaccountname
                                  delete_flag = lr_c_masterglv3->delete_flag
                                  create_by = lr_c_masterglv3->createby
                                  create_at = lr_c_masterglv3->createat
                                  last_changed_by = lr_c_masterglv3->lastchangedby
                                  last_changed_at = lr_c_masterglv3->lastchangedat
                                ).
        INSERT INTO ztgsco0032 VALUES @ls_ztgsco0032.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0032h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_masterglv3->id
                                          action = 'C'
                                          companycode = lr_c_masterglv3->companycode
                                          materialvaluationclass = lr_c_masterglv3->materialvaluationclass
                                          classname = lr_c_masterglv3->classname
                                          glaccount = lr_c_masterglv3->glaccount
                                          glaccountname = lr_c_masterglv3->glaccountname
                                          delete_flag = lr_c_masterglv3->delete_flag
                                          create_by = lr_c_masterglv3->createby
                                          create_at = lr_c_masterglv3->createat
                                          last_changed_by = lr_c_masterglv3->lastchangedby
                                          last_changed_at = lr_c_masterglv3->lastchangedat
                                        ).
              INSERT INTO ztgsco0032h VALUES @ls_ztgsco0032h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-masterglv3 IS NOT INITIAL.
      SELECT *
        FROM ztgsco0032
        WHERE id IN ( SELECT id FROM @delete-masterglv3 AS zmasterglv3 )
        INTO TABLE @DATA(lr_r_masterglv3).

      LOOP AT delete-masterglv3 REFERENCE INTO DATA(lr_d_masterglv3).
        UPDATE ztgsco0032 SET delete_flag = 'X' WHERE id = @lr_d_masterglv3->id.
        READ TABLE lr_r_masterglv3 WITH KEY id = lr_d_masterglv3->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0032h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          companycode = lr_r_data-companycode
                                          materialvaluationclass = lr_r_data-materialvaluationclass
                                          classname = lr_r_data-classname
                                          glaccount = lr_r_data-glaccount
                                          glaccountname = lr_r_data-glaccountname
                                          delete_flag = lr_r_data-delete_flag
                                          create_by = lr_r_data-create_by
                                          create_at = lr_r_data-create_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0032h VALUES @ls_ztgsco0032h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-masterglv3 IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-masterglv3 REFERENCE INTO DATA(lr_u_masterglv3).
        "평가클래스명
        IF lr_u_masterglv3->%control-classname = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0032 SET classname = @lr_u_masterglv3->classname WHERE id = @lr_u_masterglv3->id.
        ENDIF.

        "GL계정
        IF lr_u_masterglv3->%control-glaccount = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0032 SET glaccount = @lr_u_masterglv3->glaccount WHERE id = @lr_u_masterglv3->id.
        ENDIF.

        "GL계정명
        IF lr_u_masterglv3->%control-glaccountname = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0032 SET glaccountname = @lr_u_masterglv3->glaccountname WHERE id = @lr_u_masterglv3->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0032h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_masterglv3->id
                                          action = 'U'
                                          companycode = lr_u_masterglv3->companycode
                                          materialvaluationclass = lr_u_masterglv3->materialvaluationclass
                                          classname = lr_u_masterglv3->classname
                                          glaccount = lr_u_masterglv3->glaccount
                                          glaccountname = lr_u_masterglv3->glaccountname
                                          delete_flag = lr_u_masterglv3->delete_flag
                                          create_by = lr_u_masterglv3->createby
                                          create_at = lr_u_masterglv3->createat
                                          last_changed_by = lr_u_masterglv3->lastchangedby
                                          last_changed_at = lr_u_masterglv3->lastchangedat
                                        ).
              INSERT INTO ztgsco0032h VALUES @ls_ztgsco0032h.

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
