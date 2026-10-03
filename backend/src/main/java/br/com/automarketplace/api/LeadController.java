package br.com.automarketplace.api;
import br.com.automarketplace.model.*; import br.com.automarketplace.repo.*; import org.springframework.http.*; import org.springframework.web.bind.annotation.*; import java.util.Map;
@RestController @RequestMapping("/api/leads") public class LeadController {
 private final LeadRepository leads; private final VehicleRepository vehicles; private final CityRepository cities; public LeadController(LeadRepository l,VehicleRepository v,CityRepository c){leads=l;vehicles=v;cities=c;}
 public record LeadRequest(String name,String phone,String email,LeadType type,Long vehicleId,Long cityId,String notes){}
 @PostMapping ResponseEntity<?> create(@RequestBody LeadRequest r){var lead=new Lead();lead.setName(r.name());lead.setPhone(r.phone());lead.setEmail(r.email());lead.setType(r.type()==null?LeadType.INTEREST:r.type());lead.setNotes(r.notes());if(r.vehicleId()!=null){var v=vehicles.findById(r.vehicleId()).orElseThrow();lead.setVehicle(v);lead.setStore(v.getStore());lead.setCity(v.getStore().getCity());}else if(r.cityId()!=null)cities.findById(r.cityId()).ifPresent(lead::setCity);leads.save(lead);return ResponseEntity.status(201).body(Map.of("id",lead.getId(),"status",lead.getStatus()));}
}
