@Grapes([
    @Grab(group='com.structurizr', module='structurizr-dsl', version='1.23.0'),
    @GrabExclude(group="com.fasterxml.jackson.core", module="jackson-annotations"),
    // https://mvnrepository.com/artifact/com.structurizr/structurizr-export
    @Grab(group='com.structurizr', module='structurizr-export', version='1.8.3')
])
import groovy.util.logging.Log

import java.util.logging.*
import com.structurizr.*;
import com.structurizr.export.plantuml.*;
import com.structurizr.model.*;
import com.structurizr.dsl.*;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;

import groovy.cli.commons.*
import groovy.cli.*

class CustomFormatter extends SimpleFormatter {
    /**
    * @see https://stackoverflow.com/a/25547501/15619
    */
    public static final String ANSI_RESET = "\u001B[0m";
    public static final String ANSI_BLACK = "\u001B[30m";
    public static final String ANSI_RED = "\u001B[31m";
    public static final String ANSI_GREEN = "\u001B[32m";
    public static final String ANSI_YELLOW = "\u001B[33m";
    public static final String ANSI_BLUE = "\u001B[34m";
    public static final String ANSI_PURPLE = "\u001B[35m";
    public static final String ANSI_CYAN = "\u001B[36m";
    public static final String ANSI_WHITE = "\u001B[37m";

    public String format(LogRecord record) {
        def returned = switch(record.level) {
            case Level.SEVERE -> ANSI_RED + "🚨 "
            case Level.WARNING -> ANSI_YELLOW + "⚠ "
            case Level.INFO -> ANSI_BLUE + "ℹ "
            case Level.CONFIG -> ANSI_PURPLE + "🛠 "
            case Level.FINE -> ANSI_GREEN + "✅ "
            case Level.FINER -> ANSI_GREEN + "✅ "
        }
        returned += "${record.message}"
        return returned+ANSI_RESET+"\n"
    }
}

def rootLogger = Logger.getLogger("")
rootLogger.getHandlers()[0].setFormatter(new CustomFormatter())
/**
 * An example of reporting built by exploring the workspace.dsl file
 * Only requires a Groovy interpreter
 */

@Log
class ToPlantUML {
    Workspace parse(File workspaceFile) throws Exception {
        StructurizrDslParser parser = new StructurizrDslParser();
		parser.parse(workspaceFile)
		return parser.getWorkspace()
    }
    def writeDiagrams(Workspace workspace) {
        C4PlantUMLExporter plantUMLWriter = new C4PlantUMLExporter();
        plantUMLWriter.addSkinParam("pathHoverColor", "GreenYellow");
		plantUMLWriter.addSkinParam("ArrowThickness", "3");
		plantUMLWriter.addSkinParam("svgLinkTarget", "_parent");
		
        File destination = new File("target/diagrams")
        destination.mkdirs()
		
		plantUMLWriter.export(workspace).stream().parallel()
			.forEach(diagram -> {
				// Incredibly enough, that's not a view!
				Path path = new File(destination, diagram.getKey()+".plantuml").toPath();
				try {
					Files.write(
							path, 
							diagram.getDefinition().getBytes(Charset.forName("UTF-8")));
					log.info(String.format("Generated diagram %s in file %s", diagram.getKey(), path));
				} catch(IOException e) {
					throw new RuntimeException(
							String.format("Can't write diagram %s in file %s",
									diagram.getKey(), path),
							e);
				}
			});
    }
    def execute(File workspaceFile) throws Exception {
        Workspace parsed = parse workspaceFile
        writeDiagrams(parsed)
    }
}

def cli = new CliBuilder(usage: 'groovy Greeter')  
cli.h(type: boolean, longOpt: 'help', 'Show help')

def options = cli.parse(args)             

if(options.h) {
    cli.usage()
} else {
    options.arguments().each {
        new ToPlantUML().execute(new File(it))
    }
}