package com.helpdesk.dao;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class DBUtil {
    private static final Logger logger = LoggerFactory.getLogger(DBUtil.class);
    private static HikariDataSource dataSource;
    private static boolean isFallbackMode = false;
    private static String activeDatabase = "Unknown";

    static {
        initDataSource();
    }

    private static synchronized void initDataSource() {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }

        Properties props = new Properties();
        try (InputStream in = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (Exception e) {
            logger.warn("Could not load db.properties, using embedded defaults", e);
        }

        // Check environment variables first
        String envDbUrl = System.getenv("JDBC_DATABASE_URL");
        if (envDbUrl == null || envDbUrl.isEmpty()) {
            envDbUrl = System.getenv("MYSQL_URL");
        }
        if (envDbUrl == null || envDbUrl.isEmpty()) {
            envDbUrl = System.getenv("DATABASE_URL");
        }

        String envUser = System.getenv("MYSQL_USER");
        if (envUser == null || envUser.isEmpty()) envUser = System.getenv("DB_USER");
        if (envUser == null || envUser.isEmpty()) envUser = System.getenv("MYSQLUSER");

        String envPass = System.getenv("MYSQL_PASSWORD");
        if (envPass == null || envPass.isEmpty()) envPass = System.getenv("DB_PASSWORD");
        if (envPass == null || envPass.isEmpty()) envPass = System.getenv("MYSQLPASSWORD");

        String envHost = System.getenv("MYSQL_HOST");
        if (envHost == null || envHost.isEmpty()) envHost = System.getenv("DB_HOST");
        String envPort = System.getenv("MYSQL_PORT");
        if (envPort == null || envPort.isEmpty()) envPort = System.getenv("DB_PORT");
        String envDbName = System.getenv("MYSQL_DATABASE");
        if (envDbName == null || envDbName.isEmpty()) envDbName = System.getenv("DB_NAME");

        String resolvedJdbcUrl = props.getProperty("db.mysql.url", "jdbc:mysql://localhost:3306/helpdesk_db?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
        String resolvedUser = props.getProperty("db.mysql.user", "root");
        String resolvedPass = props.getProperty("db.mysql.password", "root");

        if (envDbUrl != null && !envDbUrl.isEmpty()) {
            if (envDbUrl.startsWith("mysql://")) {
                try {
                    java.net.URI uri = new java.net.URI(envDbUrl);
                    String host = uri.getHost();
                    int p = uri.getPort() > 0 ? uri.getPort() : 3306;
                    String path = uri.getPath() != null ? uri.getPath() : "/helpdesk_db";
                    if (path.startsWith("/")) path = path.substring(1);
                    String userInfo = uri.getUserInfo();
                    if (userInfo != null && userInfo.contains(":")) {
                        String[] parts = userInfo.split(":", 2);
                        resolvedUser = parts[0];
                        resolvedPass = parts[1];
                    }
                    resolvedJdbcUrl = "jdbc:mysql://" + host + ":" + p + "/" + path + "?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                } catch (Exception e) {
                    logger.warn("Could not parse mysql:// URL, using raw with jdbc: prefix", e);
                    resolvedJdbcUrl = "jdbc:" + envDbUrl;
                }
            } else if (!envDbUrl.startsWith("jdbc:")) {
                resolvedJdbcUrl = "jdbc:" + envDbUrl;
            } else {
                resolvedJdbcUrl = envDbUrl;
            }
        } else if (envHost != null && !envHost.isEmpty()) {
            int p = (envPort != null && !envPort.isEmpty()) ? Integer.parseInt(envPort) : 3306;
            String db = (envDbName != null && !envDbName.isEmpty()) ? envDbName : "helpdesk_db";
            resolvedJdbcUrl = "jdbc:mysql://" + envHost + ":" + p + "/" + db + "?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        }

        if (envUser != null && !envUser.isEmpty()) resolvedUser = envUser;
        if (envPass != null) resolvedPass = envPass;

        // Try MySQL first if configured
        String dbType = props.getProperty("db.type", "auto");
        boolean triedMysql = false;

        if ("mysql".equalsIgnoreCase(dbType) || "auto".equalsIgnoreCase(dbType)) {
            try {
                logger.info("Attempting to connect to MySQL database at {}...", resolvedJdbcUrl.replaceAll(":[^:@]+@", ":****@"));
                HikariConfig mysqlConfig = new HikariConfig();
                mysqlConfig.setDriverClassName(props.getProperty("db.mysql.driver", "com.mysql.cj.jdbc.Driver"));
                mysqlConfig.setJdbcUrl(resolvedJdbcUrl);
                mysqlConfig.setUsername(resolvedUser);
                mysqlConfig.setPassword(resolvedPass);
                mysqlConfig.setMaximumPoolSize(10);
                mysqlConfig.setConnectionTimeout(3000);
                mysqlConfig.setInitializationFailTimeout(3000);

                HikariDataSource ds = new HikariDataSource(mysqlConfig);
                // Test connection
                try (Connection conn = ds.getConnection()) {
                    dataSource = ds;
                    isFallbackMode = false;
                    activeDatabase = "MySQL 8.0 (Production Engine)";
                    logger.info("Successfully connected to MySQL database!");
                    initializeSchemaAndSeed(conn, false);
                    return;
                }
            } catch (Exception e) {
                triedMysql = true;
                logger.warn("MySQL connection could not be established ({}), falling back to embedded MySQL-mode database.", e.getMessage());
            }
        }

        // Fallback to Embedded H2 in MySQL mode
        try {
            logger.info("Initializing embedded MySQL-compatible database...");
            HikariConfig h2Config = new HikariConfig();
            h2Config.setDriverClassName(props.getProperty("db.h2.driver", "org.h2.Driver"));
            h2Config.setJdbcUrl(props.getProperty("db.h2.url", "jdbc:h2:mem:helpdesk_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE;CASE_INSENSITIVE_IDENTIFIERS=TRUE"));
            h2Config.setUsername(props.getProperty("db.h2.user", "sa"));
            h2Config.setPassword(props.getProperty("db.h2.password", ""));
            h2Config.setMaximumPoolSize(10);

            dataSource = new HikariDataSource(h2Config);
            isFallbackMode = true;
            activeDatabase = "Embedded H2 (MySQL 8.0 Compatibility Mode)";
            try (Connection conn = dataSource.getConnection()) {
                initializeSchemaAndSeed(conn, true);
            }
            logger.info("Embedded database successfully initialized and seeded!");
        } catch (Exception e) {
            logger.error("Failed to initialize database engine", e);
            throw new RuntimeException("Could not initialize database", e);
        }
    }

    private static void initializeSchemaAndSeed(Connection conn, boolean isH2) {
        try {
            // Check if users table exists
            boolean tablesExist = false;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT count(*) FROM users")) {
                if (rs.next()) {
                    tablesExist = true;
                }
            } catch (SQLException ignored) {
                // Table doesn't exist yet
            }

            if (!tablesExist) {
                logger.info("Running schema DDL...");
                executeSqlScript(conn, "schema.sql", isH2);
                logger.info("Populating initial seed data...");
                executeSqlScript(conn, "seed.sql", isH2);
            }
        } catch (Exception e) {
            logger.error("Error during schema/seed initialization: {}", e.getMessage(), e);
        }
    }

    private static void executeSqlScript(Connection conn, String scriptName, boolean isH2) {
        try (InputStream in = DBUtil.class.getClassLoader().getResourceAsStream(scriptName)) {
            if (in == null) {
                logger.warn("SQL script not found: {}", scriptName);
                return;
            }
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
                 Statement statement = conn.createStatement()) {

                StringBuilder sql = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (line.startsWith("--") || line.isEmpty()) {
                        continue;
                    }
                    // For MySQL syntax compatibility if running in pure MySQL vs H2
                    if (!isH2 && line.contains("DATEADD('HOUR'")) {
                        line = line.replace("DATEADD('HOUR',", "DATE_ADD(CURRENT_TIMESTAMP, INTERVAL ")
                                   .replace(", CURRENT_TIMESTAMP)", " HOUR)");
                    }
                    sql.append(line).append(" ");
                    if (line.endsWith(";")) {
                        String stmtStr = sql.toString();
                        stmtStr = stmtStr.substring(0, stmtStr.lastIndexOf(';')).trim();
                        if (!stmtStr.isEmpty()) {
                            try {
                                statement.execute(stmtStr);
                            } catch (SQLException e) {
                                logger.debug("Statement execution note: {} -> {}", stmtStr, e.getMessage());
                            }
                        }
                        sql.setLength(0);
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Failed to execute {}: {}", scriptName, e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            initDataSource();
        }
        return dataSource.getConnection();
    }

    public static boolean isFallbackMode() {
        return isFallbackMode;
    }

    public static String getActiveDatabase() {
        return activeDatabase;
    }

    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}
