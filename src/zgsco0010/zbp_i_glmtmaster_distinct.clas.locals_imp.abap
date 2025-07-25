CLASS lhc_glmtmaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR glmtmaster RESULT result.

ENDCLASS.

CLASS lhc_glmtmaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_glmtmaster_distinct DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_glmtmaster_distinct IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0040  TYPE ztgsco0040,
           ls_ztgsco0040h TYPE ztgsco0040h.

**********************************************************************
* Create
**********************************************************************
    IF create-glmtmaster IS NOT INITIAL.
      LOOP AT create-glmtmaster REFERENCE INTO DATA(lr_c_glmtmaster).
        ls_ztgsco0040 = VALUE #(  id = lr_c_glmtmaster->id
                                  materialvaluationclass = lr_c_glmtmaster->materialvaluationclass
                                  classname = lr_c_glmtmaster->classname
                                  glaccount = lr_c_glmtmaster->glaccount
                                  glaccountname = lr_c_glmtmaster->glaccountname
                                  delete_flag = lr_c_glmtmaster->delete_flag
                                  create_by = lr_c_glmtmaster->createby
                                  create_at = lr_c_glmtmaster->createat
                                  last_changed_by = lr_c_glmtmaster->lastchangedby
                                  last_changed_at = lr_c_glmtmaster->lastchangedat
                                ).
        INSERT INTO ztgsco0040 VALUES @ls_ztgsco0040.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0040h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_glmtmaster->id
                                          action = 'C'
                                          materialvaluationclass = lr_c_glmtmaster->materialvaluationclass
                                          classname = lr_c_glmtmaster->classname
                                          glaccount = lr_c_glmtmaster->glaccount
                                          glaccountname = lr_c_glmtmaster->glaccountname
                                          delete_flag = lr_c_glmtmaster->delete_flag
                                          create_by = lr_c_glmtmaster->createby
                                          create_at = lr_c_glmtmaster->createat
                                          last_changed_by = lr_c_glmtmaster->lastchangedby
                                          last_changed_at = lr_c_glmtmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0040h VALUES @ls_ztgsco0040h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-glmtmaster IS NOT INITIAL.
      SELECT *
        FROM ztgsco0040
        WHERE id IN ( SELECT id FROM @delete-glmtmaster AS zglmtmaster )
        INTO TABLE @DATA(lr_r_glmtmaster).

      LOOP AT delete-glmtmaster REFERENCE INTO DATA(lr_d_glmtmaster).
        UPDATE ztgsco0040 SET delete_flag = 'X' WHERE id = @lr_d_glmtmaster->id.
        READ TABLE lr_r_glmtmaster WITH KEY id = lr_d_glmtmaster->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0040h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
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
              INSERT INTO ztgsco0040h VALUES @ls_ztgsco0040h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-glmtmaster IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-glmtmaster REFERENCE INTO DATA(lr_u_glmtmaster).
        "평가클래스명
        IF lr_u_glmtmaster->%control-classname = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0040 SET classname = @lr_u_glmtmaster->classname WHERE id = @lr_u_glmtmaster->id.
        ENDIF.

        "GL
        IF lr_u_glmtmaster->%control-glaccount = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0040 SET glaccount = @lr_u_glmtmaster->glaccount WHERE id = @lr_u_glmtmaster->id.
        ENDIF.

        "GL명
        IF lr_u_glmtmaster->%control-glaccountname = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0040 SET glaccountname = @lr_u_glmtmaster->glaccountname WHERE id = @lr_u_glmtmaster->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0040h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_glmtmaster->id
                                          action = 'U'
                                          materialvaluationclass = lr_u_glmtmaster->materialvaluationclass
                                          classname = lr_u_glmtmaster->classname
                                          glaccount = lr_u_glmtmaster->glaccount
                                          glaccountname = lr_u_glmtmaster->glaccountname
                                          delete_flag = lr_u_glmtmaster->delete_flag
                                          create_by = lr_u_glmtmaster->createby
                                          create_at = lr_u_glmtmaster->createat
                                          last_changed_by = lr_u_glmtmaster->lastchangedby
                                          last_changed_at = lr_u_glmtmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0040h VALUES @ls_ztgsco0040h.

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
