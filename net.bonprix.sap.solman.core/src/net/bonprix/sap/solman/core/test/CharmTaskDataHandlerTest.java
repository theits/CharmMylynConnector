/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.test;

import java.text.ParseException;

import org.eclipse.core.runtime.AssertionFailedException;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.mylyn.tasks.core.TaskRepository;
import org.eclipse.mylyn.tasks.core.data.TaskData;
import org.hamcrest.CoreMatchers;
import org.hamcrest.MatcherAssert;
import org.junit.BeforeClass;
import org.junit.Test;

import net.bonprix.sap.solman.core.CharmCorePlugin;
import net.bonprix.sap.solman.core.CharmRepositoryConnector;
import net.bonprix.sap.solman.core.CharmTaskDataHandler;
import net.bonprix.sap.solman.core.model.CharmTask;
import net.bonprix.sap.solman.core.model.CharmTaskAttribute;

public class CharmTaskDataHandlerTest {

	private static CharmTaskDataHandler taskDataHandler;
	private static TaskRepository repository;

	@BeforeClass
	public static void initialize() {
		taskDataHandler = new CharmTaskDataHandler(new CharmRepositoryConnector());
		repository = new TaskRepository(CharmCorePlugin.CONNECTOR_KIND, "http://test.com");
	}

	@Test
	public void testAttributes() throws Exception {

		CharmTask task = new CharmTask();
		task.setGuid("1234");

		TaskData taskData = taskDataHandler.parseCharmTask(repository, task, null);
		MatcherAssert.assertThat(taskData.getTaskId(), CoreMatchers.is("1234"));
	}

	@Test(expected = AssertionFailedException.class)
	public void testEmptyId() throws ParseException, CoreException {
		CharmTask task = new CharmTask();
		taskDataHandler.parseCharmTask(repository, task, null);
	}

	@Test
	public void testCustomFields() throws Exception {
		CharmTask task = new CharmTask();
		task.setGuid("123");
		task.setId("Test-ID");
		TaskData taskData = taskDataHandler.parseCharmTask(repository, task, null);

		String id = taskData.getRoot().getAttribute(CharmTaskAttribute.ID).getValue();
		MatcherAssert.assertThat(id, CoreMatchers.is("Test-ID"));

	}

}
