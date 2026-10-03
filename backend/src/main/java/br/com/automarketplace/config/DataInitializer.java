package br.com.automarketplace.config;

import br.com.automarketplace.model.City;
import br.com.automarketplace.model.RentalVehicle;
import br.com.automarketplace.model.Role;
import br.com.automarketplace.model.Store;
import br.com.automarketplace.model.StoreType;
import br.com.automarketplace.model.User;
import br.com.automarketplace.model.Vehicle;
import br.com.automarketplace.repo.CityRepository;
import br.com.automarketplace.repo.RentalVehicleRepository;
import br.com.automarketplace.repo.StoreRepository;
import br.com.automarketplace.repo.UserRepository;
import br.com.automarketplace.repo.VehicleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner seed(
            CityRepository cities,
            StoreRepository stores,
            UserRepository users,
            VehicleRepository vehicles,
            RentalVehicleRepository rentals,
            PasswordEncoder encoder
    ) {
        return args -> {
            if (cities.count() > 0) return;

            City c1 = cities.save(new City("Umuarama", "PR"));
            City c2 = cities.save(new City("Cascavel", "PR"));

            Store s1 = new Store("Prime Motors", c1, "5544999999999");
            s1.setType(StoreType.DEALER);
            s1 = stores.save(s1);

            Store s2 = new Store("Elite Veículos", c2, "5545999999999");
            s2.setType(StoreType.DEALER);
            s2 = stores.save(s2);

            Store rent = new Store("Localiza Fácil Umuarama", c1, "5544988888888");
            rent.setType(StoreType.RENTAL_COMPANY);
            rent.setDescription("Locadora local parceira da plataforma.");
            rent = stores.save(rent);

            User admin = new User();
            admin.setName("Administrador");
            admin.setEmail("admin@automarketplace.local");
            admin.setPasswordHash(encoder.encode("Admin@123"));
            admin.setRole(Role.ADMIN);
            users.save(admin);

            User dealer = new User();
            dealer.setName("Lojista Prime");
            dealer.setEmail("lojista@automarketplace.local");
            dealer.setPasswordHash(encoder.encode("Loja@123"));
            dealer.setRole(Role.DEALER);
            dealer.setStore(s1);
            users.save(dealer);

            User rental = new User();
            rental.setName("Gestor da Locadora");
            rental.setEmail("locadora@automarketplace.local");
            rental.setPasswordHash(encoder.encode("Locadora@123"));
            rental.setRole(Role.RENTAL);
            rental.setStore(rent);
            users.save(rental);

            createVehicle(vehicles, s1, "Toyota", "Corolla", "XEi", 2022,
                    new BigDecimal("119900"), 48000,
                    "https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=80");

            createVehicle(vehicles, s2, "Honda", "Civic", "Touring", 2021,
                    new BigDecimal("129900"), 36000,
                    "https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=1200&q=80");

            createRental(rentals, rent, "Chevrolet", "Onix", "LT", 2024, "Hatch",
                    new BigDecimal("149.90"),
                    "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=80");

            createRental(rentals, rent, "Jeep", "Renegade", "Longitude", 2023, "SUV",
                    new BigDecimal("239.90"),
                    "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=80");
        };
    }

    private static void createVehicle(
            VehicleRepository repository,
            Store store,
            String brand,
            String model,
            String version,
            int year,
            BigDecimal price,
            int mileage,
            String imageUrl
    ) {
        Vehicle vehicle = new Vehicle();
        vehicle.setStore(store);
        vehicle.setBrand(brand);
        vehicle.setModel(model);
        vehicle.setVersion(version);
        vehicle.setYearManufacture(year);
        vehicle.setYearModel(year);
        vehicle.setPrice(price);
        vehicle.setMileage(mileage);
        vehicle.setTransmission("Automático");
        vehicle.setFuel("Flex");
        vehicle.setImageUrl(imageUrl);
        vehicle.setDescription("Veículo de demonstração da versão 1.0.");
        repository.save(vehicle);
    }

    private static void createRental(
            RentalVehicleRepository repository,
            Store store,
            String brand,
            String model,
            String version,
            int year,
            String category,
            BigDecimal dailyRate,
            String imageUrl
    ) {
        RentalVehicle vehicle = new RentalVehicle();
        vehicle.setStore(store);
        vehicle.setBrand(brand);
        vehicle.setModel(model);
        vehicle.setVersion(version);
        vehicle.setYearModel(year);
        vehicle.setCategory(category);
        vehicle.setDailyRate(dailyRate);
        vehicle.setWeeklyRate(dailyRate.multiply(BigDecimal.valueOf(6)));
        vehicle.setMonthlyRate(dailyRate.multiply(BigDecimal.valueOf(24)));
        vehicle.setDepositAmount(new BigDecimal("500"));
        vehicle.setTransmission("Automático");
        vehicle.setFuel("Flex");
        vehicle.setSeats(5);
        vehicle.setAirConditioning(true);
        vehicle.setUnlimitedMileage(true);
        vehicle.setMinimumAge(21);
        vehicle.setImageUrl(imageUrl);
        vehicle.setRentalRules("CNH válida, idade mínima de 21 anos e análise cadastral.");
        repository.save(vehicle);
    }
}
