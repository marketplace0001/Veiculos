package br.com.automarketplace.repo;
import br.com.automarketplace.model.RentalRequest; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface RentalRequestRepository extends JpaRepository<RentalRequest,Long>{List<RentalRequest> findByStoreIdOrderByCreatedAtDesc(Long storeId);}
