/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core;

import java.io.IOException;
import java.io.InputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.mylyn.commons.net.Policy;
import org.eclipse.mylyn.tasks.core.ITask;
import org.eclipse.mylyn.tasks.core.TaskRepository;
import org.eclipse.mylyn.tasks.core.data.AbstractTaskAttachmentHandler;
import org.eclipse.mylyn.tasks.core.data.AbstractTaskAttachmentSource;
import org.eclipse.mylyn.tasks.core.data.TaskAttachmentMapper;
import org.eclipse.mylyn.tasks.core.data.TaskAttribute;
import org.eclipse.osgi.util.NLS;

import net.bonprix.sap.solman.core.exception.CharmException;
import net.bonprix.sap.solman.core.exception.CharmHttpException;

/**
 * @author theits Provides Methods for up- and downloading attachments
 */
public class CharmTaskAttachmentHandler extends AbstractTaskAttachmentHandler {

	static final String CONTEXT_DESCRIPTION = "mylyn/context/zip";
	private final DateFormat dateFormat = new SimpleDateFormat("yyyyMMddhhmmss");

	private CharmRepositoryConnector connector;

	/**
	 * Instantiates the Repository Connector
	 * 
	 * @param solManRepositoryConnector
	 */
	public CharmTaskAttachmentHandler(CharmRepositoryConnector solManRepositoryConnector) {
		connector = solManRepositoryConnector;
	}

	@Override
	public boolean canGetContent(@NonNull TaskRepository repository, @NonNull ITask task) {
		return repository != null;
	}

	@Override
	public boolean canPostContent(@NonNull TaskRepository repository, @NonNull ITask task) {
		return false;
	}

	@Override
	public InputStream getContent(@NonNull TaskRepository repository, @NonNull ITask task,
			@NonNull TaskAttribute attachmentAttribute, @Nullable IProgressMonitor monitor) throws CoreException {

		try {
			return connector.getClient(repository).getAttachment(task, attachmentAttribute, monitor);
		} catch (CharmException e) {
			throw new CoreException(new Status(IStatus.ERROR, CharmCorePlugin.PLUGIN_ID,
					NLS.bind("Downloading attachment failed", task.getTaskId(), e)));
		}
	}

	@Override
	public void postContent(@NonNull TaskRepository repository, @NonNull ITask task,
			@NonNull AbstractTaskAttachmentSource source, @Nullable String comment,
			@Nullable TaskAttribute attachmentAttribute, @Nullable IProgressMonitor monitor) throws CoreException {

		monitor.beginTask("Uploading attachment", 1);

		CharmClient client = connector.getClient(repository);

		try {
			byte attachment[] = readData(source, monitor);

			String filename = source.getName();
			String description = source.getDescription();

			if (CONTEXT_DESCRIPTION.equals(source.getDescription()))
				filename = CONTEXT_DESCRIPTION + "-" + dateFormat.format(new Date()) + ".zip";

			else if (attachmentAttribute != null) {
				TaskAttachmentMapper mapper = TaskAttachmentMapper.createFrom(attachmentAttribute);
				if (mapper.getFileName() != null)
					filename = mapper.getFileName();
				if (mapper.getDescription() != null)
					description = mapper.getDescription();
			}

			client.putAttachmentData(task, filename, source.getContentType(), description, attachment, monitor);
			Policy.advance(monitor, 1);

		} catch (IOException | CharmHttpException e) {
			throw new CoreException(new Status(IStatus.ERROR, CharmCorePlugin.PLUGIN_ID,
					NLS.bind("Uploading attachment to task {0} failed.", task.getTaskId(), e)));
		} finally {
			monitor.done();
		}

	}

	/**
	 * Reads attachment data from Task Attachment stream
	 * 
	 * @param attachment
	 *            attachment Stream
	 * @param monitor
	 *            monitor for indicating progress
	 * @return attachment as byte array
	 * @throws IOException
	 *             error while reading attachment
	 * @throws CoreException
	 *             error while creating input stream
	 */
	private byte[] readData(AbstractTaskAttachmentSource attachment, IProgressMonitor monitor)
			throws IOException, CoreException {
		InputStream in = attachment.createInputStream(monitor);
		try {
			byte[] data = new byte[(int) attachment.getLength()];
			in.read(data, 0, (int) attachment.getLength());
			return data;
		} finally {
			in.close();
		}
	}

}
