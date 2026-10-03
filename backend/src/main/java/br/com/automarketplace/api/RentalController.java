package br.com.automarketplace.api;
import br.com.automarketplace.model.*; import br.com.automarketplace.repo.*; import org.springframework.security.core.Authentication; import org.springframework.web.bind.annotation.*; import java.time.temporal.ChronoUnit; import java.math.BigDecimal; import java.util.List;
@RestController @RequestMapping("/api/rental") public class RentalController {
 private final UserRepository users; private final RentalVehicleRepository vehicles; private final RentalRequestRepository requests;
 public RentalController(UserRepository u,RentalVehicleRepository v,RentalRequestRepository r){users=u;vehicles=v;requests=r;}
 private User current(Authentication a){return users.findByEmail(a.getName()).orElseThrow();}
 @GetMapping("/vehicles") List<RentalVehicle> vehicles(Authentication a){return vehicles.findByStoreIdOrderByCreatedAtDesc(current(a).getStore().getId());}
 @PostMapping("/vehicles") RentalVehicle create(@RequestBody RentalVehicle v,Authentication a){v.setStore(current(a).getStore());return vehicles.save(v);}
 @PatchMapping("/vehicles/{id}/status") RentalVehicle status(@PathVariable Long id,@RequestParam RentalVehicleStatus status,Authentication a){var v=vehicles.findById(id).orElseThrow();if(!v.getStore().getId().equals(current(a).getStore().getId()))throw new RuntimeException("Sem permissão");v.setStatus(status);return vehicles.save(v);}
 @GetMapping("/requests") List<RentalRequest> requests(Authentication a){return requests.findByStoreIdOrderByCreatedAtDesc(current(a).getStore().getId());}
 @PatchMapping("/requests/{id}/status") RentalRequest requestStatus(@PathVariable Long id,@RequestParam RentalRequestStatus status,Authentication a){var r=requests.findById(id).orElseThrow();if(!r.getStore().getId().equals(current(a).getStore().getId()))throw new RuntimeException("Sem permissão");r.setStatus(status);return requests.save(r);}
}
