#!/bin/bash
mcd()
{
    test -d "$1" || mkdir "$1" && cd "$1"
}

# Create parent pom
pom-cli id org.ndx.conferences.maven:about:1.0-SNAPSHOT --standalone --as=pom -Ddebug=true
pom-cli add --test org.junit.jupiter:junit-jupiter
pom-cli add --test org.assertj:assertj-core
pom-cli plug org.apache.maven.plugins:maven-failsafe-plugin
pom-cli plug org.apache.maven.plugins:maven-surefire-plugin

mcd model
pom-cli id org.ndx.conferences.maven:model
pom-cli add --test org.junit.jupiter:junit-jupiter
pom-cli add --test org.assertj:assertj-core
pom-cli plug org.apache.maven.plugins:maven-surefire-plugin
mkdir -p src/main/java/org/ndx/example/model
cat <<EOF >src/main/java/org/ndx/example/model/About.java
package org.ndx.example.model;

import java.util.*;
import java.io.*;

public class About {
    public String getVersion() {
        throw new UnsupportedOperationException(String.format("TODO implement %s#%s(...)", About.class.getName(), "getVersion"));
    }
}
EOF

cd ..
mcd service
pom-cli id org.ndx.conferences.maven:service
pom-cli add ../model
pom-cli add --test org.junit.jupiter:junit-jupiter
pom-cli add --test org.assertj:assertj-core
mkdir -p src/main/java/org/ndx/example/service
cat <<EOF >src/main/java/org/ndx/example/service/AboutService.java
package org.ndx.example.service;

import org.ndx.example.model.*;

public class AboutService {
    About about = new About();
    public String getVersion() {
        return about.getVersion();
    }
}
EOF
cd ..
mcd web
pom-cli id org.ndx.conferences.maven:web
mkdir -p src/main/java/org/ndx/example
pom-cli add ../service
pom-cli add io.javalin:javalin-bundle:6.2.0
pom-cli add --test org.junit.jupiter:junit-jupiter
pom-cli add --test org.assertj:assertj-core
pom-cli add --test io.rest-assured:rest-assured:5.5.0
pom-cli plug maven-failsafe-plugin
mkdir -p src/main/java/org/ndx/example/web
cat <<EOF >src/main/java/org/ndx/example/web/AboutWeb.java
package org.ndx.example.web;

import org.ndx.example.service.*;

import io.javalin.Javalin;
import io.javalin.http.Context;

public class AboutWeb {
    AboutService service = new AboutService();
    public static void main(String[] args) {
        AboutWeb web = new AboutWeb();
        web.start();
    }
	public void start() {
        createApp().start(7070);
	}
	public Javalin createApp() {
		return Javalin.create(/*config*/)
                .get("/about", this::getVersion);
    }
	public void getVersion(Context ctx) {
		ctx.result(service.getVersion());
	}
}
EOF
mkdir -p src/test/java/org/ndx/example/web
cat <<EOF >src/test/java/org/ndx/example/web/AboutWebIT.java
package org.ndx.example.web;

import io.javalin.Javalin;
import io.javalin.testtools.JavalinTest;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class AboutWebIT {

    Javalin app = new AboutWeb().createApp(); // inject any dependencies you might have

    @Test
    public void GET_returns_the_correct_value() {
        JavalinTest.test(app, (server, client) -> {
            assertThat(client.get("/about").code()).isEqualTo(200);
            assertThat(client.get("/about").body().string()).isEqualTo("1.0-SNAPSHOT");
        });
    }

}
EOF
