/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.ui;

import org.eclipse.mylyn.tasks.core.RepositoryTemplate;
import org.eclipse.mylyn.tasks.core.TaskRepository;
import org.eclipse.mylyn.tasks.ui.wizards.AbstractRepositorySettingsPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

import net.bonprix.sap.solman.core.CharmCorePlugin;

public class CharmSettingsPage extends AbstractRepositorySettingsPage {

	private Text client;
	private Text language;

	public CharmSettingsPage(TaskRepository repository) {
		super("SolMan Repository Settings", "Settings for SolMan Repository", repository);
		setNeedsAnonymousLogin(false);
		setNeedsEncoding(false);
		setNeedsTimeZone(false);
		setNeedsProxy(false);
		setNeedsAdvanced(true);
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		addRepositoryTemplatesToServerUrlCombo();
		
	}

	@Override
	protected void repositoryTemplateSelected(RepositoryTemplate template) {
		repositoryLabelEditor.setStringValue(template.label);
		setUrl(template.repositoryUrl);
		setUserId("user");
		setPassword("pass");

		getContainer().updateButtons();
	}

	@Override
	public String getConnectorKind() {
		return CharmCorePlugin.CONNECTOR_KIND;
	}

	@Override
	protected void createAdditionalControls(Composite parent) {
		
		Composite composite = new Composite(parent, SWT.BORDER);
		composite.setLayout(new GridLayout(2, false));

		Label label = new Label(composite, SWT.NONE);
		label.setText("Client");
		client = new Text(composite, SWT.BORDER);

		label = new Label(composite, SWT.NONE);
		label.setText("Language");
		language = new Text(composite, SWT.BORDER);

		if (repository != null) {
			client.setText(repository.getProperty(CharmCorePlugin.SETTING_CLIENT));
			language.setText(repository.getProperty(CharmCorePlugin.SETTING_LANGUAGE));
		}

	}

	@Override
	public void performFinish(TaskRepository repository) {
		super.performFinish(repository);
		repository.setProperty(CharmCorePlugin.SETTING_CLIENT, client.getText());
		repository.setProperty(CharmCorePlugin.SETTING_LANGUAGE, language.getText());
		
	}

}
