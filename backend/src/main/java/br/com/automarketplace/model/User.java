package br.com.automarketplace.model;
import jakarta.persistence.*;
@Entity @Table(name="users")
public class User {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @Column(nullable=false) private String name;
 @Column(nullable=false,unique=true) private String email;
 @Column(nullable=false) private String passwordHash;
 private String phone;
 @Enumerated(EnumType.STRING) @Column(nullable=false) private Role role;
 @ManyToOne private Store store;
 private boolean active=true;
 public Long getId(){return id;} public String getName(){return name;} public void setName(String v){name=v;} public String getEmail(){return email;} public void setEmail(String v){email=v;}
 public String getPasswordHash(){return passwordHash;} public void setPasswordHash(String v){passwordHash=v;} public String getPhone(){return phone;} public void setPhone(String v){phone=v;}
 public Role getRole(){return role;} public void setRole(Role v){role=v;} public Store getStore(){return store;} public void setStore(Store v){store=v;} public boolean isActive(){return active;} public void setActive(boolean v){active=v;}
}
