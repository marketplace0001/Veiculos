package br.com.automarketplace.repo;
import br.com.automarketplace.model.*; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface RentalVehicleRepository extends JpaRepository<RentalVehicle,Long>{List<RentalVehicle> findByStatusOrderByCreatedAtDesc(RentalVehicleStatus status);List<RentalVehicle> findByStoreIdOrderByCreatedAtDesc(Long storeId);long countByStatus(RentalVehicleStatus status);}
