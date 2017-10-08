/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 */
public class CharmCorePlugin extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "net.bonprix.sap.charm.core"; //$NON-NLS-1$

	// The shared instance
	private static CharmCorePlugin plugin;

	public static final String CONNECTOR_KIND = "SOLMAN";

	public static final String QUERY_KEY_DEVELOPER = "DEVELOPER";

	public static final String QUERY_KEY_OBJECT_ID = "OBJECT_ID";

	public static final String QUERY_KEY_PROC_TYPE = "PROC_TYPE";

	public static final String QUERY_KEY_STATUS = "STATUS";

	public static final String QUERY_KEY_PRIORITY = "PRIORITY";

	public static final String SETTING_LANGUAGE = "LANGUAGE";

	public static final String SETTING_CLIENT = "CLIENT";

	/**
	 * The constructor
	 */
	public CharmCorePlugin() {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.
	 * BundleContext)
	 */
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.
	 * BundleContext)
	 */
	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
	}

	/**
	 * Returns the shared instance
	 *
	 * @return the shared instance
	 */
	public static CharmCorePlugin getDefault() {
		return plugin;
	}

}
