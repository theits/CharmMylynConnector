*"*ChaRM Mylyn REST API
*"*Copyright (C) 2017  Torben Heits
*"*This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
*"*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
*"*You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 

*"* components of interface ZIF_001_MYLYN_SERVICE
INTERFACE zif_001_mylyn_service
  PUBLIC .

  METHODS get
    RAISING
      zcx_001_mylyn_exception .
  METHODS put
  RAISING
      zcx_001_mylyn_exception .
  METHODS post
    RAISING
      zcx_001_mylyn_exception .
  METHODS get_content_type
    RETURNING
      value(rv_content_type) TYPE string .
  METHODS get_response
  RETURNING value(rv_response) TYPE xstring.
ENDINTERFACE.                    "ZIF_001_MYLYN_SERVICE
