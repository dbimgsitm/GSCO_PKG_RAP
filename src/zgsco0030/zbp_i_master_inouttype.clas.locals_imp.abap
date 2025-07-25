CLASS lhc_masterio DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR masterio RESULT result.
    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR masterio~beforesave.

ENDCLASS.

CLASS lhc_masterio IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD beforesave.
    READ ENTITIES OF zi_master_inouttype IN LOCAL MODE
    ENTITY masterio
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_masterinout)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    SELECT materialledgerprocesstype
    FROM ztgsco0030
    WHERE materialledgerprocesstype IN ( SELECT materialledgerprocesstype
                                         FROM @lt_masterinout AS lt_checkinoutdata )
      AND delete_flag = ''
    INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                         %fail-cause = if_abap_behv=>cause-conflict
                         id = ls_key-id
                       ) TO failed-masterio.
      ENDLOOP.

*     exception
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %msg = new_message(
                        id = 'ZMCGSFI0030'
                        number = '002'
                        v1 = ls_check-materialledgerprocesstype
                        severity = if_abap_behv_message=>severity-error )
                      ) TO reported-masterio.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zi_master_inouttype DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_master_inouttype IMPLEMENTATION.

  METHOD save_modified.

    DATA : ls_ztgsco0030  TYPE ztgsco0030,
           ls_ztgsco0030h TYPE ztgsco0030h.

**********************************************************************
* Create
**********************************************************************
    IF create-masterio IS NOT INITIAL.
      LOOP AT create-masterio REFERENCE INTO DATA(lr_c_masterio).
        ls_ztgsco0030 = VALUE #(  id = lr_c_masterio->id
                                  companycode = lr_c_masterio->companycode
                                  materialledgerprocesstype = lr_c_masterio->materialledgerprocesstype
                                  typetext = lr_c_masterio->typetext
                                  delete_flag = lr_c_masterio->deleteflag
                                  create_by = lr_c_masterio->createby
                                  create_at = lr_c_masterio->createat
                                  last_changed_by = lr_c_masterio->lastchangedby
                                  last_changed_at = lr_c_masterio->lastchangedat
                                ).
        INSERT INTO ztgsco0030 VALUES @ls_ztgsco0030.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0030h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_masterio->id
                                          action = 'C'
                                          companycode = lr_c_masterio->companycode
                                          materialledgerprocesstype = lr_c_masterio->materialledgerprocesstype
                                          typetext = lr_c_masterio->typetext
                                          delete_flag = lr_c_masterio->deleteflag
                                          create_by = lr_c_masterio->createby
                                          create_at = lr_c_masterio->createat
                                          last_changed_by = lr_c_masterio->lastchangedby
                                          last_changed_at = lr_c_masterio->lastchangedat
                                        ).
              INSERT INTO ztgsco0030h VALUES @ls_ztgsco0030h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-masterio IS NOT INITIAL.
      SELECT *
        FROM ztgsco0030
        WHERE id IN ( SELECT id FROM @delete-masterio AS zmasterio )
        INTO TABLE @DATA(lr_r_masterio).

      LOOP AT delete-masterio REFERENCE INTO DATA(lr_d_masterio).
        UPDATE ztgsco0030 SET delete_flag = 'X' WHERE id = @lr_d_masterio->id.
        READ TABLE lr_r_masterio WITH KEY id = lr_d_masterio->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0030h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          companycode = lr_r_data-companycode
                                          materialledgerprocesstype = lr_r_data-materialledgerprocesstype
                                          typetext = lr_r_data-typetext
                                          delete_flag = lr_r_data-delete_flag
                                          create_by = lr_r_data-create_by
                                          create_at = lr_r_data-create_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0030h VALUES @ls_ztgsco0030h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-masterio IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-masterio REFERENCE INTO DATA(lr_u_masterio).
        "입출고타입명
        IF lr_u_masterio->%control-typetext = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0030 SET typetext = @lr_u_masterio->typetext WHERE id = @lr_u_masterio->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0030h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_masterio->id
                                          action = 'U'
                                          companycode = lr_u_masterio->companycode
                                          materialledgerprocesstype = lr_u_masterio->materialledgerprocesstype
                                          typetext = lr_u_masterio->typetext
                                          delete_flag = lr_u_masterio->deleteflag
                                          create_by = lr_u_masterio->createby
                                          create_at = lr_u_masterio->createat
                                          last_changed_by = lr_u_masterio->lastchangedby
                                          last_changed_at = lr_u_masterio->lastchangedat
                                        ).
              INSERT INTO ztgsco0030h VALUES @ls_ztgsco0030h.

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
