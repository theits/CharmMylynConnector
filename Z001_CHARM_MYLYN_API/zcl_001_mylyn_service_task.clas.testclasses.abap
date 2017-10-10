*"* use this source file for your ABAP unit test classes

*----------------------------------------------------------------------*
*       CLASS lcl_fake_server DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_fake_server DEFINITION.

  PUBLIC SECTION.

    INTERFACES if_http_server.

ENDCLASS.                    "lcl_fake_server DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_fake_server IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_fake_server IMPLEMENTATION.

ENDCLASS.                    "lcl_fake_server IMPLEMENTATION

CLASS ltcl_service_task DEFINITION DEFERRED.
CLASS zcl_001_mylyn_service_task DEFINITION LOCAL FRIENDS ltcl_service_task.
*----------------------------------------------------------------------*
*       CLASS ltcl_service_task DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ltcl_service_task DEFINITION FOR TESTING RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS test_parameters FOR TESTING.

ENDCLASS.                    "ltcl_service_task DEFINITION

*----------------------------------------------------------------------*
*       CLASS ltcl_service_task IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ltcl_service_task IMPLEMENTATION.

  METHOD test_parameters.

    DATA: lo_mocker TYPE REF TO zif_mocka_mocker,
          lo_server TYPE REF TO if_http_server,
          lo_request TYPE REF TO if_http_request,
          lo_mylyn_service_task TYPE REF TO zcl_001_mylyn_service_task,
          lt_object_guids TYPE crmt_object_guid_tab.

    CREATE OBJECT lo_server TYPE lcl_fake_server.

    lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( 'if_http_request' ).

    lo_mocker->method( 'IF_HTTP_ENTITY~GET_HEADER_FIELD' )->with( i_p1 = if_http_header_fields_sap=>query_string )->returns( 'test=123&test=1234' ).

    lo_request ?= lo_mocker->generate_mockup( ).

    lo_server->request = lo_request.

    CREATE OBJECT lo_mylyn_service_task
      EXPORTING
        io_server = lo_server.



    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = '123'
        act                  = lo_mylyn_service_task->get_parameter_value( 'TEST' ) ).


  ENDMETHOD.                    "test_parameters


ENDCLASS.                    "ltcl_service_task IMPLEMENTATION

"lcl_fake_server IMPLEMENTATION
