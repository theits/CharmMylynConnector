*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 

CLASS zcl_001_xml_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*"* public components of class ZCL_001_XML_UTIL
*"* do not include other source files here!!!

    CLASS-METHODS build_xml_datetime
       IMPORTING
         !iv_datetime TYPE c
         RETURNING value(rv_xml_datetime) TYPE zd_001_xml_datetime .
  PROTECTED SECTION.
*"* protected components of class ZCL_001_XML_UTIL
*"* do not include other source files here!!!
  PRIVATE SECTION.
*"* private components of class ZCL_001_XML_UTIL
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_001_XML_UTIL IMPLEMENTATION.


  METHOD build_xml_datetime.

    rv_xml_datetime = iv_datetime+0(4) && '-' &&
                    iv_datetime+4(2) && '-' &&
                    iv_datetime+6(2) && 'T' &&
                    iv_datetime+8(2) && ':' &&
                    iv_datetime+10(2) && ':' &&
                    iv_datetime+12(2).

  ENDMETHOD.                    "build_xml_datetime
ENDCLASS.
