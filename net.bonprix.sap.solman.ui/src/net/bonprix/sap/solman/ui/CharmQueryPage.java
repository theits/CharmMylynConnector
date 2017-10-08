/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.ui;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.mylyn.commons.workbench.forms.SectionComposite;
import org.eclipse.mylyn.tasks.core.IRepositoryQuery;
import org.eclipse.mylyn.tasks.core.TaskRepository;
import org.eclipse.mylyn.tasks.ui.wizards.AbstractRepositoryQueryPage2;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

import net.bonprix.sap.solman.core.CharmCorePlugin;

public class CharmQueryPage extends AbstractRepositoryQueryPage2 {

	private Text developer;
	private Text objectId;
	private Text procType;
	private Text status;
	private Text priority;

	public CharmQueryPage(TaskRepository repository, IRepositoryQuery query) {
		super("SolMan", repository, query);
		setTitle("SolMan Search");
		setDescription("Specify Solman Query Parameters");
	}

	@Override
	protected void doRefreshControls() {
		developer.clearSelection();
		objectId.clearSelection();
		procType.clearSelection();
		status.clearSelection();
		priority.clearSelection();

	}

	@Override
	protected boolean hasRepositoryConfiguration() {
		return true;
	}

	@Override
	protected boolean restoreState(@NonNull IRepositoryQuery query) {
		
		if (query != null) {
			developer.setText(query.getAttribute(CharmCorePlugin.QUERY_KEY_DEVELOPER));
			objectId.setText(query.getAttribute(CharmCorePlugin.QUERY_KEY_OBJECT_ID));
			procType.setText(query.getAttribute(CharmCorePlugin.QUERY_KEY_PROC_TYPE));
			status.setText(query.getAttribute(CharmCorePlugin.QUERY_KEY_STATUS));
			priority.setText(query.getAttribute(CharmCorePlugin.QUERY_KEY_PRIORITY));
			return true;
		}
		return false;
	}

	@Override
	public void applyTo(@NonNull IRepositoryQuery query) {
		if (getQueryTitle() != null) {
			query.setSummary(getQueryTitle());
		}

		query.setAttribute(CharmCorePlugin.QUERY_KEY_DEVELOPER, developer.getText());
		query.setAttribute(CharmCorePlugin.QUERY_KEY_OBJECT_ID, objectId.getText());
		query.setAttribute(CharmCorePlugin.QUERY_KEY_PRIORITY, priority.getText());
		query.setAttribute(CharmCorePlugin.QUERY_KEY_PROC_TYPE, procType.getText());
		query.setAttribute(CharmCorePlugin.QUERY_KEY_STATUS, status.getText());

	}

	@Override
	protected void createPageContent(@NonNull SectionComposite sectionComposite) {

		Composite parent = sectionComposite.getContent();

		Composite composite = new Composite(parent, SWT.BORDER);
		composite.setLayout(new GridLayout(2, false));

		Label lblDev = new Label(composite, SWT.NONE);
		lblDev.setText("Developer");
		developer = new Text(composite, SWT.BORDER);

		Label lblObjectId = new Label(composite, SWT.NONE);
		lblObjectId.setText("Process ID");
		objectId = new Text(composite, SWT.BORDER);
		objectId.setTextLimit(10);

		Label lblprocType = new Label(composite, SWT.NONE);
		lblprocType.setText("Process Type");
		procType = new Text(composite, SWT.BORDER);
		procType.setTextLimit(4);

		Label lblstatus = new Label(composite, SWT.NONE);
		lblstatus.setText("Status");
		status = new Text(composite, SWT.BORDER);

		Label lblPrio = new Label(composite, SWT.NONE);
		lblPrio.setText("Priority");
		priority = new Text(composite, SWT.BORDER);
		priority.setTextLimit(1);

	}

}
