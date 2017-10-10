/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.mylyn.tasks.core.ITask.PriorityLevel;
import org.eclipse.mylyn.tasks.core.ITaskMapping;
import org.eclipse.mylyn.tasks.core.RepositoryResponse;
import org.eclipse.mylyn.tasks.core.RepositoryResponse.ResponseKind;
import org.eclipse.mylyn.tasks.core.TaskRepository;
import org.eclipse.mylyn.tasks.core.data.AbstractTaskDataHandler;
import org.eclipse.mylyn.tasks.core.data.TaskAttachmentMapper;
import org.eclipse.mylyn.tasks.core.data.TaskAttribute;
import org.eclipse.mylyn.tasks.core.data.TaskAttributeMapper;
import org.eclipse.mylyn.tasks.core.data.TaskCommentMapper;
import org.eclipse.mylyn.tasks.core.data.TaskData;

import net.bonprix.sap.solman.core.exception.CharmHttpException;
import net.bonprix.sap.solman.core.model.CharmAttachmentMeta;
import net.bonprix.sap.solman.core.model.CharmComment;
import net.bonprix.sap.solman.core.model.CharmPartner;
import net.bonprix.sap.solman.core.model.CharmQueryResult;
import net.bonprix.sap.solman.core.model.CharmStatus;
import net.bonprix.sap.solman.core.model.CharmTask;
import net.bonprix.sap.solman.core.model.CharmTaskAttribute;

/**
 * 
 * @author theits Responsible for retrieving and posting task data to a
 *         repository
 *
 */
public class CharmTaskDataHandler extends AbstractTaskDataHandler {

	private final CharmRepositoryConnector connector;

	/**
	 * Instantiates the Charm Task Data Handler
	 * 
	 * @param connector
	 *            Repository Connector
	 */
	public CharmTaskDataHandler(CharmRepositoryConnector connector) {
		this.connector = connector;
	}

	/**
	 * Creates a Charm Task from Task Data
	 * 
	 * @param taskData
	 *            Task Data
	 * @return Charm Task
	 */
	private CharmTask createTaskFromTaskData(TaskData taskData) {
		TaskAttribute taskAttribute;

		CharmTask task = new CharmTask();

		taskAttribute = taskData.getRoot().getAttribute(CharmTaskAttribute.GUID);
		task.setGuid(taskAttribute.getValue());

		taskAttribute = taskData.getRoot().getAttribute(CharmTaskAttribute.STATUS);
		task.setStatusKey(taskAttribute.getValue());

		taskAttribute = taskData.getRoot().getAttribute(TaskAttribute.COMMENT_NEW);
		List<CharmComment> comments = new ArrayList<CharmComment>();
		List<String> commentLine = new ArrayList<String>();
		CharmComment comment1 = new CharmComment();
		commentLine.add(taskAttribute.getValue());
		comment1.setComments(commentLine);
		comments.add(comment1);
		task.setComments(comments);

		return task;
	}

	@Override
	public RepositoryResponse postTaskData(@NonNull TaskRepository repository, @NonNull TaskData taskData,
			@Nullable Set<TaskAttribute> oldAttributes, @Nullable IProgressMonitor monitor) throws CoreException {

		try {
			CharmTask charmTask = createTaskFromTaskData(taskData);
			connector.getClient(repository).putCharmTasks(charmTask);
		} catch (CharmHttpException e) {
			throw new CoreException(new Status(IStatus.ERROR, CharmCorePlugin.PLUGIN_ID, e.getErrorReason()));
		}

		return new RepositoryResponse(ResponseKind.TASK_UPDATED, taskData.getTaskId());
	}

	@Override
	public boolean initializeTaskData(@NonNull TaskRepository repository, @NonNull TaskData data,
			@Nullable ITaskMapping initializationData, @Nullable IProgressMonitor monitor) throws CoreException {

		TaskAttribute attribute = data.getRoot().createAttribute(TaskAttribute.SUMMARY);
		attribute.getMetaData().setReadOnly(true).setType(TaskAttribute.TYPE_SHORT_RICH_TEXT).setLabel("Summary:");

		attribute = data.getRoot().createAttribute(TaskAttribute.DESCRIPTION);
		attribute.getMetaData().setReadOnly(true).setType(TaskAttribute.TYPE_LONG_RICH_TEXT).setLabel("Description:");

		attribute = data.getRoot().createAttribute(TaskAttribute.DATE_MODIFICATION);
		attribute.getMetaData().setReadOnly(true).setType(TaskAttribute.TYPE_DATETIME).setLabel("Modified:");

		attribute = data.getRoot().createAttribute(TaskAttribute.USER_ASSIGNED);
		attribute.getMetaData().setReadOnly(true).setType(TaskAttribute.TYPE_LONG_RICH_TEXT).setLabel("Assigned to:");

		attribute = data.getRoot().createAttribute(TaskAttribute.STATUS);
		attribute.getMetaData().setReadOnly(true).setType(TaskAttribute.TYPE_LONG_RICH_TEXT).setLabel("Status:");
		
		attribute = data.getRoot().createAttribute(TaskAttribute.DATE_CREATION);
		attribute.getMetaData().setReadOnly(true).setType(TaskAttribute.TYPE_DATETIME).setLabel("Created:");

		attribute = data.getRoot().createAttribute(TaskAttribute.COMMENT_NEW);
		attribute.getMetaData().setType(TaskAttribute.TYPE_LONG_RICH_TEXT).setReadOnly(false);

		attribute = data.getRoot().createAttribute(TaskAttribute.PRIORITY);
		attribute.getMetaData().setReadOnly(true).setType(TaskAttribute.TYPE_SINGLE_SELECT).setLabel("Priority:");

		attribute = data.getRoot().createAttribute(TaskAttribute.TASK_URL);
		attribute.getMetaData().setReadOnly(false).setType(TaskAttribute.TYPE_URL).setLabel("Url:");

		attribute = data.getRoot().createAttribute(CharmTaskAttribute.ID);
		attribute.getMetaData().setReadOnly(true).setKind(TaskAttribute.KIND_DEFAULT).setLabel("ID:")
				.setType(TaskAttribute.TYPE_SHORT_TEXT);

		attribute = data.getRoot().createAttribute(CharmTaskAttribute.GUID);
		attribute.getMetaData().setReadOnly(true).setKind(TaskAttribute.KIND_DEFAULT).setLabel("Guid:")
				.setType(TaskAttribute.TYPE_SHORT_TEXT);

		attribute = data.getRoot().createAttribute(CharmTaskAttribute.PROCESS_TYPE);
		attribute.getMetaData().setReadOnly(true).setKind(TaskAttribute.KIND_DEFAULT).setLabel("Process type:")
				.setType(TaskAttribute.TYPE_SHORT_TEXT);

		attribute = data.getRoot().createAttribute(CharmTaskAttribute.STATUS);
		attribute.getMetaData().setKind(TaskAttribute.KIND_DEFAULT).setType(TaskAttribute.TYPE_SINGLE_SELECT)
				.setReadOnly(false).setLabel("Status");

		return true;
	}

	@Override
	public TaskAttributeMapper getAttributeMapper(@NonNull TaskRepository repository) {
		return new TaskAttributeMapper(repository);
	}

	/**
	 * Sets the attribute Value for an attribute
	 * 
	 * @param taskAttribute
	 *            Task Attribute
	 * @param value
	 *            Value
	 * @param taskData
	 *            Task Data
	 */
	private void setAttributeValue(String taskAttribute, String value, TaskData taskData) {

		if (value != null) {
			TaskAttribute attribute = taskData.getRoot().getAttribute(taskAttribute);
			attribute.setValue(value);
		}

	}

	/**
	 * Sets the date value for an attribute
	 * 
	 * @param taskAttribute
	 *            Task Attribute
	 * @param value
	 *            Value
	 * @param taskData
	 *            Task Data
	 * @throws ParseException
	 *             Error while parsing date
	 */
	private void setAttributeDateValue(String taskAttribute, Date value, TaskData taskData) throws ParseException {

		if (value != null) {
			TaskAttribute attribute = taskData.getRoot().getAttribute(taskAttribute);
			taskData.getAttributeMapper().setDateValue(attribute, value);
		}

	}

	public TaskData parseQueryResults(TaskRepository repository, CharmQueryResult result, IProgressMonitor monitor)
			throws CoreException {

		TaskData taskData = new TaskData(getAttributeMapper(repository), repository.getConnectorKind(),
				repository.getRepositoryUrl(), result.getGuid());

		initializeTaskData(repository, taskData, null, monitor);

		setAttributeValue(TaskAttribute.SUMMARY, result.getDescription(), taskData);
		return taskData;
	}

	/**
	 * Parses Charm Task to Task Data
	 * 
	 * @param repository
	 *            Repository of task
	 * @param task
	 *            Charm Task
	 * @param monitor
	 *            monitor for iniciating progress
	 * @return Task Data
	 * @throws ParseException
	 *             Error while parsing date
	 * @throws CoreException
	 *             Exception
	 */
	public TaskData parseCharmTask(TaskRepository repository, CharmTask task, IProgressMonitor monitor)
			throws ParseException, CoreException {

		TaskAttribute attribute;

		TaskData taskData = new TaskData(getAttributeMapper(repository), repository.getConnectorKind(),
				repository.getRepositoryUrl(), task.getGuid());

		initializeTaskData(repository, taskData, null, monitor);

		setAttributeValue(TaskAttribute.SUMMARY, task.getDescription(), taskData);

		setAttributeValue(TaskAttribute.STATUS, task.getStatus(), taskData);

		setAttributeValue(CharmTaskAttribute.ID, task.getId(), taskData);

		setAttributeValue(TaskAttribute.USER_ASSIGNED, task.getPartnerByKey("SMCD0001"), taskData);

		setAttributeDateValue(TaskAttribute.DATE_MODIFICATION, task.getChangedAt(), taskData);

		setAttributeDateValue(TaskAttribute.DATE_CREATION, task.getCreatedAt(), taskData);

		setAttributeValue(CharmTaskAttribute.GUID, task.getGuid(), taskData);

		setAttributeValue(TaskAttribute.TASK_URL, task.getUrl(), taskData);

		setAttributeValue(CharmTaskAttribute.PROCESS_TYPE, task.getProcessType(), taskData);

		setAttributeValue(TaskAttribute.PRIORITY,
				PriorityLevel.fromLevel(Integer.parseInt(task.getPriority())).toString(), taskData);

		for (CharmPartner solManPartner : task.getPartners()) {
			attribute = taskData.getRoot().createAttribute(solManPartner.getPartnerFunction());
			attribute.getMetaData().setReadOnly(true).setKind(TaskAttribute.KIND_PEOPLE)
					.setLabel(solManPartner.getPartnerFunction()).setType(TaskAttribute.TYPE_PERSON);
			attribute.setValue(solManPartner.getPartnerName());
		}

		List<CharmComment> comments = task.getComments();
		Collections.reverse(comments);
		int commentCounter = 1;
		for (CharmComment comment : comments) {
			TaskCommentMapper taskCommentMapper = new TaskCommentMapper();
			attribute = taskData.getRoot().createAttribute(TaskAttribute.PREFIX_COMMENT + commentCounter);
			taskCommentMapper.setAuthor(repository.createPerson(comment.getAuthor()));
			taskCommentMapper.setCommentId(String.valueOf(commentCounter));
			taskCommentMapper.setText(comment.getCommentsAsString());
			taskCommentMapper.setCreationDate(comment.getCreationDate());
			taskCommentMapper.setNumber(commentCounter);
			taskCommentMapper.applyTo(attribute);
			commentCounter++;
		}

		if (!comments.isEmpty()) {
			setAttributeValue(TaskAttribute.DESCRIPTION, comments.get(0).getCommentsAsString(), taskData);
		}

		List<CharmAttachmentMeta> attachments = task.getAttachmentsMeta();
		int attachmentCounter = 1;
		for (CharmAttachmentMeta solManAttachment : attachments) {
			TaskAttachmentMapper taskAttachmentMapper = new TaskAttachmentMapper();
			attribute = taskData.getRoot().createAttribute(TaskAttribute.PREFIX_ATTACHMENT + attachmentCounter++);
			taskAttachmentMapper.setAttachmentId(solManAttachment.getId());
			taskAttachmentMapper.setFileName(solManAttachment.getFileName());
			taskAttachmentMapper.setDescription(solManAttachment.getDescription());
			taskAttachmentMapper.setLength(solManAttachment.getLength());
			taskAttachmentMapper.setContentType(solManAttachment.getMimeType());
			taskAttachmentMapper.setAuthor(repository.createPerson(solManAttachment.getAuthor()));
			taskAttachmentMapper.setCreationDate(solManAttachment.getCreation_date());
			taskAttachmentMapper.applyTo(attribute);
		}

		attribute = taskData.getRoot().getAttribute(CharmTaskAttribute.STATUS);
		for (CharmStatus status : task.getPossibleStatus()) {
			attribute.putOption(status.getStatusKey(), status.getStatusText());
		}

		return taskData;
	}

}
