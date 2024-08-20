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
