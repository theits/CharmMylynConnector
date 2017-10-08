*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 

class ZCL_001_CHARM_COMMENT_PARSER definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_001_CHARM_COMMENT_PARSER
*"* do not include other source files here!!!

  constants C_FORMATTER_NEW_LINE type TDFORMAT value '*'. "#EC NOTEXT
  constants C_FORMATTER_NO_SPLIT type TDFORMAT value '='. "#EC NOTEXT
  constants C_FORMATTER_SPLIT type TDFORMAT value SPACE. "#EC NOTEXT
  constants C_LINE_NEW_COMMENT type TDLINE value '*____*'. "#EC NOTEXT

  class-methods PARSE_COMMENTS
    importing
      !IS_TEXTS type CRMT_TEXT_WRK
    exporting
      !ET_COMMENTS type ZTT_001_COMMENT .
  class-methods SPLIT_COMMENT_FOR_BAPI
    importing
      !IV_TEXT type STRING
      !IV_FORMAT type TDFORMAT
    exporting
      !ET_TEXTS type COMT_TEXT_LINES_T .
  PROTECTED SECTION.
*"* protected components of class ZCL_001_CHARM_COMMENT_PARSER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_001_CHARM_COMMENT_PARSER
*"* do not include other source files here!!!

  class-methods EXTRACT_CREATION_DATE
    importing
      !IV_LINE type TDLINE
    returning
      value(RV_DATETIME) type ZD_001_XML_DATETIME .
  class-methods EXTRACT_USER
    importing
      !IV_LINE type TDLINE
    returning
      value(RV_USER) type BU_NAME1TX .
ENDCLASS.



CLASS ZCL_001_CHARM_COMMENT_PARSER IMPLEMENTATION.


  METHOD extract_creation_date.
    DATA:
          lv_line  TYPE tdline,
          lv_date  TYPE tdline,
          lv_time  TYPE tdline,
          lv_dummy TYPE tdline,
          lv_year  TYPE tdline,
          lv_month TYPE tdline,
          lv_day   TYPE tdline,
          lv_datetime TYPE tdline.

    lv_line = iv_line.

    REPLACE ALL OCCURRENCES OF REGEX '\s+' IN  lv_line WITH ';'.
    SPLIT lv_line AT ';' INTO lv_date lv_time lv_dummy.

    REPLACE ALL OCCURRENCES OF '.' IN lv_date WITH ''.
    REPLACE ALL OCCURRENCES OF ':' IN lv_time WITH ''.

    lv_year  = lv_date+4(5).
    lv_month = lv_date+2(2).
    lv_day   = lv_date+0(2).
    lv_datetime = lv_year && lv_month && lv_day && lv_time.

    rv_datetime = zcl_001_xml_util=>build_xml_datetime( lv_datetime ).

  ENDMETHOD.                    "extract_creation_date


  METHOD extract_user.

    DATA:
         lv_line TYPE tdline,
         lt_lines TYPE STANDARD TABLE OF tdline.

    lv_line = iv_line.

    REPLACE ALL OCCURRENCES OF REGEX '\s+' IN  lv_line WITH ';'.
    SPLIT lv_line AT ';' INTO TABLE lt_lines.

    READ TABLE lt_lines INDEX 3 INTO rv_user.

  ENDMETHOD.         "extract_creation_date


  METHOD parse_comments.

    DATA:
        lv_line TYPE string,
        lt_comments TYPE STANDARD TABLE OF zs001_comment,
        ls_comment TYPE zs001_comment,
        lv_datetime TYPE crmt_created_at_usr,
        lv_user TYPE bu_name1tx,
        lv_line_counter TYPE int4 VALUE 1.

    FIELD-SYMBOLS <s_line> TYPE tline.

    LOOP AT is_texts-lines ASSIGNING <s_line>.

      "if the line is a new line, then insert in table
      IF <s_line>-tdformat = c_formatter_new_line AND lv_line <> ''.
        INSERT lv_line INTO TABLE ls_comment-comments.
        CLEAR lv_line.
      ENDIF.

      "the line implies, that the next line is a new comment
      IF <s_line>-tdline CP c_line_new_comment.
        INSERT ls_comment INTO TABLE lt_comments.
        CLEAR: ls_comment, lv_line.
        lv_line_counter = 1.
        CONTINUE.
      ELSEIF lv_line_counter = 2. "the second line of a comment contains the username and creation date
        ls_comment-creation_date = extract_creation_date( <s_line>-tdline ).
        ls_comment-author = extract_user( <s_line>-tdline ).
      ELSE.
        IF <s_line>-tdformat = c_formatter_split. "this means that a line was split in two lines, but should be displayed as one line
          CONCATENATE lv_line <s_line>-tdline INTO lv_line SEPARATED BY space.
        ELSE.
          CONCATENATE lv_line <s_line>-tdline INTO lv_line.
        ENDIF.
      ENDIF.
      lv_line_counter = lv_line_counter + 1.
    ENDLOOP.

    INSERT lv_line INTO TABLE ls_comment-comments.
    INSERT ls_comment INTO TABLE lt_comments.

    et_comments = lt_comments.

  ENDMETHOD.                    "PARSE_COMMENTS


  METHOD split_comment_for_bapi.

    DATA:
         lv_split_string TYPE string,
         ls_text TYPE tline,
         lv_format TYPE tline-tdformat,
         lt_split_texts TYPE comt_text_lines_t,
         lv_remaining_string TYPE string,
         lv_last_char TYPE char1.

    IF strlen( iv_text ) > 132. "one line can only contain 132 characters
      lv_split_string = iv_text+0(132).
      ls_text-tdline = lv_split_string.
      ls_text-tdformat = iv_format.
      SHIFT ls_text-tdline LEFT DELETING LEADING space.
      INSERT ls_text INTO TABLE et_texts.

      lv_remaining_string = iv_text+132. "the remaining characters
      lv_last_char = lv_remaining_string+0(1). "last character is needed in order to determine the formatting caracter

      IF strlen( lv_remaining_string ) > 132.
        IF lv_last_char = space. "this means that the next character is a new word
          lv_format = c_formatter_split.
        ELSE.
          lv_format = c_formatter_no_split.
        ENDIF.
        split_comment_for_bapi( "call method recursivly with remainig characters
           EXPORTING
             iv_text   = lv_remaining_string
             iv_format = lv_format
           IMPORTING
             et_texts =  lt_split_texts
         ).
        INSERT LINES OF lt_split_texts INTO TABLE et_texts .
      ELSE.
        IF lv_last_char = space.
          ls_text-tdformat = c_formatter_split.
        ELSE.
          ls_text-tdformat = c_formatter_no_split.
        ENDIF.
        ls_text-tdline = lv_remaining_string.
        SHIFT ls_text-tdline LEFT DELETING LEADING space.
        INSERT ls_text INTO TABLE et_texts.
      ENDIF.

    ELSE.
      ls_text-tdformat = c_formatter_new_line.
      ls_text-tdline = iv_text.
      SHIFT ls_text-tdline LEFT DELETING LEADING space.
      INSERT ls_text INTO TABLE et_texts.

    ENDIF.

  ENDMETHOD.                    "split_comment_for_bapi
ENDCLASS.
