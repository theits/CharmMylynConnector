/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.model;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

@XmlRootElement(name = "POSSIBLE_STATUS")
@XmlType(propOrder = {"statusKey","statusText"})
public class CharmStatus {

	private String statusKey;
	private String statusText;

	public CharmStatus() {

	}

	@XmlElement(name = "STATUS_KEY")
	public String getStatusKey() {
		return statusKey;
	}

	public void setStatusKey(String statusKey) {
		this.statusKey = statusKey;
	}

	@XmlElement(name = "STATUS_TEXT")
	public String getStatusText() {
		return statusText;
	}

	public void setStatusText(String statusText) {
		this.statusText = statusText;
	}

}
