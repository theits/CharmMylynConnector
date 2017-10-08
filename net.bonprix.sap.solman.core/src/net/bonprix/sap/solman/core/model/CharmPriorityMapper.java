/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits  
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.model;

import java.util.HashMap;
import java.util.Map;

public class CharmPriorityMapper {

	public Map<String, String> statusByKey = new HashMap<String, String>();

	public static String getSolManPriority(String mylynPriority) {
		switch (mylynPriority) {
		case "P1":
			return "1";
		case "P2":
			return "2";
		case "P3":
			return "3";
		case "P4":
			return "4";
		case "P5":
			return "5";

		default:
			return "5";

		}

	}

}
