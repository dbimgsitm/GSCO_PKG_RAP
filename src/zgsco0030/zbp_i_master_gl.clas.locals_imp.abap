CLASS lhc_mastergl DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR mastergl RESULT result.
    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR mastergl~beforesave.

ENDCLASS.

CLASS lhc_mastergl IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD beforesave.
    READ ENTITIES OF zi_master_gl IN LOCAL MODE
    ENTITY mastergl
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mastergl)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    SELECT materialvaluationclass
    FROM ztgsco0032
    WHERE materialvaluationclass IN ( SELECT materialvaluationclass
                                         FROM @lt_mastergl AS lt_checkgldata )
      AND delete_flag = ''
    INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                         %fail-cause = if_abap_behv=>cause-conflict
                         id = ls_key-id
                       ) TO failed-mastergl.
      ENDLOOP.

*     exception
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %msg = new_message(
                        id = 'ZMCGSFI0030'
                        number = '004'
                        v1 = ls_check-materialvaluationclass
                        severity = if_abap_behv_message=>severity-error )
                      ) TO reported-mastergl.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zi_master_gl DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

ENDCLASS.


CLASS lsc_zi_master_gl IMPLEMENTATION.

  METHOD save_modified.

    DATA : ls_ztgsco0032  TYPE ztgsco0032,
           ls_ztgsco0032h TYPE ztgsco0032h.

**********************************************************************
* Create
**********************************************************************
    IF create-mastergl IS NOT INITIAL.
      LOOP AT create-mastergl REFERENCE INTO DATA(lr_c_mastergl).
        ls_ztgsco0032 = VALUE #(  id = lr_c_mastergl->id
                                  companycode = lr_c_mastergl->companycode
                                  materialvaluationclass = lr_c_mastergl->materialvaluationclass
                                  classname = lr_c_mastergl->classname
                                  glaccount = lr_c_mastergl->glaccount
                                  glaccountname = lr_c_mastergl->glaccountname
                                  delete_flag = lr_c_mastergl->deleteflag
                                  create_by = lr_c_mastergl->createby
                                  create_at = lr_c_mastergl->createat
                                  last_changed_by = lr_c_mastergl->lastchangedby
                                  last_changed_at = lr_c_mastergl->lastchangedat
                                ).
        INSERT INTO ztgsco0032 VALUES @ls_ztgsco0032.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0032h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_mastergl->id
                                          action = 'C'
                                          companycode = lr_c_mastergl->companycode
                                          materialvaluationclass = lr_c_mastergl->materialvaluationclass
                                          classname = lr_c_mastergl->classname
                                          glaccount = lr_c_mastergl->glaccount
                                          glaccountname = lr_c_mastergl->glaccountname
                                          delete_flag = lr_c_mastergl->deleteflag
                                          create_by = lr_c_mastergl->createby
                                          create_at = lr_c_mastergl->createat
                                          last_changed_by = lr_c_mastergl->lastchangedby
                                          last_changed_at = lr_c_mastergl->lastchangedat
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
    IF delete-mastergl IS NOT INITIAL.
      SELECT *
        FROM ztgsco0032
        WHERE id IN ( SELECT id FROM @delete-mastergl AS zmastergl )
        INTO TABLE @DATA(lr_r_mastergl).

      LOOP AT delete-mastergl REFERENCE INTO DATA(lr_d_mastergl).
        UPDATE ztgsco0032 SET delete_flag = 'X' WHERE id = @lr_d_mastergl->id.
        READ TABLE lr_r_mastergl WITH KEY id = lr_d_mastergl->id INTO DATA(lr_r_data).
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
    IF update-mastergl IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-mastergl REFERENCE INTO DATA(lr_u_mastergl).
        "평가클래스명
        IF lr_u_mastergl->%control-classname = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0032 SET classname = @lr_u_mastergl->classname WHERE id = @lr_u_mastergl->id.
        ENDIF.

        "GL계정
        IF lr_u_mastergl->%control-glaccount = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0032 SET glaccount = @lr_u_mastergl->glaccount WHERE id = @lr_u_mastergl->id.
        ENDIF.

        "GL계정명
        IF lr_u_mastergl->%control-glaccountname = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0032 SET glaccountname = @lr_u_mastergl->glaccountname WHERE id = @lr_u_mastergl->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0032h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_mastergl->id
                                          action = 'U'
                                          companycode = lr_u_mastergl->companycode
                                          materialvaluationclass = lr_u_mastergl->materialvaluationclass
                                          classname = lr_u_mastergl->classname
                                          glaccount = lr_u_mastergl->glaccount
                                          glaccountname = lr_u_mastergl->glaccountname
                                          delete_flag = lr_u_mastergl->deleteflag
                                          create_by = lr_u_mastergl->createby
                                          create_at = lr_u_mastergl->createat
                                          last_changed_by = lr_u_mastergl->lastchangedby
                                          last_changed_at = lr_u_mastergl->lastchangedat
                                        ).
              INSERT INTO ztgsco0032h VALUES @ls_ztgsco0032h.

            CATCH cx_uuid_error INTO DATA(exc_u).
              DATA(excu) = exc_u.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
