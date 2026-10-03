package br.com.automarketplace.api;
import br.com.automarketplace.model.*; import br.com.automarketplace.repo.*; import org.springframework.security.core.Authentication; import org.springframework.web.bind.annotation.*; import java.util.List;
@RestController @RequestMapping("/api/dealer") public class DealerController {
 private final UserRepository users; private final VehicleRepository vehicles; private final LeadRepository leads; public DealerController(UserRepository u,VehicleRepository v,LeadRepository l){users=u;vehicles=v;leads=l;}
 private User current(Authentication a){return users.findByEmail(a.getName()).orElseThrow();}
 @GetMapping("/vehicles") List<Vehicle> vehicles(Authentication a){return vehicles.findByStoreIdOrderByCreatedAtDesc(current(a).getStore().getId());}
 @PostMapping("/vehicles") Vehicle create(@RequestBody Vehicle v,Authentication a){v.setStore(current(a).getStore());return vehicles.save(v);}
 @PatchMapping("/vehicles/{id}/status") Vehicle status(@PathVariable Long id,@RequestParam VehicleStatus status,Authentication a){var v=vehicles.findById(id).orElseThrow();if(!v.getStore().getId().equals(current(a).getStore().getId()))throw new RuntimeException("Sem permissão");v.setStatus(status);return vehicles.save(v);}
 @GetMapping("/leads") List<Lead> leads(Authentication a){return leads.findByStoreIdOrderByCreatedAtDesc(current(a).getStore().getId());}
}
