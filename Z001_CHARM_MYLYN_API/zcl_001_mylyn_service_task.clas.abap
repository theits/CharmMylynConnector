CLASS zcl_001_mylyn_service_task DEFINITION
  PUBLIC
  INHERITING FROM zcl_001_mylyn_service
  FINAL
  CREATE PUBLIC .
*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA

  PUBLIC SECTION.
*"* public components of class ZCL_001_MYLYN_SERVICE_TASK
*"* do not include other source files here!!!

    INTERFACES zif_001_mylyn_service .
  PROTECTED SECTION.
*"* protected components of class ZCL_001_MYLYN_SERVICE_TASK
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_001_MYLYN_SERVICE_TASK
*"* do not include other source files here!!!

  constants C_OBJECT_TYPE_ORDERADM_H type CRMT_OBJECT_TYPE value '05'. "#EC NOTEXT
  constants C_OBJECT_TYPE_PARTNER type CRMT_OBJECT_TYPE value '07'. "#EC NOTEXT
  constants C_PARTNER_FUNCTION_DEVELOPER type CRMT_PARTNER_FCT value 'SMCD0001'. "#EC NOTEXT
  data MV_RESPONSE type XSTRING .
  constants C_KIND_ADMIN_HEAD type CRMT_OBJECT_KIND value 'A'. "#EC NOTEXT
  constants C_TEXT_OBJECT_ORDER_HEAD type COMT_TEXT_TEXTOBJECT value 'CRM_ORDERH'. "#EC NOTEXT
  constants C_TEXT_GENERAL_NOTE type TDID value 'CD03'. "#EC NOTEXT
  constants C_OBJECT_NAME_CUSTOMER_H type CRMT_OBJECT_NAME value 'CUSTOMER_H'. "#EC NOTEXT

  methods READ_TASK
    importing
      !IV_GUID type CRMT_OBJECT_GUID
    exporting
      !ES_TASK type ZS001_CHARM_PROCESS
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods UPDATE_TASK
    importing
      !IS_TASK type ZS001_CHARM_PROCESS
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods QUERY_TASKS
    importing
      !IV_GUID type STRING
      !IV_OBJECT_ID type STRING
      !IV_PROC_TYPE type STRING
      !IV_DEVELOPER type STRING
      !IV_STATUS type STRING
      !IV_PRIO type STRING
    returning
      value(RT_QUERY_RESULTS) type ZTT_001_QUERY_RESULT
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods GET_BUPA_INFORMATION
    importing
      !IT_PARTNER type CRMT_PARTNER_EXTERNAL_WRKT
    returning
      value(RT_PARTNER) type ZTT_001_PARTNER .
  methods PREPARE_BAPI_INPUT_TEXT
    importing
      !IV_TEXT type STRING
      !IV_GUID type CRMT_OBJECT_GUID
    exporting
      !ET_BAPI_INPUT type CRMT_TEXT_COMT
    changing
      !CT_INPUT_FIELDS type CRMT_INPUT_FIELD_TAB .
  methods READ_ATTACHMENTS
    importing
      !IV_GUID type CRMT_OBJECT_GUID
    returning
      value(RT_ATTACHMENTS) type ZTT_001_ATTACHMENT
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods BUILD_URL
    importing
      !IV_GUID type CRMT_OBJECT_GUID
    returning
      value(RV_URL) type STRING .
  methods BUILD_ATTACHMENT_URL
    importing
      !IV_ATTACHMENT_ID type ZD_001_ATTACHMENT_GUID
      !IV_PROCESS_ID type CRMT_OBJECT_GUID
    returning
      value(RV_URL) type /ASU/URL
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods GET_SERVER_INFORMATION
    exporting
      !EV_HOSTNAME type STRING
      !EV_PORT type STRING
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods SELECT_PROCESS_TYPE
    importing
      !IV_PROCESS_TYPE type CRMT_PROCESS_TYPE
    returning
      value(RV_DESCRIPTION) type CRMT_DESCRIPTION_20 .
  methods DETERMINE_POSSIBLE_ACTIONS
    importing
      !IV_GUID type CRMT_OBJECT_GUID
    returning
      value(RT_ACTIONS) type CRMT_ACTION_GET_TAB
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods MAINTAIN_ORDER
    importing
      !IS_COMMENTS type ZTT_001_COMMENT
      !IV_GUID type CRMT_OBJECT_GUID
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods UPDATE_STATUS
    importing
      !IV_STATUS type PPFDTT
      !IV_GUID type CRMT_OBJECT_GUID
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods PREPARE_BAPI_INPUT_CUSTOMER_H
    importing
      !IV_VALUE type STRING
      !IV_GUID type CRMT_OBJECT_GUID
      !IV_FIELDNAME type NAME_KOMP
    exporting
      !ET_BAPI_INPUT type CRMT_CUSTOMER_H_COMT
    changing
      !CT_INPUT_FIELDS type CRMT_INPUT_FIELD_TAB .
ENDCLASS.



CLASS ZCL_001_MYLYN_SERVICE_TASK IMPLEMENTATION.


  METHOD build_attachment_url.

    DATA:
          lv_hostname TYPE string,
          lv_port TYPE string,
          lv_guid TYPE crmt_object_guid32.

    me->get_server_information(
      IMPORTING
        ev_hostname = lv_hostname
        ev_port     = lv_port
    ).

    TRY .
        cl_system_uuid=>convert_uuid_x16_static(
              EXPORTING
                uuid     = iv_process_id
              IMPORTING
                uuid_c32 = lv_guid ).
      CATCH cx_uuid_error.
        RAISE EXCEPTION TYPE zcx_001_mylyn_exception
          EXPORTING
            textid = zcx_001_mylyn_exception=>invalid_guid
            http_status = 500.
    ENDTRY.


    rv_url = 'http://' && lv_hostname && ':' && lv_port && '/sap/bc/mylyn/task/' && lv_guid && '/attachment/' && iv_attachment_id.

  ENDMETHOD.                    "BUILD_ATTACHMENT_URL


  METHOD build_url.

    DATA:
              lv_hostname TYPE string,
              lv_port TYPE string.

    TRY .
        me->get_server_information(
         IMPORTING
           ev_hostname = lv_hostname
           ev_port     = lv_port
       ).

      CATCH zcx_001_mylyn_exception.
        RETURN.
    ENDTRY.


    rv_url = 'http://' && lv_hostname && ':' && lv_port &&'/sap/bc/bsp/sap/crm_ui_start/default.htm?crm-object-type=AIC_OB_CMCD&crm-object-action=B&crm-object-value=' && iv_guid.

  ENDMETHOD.                    "build_url


  METHOD determine_possible_actions.

    DATA:
          lv_context TYPE REF TO cl_doc_context_crm_order,
          lv_toolbar     TYPE boolean,
          lv_manager     TYPE REF TO cl_manager_ppf,
          lt_context     TYPE ppftctxtir,
          lt_trigger     TYPE ppfttrgor,
          ls_trigger     TYPE ppfdtrgor,
          ls_action      TYPE crmt_action_get.


    " create action context
    CALL FUNCTION 'CRM_ACTION_CONTEXT_CREATE'
      EXPORTING
        iv_header_guid                 = iv_guid
        iv_object_guid                 = iv_guid
      IMPORTING
        ev_context                     = lv_context
      EXCEPTIONS
        no_actionprofile_for_proc_type = 1
        no_actionprofile_for_item_type = 2
        order_read_failed              = 3
        OTHERS                         = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " action deterimne
    CALL FUNCTION 'CRM_ACTION_DETERMINE'
      EXPORTING
        iv_header_guid      = iv_guid
        iv_object_guid      = iv_guid
        iv_context          = lv_context
        iv_for_toolbar_only = lv_toolbar
        iv_no_detlog        = abap_true.

    "get actions from ppf manager
    lv_manager = cl_manager_ppf=>get_instance( ).
    INSERT lv_context INTO TABLE lt_context.

    CALL METHOD lv_manager->get_inactive_triggers
      EXPORTING
        it_contexts = lt_context
      IMPORTING
        et_triggers = lt_trigger.

    "fill exporting parameters
    LOOP AT lt_trigger INTO ls_trigger.
      IF ls_trigger->get_ttype( ) <> 'Z1MJ_TO_BE_TESTED_MJ'. "This status should never be set
        ls_action-guid = ls_trigger->read_guid( ).
        ls_action-def  = ls_trigger->get_ttype( ).
        ls_action-text = cl_view_service_ppf=>get_descrp_for_dropdown(
                                              io_trigger = ls_trigger ).

        INSERT ls_action INTO TABLE rt_actions.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.                    "determine_possible_actions


  METHOD get_bupa_information.

    DATA:
          lt_partner_function TYPE TABLE OF crmc_partner_ft,
          lt_business_partner TYPE TABLE OF but000,
          ls_partner TYPE zs001_partner.

    FIELD-SYMBOLS:
                   <s_partner_function> LIKE LINE OF lt_partner_function,
                   <s_businss_partner> LIKE LINE OF lt_business_partner,
                   <s_partner>  TYPE crmt_partner_external_wrk.

    IF lines( it_partner ) = 0.
      RETURN.
    ENDIF.

    " get description of partner function
    SELECT
      description
      partner_fct
      FROM crmc_partner_ft
      INTO CORRESPONDING FIELDS OF TABLE lt_partner_function
      FOR ALL ENTRIES IN it_partner
            WHERE
            partner_fct = it_partner-partner_fct AND
            spras = sy-langu.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " get full name of business partner
    SELECT
      name1_text
      partner_guid
      FROM but000
      INTO CORRESPONDING FIELDS OF TABLE lt_business_partner
      FOR ALL ENTRIES IN it_partner
      WHERE partner_guid = it_partner-bp_partner_guid.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT it_partner ASSIGNING <s_partner>.
      "assign partner function description to partner
      READ TABLE lt_partner_function WITH KEY partner_fct = <s_partner>-partner_fct ASSIGNING <s_partner_function>. "#EC CI_STDSEQ  small table
      IF <s_partner_function> IS ASSIGNED.
        ls_partner-partner_fct_key = <s_partner_function>-partner_fct.
        ls_partner-partner_function = <s_partner_function>-description.
      ENDIF.

      READ TABLE lt_business_partner WITH KEY partner_guid = <s_partner>-bp_partner_guid ASSIGNING <s_businss_partner>. "#EC CI_STDSEQ  small table
      IF <s_businss_partner> IS ASSIGNED.
        ls_partner-partner_name = <s_businss_partner>-name1_text.
      ENDIF.

      INSERT ls_partner INTO TABLE rt_partner.
      CLEAR ls_partner.
    ENDLOOP.


  ENDMETHOD.                    "GET_BUPA_INFORMATION


  METHOD get_server_information.

    DATA:
      lt_server TYPE TABLE OF msxxlist,
      ls_server TYPE msxxlist.

    CALL FUNCTION 'TH_SERVER_LIST'
      TABLES
        list           = lt_server
      EXCEPTIONS
        no_server_list = 1
        OTHERS         = 2.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          http_status = 500.
    ENDIF.

    READ TABLE lt_server WITH KEY host = sy-host INTO ls_server. "#EC CI_STDSEQ  small table
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception.
    ENDIF.

    CALL FUNCTION 'TH_GET_VIRT_HOST_DATA'
      DESTINATION ls_server-name
      EXPORTING
        protocol       = 1 "http
      IMPORTING
        hostname       = ev_hostname
        port           = ev_port
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          http_status = 500.
    ENDIF.

  ENDMETHOD.                    "get_server_information


METHOD maintain_order.

  DATA:
        ls_comment TYPE zs001_comment,
        lv_comment TYPE string,
        lt_input_fields TYPE crmt_input_field_tab,
        lt_exceptions TYPE crmt_exception_t,
        lt_texts TYPE crmt_text_comt,
        lt_customer_h TYPE crmt_customer_h_comt,
        lv_etc TYPE string,
        ls_message TYPE bal_s_msg,
        lv_message_text TYPE c LENGTH 255.

  FIELD-SYMBOLS <s_exception> TYPE crmt_exception.

  READ TABLE is_comments INDEX 1 INTO ls_comment.
  READ TABLE ls_comment-comments INDEX 1 INTO lv_comment.

  IF lv_comment IS NOT INITIAL.

    prepare_bapi_input_text(
      EXPORTING
        iv_text = lv_comment
        iv_guid = iv_guid
      IMPORTING
        et_bapi_input = lt_texts
      CHANGING
        ct_input_fields = lt_input_fields
         ).

  ENDIF.

*  IF iv_etc IS NOT INITIAL. "Example for customer fields
*
*    lv_etc = iv_etc.
*
*    prepare_bapi_input_customer_h(
*      EXPORTING
*        iv_value        = lv_etc
*        iv_guid         = iv_guid
*        iv_fieldname    = 'ZZDEVETC'
*      IMPORTING
*        et_bapi_input   = lt_customer_h
*      CHANGING
*        ct_input_fields = lt_input_fields
*    ).
*
*  ENDIF.


  IF lt_texts IS NOT INITIAL OR lt_customer_h IS NOT INITIAL.
    CALL FUNCTION 'CRM_ORDER_MAINTAIN'
      EXPORTING
        it_text           = lt_texts
        it_customer_h     = lt_customer_h
      IMPORTING
        et_exception      = lt_exceptions
      CHANGING
        ct_input_fields   = lt_input_fields
      EXCEPTIONS
        error_occurred    = 1
        document_locked   = 2
        no_change_allowed = 3
        no_authority      = 4
        OTHERS            = 5.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          textid      = zcx_001_mylyn_exception=>internal_error
          http_status = 500.
    ENDIF.

    LOOP AT lt_exceptions ASSIGNING <s_exception>.

      CALL FUNCTION 'BAL_LOG_MSG_READ'
        EXPORTING
          i_s_msg_handle = <s_exception>-msg_handle
        IMPORTING
          e_s_msg        = ls_message
          e_txt_msg      = lv_message_text
        EXCEPTIONS
          log_not_found  = 1
          msg_not_found  = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        IF ls_message-probclass = '1'.
          RAISE EXCEPTION TYPE zcx_001_mylyn_exception
            EXPORTING
              textid      = zcx_001_mylyn_exception=>action_error
              text        = lv_message_text
              http_status = 500.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.
ENDMETHOD.


  METHOD prepare_bapi_input_customer_h.

    DATA:
          ls_customer_h       TYPE  crmt_customer_h_com,
          ls_input_fields     TYPE  crmt_input_field,
          ls_field_names      TYPE  crmt_input_field_names.

    FIELD-SYMBOLS <v_fieldname> TYPE any.

    ASSIGN COMPONENT iv_fieldname OF STRUCTURE ls_customer_h TO <v_fieldname>.

    <v_fieldname> = iv_value.

    ls_customer_h-ref_guid = iv_guid.
    ls_input_fields-ref_guid = iv_guid.
    ls_input_fields-objectname = c_object_name_customer_h.
    ls_input_fields-ref_kind = c_kind_admin_head.
    ls_field_names-fieldname = iv_fieldname.

    INSERT:
    ls_customer_h INTO TABLE et_bapi_input,
    ls_field_names INTO TABLE ls_input_fields-field_names,
    ls_input_fields INTO TABLE ct_input_fields.

  ENDMETHOD.                    "PREPARE_BAPI_INPUT_TEXT


  METHOD prepare_bapi_input_text.

    DATA:
          lt_split TYPE STANDARD TABLE OF string,
          lt_temp_lines TYPE comt_text_lines_t,
          lt_lines TYPE comt_text_lines_t,
          ls_text TYPE crmt_text_com,
          ls_input_field TYPE crmt_input_field,
          ls_fieldname TYPE crmt_input_field_names.

    FIELD-SYMBOLS <v_line> TYPE string.

    "split texts at new line an then convert
    SPLIT iv_text AT cl_abap_char_utilities=>cr_lf INTO TABLE lt_split IN CHARACTER MODE.

    LOOP AT lt_split ASSIGNING <v_line>.

      zcl_001_charm_comment_parser=>split_comment_for_bapi(
        EXPORTING
          iv_text   = <v_line>
          iv_format = '*'
        IMPORTING
          et_texts  = lt_temp_lines
      ).

      INSERT LINES OF lt_temp_lines INTO TABLE lt_lines.

      CLEAR lt_temp_lines.

    ENDLOOP.

    ls_text-ref_guid = iv_guid.
    ls_text-ref_kind = c_kind_admin_head.
    ls_text-text_object = c_text_object_order_head.
    ls_text-tdid = c_text_general_note.
    ls_text-tdspras = sy-langu.
    ls_text-tdstyle = 'SYSTEM'.
    ls_text-tdform = 'SYSTEM'.
    ls_text-lines = lt_lines.
    ls_text-mode = 'A'.

    ls_input_field-ref_guid = iv_guid.
    ls_input_field-ref_kind = c_kind_admin_head.
    ls_input_field-objectname = 'TEXTS'.
    ls_input_field-logical_key = 'CD03D'.

    ls_fieldname-fieldname = 'LINES'.
    INSERT ls_fieldname INTO TABLE ls_input_field-field_names.
    ls_fieldname-fieldname = 'TDFORM'.
    INSERT ls_fieldname INTO TABLE ls_input_field-field_names.
    ls_fieldname-fieldname = 'TDID'.
    INSERT ls_fieldname INTO TABLE ls_input_field-field_names.
    ls_fieldname-fieldname = 'TDSPRAS'.
    INSERT ls_fieldname INTO TABLE ls_input_field-field_names.
    ls_fieldname-fieldname = 'TDSTYLE'.
    INSERT ls_fieldname INTO TABLE ls_input_field-field_names.

    INSERT ls_text INTO TABLE et_bapi_input.
    INSERT ls_input_field INTO TABLE ct_input_fields.

  ENDMETHOD.                    "PREPARE_BAPI_INPUT_TEXT


  METHOD query_tasks.

    TYPES:
    BEGIN OF ts_query,
      guid TYPE crmt_object_guid,
      description TYPE crmt_description,
    END OF ts_query.

    DATA:    lr_developer        TYPE RANGE OF bu_id_number,
             ls_developer        LIKE LINE OF lr_developer,
             lr_object_id        TYPE RANGE OF crmt_object_id_db,
             ls_object_id        LIKE LINE OF lr_object_id,
             lr_process_type     TYPE RANGE OF crmt_process_type_db,
             ls_process_type     LIKE LINE OF lr_process_type,
             lr_status           TYPE RANGE OF crm_j_status,
             ls_status           LIKE LINE OF lr_status,
             lr_priority         TYPE RANGE OF crmt_priority,
             ls_priority         LIKE LINE OF lr_priority,
             lr_guid             TYPE RANGE OF crmt_object_guid,
             ls_guid             LIKE LINE OF lr_guid,
             lt_guids            TYPE crmt_object_guid_tab,
             lt_process_guids    TYPE crmt_object_guid_tab,
             lv_developer        TYPE bu_id_number,
             lv_hostname         TYPE string,
             lv_port             TYPE string,
             lt_query            TYPE STANDARD TABLE OF ts_query,
             ls_query_result     TYPE zs001_query_result.

    FIELD-SYMBOLS: <s_result> TYPE ts_query.


    IF iv_developer IS NOT INITIAL.
      lv_developer = '*' && iv_developer && '*'.
      fill_range ls_developer lv_developer lr_developer 'CP'.
    ENDIF.

    fill_range ls_guid iv_guid lr_guid 'EQ'.
    fill_range ls_object_id iv_object_id lr_object_id 'EQ'.
    fill_range ls_process_type iv_proc_type lr_process_type 'EQ'.
    fill_range ls_status iv_status lr_status 'EQ'.
    fill_range ls_priority iv_prio lr_priority 'EQ'.


    SELECT crmd_orderadm_h~guid crmd_orderadm_h~description
      FROM crmd_orderadm_h
      INTO CORRESPONDING FIELDS OF TABLE lt_query
      WHERE crmd_orderadm_h~guid IN (
        SELECT DISTINCT crmd_orderadm_h~guid
          FROM crmd_orderadm_h
          INNER JOIN crmc_proc_type  ON crmd_orderadm_h~process_type = crmc_proc_type~process_type
          INNER JOIN crm_jest        ON crmd_orderadm_h~guid = crm_jest~objnr AND crm_jest~inact <> abap_true
          INNER JOIN crmd_activity_h ON crmd_orderadm_h~guid = crmd_activity_h~guid
          INNER JOIN crmd_link ON crmd_orderadm_h~guid = crmd_link~guid_hi
          INNER JOIN crmd_partner ON crmd_link~guid_set = crmd_partner~guid
          INNER JOIN but000 ON crmd_partner~partner_no = but000~partner_guid
          INNER JOIN but0id ON but000~partner = but0id~partner
        WHERE crmd_orderadm_h~object_id    IN lr_object_id
          AND crmd_orderadm_h~process_type IN lr_process_type
          AND crm_jest~stat                IN lr_status
          AND crmd_activity_h~priority     IN lr_priority
          AND crmd_orderadm_h~guid         IN lr_guid
          AND crmd_link~objtype_hi = c_object_type_orderadm_h
          AND crmd_link~objtype_set = c_object_type_partner
          AND crmd_partner~partner_fct = c_partner_function_developer
          AND but0id~idnumber IN lr_developer ) .

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    TRY .
        get_server_information(
        IMPORTING
          ev_hostname = lv_hostname
          ev_port     = lv_port
      ).

      CATCH zcx_001_mylyn_exception.
        RETURN.
    ENDTRY.

    LOOP AT lt_query ASSIGNING <s_result>.
      TRY .

          cl_system_uuid=>convert_uuid_x16_static(
                EXPORTING
                  uuid     = <s_result>-guid
                IMPORTING
                  uuid_c32 = ls_query_result-guid ).

        CATCH cx_uuid_error.
          RAISE EXCEPTION TYPE zcx_001_mylyn_exception
            EXPORTING
              textid      = zcx_001_mylyn_exception=>internal_error
              http_status = 500.
      ENDTRY.


      ls_query_result-description = <s_result>-description.
      ls_query_result-url = 'http://' && lv_hostname && ':' && lv_port && '/sap/bc/mylyn/task/' && <s_result>-guid.

      INSERT ls_query_result INTO TABLE rt_query_results.

    ENDLOOP.



  ENDMETHOD.                    "get_relevant_guids


  METHOD read_attachments.

    DATA:
          lv_guid TYPE crmt_object_guid32,
          lt_skwg_brel TYPE TABLE OF skwg_brel,
          ls_attachment TYPE zs001_attachment_link,
          lv_sysuuid_c32 TYPE sysuuid_c32.

    FIELD-SYMBOLS <s_skwg_brel> LIKE LINE OF lt_skwg_brel.

    TRY .
        cl_system_uuid=>convert_uuid_x16_static(
              EXPORTING
                uuid     = iv_guid
              IMPORTING
                uuid_c32 = lv_guid ).
      CATCH cx_uuid_error.
        RAISE EXCEPTION TYPE zcx_001_mylyn_exception
          EXPORTING
            textid = zcx_001_mylyn_exception=>invalid_guid
            http_status = 500.
    ENDTRY.


    " select guids of attachments
    SELECT
      brelguid
      FROM skwg_brel
      INTO CORRESPONDING FIELDS OF TABLE lt_skwg_brel
      WHERE instid_a = lv_guid.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_skwg_brel ASSIGNING <s_skwg_brel>.

      TRY.
          cl_system_uuid=>convert_uuid_x16_static(
            EXPORTING
              uuid     = <s_skwg_brel>-brelguid
            IMPORTING
              uuid_c32 =    lv_sysuuid_c32 ).
        CATCH cx_uuid_error.
          RAISE EXCEPTION TYPE zcx_001_mylyn_exception
            EXPORTING
              textid = zcx_001_mylyn_exception=>internal_error
              http_status = 500.
      ENDTRY.
      ls_attachment-id = lv_sysuuid_c32.
      INSERT ls_attachment INTO TABLE rt_attachments.

    ENDLOOP.

  ENDMETHOD.                    "read_attachments


  METHOD read_task.

    DATA:
          lt_process_guids    TYPE crmt_object_guid_tab,
          lt_texts            TYPE crmt_text_wrkt,
          lt_orderadm         TYPE crmt_orderadm_h_wrkt,
          lt_status           TYPE crmt_status_wrkt,
          lt_partner          TYPE crmt_partner_external_wrkt,
          lt_charm_process    TYPE STANDARD TABLE OF zs001_charm_process,
          ls_orderadm         TYPE crmt_orderadm_h_wrk,
          ls_charm_process    TYPE zs001_charm_process,
          ls_text             TYPE crmt_text_wrk,
          lv_xml              TYPE xstring,
          ls_partner          TYPE zs001_partner,
          lt_link             TYPE STANDARD TABLE OF crmd_link,
          lt_crmd_partner     TYPE STANDARD TABLE OF crmd_partner,
          lv_status_schema    TYPE j_stsma,
          lt_possible_status  TYPE STANDARD TABLE OF jstat,
          ls_possible_status  TYPE zs001_status,
          lt_activity_h       TYPE crmt_activity_h_wrkt,
          ls_activity_h       TYPE crmt_activity_h_wrk,
          lt_attachments      TYPE ztt_001_attachment,
          lt_comments         TYPE ztt_001_comment,
          lt_guids            TYPE crmt_object_guid_tab,
          ls_attachment_link  TYPE zs001_attachment_link,
          lv_datetime         TYPE char19,
          lt_actions          TYPE crmt_action_get_tab,
          lt_customer_h       TYPE crmt_customer_h_wrkt,
          ls_customer_h       TYPE crmt_customer_h_wrk.

    FIELD-SYMBOLS:
                   <s_status>   TYPE crmt_status_wrk,
                   <s_possible_status> TYPE jstat,
                   <s_attachment> TYPE zs001_attachment_link,
                   <s_action> TYPE crmt_action_get.

    INSERT iv_guid INTO TABLE lt_guids.


    CALL FUNCTION 'CRM_ORDER_READ'
      EXPORTING
        it_header_guid       = lt_guids
      IMPORTING
        et_orderadm_h        = lt_orderadm
        et_text              = lt_texts
        et_status            = lt_status
        et_partner           = lt_partner
        et_activity_h        = lt_activity_h
        et_customer_h        = lt_customer_h
      EXCEPTIONS
        document_not_found   = 1
        error_occurred       = 2
        document_locked      = 3
        no_change_authority  = 4
        no_display_authority = 5
        no_change_allowed    = 6
        OTHERS               = 7.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          textid      = zcx_001_mylyn_exception=>process_read_error
          http_status = 404.
    ENDIF.

    "find priority of task
    READ TABLE lt_activity_h WITH TABLE KEY guid = iv_guid INTO ls_activity_h.
    IF sy-subrc = 0.
      ls_charm_process-priority = ls_activity_h-priority.
    ENDIF.

    READ TABLE lt_orderadm WITH TABLE KEY guid = iv_guid INTO ls_orderadm.
    IF sy-subrc = 0.
      TRY.
          "guid needs to be converted to character. The transformation cannot transform the other datatype
          cl_system_uuid=>convert_uuid_x16_static(
                  EXPORTING
                    uuid     = ls_orderadm-guid
                  IMPORTING
                    uuid_c32 = ls_charm_process-guid ).
        CATCH cx_uuid_error.
          RAISE EXCEPTION TYPE zcx_001_mylyn_exception
            EXPORTING
              textid      = zcx_001_mylyn_exception=>invalid_guid
              http_status = 500.
      ENDTRY.


      lv_datetime = ls_orderadm-changed_at.
      SHIFT lv_datetime LEFT DELETING LEADING space.
      ls_charm_process-changed_at = zcl_001_xml_util=>build_xml_datetime( lv_datetime ).

      lv_datetime = ls_orderadm-created_at.
      SHIFT lv_datetime LEFT DELETING LEADING space.
      ls_charm_process-created_at = zcl_001_xml_util=>build_xml_datetime( lv_datetime ).

      ls_charm_process-created_by = ls_orderadm-created_by.
      ls_charm_process-description = ls_orderadm-description.
      ls_charm_process-id = ls_orderadm-object_id.
      ls_charm_process-proc_type = select_process_type( ls_orderadm-process_type ). "get description of process type


    ENDIF.

    ls_charm_process-partners = get_bupa_information( lt_partner ).

    "select status
    LOOP AT lt_status ASSIGNING <s_status> WHERE guid = iv_guid AND user_stat_proc IS NOT INITIAL.
      ls_charm_process-status = <s_status>-txt30.
      EXIT.
    ENDLOOP.

    "parse comments
    READ TABLE lt_texts WITH TABLE KEY ref_guid = iv_guid ref_kind = c_kind_admin_head INTO ls_text. "#EC CI_STDSEQ  small table
    IF sy-subrc = 0.
      zcl_001_charm_comment_parser=>parse_comments(
        EXPORTING
          is_texts    = ls_text
        IMPORTING
          et_comments = lt_comments
      ).
      ls_charm_process-comments = lt_comments.
    ENDIF.


    " get the possible actions whoch can be executed. These are the status that can be set
    lt_actions = determine_possible_actions( iv_guid ).
    LOOP AT lt_actions ASSIGNING <s_action> .
      ls_possible_status-status_key = <s_action>-def.
      ls_possible_status-status_text = <s_action>-text.
      INSERT ls_possible_status INTO TABLE ls_charm_process-possible_status.
    ENDLOOP.


    "get the attachments
    lt_attachments = read_attachments( iv_guid ).
    LOOP AT lt_attachments ASSIGNING <s_attachment>.
      <s_attachment>-url = build_attachment_url(
                                iv_attachment_id = <s_attachment>-id
                                iv_process_id    = iv_guid ).

      INSERT <s_attachment> INTO TABLE ls_charm_process-attachments.
    ENDLOOP.


    "build the url for opening task via web ui
    ls_charm_process-url = build_url( iv_guid ).
    es_task = ls_charm_process.


  ENDMETHOD.                    "READ_TASKS


  METHOD select_process_type.

    SELECT SINGLE p_description_20
      FROM crmc_proc_type_t
      INTO rv_description
      WHERE process_type = iv_process_type AND
            langu = sy-langu.


  ENDMETHOD.                    "select_process_type


METHOD update_status.

  DATA:
          lt_actions TYPE crmt_action_get_tab,
          ls_action TYPE crmt_action_get,
          lo_object      TYPE REF TO object,
          lo_action      TYPE REF TO cl_trigger_ppf,
          lv_status      TYPE i,
          lt_message_handles TYPE bal_t_msgh,
          ls_message_handle TYPE balmsghndl,
          ls_message TYPE bal_s_msg,
          lv_message_text TYPE c LENGTH 255,
          lv_exception_text TYPE scx_attrname,
          lt_msg_handle  TYPE  bal_t_msgh.

  IF iv_status IS INITIAL.
    RETURN.
  ENDIF.

  lt_actions = determine_possible_actions( iv_guid ).
  READ TABLE lt_actions INTO ls_action WITH KEY def = iv_status. "#EC CI_STDSEQ  small table

  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_001_mylyn_exception
      EXPORTING
        textid = zcx_001_mylyn_exception=>action_not_found.
  ENDIF.

  CALL METHOD
    ca_trigger_ppf=>agent->if_os_ca_persistency~get_persistent_by_oid
    EXPORTING
      i_oid  = ls_action-guid
    RECEIVING
      result = lo_object.

  lo_action ?= lo_object.


* 6 execute action
  CALL METHOD lo_action->set_is_inactiv( space ).
  CALL METHOD lo_action->execute
    RECEIVING
      rp_rc                   = lv_status
    EXCEPTIONS
      empty_medium_reference  = 1
      empty_appl_reference    = 2
      locked                  = 3
      document_is_locked      = 4
      inactive                = 5
      startcondition_not_true = 6
      OTHERS                  = 7.


  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_001_mylyn_exception
      EXPORTING
        http_status = 500.
  ENDIF.

  IF lv_status = sppf_status_error.


    CALL FUNCTION 'CRM_MESSAGES_DISPLAY'
      EXPORTING
        iv_surpress_output = abap_true
        iv_level           = '9'
        iv_show_all_logs   = abap_true
      IMPORTING
        et_msg_handle      = lt_msg_handle
      EXCEPTIONS
        not_found          = 1
        display_error      = 2
        invalid_level      = 3
        OTHERS             = 4.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_msg_handle INTO ls_message_handle.

      CALL FUNCTION 'BAL_LOG_MSG_READ'
        EXPORTING
          i_s_msg_handle = ls_message_handle
        IMPORTING
          e_s_msg        = ls_message
          e_txt_msg      = lv_message_text
        EXCEPTIONS
          log_not_found  = 1
          msg_not_found  = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        IF ls_message-probclass = '1'.
          RAISE EXCEPTION TYPE zcx_001_mylyn_exception
            EXPORTING
              textid      = zcx_001_mylyn_exception=>action_error
              text        = lv_message_text
              http_status = 500.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


  METHOD update_task.

    DATA:
          lt_orders_to_save TYPE crmt_object_guid_tab,
          lv_guid TYPE crmt_object_guid.
    TRY .
        cl_system_uuid=>convert_uuid_c32_static(
             EXPORTING
               uuid     = is_task-guid
             IMPORTING
               uuid_x16 = lv_guid ).

      CATCH cx_uuid_error.
        RAISE EXCEPTION TYPE zcx_001_mylyn_exception
          EXPORTING
            textid = zcx_001_mylyn_exception=>invalid_guid
            http_status = 404.
    ENDTRY.

    INSERT lv_guid INTO TABLE lt_orders_to_save.


    me->maintain_order(
      EXPORTING
        is_comments = is_task-comments
        iv_guid     = lv_guid
    ).

    me->update_status(
      EXPORTING
        iv_status = is_task-status_key
        iv_guid   = lv_guid
    ).

    CALL FUNCTION 'CRM_ORDER_SAVE'
      EXPORTING
        it_objects_to_save = lt_orders_to_save
      EXCEPTIONS
        document_not_saved = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          http_status = 500.
    ENDIF.

    COMMIT WORK.

  ENDMETHOD.                    "update_task


  METHOD zif_001_mylyn_service~get.

    DATA:
      lv_xml TYPE xstring,
      lv_response TYPE string,
      lv_path TYPE string,
      lt_path TYPE STANDARD TABLE OF string,
      lv_guid TYPE crmt_object_guid,
      lt_query_result TYPE ztt_001_query_result,
      ls_process TYPE zs001_charm_process,
      lv_task TYPE string.

    lv_path = mo_http_server->request->get_header_field( '~path' ).

    SPLIT lv_path AT '/' INTO TABLE lt_path.

    READ TABLE lt_path INDEX 6 INTO lv_guid.
    READ TABLE lt_path INDEX 5 INTO lv_task.


    IF lv_task = 'task' AND lv_guid IS NOT INITIAL. "this is true, if a single task is requested

      read_task(
        EXPORTING
          iv_guid = lv_guid
        IMPORTING
          es_task = ls_process
      ).


      CALL TRANSFORMATION z_001_charm_process
       SOURCE task = ls_process
       RESULT XML lv_xml.



    ELSEIF lv_task = 'tasks' . "this is true, if you are querying for a task

      lt_query_result = query_tasks(
          iv_guid      = me->get_parameter_value( 'GUID' )
          iv_object_id = me->get_parameter_value( 'OBJECT_ID' )
          iv_proc_type = me->get_parameter_value( 'PROC_TYPE' )
          iv_developer = me->get_parameter_value( 'DEVELOPER' )
          iv_status    = me->get_parameter_value( 'STATUS' )
          iv_prio      = me->get_parameter_value( 'PRIO' )
      ).

      CALL TRANSFORMATION z_001_charm_query_result
      SOURCE tasks = lt_query_result
      RESULT XML lv_xml.

    ENDIF.


    mv_response = lv_xml.

  ENDMETHOD.                    "ZIF_001_MYLYN_SERVICE~GET


  METHOD zif_001_mylyn_service~get_content_type.
    rv_content_type = 'application/xml'.
  ENDMETHOD.                    "zif_001_mylyn_service~get_content_type


  METHOD zif_001_mylyn_service~get_response.

    rv_response = mv_response.

  ENDMETHOD.                    "zif_001_mylyn_service~get_response


  METHOD zif_001_mylyn_service~post.



  ENDMETHOD.                    "ZIF_001_MYLYN_SERVICE~POST


  METHOD zif_001_mylyn_service~put.
    DATA:
             lo_ixml_document TYPE REF TO if_ixml_document,
             lo_ixml_node TYPE REF TO if_ixml_node,
             lv_request_body TYPE xstring,
             lv_status TYPE j_estat,
             lv_priority TYPE sc_prioind,
             lv_text TYPE string,
             lv_guid_char TYPE sysuuid_c,
             lv_path TYPE string,
             lt_path TYPE STANDARD TABLE OF string,
             ls_charm_process TYPE zs001_charm_process.

    FIELD-SYMBOLS <s_process> TYPE zs001_charm_process.

    lv_path = mo_http_server->request->get_header_field( '~path' ).

    SPLIT lv_path AT '/' INTO TABLE lt_path.

    READ TABLE lt_path INDEX 6 INTO lv_guid_char.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          textid = zcx_001_mylyn_exception=>invalid_guid
          http_status = 404.
    ENDIF.

    lv_request_body = mo_http_server->request->get_data( ).

    CALL TRANSFORMATION z_001_charm_process
           SOURCE XML lv_request_body
           RESULT     task = ls_charm_process.

    update_task( ls_charm_process ).





  ENDMETHOD.                    "zif_001_mylyn_service~put
ENDCLASS.
