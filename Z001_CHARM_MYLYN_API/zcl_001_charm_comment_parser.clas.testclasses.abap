*"* use this source file for your ABAP unit test classes

CLASS ltcl_comment_parser DEFINITION FOR TESTING RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS setup.
    METHODS teardown.
    METHODS test_splittet_cooment FOR TESTING.
    METHODS test_split_new_line FOR TESTING.
    METHODS test_new_line FOR TESTING.

    DATA:
      ls_text TYPE crmt_text_wrk,
      lt_lines TYPE comt_text_lines_t,
      ls_line TYPE tline,
      lt_comments TYPE ztt_001_comment,
      lv_line TYPE tdline,
      ls_comment TYPE zs001_comment.




ENDCLASS.                    "ltcl_comment_parser DEFINITION

*----------------------------------------------------------------------*
*       CLASS ltcl_comment_parser IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ltcl_comment_parser IMPLEMENTATION.

  METHOD teardown.
    CLEAR:
    ls_text,
    lt_lines,
    ls_line,
    lt_comments,
    lv_line,
    ls_comment.

  ENDMETHOD.                    "teardown

  METHOD setup.

    ls_line-tdformat = '*'.
    ls_line-tdline = 'Test'.
    INSERT ls_line INTO TABLE lt_lines.

    ls_line-tdformat = '*'.
    ls_line-tdline = '17.05.2017 17:45:21 THEITS'.
    INSERT ls_line INTO TABLE lt_lines.

  ENDMETHOD.                    "setup



  METHOD test_splittet_cooment.

    ls_line-tdformat = '*'.
    ls_line-tdline = 'Hal'.
    INSERT ls_line INTO TABLE lt_lines.

    ls_line-tdformat = '='.
    ls_line-tdline = 'lo'.
    INSERT ls_line INTO TABLE lt_lines.

    ls_text-lines = lt_lines.

    zcl_001_charm_comment_parser=>parse_comments(
      EXPORTING
        is_texts    = ls_text
      IMPORTING
        et_comments = lt_comments
    ).

    READ TABLE lt_comments INDEX 1 INTO ls_comment.
    READ TABLE ls_comment-comments INDEX 2 INTO lv_line.

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = 'Hallo'
        act                  = lv_line
    ).

  ENDMETHOD.                    "test_1

  METHOD test_split_new_line.

    ls_line-tdformat = '*'.
    ls_line-tdline = 'Hal'.
    INSERT ls_line INTO TABLE lt_lines.

    ls_line-tdformat = ' '.
    ls_line-tdline = 'lo'.
    INSERT ls_line INTO TABLE lt_lines.

    ls_text-lines = lt_lines.

    zcl_001_charm_comment_parser=>parse_comments(
      EXPORTING
        is_texts    = ls_text
      IMPORTING
        et_comments = lt_comments
    ).

    READ TABLE lt_comments INDEX 1 INTO ls_comment.
    READ TABLE ls_comment-comments INDEX 2 INTO lv_line.

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = 'Hal lo'
        act                  = lv_line
    ).

  ENDMETHOD.                    "test_new_line

  METHOD test_new_line.

    ls_line-tdformat = '*'.
    ls_line-tdline = 'Hal'.
    INSERT ls_line INTO TABLE lt_lines.

    ls_line-tdformat = '*'.
    ls_line-tdline = 'lo'.
    INSERT ls_line INTO TABLE lt_lines.

    ls_text-lines = lt_lines.

    zcl_001_charm_comment_parser=>parse_comments(
      EXPORTING
        is_texts    = ls_text
      IMPORTING
        et_comments = lt_comments
    ).

    READ TABLE lt_comments INDEX 1 INTO ls_comment.
    READ TABLE ls_comment-comments INDEX 2 INTO lv_line.

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = 'Hal'
        act                  = lv_line
    ).

    READ TABLE ls_comment-comments INDEX 3 INTO lv_line.

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = 'lo'
        act                  = lv_line
    ).

  ENDMETHOD.                    "test_new_line

ENDCLASS.                    "ltcl_comment_parser IMPLEMENTATION



*----------------------------------------------------------------------*
*       CLASS ltcl_comment_splitter DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ltcl_comment_splitter DEFINITION FOR TESTING RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA lt_texts TYPE STANDARD TABLE OF string.

    METHODS setup.
    METHODS teardown.
    METHODS test_splittet_cooment FOR TESTING.
    METHODS test_split_new_line FOR TESTING.
    METHODS test_new_line FOR TESTING.




ENDCLASS.                    "ltcl_comment_splitter DEFINITION

*----------------------------------------------------------------------*
*       CLASS ltcl_comment_splitter IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ltcl_comment_splitter IMPLEMENTATION.

  METHOD setup.

  ENDMETHOD.                    "setup


  METHOD teardown.


  ENDMETHOD.                    "teardown

  METHOD test_splittet_cooment.

    DATA:
          ls_text TYPE string,
          lt_texts TYPE comt_text_lines_t,
          ls_line TYPE tline.

    ls_text = 'Very very very very very very very very very very very very very very very very very very very very very very very very very very splithere very very very very very long text in one line'.

    zcl_001_charm_comment_parser=>split_comment_for_bapi(
  EXPORTING
    iv_text   = ls_text
    iv_format = '*'
      IMPORTING
        et_texts  = lt_texts
).

    READ TABLE lt_texts INDEX 1 INTO ls_line.

    cl_aunit_assert=>assert_char_cp(
      EXPORTING
        act              = ls_line-tdline
        exp              = '*sp'
    ).

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = ls_line-tdformat
        act                  = '*'
    ).

    READ TABLE lt_texts INDEX 2 INTO ls_line.

    cl_aunit_assert=>assert_char_cp(
      EXPORTING
        act              = ls_line-tdline
        exp              = 'lithere*'
    ).

    cl_aunit_assert=>assert_equals(
   EXPORTING
     exp                  = ls_line-tdformat
     act                  = '='
 ).

  ENDMETHOD.                    "test_splittet_cooment

  METHOD test_split_new_line.

    DATA:
         ls_text TYPE string,
         lt_texts TYPE comt_text_lines_t,
         ls_line TYPE tline.

    ls_text = 'Very very very very very very very very very very very very very very very very very very very very very very very very very very sp lithere very very very very very long text in one line'.

    zcl_001_charm_comment_parser=>split_comment_for_bapi(
  EXPORTING
    iv_text   = ls_text
    iv_format = '*'
      IMPORTING
        et_texts  = lt_texts
).



    READ TABLE lt_texts INDEX 1 INTO ls_line.

    cl_aunit_assert=>assert_char_cp(
      EXPORTING
        act              = ls_line-tdline
        exp              = '*sp'
    ).

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = ls_line-tdformat
        act                  = '*'
    ).

    READ TABLE lt_texts INDEX 2 INTO ls_line.

    cl_aunit_assert=>assert_char_cp(
      EXPORTING
        act              = ls_line-tdline
        exp              = 'lithere*'
    ).

    cl_aunit_assert=>assert_equals(
   EXPORTING
     exp                  = ls_line-tdformat
     act                  = ' '
 ).

  ENDMETHOD.                    "test_split_new_line

  METHOD test_new_line.

    DATA:
     ls_text TYPE string,
     lt_texts TYPE comt_text_lines_t,
     ls_line TYPE tline,
     lt_split TYPE STANDARD TABLE OF string.

    FIELD-SYMBOLS <v_text> TYPE string.

    ls_text = 'Very very very very very very very very very very very very very very very very very very very very very very very very very very sp' &&  cl_abap_char_utilities=>cr_lf && 'lithere very very very very very long text in one line'.

    SPLIT ls_text AT cl_abap_char_utilities=>cr_lf INTO TABLE lt_split IN CHARACTER MODE.

    LOOP AT lt_split ASSIGNING <v_text>.

      zcl_001_charm_comment_parser=>split_comment_for_bapi(
    EXPORTING
      iv_text   = <v_text>
      iv_format = '*'
        IMPORTING
          et_texts  = lt_texts ).

    ENDLOOP.

    READ TABLE lt_texts INDEX 1 INTO ls_line.

    cl_aunit_assert=>assert_char_cp(
      EXPORTING
        act              = ls_line-tdline
        exp              = '*sp'
    ).

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = ls_line-tdformat
        act                  = '*'
    ).

    READ TABLE lt_texts INDEX 2 INTO ls_line.

    cl_aunit_assert=>assert_char_cp(
      EXPORTING
        act              = ls_line-tdline
        exp              = 'lithere*'
    ).

    cl_aunit_assert=>assert_equals(
   EXPORTING
     exp                  = ls_line-tdformat
     act                  = '*'
 ).

  ENDMETHOD.                    "test_new_line

ENDCLASS.                    "ltcl_comment_splitter IMPLEMENTATION
