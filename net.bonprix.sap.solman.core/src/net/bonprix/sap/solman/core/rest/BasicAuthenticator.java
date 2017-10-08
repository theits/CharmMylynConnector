/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.rest;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

import javax.ws.rs.client.ClientRequestContext;
import javax.ws.rs.client.ClientRequestFilter;
import javax.xml.bind.DatatypeConverter;

public class BasicAuthenticator implements ClientRequestFilter {

	private final String user;
	private final String password;

	public BasicAuthenticator(String user, String password) {
		this.user = user;
		this.password = password;
	}

	@Override
	public void filter(ClientRequestContext requestContext) throws IOException {
		final String basicAuthentication = getBasicAuthentication();
		requestContext.getHeaders().add("Authorization", basicAuthentication);
	}

	private String getBasicAuthentication() {
		String token = this.user + ":" + this.password;
		try {
			return "BASIC " + DatatypeConverter.printBase64Binary(token.getBytes("UTF-8"));
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException("Encoding with UTF-8 failed", e);
		}
	}

}
