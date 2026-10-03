package br.com.automarketplace.model;
import jakarta.persistence.*;
@Entity @Table(name="stores")
public class Store {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @Column(nullable=false) private String name;
 @Column(unique=true) private String cnpj;
 private String phone; private String whatsapp; private String address; private String description; private boolean active=true;
 @Enumerated(EnumType.STRING) @Column(nullable=false) private StoreType type=StoreType.DEALER;
 @ManyToOne(optional=false) private City city;
 public Store(){} public Store(String name,City city,String whatsapp){this.name=name;this.city=city;this.whatsapp=whatsapp;}
 public Long getId(){return id;} public String getName(){return name;} public void setName(String v){name=v;} public String getCnpj(){return cnpj;} public void setCnpj(String v){cnpj=v;}
 public String getPhone(){return phone;} public void setPhone(String v){phone=v;} public String getWhatsapp(){return whatsapp;} public void setWhatsapp(String v){whatsapp=v;}
 public String getAddress(){return address;} public void setAddress(String v){address=v;} public String getDescription(){return description;} public void setDescription(String v){description=v;}
 public boolean isActive(){return active;} public void setActive(boolean v){active=v;} public City getCity(){return city;} public void setCity(City v){city=v;}
 public StoreType getType(){return type;} public void setType(StoreType v){type=v;}
}
