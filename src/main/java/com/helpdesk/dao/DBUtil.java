package com.helpdesk.dao;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
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

        // Check environment variables
        String envDbUrl = System.getenv("JDBC_DATABASE_URL");
        if (envDbUrl == null || envDbUrl.isEmpty()) envDbUrl = System.getenv("DATABASE_URL");
        if (envDbUrl == null || envDbUrl.isEmpty()) envDbUrl = System.getenv("POSTGRES_URL");
        if (envDbUrl == null || envDbUrl.isEmpty()) envDbUrl = System.getenv("MYSQL_URL");

        // 1. Check if PostgreSQL is configured (e.g. Render Managed Postgres)
        boolean isPostgres = false;
        if (envDbUrl != null && !envDbUrl.isEmpty()) {
            if (envDbUrl.startsWith("postgres://") || envDbUrl.startsWith("postgresql://") || envDbUrl.startsWith("jdbc:postgresql:")) {
                isPostgres = true;
            }
        } else if (System.getenv("PGHOST") != null) {
            isPostgres = true;
        }

        if (isPostgres) {
            try {
                logger.info("Configuring PostgreSQL database connection...");
                String pgJdbcUrl = null;
                String pgUser = System.getenv("PGUSER");
                String pgPass = System.getenv("PGPASSWORD");

                if (envDbUrl != null && !envDbUrl.isEmpty()) {
                    if (envDbUrl.startsWith("postgres://") || envDbUrl.startsWith("postgresql://")) {
                        URI uri = new URI(envDbUrl);
                        String host = uri.getHost();
                        int port = uri.getPort() > 0 ? uri.getPort() : 5432;
                        String path = uri.getPath() != null ? uri.getPath() : "/helpdesk_db";
                        if (path.startsWith("/")) path = path.substring(1);

                        String userInfo = uri.getUserInfo();
                        if (userInfo != null && userInfo.contains(":")) {
                            String[] parts = userInfo.split(":", 2);
                            pgUser = parts[0];
                            pgPass = parts[1];
                        }

                        pgJdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + path;
                        if (uri.getQuery() != null && !uri.getQuery().isEmpty()) {
                            pgJdbcUrl += "?" + uri.getQuery();
                        } else {
                            pgJdbcUrl += "?sslmode=require";
                        }
                    } else if (envDbUrl.startsWith("jdbc:postgresql:")) {
                        pgJdbcUrl = envDbUrl;
                    }
                } else {
                    String host = System.getenv("PGHOST");
                    String port = System.getenv("PGPORT") != null ? System.getenv("PGPORT") : "5432";
                    String db = System.getenv("PGDATABASE") != null ? System.getenv("PGDATABASE") : "helpdesk_db";
                    pgJdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + db + "?sslmode=require";
                }

                HikariConfig pgConfig = new HikariConfig();
                pgConfig.setDriverClassName("org.postgresql.Driver");
                pgConfig.setJdbcUrl(pgJdbcUrl);
                if (pgUser != null && !pgUser.isEmpty()) pgConfig.setUsername(pgUser);
                if (pgPass != null) pgConfig.setPassword(pgPass);
                pgConfig.setMaximumPoolSize(10);
                pgConfig.setConnectionTimeout(5000);
                pgConfig.setInitializationFailTimeout(5000);

                HikariDataSource ds = new HikariDataSource(pgConfig);
                try (Connection conn = ds.getConnection()) {
                    dataSource = ds;
                    isFallbackMode = false;
                    activeDatabase = "PostgreSQL (Render / Cloud Engine)";
                    logger.info("Successfully connected to PostgreSQL database!");
                    initializeSchemaAndSeed(conn, "POSTGRES");
                    return;
                }
            } catch (Exception e) {
                logger.warn("PostgreSQL connection could not be established ({}), checking alternatives...", e.getMessage());
            }
        }

        // 2. Check if MySQL is configured
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

        if (envDbUrl != null && !envDbUrl.isEmpty() && (envDbUrl.startsWith("mysql://") || envDbUrl.startsWith("jdbc:mysql:"))) {
            if (envDbUrl.startsWith("mysql://")) {
                try {
                    URI uri = new URI(envDbUrl);
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
                    resolvedJdbcUrl = "jdbc:" + envDbUrl;
                }
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

        String dbType = props.getProperty("db.type", "auto");
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
                try (Connection conn = ds.getConnection()) {
                    dataSource = ds;
                    isFallbackMode = false;
                    activeDatabase = "MySQL 8.0 (Production Engine)";
                    logger.info("Successfully connected to MySQL database!");
                    initializeSchemaAndSeed(conn, "MYSQL");
                    return;
                }
            } catch (Exception e) {
                logger.warn("MySQL connection could not be established ({}), falling back to embedded database.", e.getMessage());
            }
        }

        // 3. Fallback to Embedded H2 in MySQL mode
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
                initializeSchemaAndSeed(conn, "H2");
            }
            logger.info("Embedded database successfully initialized and seeded!");
        } catch (Exception e) {
            logger.error("Failed to initialize database engine", e);
            throw new RuntimeException("Could not initialize database", e);
        }
    }

    private static void initializeSchemaAndSeed(Connection conn, String dbEngine) {
        try {
            boolean tablesExist = false;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT 1 FROM users LIMIT 1")) {
                if (rs.next()) {
                    tablesExist = true;
                }
            } catch (SQLException ignored) {
                // Table doesn't exist yet
            }

            if (!tablesExist) {
                logger.info("Running schema DDL for engine: {}...", dbEngine);
                executeSqlScript(conn, "schema.sql", dbEngine);
                logger.info("Populating initial seed data for engine: {}...", dbEngine);
                executeSqlScript(conn, "seed.sql", dbEngine);

                if ("POSTGRES".equalsIgnoreCase(dbEngine)) {
                    syncPostgresSequences(conn);
                }
            }
        } catch (Exception e) {
            logger.error("Error during schema/seed initialization: {}", e.getMessage(), e);
        }
    }

    private static void syncPostgresSequences(Connection conn) {
        String[] tables = {"users", "assets", "maintenance_logs", "tickets", "escalation_logs", "kb_articles"};
        for (String table : tables) {
            try (Statement st = conn.createStatement()) {
                st.execute("SELECT setval(pg_get_serial_sequence('" + table + "', 'id'), COALESCE((SELECT MAX(id) FROM " + table + "), 1))");
            } catch (SQLException e) {
                logger.debug("Sequence sync note for {}: {}", table, e.getMessage());
            }
        }
    }

    private static void executeSqlScript(Connection conn, String scriptName, String dbEngine) {
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

                    if ("POSTGRES".equalsIgnoreCase(dbEngine)) {
                        // Adapt syntax for PostgreSQL
                        line = line.replace("INT AUTO_INCREMENT PRIMARY KEY", "SERIAL PRIMARY KEY")
                                   .replace("AUTO_INCREMENT PRIMARY KEY", "SERIAL PRIMARY KEY")
                                   .replace("AUTO_INCREMENT", "SERIAL");
                        line = line.replaceAll("(?i)DATEADD\\s*\\(\\s*'HOUR'\\s*,\\s*(-?\\d+)\\s*,\\s*CURRENT_TIMESTAMP\\s*\\)", "(CURRENT_TIMESTAMP + INTERVAL '$1 HOUR')");
                        line = line.replaceAll("(?i)DATEADD\\s*\\(\\s*'MINUTE'\\s*,\\s*(-?\\d+)\\s*,\\s*CURRENT_TIMESTAMP\\s*\\)", "(CURRENT_TIMESTAMP + INTERVAL '$1 MINUTE')");
                        line = line.replaceAll("(?i)DATEADD\\s*\\(\\s*'DAY'\\s*,\\s*(-?\\d+)\\s*,\\s*CURRENT_TIMESTAMP\\s*\\)", "(CURRENT_TIMESTAMP + INTERVAL '$1 DAY')");
                    } else if ("MYSQL".equalsIgnoreCase(dbEngine)) {
                        // Adapt syntax for MySQL
                        line = line.replaceAll("(?i)DATEADD\\s*\\(\\s*'HOUR'\\s*,\\s*(-?\\d+)\\s*,\\s*CURRENT_TIMESTAMP\\s*\\)", "DATE_ADD(CURRENT_TIMESTAMP, INTERVAL $1 HOUR)");
                        line = line.replaceAll("(?i)DATEADD\\s*\\(\\s*'MINUTE'\\s*,\\s*(-?\\d+)\\s*,\\s*CURRENT_TIMESTAMP\\s*\\)", "DATE_ADD(CURRENT_TIMESTAMP, INTERVAL $1 MINUTE)");
                        line = line.replaceAll("(?i)DATEADD\\s*\\(\\s*'DAY'\\s*,\\s*(-?\\d+)\\s*,\\s*CURRENT_TIMESTAMP\\s*\\)", "DATE_ADD(CURRENT_TIMESTAMP, INTERVAL $1 DAY)");
                    }

                    sql.append(line).append(" ");
                    if (line.endsWith(";")) {
                        String stmtStr = sql.toString();
                        stmtStr = stmtStr.substring(0, stmtStr.lastIndexOf(';')).trim();
                        if (!stmtStr.isEmpty()) {
                            try {
                                statement.execute(stmtStr);
                            } catch (SQLException e) {
                                logger.debug("Statement note: {} -> {}", stmtStr, e.getMessage());
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
