CLASS zcl_001_mylyn_service DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .
*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA

  PUBLIC SECTION.
*"* public components of class ZCL_001_MYLYN_SERVICE
*"* do not include other source files here!!!

    METHODS constructor
      IMPORTING
        !io_server TYPE REF TO if_http_server .
protected section.
*"* protected components of class ZCL_001_MYLYN_SERVICE
*"* do not include other source files here!!!

  data MT_PARAMETER type ZTT001_QUERY_PARAMETER .
  data MO_HTTP_SERVER type ref to IF_HTTP_SERVER .

  methods PARSE_PARAMETERS .
  methods GET_PARAMETER_VALUE
    importing
      !IV_NAME type ZE_001_query_parameter_name
    returning
      value(RV_VALUE) type ze_001_query_parameter_value .
  PRIVATE SECTION.
*"* private components of class ZCL_001_MYLYN_SERVICE
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_001_MYLYN_SERVICE IMPLEMENTATION.


  METHOD constructor.
    mo_http_server = io_server.
    parse_parameters( ).
  ENDMETHOD.                    "constructor


  METHOD get_parameter_value.

    FIELD-SYMBOLS: <s_parameter> LIKE LINE OF mt_parameter.

    READ TABLE mt_parameter ASSIGNING <s_parameter> WITH TABLE KEY name = iv_name.

    IF sy-subrc = 0.
      rv_value = <s_parameter>-value.
    ELSE.
      CLEAR rv_value.
    ENDIF.

  ENDMETHOD.                    "get_parameter_value


  METHOD parse_parameters.

    DATA: lt_name_value_params TYPE TABLE OF string,
        ls_parameter TYPE zs001_query_parameter,
        lv_parameter_string TYPE string,
        lv_name_value_string TYPE string.


    lv_parameter_string = mo_http_server->request->get_header_field( if_http_header_fields_sap=>query_string ).


    SPLIT lv_parameter_string AT '&' INTO TABLE lt_name_value_params.

    LOOP AT lt_name_value_params INTO lv_name_value_string.

      SPLIT lv_name_value_string AT '=' INTO ls_parameter-name ls_parameter-value.

      TRANSLATE: ls_parameter-name  TO UPPER CASE,
                 ls_parameter-value TO UPPER CASE.

      INSERT ls_parameter INTO TABLE mt_parameter.

    ENDLOOP.

  ENDMETHOD.                    "parse_parameters
ENDCLASS.
