CLASS lhc_mastermtc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR mastermtc RESULT result.

ENDCLASS.

CLASS lhc_mastermtc IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_master_mtclass DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_master_mtclass IMPLEMENTATION.

  METHOD save_modified.

    DATA : ls_ztgsco0060  TYPE ztgsco0060,
           ls_ztgsco0060h TYPE ztgsco0060h.

**********************************************************************
* Create
**********************************************************************
    IF create-mastermtc IS NOT INITIAL.
      LOOP AT create-mastermtc REFERENCE INTO DATA(lr_c_mastermtc).
        ls_ztgsco0060 = VALUE #(  id = lr_c_mastermtc->id
                                  materialclass = lr_c_mastermtc->materialclass
                                  materialtype = lr_c_mastermtc->materialtype
                                  account = lr_c_mastermtc->account
                                  delete_flag = lr_c_mastermtc->delete_flag
                                  create_by = lr_c_mastermtc->createby
                                  create_at = lr_c_mastermtc->createat
                                  last_changed_by = lr_c_mastermtc->lastchangedby
                                  last_changed_at = lr_c_mastermtc->lastchangedat
                                ).
        INSERT INTO ztgsco0060 VALUES @ls_ztgsco0060.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0060h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_mastermtc->id
                                          action = 'C'
                                          materialclass = lr_c_mastermtc->materialclass
                                          materialtype = lr_c_mastermtc->materialtype
                                          account = lr_c_mastermtc->account
                                          delete_flag = lr_c_mastermtc->delete_flag
                                          create_by = lr_c_mastermtc->createby
                                          create_at = lr_c_mastermtc->createat
                                          last_changed_by = lr_c_mastermtc->lastchangedby
                                          last_changed_at = lr_c_mastermtc->lastchangedat
                                        ).
              INSERT INTO ztgsco0060h VALUES @ls_ztgsco0060h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-mastermtc IS NOT INITIAL.
      SELECT *
        FROM ztgsco0060
        WHERE id IN ( SELECT id FROM @delete-mastermtc AS zmastermtc )
        INTO TABLE @DATA(lr_r_mastermtc).

      LOOP AT delete-mastermtc REFERENCE INTO DATA(lr_d_mastermtc).
        UPDATE ztgsco0060 SET delete_flag = 'X' WHERE id = @lr_d_mastermtc->id.
        READ TABLE lr_r_mastermtc WITH KEY id = lr_d_mastermtc->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0060h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          materialclass = lr_r_data-materialclass
                                          materialtype = lr_r_data-materialtype
                                          account = lr_r_data-account
                                          delete_flag = lr_r_data-delete_flag
                                          create_by = lr_r_data-create_by
                                          create_at = lr_r_data-create_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0060h VALUES @ls_ztgsco0060h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-mastermtc IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-mastermtc REFERENCE INTO DATA(lr_u_mastermtc).
        "타입
        IF lr_u_mastermtc->%control-materialtype = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0060 SET materialtype = @lr_u_mastermtc->materialtype WHERE id = @lr_u_mastermtc->id.
        ENDIF.

        "계정
        IF lr_u_mastermtc->%control-account = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0060 SET account = @lr_u_mastermtc->account WHERE id = @lr_u_mastermtc->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0060h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_mastermtc->id
                                          action = 'U'
                                          materialclass = lr_u_mastermtc->materialclass
                                          materialtype = lr_u_mastermtc->materialtype
                                          account = lr_u_mastermtc->account
                                          delete_flag = lr_u_mastermtc->delete_flag
                                          create_by = lr_u_mastermtc->createby
                                          create_at = lr_u_mastermtc->createat
                                          last_changed_by = lr_u_mastermtc->lastchangedby
                                          last_changed_at = lr_u_mastermtc->lastchangedat
                                        ).
              INSERT INTO ztgsco0060h VALUES @ls_ztgsco0060h.

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
