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

        System.out.println(
            "=============================================="
        );

        System.out.println(
            "AutoMarketplace - verificando banco de dados..."
        );

        try {

            Integer cityCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM cities",
                Integer.class
            );

            if (cityCount != null && cityCount == 0) {

                jdbcTemplate.update(
                    """
                    INSERT INTO cities
                    (
                        name,
                        state,
                        active
                    )
                    VALUES
                    (
                        ?,
                        ?,
                        ?
                    )
                    """,
                    "Cidade Piloto",
                    "RJ",
                    true
                );

                System.out.println(
                    "Cidade inicial criada."
                );

            } else {

                System.out.println(
                    "Tabela cities encontrada."
                );

            }


            Integer vehicleTable = jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = 'public'
                AND table_name = 'vehicles'
                """,
                Integer.class
            );

            if (
                vehicleTable != null &&
                vehicleTable > 0
            ) {

                System.out.println(
                    "Tabela vehicles encontrada."
                );

            }


            Integer storeTable = jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = 'public'
                AND table_name = 'stores'
                """,
                Integer.class
            );

            if (
                storeTable != null &&
                storeTable > 0
            ) {

                System.out.println(
                    "Tabela stores encontrada."
                );

            }


            Integer rentalVehicleTable =
                jdbcTemplate.queryForObject(
                    """
                    SELECT COUNT(*)
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    AND table_name = 'rental_vehicles'
                    """,
                    Integer.class
                );

            if (
                rentalVehicleTable != null &&
                rentalVehicleTable > 0
            ) {

                System.out.println(
                    "Tabela rental_vehicles encontrada."
                );

            }


            Integer rentalRequestTable =
                jdbcTemplate.queryForObject(
                    """
                    SELECT COUNT(*)
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    AND table_name = 'rental_requests'
                    """,
                    Integer.class
                );

            if (
                rentalRequestTable != null &&
                rentalRequestTable > 0
            ) {

                System.out.println(
                    "Tabela rental_requests encontrada."
                );

            }


            System.out.println(
                "Banco de dados inicializado com sucesso."
