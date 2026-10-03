package br.com.automarketplace.model;
import jakarta.persistence.*;
@Entity @Table(name="cities")
public class City {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @Column(nullable=false) private String name;
  @Column(nullable=false, length=2) private String state;
  private boolean active=true;
  public City() {}
  public City(String name,String state){this.name=name;this.state=state;}
  public Long getId(){return id;} public String getName(){return name;} public void setName(String v){name=v;}
  public String getState(){return state;} public void setState(String v){state=v;} public boolean isActive(){return active;} public void setActive(boolean v){active=v;}
}
