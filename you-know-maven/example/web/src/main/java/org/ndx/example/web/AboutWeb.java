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
