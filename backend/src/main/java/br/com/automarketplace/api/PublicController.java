package br.com.automarketplace.api;
import br.com.automarketplace.model.*; import br.com.automarketplace.repo.*; import org.springframework.web.bind.annotation.*; import java.util.List;
@RestController @RequestMapping("/api/public") public class PublicController {
 private final VehicleRepository vehicles; private final StoreRepository stores; private final CityRepository cities; public PublicController(VehicleRepository v,StoreRepository s,CityRepository c){vehicles=v;stores=s;cities=c;}
 @GetMapping("/vehicles") List<Vehicle> vehicles(){return vehicles.findByStatus(VehicleStatus.ACTIVE);} @GetMapping("/stores") List<Store> stores(){return stores.findAll().stream().filter(Store::isActive).toList();} @GetMapping("/cities") List<City> cities(){return cities.findAll().stream().filter(City::isActive).toList();}
}
