package br.com.automarketplace.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    public DataInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {

        System.out.println("==============================================");
        System.out.println("AutoMarketplace - verificando banco de dados...");

        Integer citiesTable = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) " +
                "FROM information_schema.tables " +
                "WHERE table_schema = 'public' " +
                "AND table_name = 'cities'",
                Integer.class
        );

        if (citiesTable != null && citiesTable > 0) {

            System.out.println("Tabela cities encontrada.");

            Integer cityCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM cities",
                    Integer.class
            );

            if (cityCount != null && cityCount == 0) {

                jdbcTemplate.update(
                        "INSERT INTO cities (name, state, active) VALUES (?, ?, ?)",
                        "Cidade Piloto",
                        "RJ",
                        true
                );

                System.out.println("Cidade inicial criada.");
            }

        } else {
            System.out.println("ATENCAO: tabela cities ainda nao existe.");
        }

        verificarTabela("stores");
        verificarTabela("users");
        verificarTabela("vehicles");
        verificarTabela("rental_vehicles");
        verificarTabela("leads");
        verificarTabela("rental_requests");

        System.out.println("Verificacao do banco concluida.");
        System.out.println("==============================================");
    }

    private void verificarTabela(String tabela) {

        Integer quantidade = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) " +
                "FROM information_schema.tables " +
                "WHERE table_schema = 'public' " +
                "AND table_name = ?",
                Integer.class,
                tabela
        );

        if (quantidade != null && quantidade > 0) {
            System.out.println("Tabela " + tabela + " encontrada.");
        } else {
            System.out.println("ATENCAO: tabela " + tabela + " nao encontrada.");
        }
    }
}
