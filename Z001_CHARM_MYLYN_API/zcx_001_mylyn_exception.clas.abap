*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 

class ZCX_001_MYLYN_EXCEPTION definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.
*"* public components of class ZCX_001_MYLYN_EXCEPTION
*"* do not include other source files here!!!

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ERROR,
      msgid type symsgid value 'Z001_CHARM_MYLYN_API',
      msgno type symsgno value '000',
      attr1 type scx_attrname value 'TEXT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ERROR .
  constants:
    begin of ATTACHMENT_ERROR,
      msgid type symsgid value 'Z001_CHARM_MYLYN_API',
      msgno type symsgno value '006',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ATTACHMENT_ERROR .
  constants:
    begin of INVALID_GUID,
      msgid type symsgid value 'Z001_CHARM_MYLYN_API',
      msgno type symsgno value '005',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_GUID .
  constants:
    begin of INTERNAL_ERROR,
      msgid type symsgid value 'Z001_CHARM_MYLYN_API',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INTERNAL_ERROR .
  constants:
    begin of PROCESS_READ_ERROR,
      msgid type symsgid value 'Z001_CHARM_MYLYN_API',
      msgno type symsgno value '001',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PROCESS_READ_ERROR .
  constants:
    begin of ACTION_ERROR,
      msgid type symsgid value 'Z001_CHARM_MYLYN_API',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'TEXT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ACTION_ERROR .
  constants:
    begin of ACTION_NOT_FOUND,
      msgid type symsgid value 'Z001_CHARM_MYLYN_API',
      msgno type symsgno value '008',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ACTION_NOT_FOUND .
  data TEXT type CHAR255 .
  data HTTP_STATUS type INT4 .
  data ACTION type CHAR255 .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !TEXT type CHAR255 optional
      !HTTP_STATUS type INT4 optional
      !ACTION type CHAR255 optional .
protected section.
*"* protected components of class ZCX_001_MYLYN_EXCEPTION
*"* do not include other source files here!!!
private section.
*"* private components of class ZCX_001_MYLYN_EXCEPTION
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCX_001_MYLYN_EXCEPTION IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->TEXT = TEXT .
me->HTTP_STATUS = HTTP_STATUS .
me->ACTION = ACTION .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.
ENDCLASS.
