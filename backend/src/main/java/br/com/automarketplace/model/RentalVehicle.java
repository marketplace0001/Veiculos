package br.com.automarketplace.model;
import jakarta.persistence.*; import java.math.BigDecimal; import java.time.Instant;
@Entity @Table(name="rental_vehicles")
public class RentalVehicle {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @Column(nullable=false) private String brand; @Column(nullable=false) private String model; private String version; private int yearModel;
 private String category; private String transmission; private String fuel; private String color; private int seats=5; private boolean airConditioning=true;
 @Column(nullable=false) private BigDecimal dailyRate; private BigDecimal weeklyRate; private BigDecimal monthlyRate; private BigDecimal depositAmount;
 private boolean unlimitedMileage=true; private Integer mileageLimitPerDay; private Integer minimumAge=21; private String imageUrl;
 @Column(length=3000) private String rentalRules;
 @Enumerated(EnumType.STRING) private RentalVehicleStatus status=RentalVehicleStatus.AVAILABLE;
 @ManyToOne(optional=false) private Store store; private Instant createdAt=Instant.now(); private Instant updatedAt=Instant.now();
 @PreUpdate void touch(){updatedAt=Instant.now();}
 public Long getId(){return id;} public String getBrand(){return brand;} public void setBrand(String v){brand=v;} public String getModel(){return model;} public void setModel(String v){model=v;} public String getVersion(){return version;} public void setVersion(String v){version=v;}
 public int getYearModel(){return yearModel;} public void setYearModel(int v){yearModel=v;} public String getCategory(){return category;} public void setCategory(String v){category=v;} public String getTransmission(){return transmission;} public void setTransmission(String v){transmission=v;} public String getFuel(){return fuel;} public void setFuel(String v){fuel=v;} public String getColor(){return color;} public void setColor(String v){color=v;} public int getSeats(){return seats;} public void setSeats(int v){seats=v;} public boolean isAirConditioning(){return airConditioning;} public void setAirConditioning(boolean v){airConditioning=v;}
 public BigDecimal getDailyRate(){return dailyRate;} public void setDailyRate(BigDecimal v){dailyRate=v;} public BigDecimal getWeeklyRate(){return weeklyRate;} public void setWeeklyRate(BigDecimal v){weeklyRate=v;} public BigDecimal getMonthlyRate(){return monthlyRate;} public void setMonthlyRate(BigDecimal v){monthlyRate=v;} public BigDecimal getDepositAmount(){return depositAmount;} public void setDepositAmount(BigDecimal v){depositAmount=v;}
 public boolean isUnlimitedMileage(){return unlimitedMileage;} public void setUnlimitedMileage(boolean v){unlimitedMileage=v;} public Integer getMileageLimitPerDay(){return mileageLimitPerDay;} public void setMileageLimitPerDay(Integer v){mileageLimitPerDay=v;} public Integer getMinimumAge(){return minimumAge;} public void setMinimumAge(Integer v){minimumAge=v;} public String getImageUrl(){return imageUrl;} public void setImageUrl(String v){imageUrl=v;} public String getRentalRules(){return rentalRules;} public void setRentalRules(String v){rentalRules=v;}
 public RentalVehicleStatus getStatus(){return status;} public void setStatus(RentalVehicleStatus v){status=v;} public Store getStore(){return store;} public void setStore(Store v){store=v;} public Instant getCreatedAt(){return createdAt;} public Instant getUpdatedAt(){return updatedAt;}
}
