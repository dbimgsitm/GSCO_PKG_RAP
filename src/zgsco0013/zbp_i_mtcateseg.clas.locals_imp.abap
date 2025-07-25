CLASS lhc_mtcateseg DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR mtcateseg RESULT result.

ENDCLASS.

CLASS lhc_mtcateseg IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_mtcateseg DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_mtcateseg IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0050  TYPE ztgsco0050,
           ls_ztgsco0050h TYPE ztgsco0050h.

**********************************************************************
* Create
**********************************************************************
    IF create-mtcateseg IS NOT INITIAL.
      LOOP AT create-mtcateseg REFERENCE INTO DATA(lr_c_mtcateseg).
        ls_ztgsco0050 = VALUE #(  id = lr_c_mtcateseg->id
                                  sequence = lr_c_mtcateseg->sequence
                                  materialledgercategory = lr_c_mtcateseg->materialledgercategory
                                  materialledgercategorytext = lr_c_mtcateseg->materialledgercategorytext
                                  delete_flag = lr_c_mtcateseg->deleteflag
                                  create_by = lr_c_mtcateseg->createby
                                  create_at = lr_c_mtcateseg->createat
                                  last_changed_by = lr_c_mtcateseg->lastchangedby
                                  last_changed_at = lr_c_mtcateseg->lastchangedat
                                ).
        INSERT INTO ztgsco0050 VALUES @ls_ztgsco0050.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0050h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_mtcateseg->id
                                          action = 'C'
                                          sequence = lr_c_mtcateseg->sequence
                                          materialledgercategory = lr_c_mtcateseg->materialledgercategory
                                          materialledgercategorytext = lr_c_mtcateseg->materialledgercategorytext
                                          delete_flag = lr_c_mtcateseg->deleteflag
                                          create_by = lr_c_mtcateseg->createby
                                          create_at = lr_c_mtcateseg->createat
                                          last_changed_by = lr_c_mtcateseg->lastchangedby
                                          last_changed_at = lr_c_mtcateseg->lastchangedat
                                        ).
              INSERT INTO ztgsco0050h VALUES @ls_ztgsco0050h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-mtcateseg IS NOT INITIAL.
      SELECT *
        FROM ztgsco0050
        WHERE id IN ( SELECT id FROM @delete-mtcateseg AS zmtcateseg )
        INTO TABLE @DATA(lr_r_mtcateseg).

      LOOP AT delete-mtcateseg REFERENCE INTO DATA(lr_d_mtcateseg).
        UPDATE ztgsco0050 SET delete_flag = 'X' WHERE id = @lr_d_mtcateseg->id.
        READ TABLE lr_r_mtcateseg WITH KEY id = lr_d_mtcateseg->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0050h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          sequence = lr_r_data-sequence
                                          materialledgercategory = lr_r_data-materialledgercategory
                                          materialledgercategorytext = lr_r_data-materialledgercategorytext
                                          delete_flag = lr_r_data-delete_flag
                                          create_by = lr_r_data-create_by
                                          create_at = lr_r_data-create_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0050h VALUES @ls_ztgsco0050h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-mtcateseg IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-mtcateseg REFERENCE INTO DATA(lr_u_mtcateseg).
        "순번
        IF lr_u_mtcateseg->%control-sequence = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0050 SET sequence = @lr_u_mtcateseg->sequence WHERE id = @lr_u_mtcateseg->id.
        ENDIF.

        "자재원장
        IF lr_u_mtcateseg->%control-materialledgercategory = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0050 SET materialledgercategory = @lr_u_mtcateseg->materialledgercategory WHERE id = @lr_u_mtcateseg->id.
        ENDIF.

        "자재원장텍스트
        IF lr_u_mtcateseg->%control-materialledgercategorytext = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0050 SET materialledgercategorytext = @lr_u_mtcateseg->materialledgercategorytext WHERE id = @lr_u_mtcateseg->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0050h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_mtcateseg->id
                                          action = 'U'
                                          sequence = lr_u_mtcateseg->sequence
                                          materialledgercategory = lr_u_mtcateseg->materialledgercategory
                                          materialledgercategorytext = lr_u_mtcateseg->materialledgercategorytext
                                          delete_flag = lr_u_mtcateseg->deleteflag
                                          create_by = lr_u_mtcateseg->createby
                                          create_at = lr_u_mtcateseg->createat
                                          last_changed_by = lr_u_mtcateseg->lastchangedby
                                          last_changed_at = lr_u_mtcateseg->lastchangedat
                                        ).
              INSERT INTO ztgsco0050h VALUES @ls_ztgsco0050h.

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
