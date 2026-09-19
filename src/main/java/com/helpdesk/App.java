package com.helpdesk;

import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

public class App {
    public static void main(String[] args) throws Exception {
        int port = 8080;
        String envPort = System.getenv("PORT");
        if (envPort != null && !envPort.trim().isEmpty()) {
            try {
                port = Integer.parseInt(envPort.trim());
            } catch (NumberFormatException ignored) {}
        }
        String portProp = System.getProperty("server.port");
        if (portProp != null && !portProp.trim().isEmpty()) {
            try {
                port = Integer.parseInt(portProp.trim());
            } catch (NumberFormatException ignored) {}
        }

        File baseDir = new File("target/tomcat");
        if (!baseDir.exists()) {
            baseDir.mkdirs();
        }

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.setBaseDir(baseDir.getAbsolutePath());
        tomcat.getConnector(); // trigger connector creation

        String webappDirLocation = "src/main/webapp";
        File webappDir = new File(webappDirLocation);

        StandardContext ctx = (StandardContext) tomcat.addWebapp("", webappDir.getAbsolutePath());
        ctx.setParentClassLoader(App.class.getClassLoader());

        File additionWebInfClasses = new File("target/classes");
        if (additionWebInfClasses.exists()) {
            WebResourceRoot resources = new StandardRoot(ctx);
            resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                    additionWebInfClasses.getAbsolutePath(), "/"));
            ctx.setResources(resources);
        }

        System.out.println("==================================================================");
        System.out.println("  🚀 HelpDesk Lite — Internal IT Ticketing & Asset Tracker");
        System.out.println("  🌐 Server running on: http://localhost:" + port);
        System.out.println("==================================================================");

        tomcat.start();
        tomcat.getServer().await();
    }
}
