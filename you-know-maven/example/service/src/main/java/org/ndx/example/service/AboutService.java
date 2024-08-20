package org.ndx.example.service;

import org.ndx.example.model.*;

public class AboutService {
    private final About about = new About();
    public About getAbout() {
        return about;
    }
    public String getVersion() {
        return about.getVersion();
    }
}
