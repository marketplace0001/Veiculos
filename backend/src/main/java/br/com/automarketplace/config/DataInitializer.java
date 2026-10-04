package br.com.automarketplace;

import br.com.automarketplace.model.City;
import br.com.automarketplace.repo.CityRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;
    private final CityRepository cityRepository;

    public DataInitializer(
            JdbcTemplate jdbcTemplate,
            CityRepository cityRepository
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.cityRepository = cityRepository;
    }

    @Override
    public void run(String... args) {

        // Garante a criação da tabela antes de qualquer consulta JPA
        jdbcTemplate.execute("""
            CREATE TABLE IF NOT EXISTS cities (
                id BIGSERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                state VARCHAR(2) NOT NULL,
                active BOOLEAN NOT NULL DEFAULT TRUE
            )
        """);

        // Só consulta depois que a tabela está garantida
        if (cityRepository.count() == 0) {

            City city = new City(
                    "Cidade Piloto",
                    "SP"
            );

            cityRepository.save(city);
        }

        System.out.println("Banco de dados inicializado com sucesso.");
    }
}
