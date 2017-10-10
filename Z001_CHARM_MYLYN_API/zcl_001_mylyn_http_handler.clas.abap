CLASS zcl_001_mylyn_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA

  PUBLIC SECTION.
*"* public components of class ZCL_001_MYLYN_HTTP_HANDLER
*"* do not include other source files here!!!

    CONSTANTS:
    c_http_status_not_found TYPE i VALUE 404,
    c_http_status_not_implemented TYPE i VALUE 400,
    c_http_status_internal_error TYPE i VALUE 500,
    c_http_status_ok TYPE i VALUE 200.


    INTERFACES if_http_extension .
  PROTECTED SECTION.
*"* protected components of class ZCL_001_MYLYN_HTTP_HANDLER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_001_MYLYN_HTTP_HANDLER
*"* do not include other source files here!!!

  methods BUILD_SERVICE_HANDLER
    importing
      !IO_SERVER type ref to IF_HTTP_SERVER
    returning
      value(RO_SERVICE_HANDLER) type ref to ZIF_001_MYLYN_SERVICE
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods RUN_SERVICE
    importing
      !IO_SERVER type ref to IF_HTTP_SERVER
      !IO_SERVICE_HANDLER type ref to ZIF_001_MYLYN_SERVICE
    raising
      ZCX_001_MYLYN_EXCEPTION .
  methods BUILD_ERROR_MESSAGE
    importing
      !IV_MESSAGE type STRING
    returning
      value(RV_RESPOND) type XSTRING .
ENDCLASS.



CLASS ZCL_001_MYLYN_HTTP_HANDLER IMPLEMENTATION.


METHOD build_error_message.

  DATA ls_message TYPE zs001_error_message.

  ls_message-message = iv_message.

  CALL TRANSFORMATION z_001_charm_error
        SOURCE error = ls_message
        RESULT XML rv_respond.

ENDMETHOD.


  METHOD build_service_handler.

    DATA: lo_service_handler TYPE REF TO zif_001_mylyn_service,
          lv_path TYPE string.

    lv_path = io_server->request->get_header_field( '~path' ).


    IF lv_path CP '/sap/bc/mylyn/task/*/attachment*'.
      CREATE OBJECT lo_service_handler TYPE zcl_001_mylyn_service_attachme
        EXPORTING
          io_server = io_server.

    ELSEIF lv_path CP '/sap/bc/mylyn/task/*' OR lv_path = '/sap/bc/mylyn/tasks'  .
      CREATE OBJECT lo_service_handler TYPE zcl_001_mylyn_service_task
        EXPORTING
          io_server = io_server.
    ENDIF.

    "throw exceotion with http code 404 not found
    IF lo_service_handler IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_001_mylyn_exception
        EXPORTING
          http_status = 404.
    ENDIF.

    ro_service_handler = lo_service_handler.

  ENDMETHOD.                    "handle_swagger_request


  METHOD if_http_extension~handle_request.

    DATA:
          lv_path TYPE string,
          lv_response TYPE xstring,
          lx_error TYPE REF TO zcx_001_mylyn_exception,
          lv_status_code TYPE int4,
          lv_reason TYPE string,
          lv_content_type TYPE string,
          lo_service_handler TYPE REF TO zif_001_mylyn_service.

    TRY .
        "builds service handler object depending on the requested ressource: task or attachment
        lo_service_handler = me->build_service_handler( server ).

        "executes the http method get, put post etc.
        me->run_service(
          io_server = server
          io_service_handler = lo_service_handler ).

        lv_response = lo_service_handler->get_response( ).
        lv_content_type = lo_service_handler->get_content_type( ).
        lv_status_code = c_http_status_ok. "if no exception occured, set status to ok (200)

      CATCH zcx_001_mylyn_exception INTO lx_error.
        lv_status_code = lx_error->http_status.
        lv_response = build_error_message( lx_error->get_text( ) ).
        lv_content_type = 'application/xml'.
    ENDTRY.

    server->response->set_status(
      EXPORTING
        code   = lv_status_code
        reason = lv_reason ).

    IF lv_response IS NOT INITIAL.

      server->response->set_header_field(
            name  = if_http_header_fields=>content_type
            value = lv_content_type ).

      server->response->set_data(
          data = lv_response ).
    ENDIF.

  ENDMETHOD.                    "IF_HTTP_EXTENSION~handle_request


  METHOD run_service.

    CASE io_server->request->get_method( ).
      WHEN 'GET'.
        io_service_handler->get( ).
      WHEN 'POST'.
        io_service_handler->post( ).
      WHEN 'PUT'.
        io_service_handler->put( ).
      WHEN OTHERS. "throw exception with http status 400 - not implemented
        RAISE EXCEPTION TYPE zcx_001_mylyn_exception
          EXPORTING
            http_status = 400.
    ENDCASE.


  ENDMETHOD.                    "run_service
ENDCLASS.
