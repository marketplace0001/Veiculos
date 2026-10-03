package br.com.automarketplace.model;
import jakarta.persistence.*; import java.math.BigDecimal; import java.time.Instant;
@Entity @Table(name="vehicles")
public class Vehicle {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @Column(nullable=false) private String brand; @Column(nullable=false) private String model; private String version;
 private int yearManufacture; private int yearModel; @Column(nullable=false) private BigDecimal price; private int mileage;
 private String transmission; private String fuel; private String color; private String imageUrl; @Column(length=3000) private String description;
 @Enumerated(EnumType.STRING) private VehicleStatus status=VehicleStatus.ACTIVE;
 @ManyToOne(optional=false) private Store store; private Instant createdAt=Instant.now(); private Instant updatedAt=Instant.now();
 @PreUpdate void touch(){updatedAt=Instant.now();}
 public Long getId(){return id;} public String getBrand(){return brand;} public void setBrand(String v){brand=v;} public String getModel(){return model;} public void setModel(String v){model=v;} public String getVersion(){return version;} public void setVersion(String v){version=v;}
 public int getYearManufacture(){return yearManufacture;} public void setYearManufacture(int v){yearManufacture=v;} public int getYearModel(){return yearModel;} public void setYearModel(int v){yearModel=v;} public BigDecimal getPrice(){return price;} public void setPrice(BigDecimal v){price=v;} public int getMileage(){return mileage;} public void setMileage(int v){mileage=v;}
 public String getTransmission(){return transmission;} public void setTransmission(String v){transmission=v;} public String getFuel(){return fuel;} public void setFuel(String v){fuel=v;} public String getColor(){return color;} public void setColor(String v){color=v;} public String getImageUrl(){return imageUrl;} public void setImageUrl(String v){imageUrl=v;} public String getDescription(){return description;} public void setDescription(String v){description=v;}
 public VehicleStatus getStatus(){return status;} public void setStatus(VehicleStatus v){status=v;} public Store getStore(){return store;} public void setStore(Store v){store=v;} public Instant getCreatedAt(){return createdAt;} public Instant getUpdatedAt(){return updatedAt;}
}
