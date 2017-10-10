/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits  
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core;

import java.net.MalformedURLException;
import java.net.URL;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.mylyn.tasks.core.AbstractRepositoryConnector;
import org.eclipse.mylyn.tasks.core.IRepositoryQuery;
import org.eclipse.mylyn.tasks.core.ITask;
import org.eclipse.mylyn.tasks.core.TaskRepository;
import org.eclipse.mylyn.tasks.core.data.AbstractTaskAttachmentHandler;
import org.eclipse.mylyn.tasks.core.data.AbstractTaskDataHandler;
import org.eclipse.mylyn.tasks.core.data.TaskAttribute;
import org.eclipse.mylyn.tasks.core.data.TaskData;
import org.eclipse.mylyn.tasks.core.data.TaskDataCollector;
import org.eclipse.mylyn.tasks.core.data.TaskMapper;
import org.eclipse.mylyn.tasks.core.sync.ISynchronizationSession;
import org.eclipse.osgi.util.NLS;

import net.bonprix.sap.solman.core.exception.CharmException;
import net.bonprix.sap.solman.core.exception.CharmHttpException;
import net.bonprix.sap.solman.core.model.CharmQueryResult;
import net.bonprix.sap.solman.core.model.CharmTask;

/**
 * @author theits Encapsulates common operations that can be performed on a task
 *         repository.
 */
public class CharmRepositoryConnector extends AbstractRepositoryConnector {

	private static Map<TaskRepository, CharmClient> clientByRepository = new HashMap<TaskRepository, CharmClient>();
	private final CharmTaskDataHandler taskDataHandler;
	private final CharmTaskAttachmentHandler attachmentHandler;

	public CharmRepositoryConnector() {
		this.taskDataHandler = new CharmTaskDataHandler(this);
		this.attachmentHandler = new CharmTaskAttachmentHandler(this);
	}

	/**
	 * Returns the corresponding client of the Task Repository
	 * 
	 * @param repository
	 * @return
	 */
	public synchronized CharmClient getClient(TaskRepository repository) {

		CharmClient client = clientByRepository.get(repository);
		if (client == null) {
			client = new CharmClient(repository);
			clientByRepository.put(repository, client);
		}
		return client;
	}

	@Override
	public boolean canCreateNewTask(@NonNull TaskRepository repository) {
		return false;
	}

	@Override
	public boolean canCreateTaskFromKey(@NonNull TaskRepository repository) {
		return false;
	}

	@Override
	public @NonNull String getConnectorKind() {
		return CharmCorePlugin.CONNECTOR_KIND;
	}

	@Override
	public @NonNull String getLabel() {
		return "SolMan Repository";
	}

	@Override
	public @Nullable String getRepositoryUrlFromTaskUrl(@NonNull String taskUrl) {

		try {
			URL url = new URL(taskUrl);
			return url.getHost();
		} catch (MalformedURLException e) {
		}

		return null;
	}

	@Override
	public @NonNull TaskData getTaskData(@NonNull TaskRepository repository, @NonNull String taskId,
			@NonNull IProgressMonitor monitor) throws CoreException {

		try {
			SubMonitor subMonitor = SubMonitor.convert(monitor);
			CharmTask charmTask = getClient(repository).getTask(taskId, subMonitor);
			TaskData taskData = taskDataHandler.parseCharmTask(repository, charmTask, monitor);
			subMonitor.split(1);
			return taskData;
		} catch (CharmHttpException e) {
			throw new CoreException(new Status(IStatus.ERROR, CharmCorePlugin.PLUGIN_ID,
					NLS.bind("Error getting task: {0}", e.getMessage()), e));
		} catch (ParseException e) {
			throw new CoreException(new Status(IStatus.ERROR, CharmCorePlugin.PLUGIN_ID,
					NLS.bind("Error parsing task: {0}", e.getMessage()), e));
		} finally {
			monitor.done();
		}

	}

	@Override
	public @Nullable String getTaskIdFromTaskUrl(@NonNull String taskUrl) {
		return null;
	}

	@Override
	public @Nullable String getTaskUrl(@NonNull String repositoryUrl, @NonNull String taskIdOrKey) {
		return null;
	}

	@Override
	public boolean hasTaskChanged(@NonNull TaskRepository taskRepository, @NonNull ITask task,
			@NonNull TaskData taskData) {

		Date changedAtTaskData = taskData.getAttributeMapper()
				.getDateValue(taskData.getRoot().getAttribute(TaskAttribute.DATE_MODIFICATION));
		Date changedAtTask = task.getModificationDate();

		if (changedAtTask == null || changedAtTaskData == null)
			return true;

		if (!changedAtTask.equals(changedAtTaskData))
			return true;

		return false;
	}

	@Override
	public @NonNull IStatus performQuery(@NonNull TaskRepository repository, @NonNull IRepositoryQuery query,
			@NonNull TaskDataCollector collector, @Nullable ISynchronizationSession session,
			@NonNull IProgressMonitor monitor) {

		try {

			List<CharmQueryResult> charmTasks = getClient(repository).queryTasks(monitor, query).getQueryResults();
			SubMonitor subMonitor = SubMonitor.convert(monitor, charmTasks.size());

			for (CharmQueryResult charmTask : charmTasks) {
				TaskData taskData = this.taskDataHandler.parseQueryResults(repository, charmTask, monitor);
				taskData.setPartial(true);
				collector.accept(taskData);
				subMonitor.split(1);
			}

		} catch (CharmException | CoreException e) {
			return new Status(IStatus.ERROR, CharmCorePlugin.PLUGIN_ID, NLS.bind("Query failed: ''{0}''", e.getMessage()),
					e);
		} finally {
			monitor.done();
		}

		return Status.OK_STATUS;

	}

	@Override
	public void updateRepositoryConfiguration(@NonNull TaskRepository taskRepository, @NonNull IProgressMonitor monitor)
			throws CoreException {
		// TODO Auto-generated method stub

	}

	@Override
	public void updateTaskFromTaskData(@NonNull TaskRepository taskRepository, @NonNull ITask task,
			@NonNull TaskData taskData) {

		TaskMapper mapper = (TaskMapper) getTaskMapping(taskData);
		mapper.applyTo(task);

	}

	@Override
	public @Nullable AbstractTaskDataHandler getTaskDataHandler() {
		return taskDataHandler;

	}

	@Override
	public @Nullable AbstractTaskAttachmentHandler getTaskAttachmentHandler() {
		return attachmentHandler;
	}

}
