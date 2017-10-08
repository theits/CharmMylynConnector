*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 

*&---------------------------------------------------------------------*
*&  Include           ZI001_MYLYN_EXCEPTION
*&---------------------------------------------------------------------*

 DEFINE fill_range.

   if &2 is not initial.
     &1-sign = 'I'.
     &1-option = &4.
     &1-low = &2.

     insert &1 into table &3.
   endif.



 END-OF-DEFINITION.

 DEFINE throw_0.
   raise exception type &1
     exporting
       textid = &2.

 END-OF-DEFINITION.
