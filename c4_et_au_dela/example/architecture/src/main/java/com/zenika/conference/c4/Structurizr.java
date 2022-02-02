package com.zenika.conference.c4;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.logging.Logger;

import org.apache.commons.io.FileUtils;

import com.pivovarit.function.ThrowingConsumer;
import com.structurizr.Workspace;
import com.structurizr.analysis.ComponentFinder;
import com.structurizr.analysis.ReferencedTypesSupportingTypesStrategy;
import com.structurizr.analysis.SpringComponentFinderStrategy;
import com.structurizr.io.WorkspaceReader;
import com.structurizr.io.WorkspaceReaderException;
import com.structurizr.io.json.JsonReader;
import com.structurizr.io.plantuml.C4PlantUMLWriter;
import com.structurizr.io.plantuml.PlantUMLDiagram;
import com.structurizr.model.Container;
import com.structurizr.model.Model;
import com.structurizr.model.SoftwareSystem;
import com.structurizr.view.ComponentView;
import com.structurizr.view.ViewSet;

public class Structurizr {
	public static final Logger logger = Logger.getLogger(Structurizr.class.getName());
	
	
	public static void main(String[] args) throws Throwable {
		Workspace workspace = readFromJson();
		Model model = workspace.getModel();
		SoftwareSystem system = model.getSoftwareSystemWithName("Pet Clinic");
		Container webapp = system.getContainerWithName("Web Application");
		// Now it's time to read components from Spring code!
		SpringComponentFinderStrategy springComponentFinderStrategy = new SpringComponentFinderStrategy(
		        new ReferencedTypesSupportingTypesStrategy(false)
		);
		springComponentFinderStrategy.setIncludePublicTypesOnly(false);
		ComponentFinder componentFinder = new ComponentFinder(
			    webapp, "org.springframework.samples.petclinic",
			    springComponentFinderStrategy);

			componentFinder.findComponents();
			
		logger.info(String.format("Found %d components in webapp", webapp.getComponents().size()));
		// Now we can add a component view
		ViewSet views = workspace.getViews();
		ComponentView components = views.createComponentView(webapp, "components", "components of webapp");
		components.addAllComponents();
		// And now, write views !
		File destination = new File("target/diagrams");
		destination.mkdirs();
		C4PlantUMLWriter writer = new C4PlantUMLWriter();
		writer.toPlantUMLDiagrams(workspace).stream()
			.forEach(ThrowingConsumer.unchecked(diagram -> writeDiagram(destination, diagram)));
		
	}

	static void writeDiagram(File folder, PlantUMLDiagram diagram) throws IOException {
		File file = new File(folder, diagram.getKey()+".plantuml");
		FileUtils.write(file, diagram.getDefinition(), "UTF-8");
		logger.info(String.format("Written diagram %s", diagram.getName()));
	}
	
	private static Workspace readFromJson() throws WorkspaceReaderException, FileNotFoundException, IOException {
		try(FileReader fileReader = new FileReader(new File("workspace.json"))) {
			WorkspaceReader workspaceReader = new JsonReader();
			return workspaceReader.read(fileReader);
		}
	}
}
