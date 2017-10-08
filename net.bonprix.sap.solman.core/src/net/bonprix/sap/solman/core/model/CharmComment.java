/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

@XmlRootElement(name = "COMMENT")
@XmlType(propOrder = { "author", "creationDate", "comments" })
public class CharmComment {

	private List<String> comments = new ArrayList<String>();
	private String author;
	private Date creationDate;

	@XmlElementWrapper(name = "COMMENTS")
	@XmlElement(name = "STRING")
	public List<String> getComments() {
		return comments;
	}

	public String getCommentsAsString() {
		String comment = "";
		for (String string : comments) {
			comment += string + "\n";
		}
		return comment;
	}

	public void setComments(List<String> comments) {
		this.comments = comments;
	}

	@XmlElement(name = "AUTHOR", nillable = true, required = true)
	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	@XmlElement(name = "CREATION_DATE", nillable = true, required = true)
	public Date getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	public void addLine(String comment) {
		comments.add(comment);
	}

}
