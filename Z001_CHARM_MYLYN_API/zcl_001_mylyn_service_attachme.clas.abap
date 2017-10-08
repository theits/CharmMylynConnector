*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits 
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 

CLASS zcl_001_mylyn_service_attachme DEFINITION
  PUBLIC
  INHERITING FROM zcl_001_mylyn_service
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*"* public components of class ZCL_001_MYLYN_SERVICE_ATTACHME
*"* do not include other source files here!!!

    INTERFACES zif_001_mylyn_service .
  PROTECTED SECTION.
*"* protected components of class ZCL_001_MYLYN_SERVICE_ATTACHME
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_001_MYLYN_SERVICE_ATTACHME
*"* do not include other source files here!!!

  data MV_RESPONSE type XSTRING .
  data MV_URL type STRING .
  data MV_CONTENT_TYPE type STRING .
  constants C_ATTACHMENT_FILE type SDOK_CLASS value 'CRM_P_ORD'. "#EC NOTEXT
  constants C_ATTACHMENT_URL type SDOK_CLASS value 'CRM_P_URL'. "#EC NOTEXT

  methods READ_ATTACHMENT
    importing
      !IS_LOIO type SKWF_IO
      !IS_PHIO type SKWF_IO
    returning
      value(RV_FILE) type XSTRING
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods READ_ATTACHMENT_META
    importing
      !IV_PROCESS type CRMT_OBJECT_GUID32
      !IV_ATTACHMENT_ID type CRMT_OBJECT_GUID32
    returning
      value(RS_ATTACHMENT) type ZS001_ATTACHMENT_META
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods GET_ATTACHMENT_OBJECT
    importing
      !IV_GUID type CRMT_OBJECT_GUID32
    exporting
      !ES_LOIO type SKWF_IO
      !ES_PHIO type SKWF_IO
    raising
      ZCX_001_MYLYN_EXCEPTION .
ENDCLASS.



CLASS ZCL_001_MYLYN_SERVICE_ATTACHME IMPLEMENTATION.


  METHOD get_attachment_object.

    DATA:
          ls_skwg_brel TYPE skwg_brel,
          lt_phios TYPE skwf_ios,
          lt_loios TYPE skwf_ios,
          ls_phio TYPE skwf_io,
          lv_brelguid TYPE os_guid,
          ls_business_object TYPE sibflporb.

    TRY .
        cl_system_uuid=>convert_uuid_c32_static(
          EXPORTING
            uuid     = iv_guid
          IMPORTING
            uuid_x16 = lv_brelguid
        ).
      CATCH cx_uuid_error.
        RAISE EXCEPTION TYPE zcx_001_mylyn_exception
          EXPORTING
            http_status = 500
            textid      = zcx_001_mylyn_exception=>attachment_error.
    ENDTRY.

    SELECT SINGLE
        instid_b
        typeid_b
        catid_b
         FROM skwg_brel
         INTO CORRESPONDING FIELDS OF ls_skwg_brel
         WHERE brelguid = lv_brelguid.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          http_status = 404.
    ENDIF.

    ls_business_object-instid = ls_skwg_brel-instid_b.
    ls_business_object-typeid = ls_skwg_brel-typeid_b .
    ls_business_object-catid = ls_skwg_brel-catid_b.

    cl_crm_documents=>get_info(
      EXPORTING
        business_object          = ls_business_object
      IMPORTING
        phios                    = lt_phios
        loios                    = lt_loios ).

    READ TABLE lt_phios INDEX 1 INTO es_phio.
    READ TABLE lt_loios INDEX 1 INTO es_loio.

  ENDMETHOD.                    "GET_ATTACHMENT_PHIO


  METHOD read_attachment.

    DATA:
          ls_object_id TYPE sdokobject,
          lv_url TYPE sdokfilacs-uri,
          lv_url_object TYPE string.

    "attached files and urls cannot be read the same way
    IF is_phio-class = c_attachment_file.

      cl_sol_ict_tools=>get_attachment_content(
       EXPORTING
         document      = is_phio
       IMPORTING
         content       = rv_file
     ).

    ELSEIF is_phio-class = c_attachment_url.

      MOVE-CORRESPONDING is_loio TO ls_object_id.

      "get logical io
      CALL FUNCTION 'SDOK_LOIO_GET_URI'
        EXPORTING
          object_id          = ls_object_id
        IMPORTING
          uri                = lv_url
        EXCEPTIONS
          not_existing       = 1
          no_physical_object = 2
          not_authorized     = 3
          no_content         = 4
          bad_storage_type   = 5
          OTHERS             = 6.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_001_mylyn_exception
          EXPORTING
            http_status = 500
            textid = zcx_001_mylyn_exception=>attachment_error.
      ENDIF.

      "build link file
      CONCATENATE '[InternetShortcut]' cl_abap_char_utilities=>newline 'URL=' lv_url INTO lv_url_object.

      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = lv_url_object
        IMPORTING
          buffer = rv_file
        EXCEPTIONS
          failed = 1
          OTHERS = 2.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_001_mylyn_exception
          EXPORTING
            textid = zcx_001_mylyn_exception=>attachment_error.
      ENDIF.

    ENDIF.



  ENDMETHOD.                    "read_attachment


  METHOD read_attachment_meta.

    DATA:
          lv_filename TYPE sdok_filnm,
          lv_mime_type TYPE w3conttype,
          lv_file_size TYPE sdok_fsize,
          lt_doc_properties TYPE sdokproptys,
          ls_doc_property TYPE sdokpropty,
          ls_phio TYPE skwf_io.




    get_attachment_object(
      EXPORTING
        iv_guid = iv_attachment_id
      IMPORTING
        es_phio = ls_phio
    ).

    IF ls_phio IS NOT INITIAL.

      rs_attachment-id = iv_attachment_id.

      cl_crm_documents=>get_document(
        EXPORTING
          io         = ls_phio
        IMPORTING
          properties = lt_doc_properties ).

      READ TABLE lt_doc_properties WITH KEY name = 'FILE_NAME' INTO ls_doc_property.  "#EC CI_STDSEQ  small table
      rs_attachment-file_name = ls_doc_property-value.

      READ TABLE lt_doc_properties WITH KEY name = 'DESCRIPTION' INTO ls_doc_property. "#EC CI_STDSEQ  small table
      rs_attachment-description = ls_doc_property-value.

      READ TABLE lt_doc_properties WITH KEY name = 'MIME_TYPE' INTO ls_doc_property. "#EC CI_STDSEQ  small table
      rs_attachment-mime_type = ls_doc_property-value.

      READ TABLE lt_doc_properties WITH KEY name = 'CREATED_BY' INTO ls_doc_property. "#EC CI_STDSEQ  small table
      rs_attachment-author = ls_doc_property-value.

      READ TABLE lt_doc_properties WITH KEY name = 'CREATED_AT' INTO ls_doc_property. "#EC CI_STDSEQ  small table
      rs_attachment-creation_date = zcl_001_xml_util=>build_xml_datetime( ls_doc_property-value ).


      cl_crm_documents=>get_file_info(
        EXPORTING
          phio      = ls_phio
        IMPORTING
          file_size = rs_attachment-length ).

    ENDIF.




  ENDMETHOD.                    "READ_ATTACHMENT_META


  METHOD zif_001_mylyn_service~get.

    DATA:
          lv_path TYPE string,
          lt_path TYPE STANDARD TABLE OF string,
          lv_attachment_guid TYPE crmt_object_guid32,
          lv_object_guid TYPE crmt_object_guid32,
          lv_file TYPE xstring,
          ls_phio TYPE skwf_io,
          ls_loio TYPE skwf_io,
          ls_attachment TYPE zs001_attachment_meta,
          lv_download TYPE string.

    lv_path = mo_http_server->request->get_header_field( '~path' ).

    SPLIT lv_path AT '/' INTO TABLE lt_path.

    READ TABLE lt_path INDEX 6 INTO lv_object_guid.
    READ TABLE lt_path INDEX 8 INTO lv_attachment_guid.

    IF sy-subrc = 0.

      ls_attachment = me->read_attachment_meta(
         iv_process       = lv_object_guid
         iv_attachment_id = lv_attachment_guid
     ).
      READ TABLE lt_path INDEX 9 INTO lv_download.
      IF sy-subrc = 0.

        get_attachment_object(
          EXPORTING
            iv_guid = lv_attachment_guid
          IMPORTING
            es_loio = ls_loio
            es_phio = ls_phio
        ).

        mv_response = read_attachment(
            is_loio = ls_loio
            is_phio = ls_phio
        ).
        mv_content_type = ls_attachment-mime_type.

      ELSE.

        CALL TRANSFORMATION z_001_charm_attachment
        SOURCE attachment = ls_attachment
        RESULT XML lv_file.

        mv_response = lv_file.
        mv_content_type = 'application/xml'.

      ENDIF.

    ELSE.
      RAISE EXCEPTION TYPE ZCX_001_MYLYN_EXCEPTION
        EXPORTING
          textid = zcx_001_mylyn_exception=>attachment_error
          http_status = 404.
    ENDIF.

  ENDMETHOD.                    "zif_001_mylyn_service~get


  METHOD zif_001_mylyn_service~get_content_type.
    rv_content_type = mv_content_type.
  ENDMETHOD.                    "zif_001_mylyn_service~get_content_type


  METHOD zif_001_mylyn_service~get_response.

    rv_response = mv_response.

  ENDMETHOD.        "ZIF_001_MYLYN_SERVICE~SET_RESPONSE


  METHOD zif_001_mylyn_service~post.

    DATA:
             ls_business_object TYPE sibflporb,
             lt_properties TYPE sdokproptys,
             lt_file_access_info TYPE sdokfilacis,
             ls_file_access_info TYPE sdokfilaci,
             lt_content TYPE sdokcntbins,
             ls_loio TYPE skwf_io,
             ls_phio TYPE skwf_io,
             ls_error TYPE skwf_error,
             lv_path TYPE string,
             lv_guid_char TYPE crmt_object_guid32,
             lv_object_type TYPE crmt_subobject_category_db,
             lt_path TYPE TABLE OF string,
             ls_property TYPE sdokpropty,
             lv_parameter_value TYPE sdok_propv,
             lv_payload TYPE xstring,
             lv_file_length TYPE i,
             ls_attachment TYPE zs001_attachment_post,
             lv_attachment TYPE string.

    lv_path = mo_http_server->request->get_header_field( '~path' ).

    SPLIT lv_path AT '/' INTO TABLE lt_path.
    READ TABLE lt_path INDEX 6 INTO lv_guid_char.

    SELECT SINGLE object_type
      FROM crmd_orderadm_h
      INTO lv_object_type
      WHERE guid = lv_guid_char.

    IF sy-subrc <> 0.

      RAISE EXCEPTION TYPE ZCX_001_MYLYN_EXCEPTION
        EXPORTING
          textid = zcx_001_mylyn_exception=>attachment_error
          http_status = 404.

    ENDIF.

    ls_business_object-instid = lv_guid_char. "Guid
    ls_business_object-typeid = lv_object_type.
    ls_business_object-catid = 'BO'.

    lv_payload = mo_http_server->request->get_data( ).

    CALL TRANSFORMATION z_001_attachment_post
    SOURCE XML lv_payload
    RESULT attachment = ls_attachment.

    lv_payload = cl_http_utility=>decode_x_base64( ls_attachment-payload ).

    ls_property-name = 'DESCRIPTION'.
    ls_property-value = ls_attachment-description.
    INSERT ls_property INTO TABLE lt_properties.

    ls_property-name = 'KW_RELATIVE_URL'.
    ls_property-value = ls_attachment-name.
    INSERT ls_property INTO TABLE lt_properties.

    ls_property-name = 'LANGUAGE'.
    ls_property-value = sy-langu.
    INSERT ls_property INTO TABLE lt_properties.


    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_payload
      IMPORTING
        output_length = lv_file_length
      TABLES
        binary_tab    = lt_content.

    ls_file_access_info-file_size = lv_file_length.
    ls_file_access_info-binary_flg = abap_true.
    ls_file_access_info-file_name = ls_attachment-name.
    ls_file_access_info-mimetype = ls_attachment-mimetype.
    INSERT ls_file_access_info INTO TABLE lt_file_access_info.

    cl_crm_documents=>create_with_table(
      EXPORTING
        business_object     = ls_business_object
        properties          = lt_properties
        file_access_info    = lt_file_access_info
        file_content_binary = lt_content
        raw_mode            = abap_true
      IMPORTING
        loio                = ls_loio
        phio                = ls_phio
        error               = ls_error
    ).
  ENDMETHOD.                    "zif_001_mylyn_service~post


  METHOD zif_001_mylyn_service~put.

  ENDMETHOD.                    "zif_001_mylyn_service~put
ENDCLASS.
