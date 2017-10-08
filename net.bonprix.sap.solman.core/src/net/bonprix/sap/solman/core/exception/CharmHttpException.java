/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.exception;

public class CharmHttpException extends CharmException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int httpCode;
	private String errorReason;

	public CharmHttpException(int httpCode, String reason) {
		super("HTTP-request failed.\nHTTP-Code: "+httpCode+"\nReason: "+reason);
		this.httpCode = httpCode;
		this.errorReason = reason;
	}

	public int getHttpCode() {
		return httpCode;
	}
	
	public String getErrorReason() {
		return errorReason;
	}

}
