package com.example;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class AppTest.java {

    @Test
    public void testGreet() {
        HelloWorld helloWorld = new HelloWorld();
        String result = helloWorld.greet("World");
        assertEquals("Hello, World!", result);
    }
}
