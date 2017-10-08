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
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;

@XmlRootElement(name = "TASK")
@XmlType(propOrder = { "guid", "id", "description", "createdAt", "changedAt", "createdBy", "processType", "priority",
		"status", "statusKey", "url", "devPlan", "devEtc", "partners", "comments", "possibleStatus", "attachments" })
public class CharmTask {

	private String guid;

	private String id;

	private String description;

	private Date createdAt;

	private Date changedAt;

	private String createdBy;

	private String processType;

	private String priority;

	private String status;

	private String statusKey;

	private String url;
	
	private float devPlan;
	
	private float devEtc;

	private List<CharmPartner> partners = new ArrayList<CharmPartner>();
	private List<CharmComment> comments = new ArrayList<CharmComment>();
	private List<CharmStatus> possibleStatus = new ArrayList<CharmStatus>();
	private List<CharmAttachmentRef> attachments = new ArrayList<CharmAttachmentRef>();

	@XmlElement(name = "DEV_PLAN", nillable = true, required = true)
	public float getDevPlan() {
		return devPlan;
	}

	public void setDevPlan(float devPlan) {
		this.devPlan = devPlan;
	}

	@XmlElement(name = "DEV_ETC", nillable = true, required = true)
	public float getDevEtc() {
		return devEtc;
	}

	public void setDevEtc(float devEtc) {
		this.devEtc = devEtc;
	}

	@XmlTransient
	private List<CharmAttachmentMeta> attachmentsMeta = new ArrayList<CharmAttachmentMeta>();

	public String getPartnerByKey(String key) {
		for (CharmPartner solManPartner : partners) {
			if (solManPartner.getFunctionKey().equals(key))
				return solManPartner.getPartnerName();
		}
		return "";
	}

	@XmlElement(name = "PROC_TYPE", nillable = true, required = true)
	public String getProcessType() {
		return processType;
	}

	public void setProcessType(String processType) {
		this.processType = processType;
	}

	@XmlElement(name = "GUID")
	public String getGuid() {
		return guid;
	}

	@XmlElement(name = "ID", nillable = true, required = true)
	public String getId() {
		return id;
	}

	@XmlElement(name = "DESCRIPTION", nillable = true, required = true)
	public String getDescription() {
		return description;
	}

	@XmlElement(name = "CREATED_AT", nillable = true, required = true)
	public Date getCreatedAt() {
		return createdAt;
	}

	@XmlElement(name = "CHANGED_AT", nillable = true, required = true)
	public Date getChangedAt() {
		return changedAt;
	}

	@XmlElement(name = "CREATED_BY", nillable = true, required = true)
	public String getCreatedBy() {
		return createdBy;
	}

	@XmlElement(name = "PRIORITY", nillable = true, required = true)
	public String getPriority() {
		return priority;
	}

	@XmlElement(name = "STATUS", nillable = true, required = true)
	public String getStatus() {
		return status;
	}

	@XmlElement(name = "STATUS_KEY", nillable = true, required = true)
	public String getStatusKey() {
		return statusKey;
	}

	@XmlElement(name = "URL", nillable = true, required = true)
	public String getUrl() {
		return url;
	}

	@XmlElementWrapper(name = "PARTNERS")
	@XmlElement(name = "PARTNER")
	public List<CharmPartner> getPartners() {
		return partners;
	}

	@XmlElementWrapper(name = "COMMENTS")
	@XmlElement(name = "COMMENT")
	public List<CharmComment> getComments() {
		return comments;
	}

	@XmlElementWrapper(name = "POSSIBLE_STATI")
	@XmlElement(name = "POSSIBLE_STATUS")
	public List<CharmStatus> getPossibleStatus() {
		return possibleStatus;
	}

	@XmlElementWrapper(name = "ATTACHMENTS")
	@XmlElement(name = "ATTACHMENT")
	public List<CharmAttachmentRef> getAttachments() {
		return attachments;
	}

	@XmlTransient
	public List<CharmAttachmentMeta> getAttachmentsMeta() {
		return attachmentsMeta;
	}

	public void setAttachments(List<CharmAttachmentRef> attachments) {
		this.attachments = attachments;
	}

	public void setStatusKey(String statusKey) {
		this.statusKey = statusKey;
	}

	public void setAttachmentsMeta(List<CharmAttachmentMeta> attachment) {
		this.attachmentsMeta = attachment;
	}

	public void setGuid(String guid) {
		this.guid = guid;
	}

	public void setId(String id) {
		this.id = id;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public void setPriority(String priority) {
		this.priority = priority;
	}

	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}

	public void setChangedAt(Date changedAt) {
		this.changedAt = changedAt;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public void setPartners(List<CharmPartner> partners) {
		this.partners = partners;
	}

	public void setComments(List<CharmComment> comments) {
		this.comments = comments;
	}

	public void setPossibleStatus(List<CharmStatus> stati) {
		this.possibleStatus = stati;
	}

	public void addAttachment(CharmAttachmentMeta attachment) {
		this.attachmentsMeta.add(attachment);
	}

}
