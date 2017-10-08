/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits  
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.test;

import static org.junit.Assert.assertThat;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.hamcrest.CoreMatchers;
import org.junit.BeforeClass;
import org.junit.Test;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import net.bonprix.sap.solman.core.model.CharmAttachmentMeta;
import net.bonprix.sap.solman.core.model.CharmTask;

public class CharmAttachmentParserTest {

	private static CharmTask charmTask = new CharmTask();

	@BeforeClass
	public static void beforeClass() throws Exception {

		Document doc;
		Element rootElement;
		Element element;

		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();
		doc = builder.newDocument();

		rootElement = doc.createElement("ATTACHMENT");
		doc.appendChild(rootElement);

		element = doc.createElement("ID");
		element.setTextContent("id");
		rootElement.appendChild(element);

		element = doc.createElement("FILE_NAME");
		element.setTextContent("filename");
		rootElement.appendChild(element);

		element = doc.createElement("DESCRIPTION");
		element.setTextContent("description");
		rootElement.appendChild(element);

		element = doc.createElement("LENGTH");
		element.setTextContent("1");
		rootElement.appendChild(element);

		element = doc.createElement("MIME_TYPE");
		element.setTextContent("mimetype");
		rootElement.appendChild(element);

		element = doc.createElement("AUTHOR");
		element.setTextContent("author");
		rootElement.appendChild(element);

		element = doc.createElement("CREATION_DATE");
		element.setTextContent("2017-04-26T14:11:11");
		rootElement.appendChild(element);

		TransformerFactory transformerFactory = TransformerFactory.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		DOMSource source = new DOMSource(doc);

		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		StreamResult result = new StreamResult(bos);
		transformer.transform(source, result);
		byte[] xml = bos.toByteArray();

		ByteArrayInputStream inputStream = new ByteArrayInputStream(xml);
		
		JAXBContext context = JAXBContext.newInstance(CharmAttachmentMeta.class);
		Unmarshaller attachmentUnmarshaller = context.createUnmarshaller();

		CharmAttachmentMeta attachment = (CharmAttachmentMeta) attachmentUnmarshaller.unmarshal(inputStream);

		charmTask.addAttachment(attachment);

	}

	@Test
	public void testAttachment() throws Exception {
		
		SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");

		assertThat(charmTask.getAttachmentsMeta().get(0).getDescription(), CoreMatchers.is("description"));
		assertThat(charmTask.getAttachmentsMeta().get(0).getFileName(), CoreMatchers.is("filename"));
		assertThat(charmTask.getAttachmentsMeta().get(0).getMimeType(), CoreMatchers.is("mimetype"));
		assertThat(charmTask.getAttachmentsMeta().get(0).getId(), CoreMatchers.is("id"));
		assertThat(charmTask.getAttachmentsMeta().get(0).getLength(), CoreMatchers.is(1L));
		assertThat(charmTask.getAttachmentsMeta().get(0).getAuthor(), CoreMatchers.is("author"));
		assertThat(charmTask.getAttachmentsMeta().get(0).getCreation_date(), CoreMatchers.is(df.parse("20170426141111")));
	}

}
