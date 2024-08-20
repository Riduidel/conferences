package org.ndx.example.model;
import java.util.*;
import java.io.*;
public class About {
    private final String version;
    private final String buildNumber;
    private final String branch;
    public About() {
        try {
            try(InputStream input = getClass().getClassLoader().getResourceAsStream("version.properties")) {
                Properties p = new Properties();
                p.load(input);
                version = p.getProperty("version");
                buildNumber = p.getProperty("buildNumber");
                branch = p.getProperty("branch");
            }
        } catch(IOException e) {
            throw new RuntimeException("can't read version.properties", e);
        }
    }
    public String getVersion() {
        return version;
    }
    public String getBuildNumber() {
        return buildNumber;
    }
    public String getBranch() {
        return branch;
    }
}
