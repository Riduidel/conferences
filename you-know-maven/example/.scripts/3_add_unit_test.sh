#!/bin/bash

mkdir -p model/src/test/java/org/ndx/example/model

cat <<EOF > model/src/test/java/org/ndx/example/model/AboutTest.java
package org.ndx.example.model;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class AboutTest {

    @Test
    public void can_get_correct_version() {
        assertThat(new About().getVersion()).isEqualTo("1.0-SNAPSHOT");
    }

}
EOF
