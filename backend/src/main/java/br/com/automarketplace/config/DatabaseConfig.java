package br.com.automarketplace.config;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

@Configuration
public class DatabaseConfig {

    @Bean
    public DataSource dataSource() {

        String databaseUrl = System.getenv("DATABASE_URL");

        if (databaseUrl == null || databaseUrl.isBlank()) {
            throw new IllegalStateException(
                "A variável de ambiente DATABASE_URL não foi encontrada."
            );
        }

        try {
            URI uri = URI.create(databaseUrl);

            String userInfo = uri.getUserInfo();

            if (userInfo == null || !userInfo.contains(":")) {
                throw new IllegalStateException(
                    "DATABASE_URL não contém usuário e senha válidos."
                );
            }

            String[] credentials = userInfo.split(":", 2);

            String username = URLDecoder.decode(
                credentials[0],
                StandardCharsets.UTF_8
            );

            String password = URLDecoder.decode(
                credentials[1],
                StandardCharsets.UTF_8
            );

            String host = uri.getHost();

            int port = uri.getPort();

            if (port == -1) {
                port = 5432;
            }

            String database = uri.getPath();

            if (database.startsWith("/")) {
                database = database.substring(1);
            }

            String jdbcUrl =
                "jdbc:postgresql://" +
                host +
                ":" +
                port +
                "/" +
                database;

            if (uri.getQuery() != null && !uri.getQuery().isBlank()) {
                jdbcUrl += "?" + uri.getQuery();
            }

            HikariDataSource dataSource = new HikariDataSource();

            dataSource.setJdbcUrl(jdbcUrl);
            dataSource.setUsername(username);
            dataSource.setPassword(password);
            dataSource.setDriverClassName("org.postgresql.Driver");

            dataSource.setMaximumPoolSize(5);
            dataSource.setMinimumIdle(1);
            dataSource.setConnectionTimeout(30000);
            dataSource.setIdleTimeout(600000);
            dataSource.setMaxLifetime(1800000);

            return dataSource;

        } catch (Exception e) {
            throw new IllegalStateException(
                "Erro ao configurar o PostgreSQL usando DATABASE_URL.",
                e
            );
        }
    }
}
