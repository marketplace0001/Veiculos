package br.com.automarketplace.security;
import br.com.automarketplace.model.User; import io.jsonwebtoken.*; import io.jsonwebtoken.security.Keys; import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Service; import javax.crypto.SecretKey; import java.nio.charset.StandardCharsets; import java.util.Date;
@Service public class JwtService {
 private final SecretKey key; public JwtService(@Value("${app.jwt-secret}") String secret){this.key=Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));}
 public String create(User u){return Jwts.builder().subject(u.getEmail()).claim("role",u.getRole().name()).issuedAt(new Date()).expiration(new Date(System.currentTimeMillis()+1000L*60*60*12)).signWith(key).compact();}
 public String subject(String token){return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload().getSubject();}
}
