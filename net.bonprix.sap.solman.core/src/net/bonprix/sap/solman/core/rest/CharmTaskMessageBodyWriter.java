/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.rest;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.annotation.Annotation;
import java.lang.reflect.Type;

import javax.ws.rs.ProcessingException;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.ext.MessageBodyWriter;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

import net.bonprix.sap.solman.core.model.CharmTask;

public class CharmTaskMessageBodyWriter implements MessageBodyWriter<CharmTask> {

	@Override
	public long getSize(CharmTask charmTask, Class<?> type, Type genericType, Annotation[] annotations,
			MediaType mediaType) {
		return 0;
	}

	@Override
	public boolean isWriteable(Class<?> type, Type genericType, Annotation[] annotations, MediaType mediaType) {
		return type == CharmTask.class;
	}

	@Override
	public void writeTo(CharmTask charmTask, Class<?> type, Type genericType, Annotation[] annotations,
			MediaType mediaType, MultivaluedMap<String, Object> httpHeaders, OutputStream entityStream)
			throws IOException, WebApplicationException {

		try {

			JAXBContext context = JAXBContext.newInstance(CharmTask.class);
			Marshaller taskMarshaller = context.createMarshaller();
			taskMarshaller.marshal(charmTask, entityStream);

		} catch (JAXBException e) {
			throw new ProcessingException("Error serializing Charm Task to output stream");
		}

	}

}
