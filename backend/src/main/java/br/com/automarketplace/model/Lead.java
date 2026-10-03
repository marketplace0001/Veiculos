package br.com.automarketplace.model;
import jakarta.persistence.*; import java.time.Instant;
@Entity @Table(name="leads")
public class Lead {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @Column(nullable=false) private String name; @Column(nullable=false) private String phone; private String email;
 @Enumerated(EnumType.STRING) private LeadType type; @Enumerated(EnumType.STRING) private LeadStatus status=LeadStatus.NEW;
 @ManyToOne private Vehicle vehicle; @ManyToOne private Store store; @ManyToOne private City city;
 @Column(length=3000) private String notes; private Instant createdAt=Instant.now();
 public Long getId(){return id;} public String getName(){return name;} public void setName(String v){name=v;} public String getPhone(){return phone;} public void setPhone(String v){phone=v;} public String getEmail(){return email;} public void setEmail(String v){email=v;}
 public LeadType getType(){return type;} public void setType(LeadType v){type=v;} public LeadStatus getStatus(){return status;} public void setStatus(LeadStatus v){status=v;} public Vehicle getVehicle(){return vehicle;} public void setVehicle(Vehicle v){vehicle=v;} public Store getStore(){return store;} public void setStore(Store v){store=v;} public City getCity(){return city;} public void setCity(City v){city=v;} public String getNotes(){return notes;} public void setNotes(String v){notes=v;} public Instant getCreatedAt(){return createdAt;}
}
