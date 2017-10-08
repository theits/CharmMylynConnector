/*ChaRM Mylyn REST API
Copyright (C) 2017  Torben Heits 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA */
package net.bonprix.sap.solman.core.test;

import static org.junit.Assert.assertThat;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
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

import net.bonprix.sap.solman.core.model.CharmTask;

public class CharmTaskParserTest {

	private static CharmTask charmTask;
	private static SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");

	@BeforeClass
	public static void beforeClass() throws Exception {

		Document doc;
		Element task;

		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();
		doc = builder.newDocument();

		task = doc.createElement("TASK");
		doc.appendChild(task);

		Element element = doc.createElement("GUID");
		element.setTextContent("testguid");
		task.appendChild(element);

		element = doc.createElement("ID");
		element.setTextContent("testid");
		task.appendChild(element);

		element = doc.createElement("DESCRIPTION");
		element.setTextContent("description");
		task.appendChild(element);

		element = doc.createElement("CREATED_AT");
		element.setTextContent("2017-01-01T12:45:12");
		task.appendChild(element);

		element = doc.createElement("CHANGED_AT");
		element.setTextContent("2017-01-01T12:45:12");
		task.appendChild(element);

		element = doc.createElement("CREATED_BY");
		element.setTextContent("theits");
		task.appendChild(element);

		element = doc.createElement("PRIORITY");
		element.setTextContent("1");
		task.appendChild(element);

		element = doc.createElement("STATUS");
		element.setTextContent("status");
		task.appendChild(element);

		element = doc.createElement("STATUS_KEY");
		element.setTextContent("statusKey");
		task.appendChild(element);

		Element partners = doc.createElement("PARTNERS");
		task.appendChild(partners);

		Element partner = doc.createElement("PARTNER");
		partners.appendChild(partner);

		element = doc.createElement("PARTNER_FCT_KEY");
		element.setTextContent("dev");
		partner.appendChild(element);

		element = doc.createElement("PARTNER_FUNCTION");
		element.setTextContent("developer");
		partner.appendChild(element);

		element = doc.createElement("PARTNER_NAME");
		element.setTextContent("theits");
		partner.appendChild(element);

		Element comments = doc.createElement("COMMENTS");
		task.appendChild(comments);

		Element comment = doc.createElement("COMMENT");
		comments.appendChild(comment);

		element = doc.createElement("AUTHOR");
		element.setTextContent("theits");
		comment.appendChild(element);

		element = doc.createElement("ID");
		element.setTextContent("1");
		comment.appendChild(element);

		element = doc.createElement("CREATION_DATE");
		element.setTextContent("2017-01-01T12:45:12");
		comment.appendChild(element);

		Element lines = doc.createElement("COMMENTS");
		comment.appendChild(lines);

		Element line = doc.createElement("STRING");
		line.setTextContent("comment");
		lines.appendChild(line);

		Element possibleStati = doc.createElement("POSSIBLE_STATI");
		task.appendChild(possibleStati);

		Element possibleStatus = doc.createElement("POSSIBLE_STATUS");
		possibleStati.appendChild(possibleStatus);

		element = doc.createElement("STATUS_KEY");
		element.setTextContent("dev");
		possibleStatus.appendChild(element);

		element = doc.createElement("STATUS_TEXT");
		element.setTextContent("in development");
		possibleStatus.appendChild(element);

		Element attachments = doc.createElement("ATTACHMENTS");
		task.appendChild(attachments);

		Element attachment = doc.createElement("ATTACHMENT");
		attachment.setTextContent("test");
		attachments.appendChild(attachment);

		TransformerFactory transformerFactory = TransformerFactory.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		DOMSource source = new DOMSource(doc);

		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		StreamResult result = new StreamResult(bos);
		transformer.transform(source, result);
		byte[] xml = bos.toByteArray();

		InputStream inputStream = new ByteArrayInputStream(xml);

		JAXBContext context = JAXBContext.newInstance(CharmTask.class);
		Unmarshaller taskUnmarshaller = context.createUnmarshaller();
		charmTask = (CharmTask) taskUnmarshaller.unmarshal(inputStream);

	}

	@Test
	public void testParsePartners() throws Exception {
		assertThat(charmTask.getPartners().get(0).getFunctionKey(), CoreMatchers.is("dev"));
		assertThat(charmTask.getPartners().get(0).getPartnerFunction(), CoreMatchers.is("developer"));
		assertThat(charmTask.getPartners().get(0).getPartnerName(), CoreMatchers.is("theits"));
	}

	@Test
	public void testParseComments() throws Exception {
		assertThat(charmTask.getComments().get(0).getAuthor(), CoreMatchers.is("theits"));
		assertThat(charmTask.getComments().get(0).getCreationDate(), CoreMatchers.is(df.parse("20170101124512")));
		assertThat(charmTask.getComments().get(0).getComments().get(0), CoreMatchers.is("comment"));
	}

	@Test
	public void testParseStauts() throws Exception {
		assertThat(charmTask.getPossibleStatus().get(0).getStatusKey(), CoreMatchers.is("dev"));
		assertThat(charmTask.getPossibleStatus().get(0).getStatusText(), CoreMatchers.is("in development"));
	}

	@Test
	public void testParseAttachment() throws Exception {
		assertThat(charmTask.getAttachments().get(0).getGuid(), CoreMatchers.is("test"));
	}

	@Test
	public void testParseHeader() throws Exception {

		assertThat(charmTask.getChangedAt(), CoreMatchers.is(df.parse("20170101124512")));
		assertThat(charmTask.getCreatedAt(), CoreMatchers.is(df.parse("20170101124512")));
		assertThat(charmTask.getCreatedBy(), CoreMatchers.is("theits"));
		assertThat(charmTask.getDescription(), CoreMatchers.is("description"));
		assertThat(charmTask.getGuid(), CoreMatchers.is("testguid"));
		assertThat(charmTask.getId(), CoreMatchers.is("testid"));
		assertThat(charmTask.getPriority(), CoreMatchers.is("1"));
		assertThat(charmTask.getStatus(), CoreMatchers.is("status"));

	}

}
