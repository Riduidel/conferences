@Grapes([
    @Grab(group='com.structurizr', module='structurizr-dsl', version='1.23.0'),
    @GrabExclude(group="com.fasterxml.jackson.core", module="jackson-annotations")
])
import groovy.util.logging.Log

import java.util.logging.*
import com.structurizr.*;
import com.structurizr.model.*;
import com.structurizr.dsl.*;

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
        def returned = ""
        switch(record.level) {
            case Level.SEVERE: returned += ANSI_RED + "🚨 "; break;
            case Level.WARNING: returned += ANSI_YELLOW + "⚠ "; break;
            case Level.INFO: returned += ANSI_BLUE + "ℹ "; break;
            case Level.CONFIG: returned += ANSI_PURPLE + "🛠 "; break;
            case Level.FINE: returned += ANSI_GREEN + "✅ "; break;
            case Level.FINER: returned += ANSI_GREEN + "✅ "; break;
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
class Linter {
    Workspace parse(File workspaceFile) throws Exception {
        log.info "Parsing file "+workspaceFile.absolutePath
        StructurizrDslParser parser = new StructurizrDslParser();
		parser.parse(workspaceFile)
		return parser.getWorkspace()
    }
    def lintElement(Element element) {
        if(element?.description.isBlank())
            log.warning "\"${element.canonicalName}\" has no description set"
    }
    def lintPerson(Person person) {
        lintElement(person)
    }
    def lintContainer(Container container) {
        lintElement(container)
        if(container?.technology.isBlank()) {
            log.warning "\"${container.canonicalName}\" has no technology defined"
        }
    }
    def lintSoftwareSystem(SoftwareSystem softwareSystem) {
        lintElement(softwareSystem)
        softwareSystem.containers.each {
            lintContainer(it)
        }
    }
    def lintRelationship(Relationship relationship) {
        if(relationship?.description.isBlank())
            log.warning "\"${relationship.canonicalName}\" has no description set"
        if(relationship?.technology.isBlank())
            log.warning "\"${relationship.canonicalName}\" has no technology set"
    }
    def lintModel(Model model) {
        model.people.each {
            lintPerson(it)
        }
        model.softwareSystems.each {
            switch(it.location) {
                case Location.Unspecified:
                    log.warning "\"${it.canonicalName}\" has no location defined. We consider it as internal"
                case Location.Internal:
                    lintSoftwareSystem(it)
                    break
                case Location.External:
                    log.warning "\"${it.canonicalName}\" is an external system, we don't want to analyze it any further"
                    break
            }
        }
        model.relationships.each {
            lintRelationship(it)
        }
    }
    def execute(File workspaceFile) throws Exception {
        Workspace parsed = parse workspaceFile
        log.info "parsing workspace "+parsed.name
        lintModel(parsed.model)
    }
}

def cli = new CliBuilder(usage: 'groovy linter.groovy workspace.dsl')  
cli.h(type: boolean, longOpt: 'help', 'Show help')

def options = cli.parse(args)             

if(options.h) {
    cli.usage()
} else {
    def listChoices = new Linter()
    options.arguments().each {
        listChoices.execute(new File(it))
    }
}