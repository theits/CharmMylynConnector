/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core;

import java.io.IOException;
import java.io.InputStream;
import java.net.Authenticator;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.apache.commons.httpclient.HttpException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.mylyn.commons.net.AuthenticationType;
import org.eclipse.mylyn.tasks.core.IRepositoryQuery;
import org.eclipse.mylyn.tasks.core.ITask;
import org.eclipse.mylyn.tasks.core.TaskRepository;
import org.eclipse.mylyn.tasks.core.data.TaskAttribute;

import net.bonprix.sap.solman.core.exception.CharmException;
import net.bonprix.sap.solman.core.exception.CharmHttpException;
import net.bonprix.sap.solman.core.model.CharmAttachmentMeta;
import net.bonprix.sap.solman.core.model.CharmAttachmentPost;
import net.bonprix.sap.solman.core.model.CharmAttachmentRef;
import net.bonprix.sap.solman.core.model.CharmErrorMessage;
import net.bonprix.sap.solman.core.model.CharmQueryResults;
import net.bonprix.sap.solman.core.model.CharmTask;
import net.bonprix.sap.solman.core.model.CharmTaskAttribute;
import net.bonprix.sap.solman.core.rest.BasicAuthenticator;
import net.bonprix.sap.solman.core.rest.CharmAttachmentMessageBodyReader;
import net.bonprix.sap.solman.core.rest.CharmAttachmentPostWriter;
import net.bonprix.sap.solman.core.rest.CharmErrorMessageBodyReader;
import net.bonprix.sap.solman.core.rest.CharmQueryMessageBodyReader;
import net.bonprix.sap.solman.core.rest.CharmTaskMessageBodyReader;
import net.bonprix.sap.solman.core.rest.CharmTaskMessageBodyWriter;

/**
 * @author theits
 */
public class CharmClient {

	private TaskRepository repository;

	/**
	 * Instantiates the CharmHttpClient
	 * 
	 * @param repository
	 *            The Repository bound to the client
	 */
	public CharmClient(TaskRepository repository) {
		this.repository = repository;
		Authenticator.setDefault(null);

	}

	public WebTarget buildWebTarget(String path, Class<?> messageBodyReader, Class<?> errorBodyReader) {

		return buildWebTarget(path).register(messageBodyReader).register(errorBodyReader);
	}

	public WebTarget buildWebTarget(String path) {

		Client client = ClientBuilder.newClient();

		return client.target(repository.getUrl()).path(path)
				.queryParam("sap-client", repository.getProperty(CharmCorePlugin.SETTING_CLIENT))
				.queryParam("sap-language", repository.getProperty(CharmCorePlugin.SETTING_LANGUAGE))
				.register(new BasicAuthenticator(repository.getCredentials(AuthenticationType.REPOSITORY).getUserName(),
						repository.getCredentials(AuthenticationType.REPOSITORY).getPassword()));

	}

	/**
	 * Returns a CharmTask
	 * 
	 * @param taskId
	 *            Id of the task
	 * @param monitor
	 *            monitor for indicating the progress
	 * @return charmTask
	 * @throws CharmException
	 *             Error occurred while reading the task
	 */
	public CharmTask getTask(String taskId, IProgressMonitor monitor) throws CharmHttpException {

		Response response = buildWebTarget("/task/" + taskId, CharmTaskMessageBodyReader.class,
				CharmErrorMessageBodyReader.class).request(MediaType.APPLICATION_XML).get();

		if (response.getStatus() == 200) {
			CharmTask task = (CharmTask) response.readEntity(CharmTask.class);
			task.setAttachmentsMeta(getAttachments(task));
			return task;
		} else {
			CharmErrorMessage message = (CharmErrorMessage) response.readEntity(CharmErrorMessage.class);
			throw new CharmHttpException(response.getStatusInfo().getStatusCode(), message.getMessage());
		}
	}

	/**
	 * Queries tasks and returns a list of CharmTasks
	 * 
	 * @param monitor
	 *            monitor for indicating the progress
	 * @param query
	 *            query-object which contains the query parameters
	 * @return List of CharmTasks
	 * @throws CharmException
	 *             Error occurred while querying tasks
	 */
	public CharmQueryResults queryTasks(IProgressMonitor monitor, @NonNull IRepositoryQuery query)
			throws CharmException {

		Response response = buildWebTarget("/tasks", CharmQueryMessageBodyReader.class,
				CharmErrorMessageBodyReader.class)
						.queryParam("developer", query.getAttribute(CharmCorePlugin.QUERY_KEY_DEVELOPER))
						.queryParam("object_id", query.getAttribute(CharmCorePlugin.QUERY_KEY_OBJECT_ID))
						.queryParam("proc_type", query.getAttribute(CharmCorePlugin.QUERY_KEY_PROC_TYPE))
						.queryParam("status", query.getAttribute(CharmCorePlugin.QUERY_KEY_STATUS))
						.queryParam("priority", query.getAttribute(CharmCorePlugin.QUERY_KEY_PRIORITY))
						.request(MediaType.APPLICATION_XML).get();

		if (response.getStatus() == 200) {
			return (CharmQueryResults) response.readEntity(CharmQueryResults.class);
		} else {
			CharmErrorMessage message = (CharmErrorMessage) response.readEntity(CharmErrorMessage.class);
			throw new CharmHttpException(response.getStatusInfo().getStatusCode(), message.getMessage());
		}

	}

	/**
	 * Returns a List of Charm Attachment Metadata
	 * 
	 * @param task
	 *            Charm Task
	 * @return List of Charm Attachments Metadata
	 * @throws HttpException
	 *             Error in http-request
	 * @throws IOException
	 *             Error while establishing network connection
	 * @throws CharmXmlException
	 *             XML-file could not be parsed
	 * @throws CharmHttpException
	 *             Bad http-response e.g. 500 or 404
	 */
	private List<CharmAttachmentMeta> getAttachments(CharmTask task) throws CharmHttpException {

		List<CharmAttachmentMeta> attachments = new ArrayList<CharmAttachmentMeta>();

		for (CharmAttachmentRef attachment : task.getAttachments()) {

			Response response = buildWebTarget("/task/" + task.getGuid() + "/attachment/" + attachment.getGuid(),
					CharmAttachmentMessageBodyReader.class, CharmErrorMessageBodyReader.class)
							.request(MediaType.APPLICATION_XML).get();

			if (response.getStatus() == 200) {
				CharmAttachmentMeta attachmentMeta = (CharmAttachmentMeta) response
						.readEntity(CharmAttachmentMeta.class);
				attachments.add(attachmentMeta);
			} else {
				CharmErrorMessage message = (CharmErrorMessage) response.readEntity(CharmErrorMessage.class);
				throw new CharmHttpException(response.getStatusInfo().getStatusCode(), message.getMessage());
			}

		}
		return attachments;

	}

	/**
	 * Get an attachment it it's origin-format as a byte-array
	 * 
	 * @param task
	 *            Charm Task of attachment
	 * @param attachmentAttribute
	 *            attachment Attributes
	 * @param monitor
	 *            monitor for indicating progress
	 * @return attachment as byte array
	 * @throws CharmException
	 *             error while reading attachment
	 * @throws IOException
	 */
	public InputStream getAttachment(@NonNull ITask task, @NonNull TaskAttribute attachmentAttribute,
			@Nullable IProgressMonitor monitor) throws CharmException {

		String attachmentId = attachmentAttribute.getValue();
		String taskId = attachmentAttribute.getTaskData().getRoot().getAttribute(CharmTaskAttribute.GUID).getValue();

		Response response = buildWebTarget("/task/" + taskId + "/attachment/" + attachmentId + "/download")
				.request(MediaType.WILDCARD).get();

		if (response.getStatus() == 200) {
			return (InputStream) response.getEntity();
		} else {
			CharmErrorMessage message = (CharmErrorMessage) response.readEntity(CharmErrorMessage.class);
			throw new CharmHttpException(response.getStatusInfo().getStatusCode(), message.getMessage());
		}

	}

	/**
	 * Uploads an attachment to the repository
	 * 
	 * @param task
	 *            attached task
	 * @param filename
	 * @param mimeType
	 * @param description
	 * @param attachment
	 * @param monitor
	 * @throws CharmHttpException
	 */
	public void putAttachmentData(@NonNull ITask task, String filename, String mimeType, String description,
			byte[] attachment, @Nullable IProgressMonitor monitor) throws CharmHttpException {

		CharmAttachmentPost charmAttachment = new CharmAttachmentPost();
		charmAttachment.setDescription(description);
		charmAttachment.setMimeType(mimeType);
		charmAttachment.setName(filename);
		charmAttachment.setPayload(Base64.getEncoder().encodeToString(attachment));

		Response response = buildWebTarget("/task/" + task.getTaskId() + "/attachment", CharmAttachmentPostWriter.class,
				CharmErrorMessageBodyReader.class).request(MediaType.APPLICATION_XML)
						.post(Entity.entity(charmAttachment, MediaType.APPLICATION_XML));

		if (response.getStatus() != 200) {
			CharmErrorMessage message = (CharmErrorMessage) response.readEntity(CharmErrorMessage.class);
			throw new CharmHttpException(response.getStatusInfo().getStatusCode(), message.getMessage());
		}

	}

	/**
	 * Updates a Charm Tasks
	 * 
	 * @param charmTask
	 *            Charm Task with updated information
	 * @throws CharmException
	 *             error while updating
	 */
	public void putCharmTasks(CharmTask charmTask) throws CharmHttpException {

		Response response = buildWebTarget("/task/" + charmTask.getGuid(), CharmTaskMessageBodyWriter.class,
				CharmErrorMessageBodyReader.class).request(MediaType.APPLICATION_XML)
						.put(Entity.entity(charmTask, MediaType.APPLICATION_XML));

		if (response.getStatus() != 200) {
			CharmErrorMessage message = (CharmErrorMessage) response.readEntity(CharmErrorMessage.class);
			throw new CharmHttpException(response.getStatusInfo().getStatusCode(), message.getMessage());
		}

	}

}
