package br.com.automarketplace.api;
import br.com.automarketplace.model.*; import br.com.automarketplace.repo.*; import org.springframework.http.*; import org.springframework.web.bind.annotation.*; import java.time.*; import java.time.temporal.ChronoUnit; import java.math.BigDecimal; import java.util.Map;
@RestController @RequestMapping("/api/public/rentals") public class RentalPublicController {
 private final RentalVehicleRepository vehicles; private final RentalRequestRepository requests;
 public RentalPublicController(RentalVehicleRepository v,RentalRequestRepository r){vehicles=v;requests=r;}
 @GetMapping java.util.List<RentalVehicle> list(){return vehicles.findByStatusOrderByCreatedAtDesc(RentalVehicleStatus.AVAILABLE);}
 public record Request(String name,String phone,String email,Long rentalVehicleId,LocalDate pickupDate,LocalDate returnDate,String notes){}
 @PostMapping("/requests") ResponseEntity<?> request(@RequestBody Request x){var v=vehicles.findById(x.rentalVehicleId()).orElseThrow();if(v.getStatus()!=RentalVehicleStatus.AVAILABLE)throw new RuntimeException("Veículo indisponível");var days=(int)Math.max(1,ChronoUnit.DAYS.between(x.pickupDate(),x.returnDate()));var r=new RentalRequest();r.setName(x.name());r.setPhone(x.phone());r.setEmail(x.email());r.setRentalVehicle(v);r.setStore(v.getStore());r.setCity(v.getStore().getCity());r.setPickupDate(x.pickupDate());r.setReturnDate(x.returnDate());r.setDays(days);r.setEstimatedTotal(v.getDailyRate().multiply(BigDecimal.valueOf(days)));r.setNotes(x.notes());requests.save(r);return ResponseEntity.status(201).body(Map.of("id",r.getId(),"days",days,"estimatedTotal",r.getEstimatedTotal(),"status",r.getStatus()));}
}
