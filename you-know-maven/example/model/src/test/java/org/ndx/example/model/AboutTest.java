package org.ndx.example.model;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class AboutTest {

    @Test
    public void can_get_correct_version() {
        assertThat(new About().getVersion()).isEqualTo("1.0-SNAPSHOT");
    }

    @Test
    public void can_get_a_non_null_branch() {
        assertThat(new About().getBranch()).isNotNull();
    }

    @Test
    public void can_get_a_non_null_build_number() {
        assertThat(new About().getBuildNumber()).isNotNull();
    }

}
