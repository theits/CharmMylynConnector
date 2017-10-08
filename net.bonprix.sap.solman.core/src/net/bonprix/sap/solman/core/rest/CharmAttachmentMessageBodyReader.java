/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.rest;

import java.io.IOException;
import java.io.InputStream;
import java.lang.annotation.Annotation;
import java.lang.reflect.Type;

import javax.ws.rs.ProcessingException;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.ext.MessageBodyReader;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

import net.bonprix.sap.solman.core.model.CharmAttachmentMeta;

public class CharmAttachmentMessageBodyReader implements MessageBodyReader<CharmAttachmentMeta> {

	@Override
	public boolean isReadable(Class<?> type, Type genericType, Annotation[] annotations, MediaType mediaType) {
		return type == CharmAttachmentMeta.class;
	}

	@Override
	public CharmAttachmentMeta readFrom(Class<CharmAttachmentMeta> type, Type genericType, Annotation[] annotations,
			MediaType mediaType, MultivaluedMap<String, String> httpHeaders, InputStream entityStream)
			throws IOException, WebApplicationException {

		try {

			JAXBContext context = JAXBContext.newInstance(CharmAttachmentMeta.class);
			Unmarshaller attachmentUnmarshaller = context.createUnmarshaller();
			return (CharmAttachmentMeta) attachmentUnmarshaller.unmarshal(entityStream);

		} catch (JAXBException e) {
			throw new ProcessingException("Error deserializing Attachment");
		}

	}

}